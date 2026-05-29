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
import android.view.accessibility.AccessibilityNodeInfo
import android.util.TypedValue

import android.widget.FrameLayout

class CustomButton(activity: Activity) : FrameLayout(activity) {
    var buttonStyle: Int = ButtonStyle.BORDERED
    var action: SwiftAction? = null

    private val density = resources.displayMetrics.density

    private val borderedDrawable by lazy {
        val outValue = TypedValue()
        activity.theme.resolveAttribute(android.R.attr.selectableItemBackground, outValue, true)
        activity.getDrawable(outValue.resourceId)
    }
    private val borderlessDrawable by lazy {
        val outValue = TypedValue()
        activity.theme.resolveAttribute(android.R.attr.selectableItemBackgroundBorderless, outValue, true)
        activity.getDrawable(outValue.resourceId)
    }

    private val borderedBackground by lazy {
        GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(getAdaptiveGray(context))
            cornerRadius = 3f * resources.displayMetrics.density
        }
    }

    class ButtonStyle{
        companion object {
            const val BORDERED = 0
            const val PLAIN = 1
            const val BORDERLESS = 2
        }
    }

    init {
        isClickable = true
        isFocusable = true
        updateButtonStyle()

        setOnClickListener { view ->
            if (isEnabled) this.action?.call()
        }
    }

    fun set(action: SwiftAction, buttonType: Int, isEnabled: Boolean) {
        this.buttonStyle = buttonType
        this.action = action
        this.isEnabled = isEnabled

        updateButtonStyle()
    }

    fun updateButtonStyle() {
        alpha = if (isEnabled || buttonStyle == ButtonStyle.BORDERED) 1.0f else 0.38f

        when (buttonStyle) {
            ButtonStyle.BORDERED -> {
                background = borderedBackground
                setPadding((12 * density).toInt(), (5 * density).toInt(), (12 * density).toInt(), (6 * density).toInt())
            }
            ButtonStyle.PLAIN, ButtonStyle.BORDERLESS -> {
                background = null
                setPadding(0, 0, 0, 0)
            }
            else -> {
                background = borderedBackground
                setPadding((12 * density).toInt(), (5 * density).toInt(), (12 * density).toInt(), (6 * density).toInt())
            }
        }

        if (isEnabled) {
            foreground = when (buttonStyle) {
                ButtonStyle.BORDERED -> borderedDrawable
                ButtonStyle.PLAIN, ButtonStyle.BORDERLESS -> borderlessDrawable
                else -> borderedDrawable
            }
        } else {
            foreground = null
        }
    }

    override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(info)
        info.className = "android.widget.Button"
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