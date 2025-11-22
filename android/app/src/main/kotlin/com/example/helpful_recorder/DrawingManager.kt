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
    private var drawingToolbarView: android.view.View? = null
    private var isDrawingOverlayAdded = false

    fun showDrawingOverlay() {
        if (isDrawingOverlayAdded) return

        // 1. Create drawing overlay (Full screen, transparent)
        drawingOverlayView = DrawingOverlayView(context)
        
        val overlayParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT
        )

        // 2. Create drawing toolbar (Floating at bottom)
        drawingToolbarView = android.view.LayoutInflater.from(context).inflate(R.layout.layout_drawing_toolbar, null)
        
        val toolbarParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply {
            android.view.Gravity.BOTTOM or android.view.Gravity.CENTER_HORIZONTAL
            y = 100 // Margin from bottom
        }
        toolbarParams.gravity = android.view.Gravity.BOTTOM or android.view.Gravity.CENTER_HORIZONTAL

        // Set up toolbar listeners
        setupToolbarListeners(drawingToolbarView!!)

        try {
            // Add overlay first (bottom layer)
            windowManager.addView(drawingOverlayView, overlayParams)
            // Add toolbar second (top layer)
            windowManager.addView(drawingToolbarView, toolbarParams)
            isDrawingOverlayAdded = true
        } catch (e: Exception) {
            Log.e("DrawingManager", "Failed to add drawing overlay: ${e.message}")
        }
    }

    private fun setupToolbarListeners(view: android.view.View) {
        // Colors
        view.findViewById<android.view.View>(R.id.color_red).setOnClickListener { setDrawingColor(0xFFFF0000.toInt()) }
        view.findViewById<android.view.View>(R.id.color_blue).setOnClickListener { setDrawingColor(0xFF0000FF.toInt()) }
        view.findViewById<android.view.View>(R.id.color_green).setOnClickListener { setDrawingColor(0xFF00FF00.toInt()) }
        view.findViewById<android.view.View>(R.id.color_yellow).setOnClickListener { setDrawingColor(0xFFFFFF00.toInt()) }
        view.findViewById<android.view.View>(R.id.color_white).setOnClickListener { setDrawingColor(0xFFFFFFFF.toInt()) }
        view.findViewById<android.view.View>(R.id.color_black).setOnClickListener { setDrawingColor(0xFF000000.toInt()) }

        // Sizes
        view.findViewById<android.view.View>(R.id.size_small).setOnClickListener { setDrawingWidth(5f) }
        view.findViewById<android.view.View>(R.id.size_medium).setOnClickListener { setDrawingWidth(15f) }
        view.findViewById<android.view.View>(R.id.size_large).setOnClickListener { setDrawingWidth(30f) }

        // Actions
        view.findViewById<android.view.View>(R.id.btn_undo).setOnClickListener { undoDrawing() }
        view.findViewById<android.view.View>(R.id.btn_clear).setOnClickListener { clearDrawing() }
        view.findViewById<android.view.View>(R.id.btn_close).setOnClickListener { hideDrawingOverlay() }
    }

    fun hideDrawingOverlay() {
        if (isDrawingOverlayAdded) {
            try {
                if (drawingOverlayView != null) windowManager.removeView(drawingOverlayView)
                if (drawingToolbarView != null) windowManager.removeView(drawingToolbarView)
            } catch (e: Exception) {
                Log.e("DrawingManager", "Failed to remove drawing overlay: ${e.message}")
            }
            drawingOverlayView = null
            drawingToolbarView = null
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
