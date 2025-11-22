package com.example.helpful_recorder

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.view.MotionEvent
import android.view.View

class DrawingOverlayView(context: Context) : View(context) {

    data class DrawingPath(
        val path: Path,
        val paint: Paint
    )

    private val paths = mutableListOf<DrawingPath>()
    private var currentPath: Path? = null
    private var currentPaint: Paint = Paint().apply {
        color = Color.RED
        strokeWidth = 10f
        style = Paint.Style.STROKE
        strokeJoin = Paint.Join.ROUND
        strokeCap = Paint.Cap.ROUND
        isAntiAlias = true
    }

    var isDrawingEnabled = true
    var currentColor: Int = Color.RED
        set(value) {
            field = value
            currentPaint.color = value
        }
    
    var currentStrokeWidth: Float = 10f
        set(value) {
            field = value
            currentPaint.strokeWidth = value
        }

    init {
        setBackgroundColor(Color.TRANSPARENT)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isDrawingEnabled) {
            return false // Pass through if drawing is disabled
        }

        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                currentPath = Path().apply {
                    moveTo(event.x, event.y)
                }
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                currentPath?.lineTo(event.x, event.y)
                invalidate()
                return true
            }
            MotionEvent.ACTION_UP -> {
                currentPath?.let { path ->
                    // Create a copy of the current paint for this path
                    val paintCopy = Paint(currentPaint)
                    paths.add(DrawingPath(path, paintCopy))
                }
                currentPath = null
                invalidate()
                return true
            }
        }
        return false
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        // Draw all completed paths
        paths.forEach { drawingPath ->
            canvas.drawPath(drawingPath.path, drawingPath.paint)
        }
        
        // Draw current path being drawn
        currentPath?.let { path ->
            canvas.drawPath(path, currentPaint)
        }
    }

    fun undo() {
        if (paths.isNotEmpty()) {
            paths.removeAt(paths.size - 1)
            invalidate()
        }
    }

    fun clear() {
        paths.clear()
        currentPath = null
        invalidate()
    }

    fun setColor(color: Int) {
        currentColor = color
    }

    fun setStrokeWidth(width: Float) {
        currentStrokeWidth = width
    }
}
