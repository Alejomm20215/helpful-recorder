package com.example.helpful_recorder

import android.content.Context
import android.os.Build
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager

class TouchVisualizationManager(
    private val context: Context,
    private val windowManager: WindowManager
) {

    private val touchIndicators = mutableListOf<View>()
    private var touchOverlayView: View? = null
    var showTouchesEnabled: Boolean = false

    fun setupTouchVisualization() {
        // Create a transparent overlay that covers the entire screen to detect touches
        touchOverlayView = View(context).apply {
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
                android.view.MotionEvent.ACTION_DOWN, android.view.MotionEvent.ACTION_MOVE -> {
                    showTouchIndicator(event.rawX, event.rawY)
                    false // Don't consume the touch event
                }
                else -> false
            }
        }

        try {
            windowManager.addView(touchOverlayView, overlayParams)
        } catch (e: Exception) {
            Log.e("TouchVisualization", "Failed to add touch overlay: ${e.message}")
        }
    }

    fun removeTouchOverlay() {
        if (touchOverlayView != null) {
            try {
                windowManager.removeView(touchOverlayView)
            } catch (e: Exception) {
                Log.e("TouchVisualization", "Failed to remove touch overlay: ${e.message}")
            }
            touchOverlayView = null
        }
    }

    fun showTouchIndicator(x: Float, y: Float) {
        if (!showTouchesEnabled) return

        val touchView = View(context).apply {
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
            windowManager.addView(touchView, params)
            touchIndicators.add(touchView)

            // Auto-remove after animation
            touchView.postDelayed({
                removeTouchIndicator(touchView)
            }, 500) // Show for 500ms
        } catch (e: Exception) {
            Log.e("TouchVisualization", "Failed to show touch indicator: ${e.message}")
        }
    }

    private fun removeTouchIndicator(view: View) {
        try {
            windowManager.removeView(view)
            touchIndicators.remove(view)
        } catch (e: Exception) {
            Log.e("TouchVisualization", "Failed to remove touch indicator: ${e.message}")
        }
    }

    fun clearAllTouchIndicators() {
        touchIndicators.forEach { view ->
            try {
                windowManager.removeView(view)
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
        }
        touchIndicators.clear()
    }
}
