package com.codesym.retainly

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "focus_shield"
    private var focusShieldActive = false
    private var previousInterruptionFilter = NotificationManager.INTERRUPTION_FILTER_ALL

    override fun onDestroy() {
        if (focusShieldActive) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.setInterruptionFilter(previousInterruptionFilter)
        }
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isFocusShieldAvailable" -> {
                    val available = isDndAccessGranted()
                    result.success(available)
                }
                "toggleFocusShield" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    val success = setFocusShield(enable)
                    result.success(success)
                }
                "openDndSettings" -> {
                    openDndSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        processIntent(intent)
    }

    private fun processIntent(intent: Intent) {
        val action = intent.getStringExtra("action")
        if (action == FocusShieldForegroundService.ACTION_STOP_FOCUS_SHIELD) {
            setFocusShield(false)
        }
    }

    private fun isDndAccessGranted(): Boolean {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notificationManager.isNotificationPolicyAccessGranted
        } else {
            true
        }
    }

    private fun setFocusShield(enable: Boolean): Boolean {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!notificationManager.isNotificationPolicyAccessGranted) {
                Log.w("FocusShield", "DND access not granted")
                return false
            }
            if (enable) {
                previousInterruptionFilter = notificationManager.currentInterruptionFilter
                notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                startFocusShieldService()
            } else {
                notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                stopFocusShieldService()
            }
            focusShieldActive = enable
            true
        } else {
            Log.w("FocusShield", "DND control requires API 23+")
            false
        }
    }

    private fun startFocusShieldService() {
        val intent = Intent(this, FocusShieldForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopFocusShieldService() {
        val intent = Intent(this, FocusShieldForegroundService::class.java)
        stopService(intent)
    }

    private fun openDndSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }
}
