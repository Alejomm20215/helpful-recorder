package com.example.helpful_recorder

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.WindowManager

class ScreenRecorderService : Service() {

    private var windowManager: WindowManager? = null
    
    // Managers
    private lateinit var notificationHelper: NotificationHelper
    private lateinit var recordingManager: RecordingManager
    private lateinit var floatingControlsManager: FloatingControlsManager
    private lateinit var touchVisualizationManager: TouchVisualizationManager
    private lateinit var drawingManager: DrawingManager

    // Recording parameters
    private var resultCode: Int = 0
    private var data: Intent? = null
    private var fileName: String = ""
    private var showTouchesEnabled: Boolean = false

    companion object {
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
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        // Initialize managers
        notificationHelper = NotificationHelper(this)
        recordingManager = RecordingManager(this)
        floatingControlsManager = FloatingControlsManager(this, windowManager!!)
        touchVisualizationManager = TouchVisualizationManager(this, windowManager!!)
        drawingManager = DrawingManager(this, windowManager!!)
        
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
                notificationHelper.createNotificationChannel()
                val notification = notificationHelper.createNotification()
                startForeground(1, notification)

                resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, 0)
                data = intent.getParcelableExtra(EXTRA_DATA)
                fileName = intent.getStringExtra(EXTRA_FILENAME) ?: "recording"
                val recordAudio = intent.getBooleanExtra("recordAudio", true)
                val videoQuality = intent.getStringExtra("videoQuality") ?: "high"
                showTouchesEnabled = intent.getBooleanExtra("showTouches", false)

                if (resultCode != 0 && data != null) {
                    startRecording(resultCode, data!!, fileName, recordAudio)
                }
            }
            ACTION_STOP -> {
                stopRecordingAndService()
            }
        }

        return START_STICKY
    }

    private fun startRecording(resultCode: Int, data: Intent, fileName: String, recordAudio: Boolean) {
        recordingManager.startRecording(
            resultCode = resultCode,
            data = data,
            fileName = fileName,
            recordAudio = recordAudio,
            onSuccess = {
                // Show floating controls after recording starts successfully
                floatingControlsManager.showFloatingControls(
                    onStop = {
                        stopRecordingAndService()
                        // Notify Flutter that recording was stopped from native overlay
                        MainActivity.instance?.sendEventToFlutter("RECORDING_STOPPED:${recordingManager.filePath}")
                    },
                    onPause = {
                        recordingManager.pauseRecording()
                    },
                    onResume = {
                        recordingManager.resumeRecording()
                    },
                    onRestart = {
                        stopRecordingAndService()
                        // Send event to Flutter to trigger restart
                        MainActivity.instance?.sendEventToFlutter("RECORDING_RESTART_REQUESTED")
                    }
                )
                
                // Initialize touch visualization if enabled
                if (showTouchesEnabled) {
                    touchVisualizationManager.showTouchesEnabled = true
                    touchVisualizationManager.setupTouchVisualization()
                }
            },
            onError = {
                stopRecordingAndService()
            }
        )
    }

    private fun stopRecordingAndService() {
        recordingManager.stopRecording()
        floatingControlsManager.removeFloatingControls()
        touchVisualizationManager.removeTouchOverlay()
        touchVisualizationManager.clearAllTouchIndicators()
        drawingManager.hideDrawingOverlay()
        stopForeground(true)
        stopSelf()
    }

    // Drawing overlay methods (called from MainActivity via method channels)
    fun showDrawingOverlay() {
        drawingManager.showDrawingOverlay()
    }

    fun hideDrawingOverlay() {
        drawingManager.hideDrawingOverlay()
    }

    fun setDrawingColor(color: Int) {
        drawingManager.setDrawingColor(color)
    }

    fun setDrawingWidth(width: Float) {
        drawingManager.setDrawingWidth(width)
    }

    fun clearDrawing() {
        drawingManager.clearDrawing()
    }

    fun undoDrawing() {
        drawingManager.undoDrawing()
    }

    fun updateOverlayStyle(backgroundColor: Int, panelColor: Int, iconColor: Int) {
        floatingControlsManager.updateOverlayStyle(backgroundColor, panelColor, iconColor)
    }
}
