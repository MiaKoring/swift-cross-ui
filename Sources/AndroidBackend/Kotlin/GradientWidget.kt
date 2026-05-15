package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import android.graphics.LinearGradient
import android.graphics.RadialGradient
import android.graphics.SweepGradient
import android.view.View

class GradientWidget(activity: Activity): View(activity) {
    private var path: Path = Path()
    private var fillPaint: Paint = Paint().apply {
        style = Paint.Style.FILL
        color = Color.RED
        isAntiAlias = true
    }
    
    fun set(width: Float, height: Float) {
        // Reset path and draw rectangle for current bounds
        this.path.reset()
        this.path.apply {
            addRect(0f, 0f, width, height, Path.Direction.CW)
        }
    }
    
    fun setLinearGradient(gradient: LinearGradient) {
        this.fillPaint.shader = gradient
    }
    
    fun setRadialGradient(gradient: RadialGradient) {
        this.fillPaint.shader = gradient
    }
    
    fun setSweepGradient(gradient: SweepGradient) {
        this.fillPaint.shader = gradient
    }
    
    override fun onDraw(canvas: Canvas) {
        canvas.drawPath(path, fillPaint)
    }
}
