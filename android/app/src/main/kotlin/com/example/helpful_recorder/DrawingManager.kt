package com.example.helpful_recorder

import android.content.Context
import android.os.Build
import android.util.Log
import android.view.WindowManager

class DrawingManager(
    private val context: Context,
    private val windowManager: WindowManager
) {

    private var drawingOverlayView: DrawingOverlayView? = null
    private var isDrawingOverlayAdded = false

    fun showDrawingOverlay() {
        if (isDrawingOverlayAdded) return

        // Create drawing overlay
        drawingOverlayView = DrawingOverlayView(context)
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            // Use a lower priority type so floating controls appear above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            // Allow touches to pass through to views above, but still capture drawing touches
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_SPLIT_TOUCH, // Allow simultaneous touch events
            android.graphics.PixelFormat.TRANSLUCENT
        )

        try {
            windowManager.addView(drawingOverlayView, params)
            isDrawingOverlayAdded = true
        } catch (e: Exception) {
            Log.e("DrawingManager", "Failed to add drawing overlay: ${e.message}")
        }
    }

    fun hideDrawingOverlay() {
        if (isDrawingOverlayAdded && drawingOverlayView != null) {
            try {
                windowManager.removeView(drawingOverlayView)
            } catch (e: Exception) {
                Log.e("DrawingManager", "Failed to remove drawing overlay: ${e.message}")
            }
            drawingOverlayView = null
            isDrawingOverlayAdded = false
        }
    }

    fun setDrawingColor(color: Int) {
        drawingOverlayView?.setColor(color)
    }

    fun setDrawingWidth(width: Float) {
        drawingOverlayView?.setStrokeWidth(width)
    }

    fun clearDrawing() {
        drawingOverlayView?.clear()
    }

    fun undoDrawing() {
        drawingOverlayView?.undo()
    }
}
