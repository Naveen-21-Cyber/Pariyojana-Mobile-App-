package com.navii.pariyojana

import android.content.Intent
import android.media.MediaDrm
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Base64
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.navii.velvet/icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Anti-Forensic Protection: Enforce FLAG_SECURE to block screen recording, screenshot malware & task switcher caching
        try {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        } catch (e: Exception) {
            // Ignored
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "changeIcon" -> {
                    val iconName = call.argument<String>("iconName")
                    result.success(true)
                }
                "openBatterySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("BATTERY_ERROR", ex.localizedMessage, null)
                        }
                    }
                }
                "getHardwareDrmFingerprint" -> {
                    try {
                        val WIDEVINE_UUID = UUID(-0x121074568629b532L, -0x5c37d823277d3f13L)
                        val mediaDrm = MediaDrm(WIDEVINE_UUID)
                        val deviceIdBytes = mediaDrm.getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            mediaDrm.close()
                        } else {
                            @Suppress("DEPRECATION")
                            mediaDrm.release()
                        }
                        val drmFingerprint = Base64.encodeToString(deviceIdBytes, Base64.NO_WRAP)
                        result.success(drmFingerprint)
                    } catch (e: Exception) {
                        val fallbackId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                        result.success("DRM_HW_FALLBACK_$fallbackId")
                    }
                }
                "toggleFlagSecure" -> {
                    val enable = call.argument<Boolean>("enable") ?: true
                    try {
                        if (enable) {
                            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(enable)
                    } catch (e: Exception) {
                        result.error("FLAG_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
