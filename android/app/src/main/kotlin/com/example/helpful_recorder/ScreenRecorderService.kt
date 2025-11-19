package com.example.helpful_recorder

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.PorterDuff
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import android.os.IBinder
import android.os.SystemClock
import android.provider.MediaStore
import android.util.DisplayMetrics
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import java.io.File
import java.io.IOException

class ScreenRecorderService : Service() {

    private var mMediaProjection: MediaProjection? = null
    private var mMediaRecorder: MediaRecorder? = null
    private var mVirtualDisplay: VirtualDisplay? = null
    private var mScreenDensity: Int = 0
    private var mScreenWidth: Int = 720
    private var mScreenHeight: Int = 1280
    private var mFilePath: String = ""
    private var mWindowManager: WindowManager? = null
    private var mFloatingView: View? = null
    private var mFloatingParams: WindowManager.LayoutParams? = null
    private var mIsFloatingViewAdded = false
    private var mIsFloatingHidden = false
    private var mLastTapTime = 0L
    private var overlayBackgroundColor: Int = 0xCC000000.toInt()
    private var overlayPanelColor: Int = 0xFF1F1F1F.toInt()
    private var overlayIconColor: Int = 0xFFFFFFFF.toInt()
    private var showTouchesEnabled: Boolean = false
    private val touchIndicators = mutableListOf<View>()
    private var touchOverlayView: View? = null

    // For MediaStore
    private var mCurrentUri: android.net.Uri? = null
    private var mResultCode: Int = 0
    private var mData: Intent? = null
    private var mFileName: String = ""

