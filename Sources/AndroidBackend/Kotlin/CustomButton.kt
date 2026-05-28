package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.R
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.content.Context
import android.content.res.Configuration
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue

import android.widget.FrameLayout

class CustomButton(activity: Activity) : FrameLayout(activity) {
    var buttonType: Int = ButtonStyle.BORDERED
    var action: SwiftAction? = null
    var _isEnabled: Boolean = true
    var foregroundDrawable: Drawable?

    class ButtonStyle{
        companion object {
            const val BORDERED = 0
            const val PLAIN = 1
            const val BORDERLESS = 2
        }
    }

    init {
        val shape = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(getAdaptiveGray(context))
            cornerRadius = 3f * resources.displayMetrics.density
        }
        background = shape

        val outValue = TypedValue()
        activity.theme.resolveAttribute(android.R.attr.selectableItemBackground, outValue, true)
        foregroundDrawable = activity.getDrawable(outValue.resourceId)
        foreground = foregroundDrawable

        isClickable = true
        isFocusable = true

        setPadding(12, 5, 12, 5)

        setOnClickListener { view ->
            if (_isEnabled) {
                this.action?.call()
            }
        }
    }

    fun set(action: SwiftAction, buttonType: Int, isEnabled: Boolean) {
        this.buttonType = buttonType
        this.action = action
        this._isEnabled = isEnabled

        if (isEnabled) {
            foreground = foregroundDrawable
        } else {
            foreground = null
        }
    }

    override fun addView(child: View, index: Int, params: ViewGroup.LayoutParams) {
        val frameParams = params as? LayoutParams ?: LayoutParams(params)

        frameParams.gravity = Gravity.CENTER
        frameParams.width = ViewGroup.LayoutParams.WRAP_CONTENT
        frameParams.height = ViewGroup.LayoutParams.WRAP_CONTENT

        super.addView(child, index, frameParams)
    }

    fun getAdaptiveGray(context: Context): Int {
        val isDarkMode = (
                    context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                ) == Configuration.UI_MODE_NIGHT_YES

        return if (isDarkMode) {
            Color.DKGRAY
        } else {
            Color.LTGRAY
        }
    }
}