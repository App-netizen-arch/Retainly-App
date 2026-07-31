package com.codesym.retainly

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent

// Optional service that requires enabling in system Settings > Accessibility.
// It can be used to detect when the user leaves the Focus screen during a session.
class FocusAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i("FocusAccessibilityService", "Service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            Log.i("FocusAccessibilityService", "Window changed: $packageName")
        }
        if (event.eventType == AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED) {
            Log.i("FocusAccessibilityService", "Notification received")
        }
    }

    override fun onInterrupt() {
        Log.i("FocusAccessibilityService", "Service interrupted")
    }
}
