package dev.swiftcrossui.androidbackend

import android.view.View
import android.view.MotionEvent

class ViewOnHoverListener(
    private val enterAction: SwiftAction,
    private val leaveAction: SwiftAction
) : View.OnHoverListener {
    override fun onHover(view: View, event: MotionEvent): Boolean {
        if (event.getAction() == MotionEvent.ACTION_HOVER_ENTER) {
            enterAction.call()
            return true
        }
        
        if (event.getAction() == MotionEvent.ACTION_HOVER_EXIT) {
            leaveAction.call()
            return true
        }

        return false
    }
}
