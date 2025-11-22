package com.example.helpful_recorder

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.io.File
import android.os.Environment
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.helpful_recorder/recorder"
    private val EVENT_CHANNEL = "com.example.helpful_recorder/recorder_events"
    private val SCREEN_RECORD_REQUEST_CODE = 1001
    private var mResult: MethodChannel.Result? = null
    private var mFileName: String = ""
    
    // Store permission data temporarily
    private var mPermissionResultCode: Int = 0
    private var mPermissionData: Intent? = null
    
    // Event sink for broadcasting events to Flutter
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup EventChannel for broadcasting events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepareRecording" -> {
                    // Step 1: Ask for permission
                    mResult = result
                    val manager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                    startActivityForResult(manager.createScreenCaptureIntent(), SCREEN_RECORD_REQUEST_CODE)
                }
                "startRecording" -> {
                    // Step 2: Actually start using the stored permission
                    mFileName = call.argument<String>("fileName") ?: "recording"
                    
                    if (mPermissionResultCode != 0 && mPermissionData != null) {
                        startServiceWithPermission()
                        val path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).absolutePath + "/HelpfulRecorder/$mFileName.mp4"
                        result.success(path)
                    } else {
                        result.error("NO_PERMISSION", "Permission not granted or lost", null)
                    }
                }
                "stopRecording" -> {
                    val serviceIntent = Intent(this, ScreenRecorderService::class.java)
                    serviceIntent.action = ScreenRecorderService.ACTION_STOP
                    startService(serviceIntent)

                    // Give the service a moment to finish saving
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        try {
                            // Check if the file actually exists before returning success
                            val expectedPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).absolutePath + "/HelpfulRecorder/$mFileName.mp4"
                            val file = java.io.File(expectedPath)

                            if (file.exists() && file.length() > 0) {
                                result.success(expectedPath)
                            } else {
                                result.error("SAVE_FAILED", "Recording file was not saved properly", null)
                            }
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", "Error checking saved file: ${e.message}", null)
                        }
                    }, 500) // 500ms delay to allow file saving to complete
                }
                "updateOverlayStyle" -> {
                    val bg = call.argument<Int>("backgroundColor") ?: 0xCC000000.toInt()
                    val panel = call.argument<Int>("panelColor") ?: 0xFF1F1F1F.toInt()
                    val icon = call.argument<Int>("iconColor") ?: 0xFFFFFFFF.toInt()
                    ScreenRecorderService.instance?.updateOverlayStyle(bg, panel, icon)
                    result.success(true)
                }
                "showDrawingOverlay" -> {
                    ScreenRecorderService.instance?.showDrawingOverlay()
                    result.success(true)
                }
                "hideDrawingOverlay" -> {
                    ScreenRecorderService.instance?.hideDrawingOverlay()
                    result.success(true)
                }
                "setDrawingColor" -> {
                    val color = call.argument<Int>("color") ?: android.graphics.Color.RED
                    ScreenRecorderService.instance?.setDrawingColor(color)
                    result.success(true)
                }
                "setDrawingWidth" -> {
                    val width = call.argument<Double>("width")?.toFloat() ?: 10f
                    ScreenRecorderService.instance?.setDrawingWidth(width)
                    result.success(true)
                }
                "clearDrawing" -> {
                    ScreenRecorderService.instance?.clearDrawing()
                    result.success(true)
                }
                "undoDrawing" -> {
                    ScreenRecorderService.instance?.undoDrawing()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SCREEN_RECORD_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                // Store permission
                mPermissionResultCode = resultCode
                mPermissionData = data
                
                // Tell Flutter we are ready to countdown
                mResult?.success(true)
            } else {
                mResult?.error("PERMISSION_DENIED", "Permission not granted or lost", null)
            }
            mResult = null
        }
    }

    private fun startServiceWithPermission() {
        val serviceIntent = Intent(this, ScreenRecorderService::class.java)
        serviceIntent.action = ScreenRecorderService.ACTION_START
        serviceIntent.putExtra(ScreenRecorderService.EXTRA_RESULT_CODE, mPermissionResultCode)
        serviceIntent.putExtra(ScreenRecorderService.EXTRA_DATA, mPermissionData)
        serviceIntent.putExtra(ScreenRecorderService.EXTRA_FILENAME, mFileName)
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
    
    fun sendEventToFlutter(event: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(event)
        }
    }
    
    companion object {
        var instance: MainActivity? = null
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
    }
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}
