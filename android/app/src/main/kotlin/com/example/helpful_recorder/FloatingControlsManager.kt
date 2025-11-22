package com.example.helpful_recorder

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView

class FloatingControlsManager(
    private val context: Context,
    private val windowManager: WindowManager
) {

    private var floatingView: View? = null
    private var floatingParams: WindowManager.LayoutParams? = null
    private var isFloatingViewAdded = false
    private var isFloatingHidden = false
    private var lastTapTime = 0L
    
    private var overlayBackgroundColor: Int = 0xCC000000.toInt()
    private var overlayPanelColor: Int = 0xFF1F1F1F.toInt()
    private var overlayIconColor: Int = 0xFFFFFFFF.toInt()

    fun showFloatingControls(
        onStop: () -> Unit,
        onPause: () -> Unit,
        onResume: () -> Unit,
        onRestart: () -> Unit
    ) {
        if (isFloatingViewAdded) return

        val inflated = LayoutInflater.from(context).inflate(R.layout.layout_floating_widget, null)
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
                        windowManager.updateViewLayout(inflated, params)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        val deltaX = (event.rawX - initialTouchX).toInt()
                        val deltaY = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10) {
                            val now = SystemClock.uptimeMillis()
                            if (now - lastTapTime < 300) {
                                isFloatingHidden = !isFloatingHidden
                                inflated.visibility = if (isFloatingHidden) View.INVISIBLE else View.VISIBLE
                                expandedPanel.visibility = View.GONE
                            } else {
                                expandedPanel.visibility = if (expandedPanel.visibility == View.VISIBLE) View.GONE else View.VISIBLE
                            }
                            lastTapTime = now
                        }
                        return true
                    }
                }
                return false
            }
        })

        btnStop.setOnClickListener { onStop() }
        btnPause.setOnClickListener { onPause() }
        btnResume.setOnClickListener { onResume() }
        btnRestart.setOnClickListener { onRestart() }

        try {
            windowManager.addView(inflated, params)
            floatingView = inflated
            floatingParams = params
            isFloatingViewAdded = true
            applyOverlayColors(inflated)
        } catch (e: Exception) {
            Log.e("FloatingControls", "Failed to add floating view: ${e.message}")
        }
    }

    fun removeFloatingControls() {
        if (isFloatingViewAdded && floatingView != null) {
            try {
                windowManager.removeView(floatingView)
            } catch (e: Exception) {
                Log.e("FloatingControls", "Overlay remove failed: ${e.message}")
            }
            floatingView = null
            floatingParams = null
            isFloatingViewAdded = false
        }
    }

    fun updateOverlayStyle(backgroundColor: Int, panelColor: Int, iconColor: Int) {
        overlayBackgroundColor = backgroundColor
        overlayPanelColor = panelColor
        overlayIconColor = iconColor
        floatingView?.let { applyOverlayColors(it) }
    }

    private fun applyOverlayColors(view: View) {
        val collapsed = view.findViewById<View>(R.id.btn_collapsed)
        collapsed.background?.setTint(overlayBackgroundColor)

        val panel = view.findViewById<View>(R.id.layout_controls)
        panel.background?.mutate()?.setTint(overlayPanelColor)

        // ImageViews already have their tint colors set in XML
        // btnStop is red, btnPause is white, btnResume is green
    }
}
