package com.katanalabs.finan2

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

private const val TIMEZONE_CHANNEL = "finan2/timezone"

// A FragmentActivity because local_auth (fingerprint / Face ID) needs one.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // No snapshot of balances in the app switcher (Android 13+); unlike
        // FLAG_SECURE, normal screenshots still work. Older versions get the
        // blur from PrivacyShield.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getLocalTimezone") {
                    result.success(TimeZone.getDefault().id)
                } else {
                    result.notImplemented()
                }
            }
    }
}