    companion object {
        private const val CHANNEL_ID = "ScreenRecorderChannel"
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val EXTRA_RESULT_CODE = "EXTRA_RESULT_CODE"
        const val EXTRA_DATA = "EXTRA_DATA"
        const val EXTRA_FILENAME = "EXTRA_FILENAME"
        var instance: ScreenRecorderService? = null
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        mWindowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY

        when (intent.action) {
            ACTION_START -> {
                createNotificationChannel()
                val notification = createNotification()
                startForeground(1, notification)

                val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, 0)
                val data = intent.getParcelableExtra<Intent>(EXTRA_DATA)
                val fileName = intent.getStringExtra(EXTRA_FILENAME) ?: "recording"
                val recordAudio = intent.getBooleanExtra("recordAudio", true)
                val videoQuality = intent.getStringExtra("videoQuality") ?: "high"
                val showTouches = intent.getBooleanExtra("showTouches", false)

                if (resultCode != 0 && data != null) {
                    mResultCode = resultCode
                    mData = data
                    mFileName = fileName
                    showTouchesEnabled = showTouches
                    startRecording(resultCode, data, fileName)
                }
            }
            ACTION_STOP -> {
                stopRecordingHelper()
                stopForeground(true)
                stopSelf()
            }
        }

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Screen Recorder Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Recorder")
            .setContentText("Recording in progress...")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .build()
    }

    private fun startRecording(resultCode: Int, data: Intent, fileName: String) {
        val metrics = DisplayMetrics()
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getRealMetrics(metrics)
        mScreenDensity = metrics.densityDpi
        mScreenWidth = metrics.widthPixels
        mScreenHeight = metrics.heightPixels

        mMediaRecorder = MediaRecorder()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Use MediaStore for Android 10+
            val contentValues = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, "$fileName.mp4")
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/HelpfulRecorder")
            }
            val resolver = contentResolver
            mCurrentUri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
            
            // We need a file descriptor to write to
            if (mCurrentUri != null) {
                 // Note: setOutputFile(FileDescriptor) is needed
                 // But MediaRecorder needs a file path or FileDescriptor.
                 // Let's see if we can get FD.
                 try {
                    val pfd = resolver.openFileDescriptor(mCurrentUri!!, "w")
                    if (pfd != null) {
                        mMediaRecorder?.setOutputFile(pfd.fileDescriptor)
                    }
                 } catch (e: Exception) {
                     Log.e("ScreenRecorder", "Error setting output to MediaStore: ${e.message}")
                 }
            }
            // We will return the URI string as path later if possible, or just let UI know.
            mFilePath = mCurrentUri.toString()
        } else {
            // Legacy External Storage
            val moviesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            val appDir = File(moviesDir, "HelpfulRecorder")
            if (!appDir.exists()) appDir.mkdirs()
            mFilePath = File(appDir, "$fileName.mp4").absolutePath
            mMediaRecorder?.setOutputFile(mFilePath)
        }

        initRecorder()
        
        // Extra config for FD based recording if needed (already set above for Q+)
        
        prepareRecorder()

        val projectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mMediaProjection = projectionManager.getMediaProjection(resultCode, data)

        val callback = object : MediaProjection.Callback() {
            override fun onStop() {
                stopRecordingHelper()
            }
        }
        mMediaProjection?.registerCallback(callback, null)

        mVirtualDisplay = mMediaProjection?.createVirtualDisplay(
            "ScreenRecorder",
            mScreenWidth,
            mScreenHeight,
            mScreenDensity,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            mMediaRecorder?.surface,
            null,
            null
        )

        try {
            mMediaRecorder?.start()
            // Show floating controls ONLY after recording starts successfully
            showFloatingControls()
            // Initialize touch visualization if enabled
            if (showTouchesEnabled) {
                setupTouchVisualization()
            }
        } catch (e: IllegalStateException) {
            Log.e("ScreenRecorderService", "Error starting recorder: ${e.message}")
            stopRecordingHelper()
        }
    }

    private fun initRecorder() {
        mMediaRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)
        mMediaRecorder?.setVideoSource(MediaRecorder.VideoSource.SURFACE)
        mMediaRecorder?.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
        mMediaRecorder?.setVideoEncoder(MediaRecorder.VideoEncoder.H264)
        mMediaRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
        mMediaRecorder?.setVideoEncodingBitRate(8 * 1000 * 1000) // Higher bitrate for better quality
        mMediaRecorder?.setVideoFrameRate(60) // 60fps for smoothness
        mMediaRecorder?.setVideoSize(mScreenWidth, mScreenHeight)
        // Output file is set in startRecording logic due to version diffs
    }

    private fun prepareRecorder() {
        try {
            mMediaRecorder?.prepare()
        } catch (e: IOException) {
            Log.e("ScreenRecorderService", "Error preparing recorder: ${e.message}")
        }
    }

    private fun stopRecordingHelper() {
        try {
            mMediaRecorder?.stop()
            mMediaRecorder?.reset()
        } catch (e: Exception) {
            Log.e("ScreenRecorderService", "Error stopping recorder: ${e.message}")
        } finally {
            mVirtualDisplay?.release()
            mMediaProjection?.stop()
            mMediaRecorder?.release()
            mMediaRecorder = null
            mMediaProjection = null
            mVirtualDisplay = null
            mCurrentUri = null
            // Remove floating controls, touch overlay, and touch indicators when recording stops
            removeFloatingControls()
            removeTouchOverlay()
            clearAllTouchIndicators()
        }
    }


    private fun showFloatingControls() {
        if (mIsFloatingViewAdded) return

        val inflated = LayoutInflater.from(this).inflate(R.layout.layout_floating_widget, null)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = 50
            y = 150
        }

        val collapsedView = inflated.findViewById<View>(R.id.btn_collapsed)
        val expandedPanel = inflated.findViewById<View>(R.id.layout_controls)
        val btnStop = inflated.findViewById<ImageView>(R.id.btn_stop)
        val btnPause = inflated.findViewById<ImageView>(R.id.btn_pause)
        val btnResume = inflated.findViewById<ImageView>(R.id.btn_resume)
        val btnRestart = inflated.findViewById<ImageView>(R.id.btn_restart)

        collapsedView.setOnTouchListener(object : View.OnTouchListener {
            var initialX = 0
            var initialY = 0
            var initialTouchX = 0f
            var initialTouchY = 0f

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX - (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        mWindowManager?.updateViewLayout(inflated, params)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        val deltaX = (event.rawX - initialTouchX).toInt()
                        val deltaY = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10) {
                            val now = SystemClock.uptimeMillis()
                            if (now - mLastTapTime < 300) {
                                mIsFloatingHidden = !mIsFloatingHidden
                                inflated.visibility = if (mIsFloatingHidden) View.INVISIBLE else View.VISIBLE
                                expandedPanel.visibility = View.GONE
                            } else {
                                expandedPanel.visibility = if (expandedPanel.visibility == View.VISIBLE) View.GONE else View.VISIBLE
                            }
                            mLastTapTime = now
                        }
                        return true
                    }
                }
                return false
            }
        })

        btnStop.setOnClickListener {
            stopRecordingHelper()
            stopForeground(true)
            stopSelf()
            // Notify Flutter that recording was stopped from native overlay
            MainActivity.instance?.sendEventToFlutter("RECORDING_STOPPED")
        }

        btnPause.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mMediaRecorder?.pause()
                btnPause.visibility = View.GONE
                btnResume.visibility = View.VISIBLE
            }
        }

        btnResume.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                mMediaRecorder?.resume()
                btnResume.visibility = View.GONE
                btnPause.visibility = View.VISIBLE
            }
        }

        btnRestart.setOnClickListener {
            // Stop current recording and notify Flutter to restart with countdown
            stopRecordingHelper()
            stopForeground(true)
            stopSelf()
            
            // Send event to Flutter to trigger restart (which will show countdown and start new recording)
            MainActivity.instance?.sendEventToFlutter("RECORDING_RESTART_REQUESTED")
        }

        try {
            mWindowManager?.addView(inflated, params)
            mFloatingView = inflated
            mFloatingParams = params
            mIsFloatingViewAdded = true
            applyOverlayColors(inflated)
        } catch (e: Exception) {
            Log.e("ScreenRecorderService", "Failed to add floating view: ${e.message}")
        }
    }

    private fun removeFloatingControls() {
        if (mIsFloatingViewAdded && mFloatingView != null) {
            try {
                mWindowManager?.removeView(mFloatingView)
            } catch (e: Exception) {
                Log.e("ScreenRecorderService", "Overlay remove failed: ${e.message}")
            }
            mFloatingView = null
            mFloatingParams = null
            mIsFloatingViewAdded = false
        }
    }

    private fun showTouchIndicator(x: Float, y: Float) {
        if (!showTouchesEnabled) return

        val touchView = View(this).apply {
            setBackgroundResource(R.drawable.bg_circle_red)
            background?.setTint(0xFFFF4444.toInt()) // Red color for touch indicator
        }

        val params = WindowManager.LayoutParams(
            60, // Size of touch indicator
            60,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE, // Don't interfere with touches
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            this.x = (x - 30).toInt() // Center on touch point
            this.y = (y - 30).toInt()
        }

        try {
            mWindowManager?.addView(touchView, params)
            touchIndicators.add(touchView)

            // Auto-remove after animation
            touchView.postDelayed({
                removeTouchIndicator(touchView)
            }, 500) // Show for 500ms
        } catch (e: Exception) {
            Log.e("ScreenRecorderService", "Failed to show touch indicator: ${e.message}")
        }
    }

    private fun removeTouchIndicator(view: View) {
        try {
            mWindowManager?.removeView(view)
            touchIndicators.remove(view)
        } catch (e: Exception) {
            Log.e("ScreenRecorderService", "Failed to remove touch indicator: ${e.message}")
        }
    }

    private fun clearAllTouchIndicators() {
        touchIndicators.forEach { view ->
            try {
                mWindowManager?.removeView(view)
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
        }
        touchIndicators.clear()
    }

    private fun setupTouchVisualization() {
        // Create a transparent overlay that covers the entire screen to detect touches
        touchOverlayView = View(this).apply {
            setBackgroundColor(0x00000000) // Completely transparent
        }

        val overlayParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL, // Allow touches to pass through
            android.graphics.PixelFormat.TRANSLUCENT
        )

        touchOverlayView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                    showTouchIndicator(event.rawX, event.rawY)
                    false // Don't consume the touch event
                }
                else -> false
            }
        }

        try {
            mWindowManager?.addView(touchOverlayView, overlayParams)
        } catch (e: Exception) {
            Log.e("ScreenRecorderService", "Failed to add touch overlay: ${e.message}")
        }
    }

    private fun removeTouchOverlay() {
        if (touchOverlayView != null) {
            try {
                mWindowManager?.removeView(touchOverlayView)
            } catch (e: Exception) {
                Log.e("ScreenRecorderService", "Failed to remove touch overlay: ${e.message}")
            }
            touchOverlayView = null
        }
    }

    private fun applyOverlayColors(view: View) {
        val collapsed = view.findViewById<View>(R.id.btn_collapsed)
        collapsed.background?.setTint(overlayBackgroundColor)

        val panel = view.findViewById<View>(R.id.layout_controls)
        panel.background?.mutate()?.setTint(overlayPanelColor)

        // ImageViews already have their tint colors set in XML
        // btnStop is red, btnPause is white, btnResume is green
    }

    fun updateOverlayStyle(backgroundColor: Int, panelColor: Int, iconColor: Int) {
        overlayBackgroundColor = backgroundColor
        overlayPanelColor = panelColor
        overlayIconColor = iconColor
        mFloatingView?.let { applyOverlayColors(it) }
    }
}
