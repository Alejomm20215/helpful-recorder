package com.example.helpful_recorder

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import java.io.File
import java.io.IOException

class RecordingManager(private val context: Context) {

    private var mediaProjection: MediaProjection? = null
    private var mediaRecorder: MediaRecorder? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var screenDensity: Int = 0
    private var screenWidth: Int = 720
    private var screenHeight: Int = 1280
    var filePath: String = ""
        private set
    private var currentUri: android.net.Uri? = null
    private var recordAudioEnabled: Boolean = true

    fun startRecording(
        resultCode: Int,
        data: Intent,
        fileName: String,
        recordAudio: Boolean,
        onSuccess: () -> Unit,
        onError: () -> Unit
    ) {
        recordAudioEnabled = recordAudio

        val metrics = DisplayMetrics()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager.defaultDisplay.getRealMetrics(metrics)
        screenDensity = metrics.densityDpi
        screenWidth = metrics.widthPixels
        screenHeight = metrics.heightPixels

        mediaRecorder = MediaRecorder()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Use MediaStore for Android 10+
            val contentValues = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, "$fileName.mp4")
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/HelpfulRecorder")
            }
            val resolver = context.contentResolver
            currentUri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
            
            if (currentUri != null) {
                 try {
                    val pfd = resolver.openFileDescriptor(currentUri!!, "w")
                    if (pfd != null) {
                        mediaRecorder?.setOutputFile(pfd.fileDescriptor)
                    }
                 } catch (e: Exception) {
                     Log.e("RecordingManager", "Error setting output to MediaStore: ${e.message}")
                 }
            }
            filePath = currentUri.toString()
        } else {
            // Legacy External Storage
            val moviesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            val appDir = File(moviesDir, "HelpfulRecorder")
            if (!appDir.exists()) appDir.mkdirs()
            filePath = File(appDir, "$fileName.mp4").absolutePath
            mediaRecorder?.setOutputFile(filePath)
        }

        initRecorder()
        prepareRecorder()

        val projectionManager = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = projectionManager.getMediaProjection(resultCode, data)

        val callback = object : MediaProjection.Callback() {
            override fun onStop() {
                stopRecording()
            }
        }
        mediaProjection?.registerCallback(callback, null)

        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "ScreenRecorder",
            screenWidth,
            screenHeight,
            screenDensity,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            mediaRecorder?.surface,
            null,
            null
        )

        try {
            mediaRecorder?.start()
            onSuccess()
        } catch (e: IllegalStateException) {
            Log.e("RecordingManager", "Error starting recorder: ${e.message}")
            stopRecording()
            onError()
        }
    }

    private fun initRecorder() {
        // Only set audio source if recording audio is enabled
        if (recordAudioEnabled) {
            mediaRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)
        }
        mediaRecorder?.setVideoSource(MediaRecorder.VideoSource.SURFACE)
        mediaRecorder?.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
        mediaRecorder?.setVideoEncoder(MediaRecorder.VideoEncoder.H264)
        // Only set audio encoder if recording audio is enabled
        if (recordAudioEnabled) {
            mediaRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
        }
        mediaRecorder?.setVideoEncodingBitRate(8 * 1000 * 1000) // Higher bitrate for better quality
        mediaRecorder?.setVideoFrameRate(60) // 60fps for smoothness
        mediaRecorder?.setVideoSize(screenWidth, screenHeight)
    }

    private fun prepareRecorder() {
        try {
            mediaRecorder?.prepare()
        } catch (e: IOException) {
            Log.e("RecordingManager", "Error preparing recorder: ${e.message}")
        }
    }

    fun stopRecording() {
        try {
            mediaRecorder?.stop()
            mediaRecorder?.reset()
        } catch (e: Exception) {
            Log.e("RecordingManager", "Error stopping recorder: ${e.message}")
        } finally {
            virtualDisplay?.release()
            mediaProjection?.stop()
            mediaRecorder?.release()
            mediaRecorder = null
            mediaProjection = null
            virtualDisplay = null
            currentUri = null
        }
    }

    fun pauseRecording() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mediaRecorder?.pause()
        }
    }

    fun resumeRecording() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mediaRecorder?.resume()
        }
    }
}
