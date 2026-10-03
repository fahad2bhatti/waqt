package com.fahadapps.waqt

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var blockerChannel: MethodChannel

    private val blockerReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BlockerBroadcastReceiver.ACTION_BLOCK_APP) {
                // Flutter ko batao ke blocked app open hui hai
                blockerChannel.invokeMethod("onAppBlocked", null)
            }
        }
    }

    override fun onStart() {
        super.onStart()
        ContextCompat.registerReceiver(
            this,
            blockerReceiver,
            IntentFilter(BlockerBroadcastReceiver.ACTION_BLOCK_APP),
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
    }

    override fun onStop() {
        super.onStop()
        unregisterReceiver(blockerReceiver)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // Proper initialization with binaryMessenger
        blockerChannel = MethodChannel(messenger, "com.waqt/prayer_blocker")

        MethodChannel(messenger, "com.fahadapps.waqt/azan")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedule" -> {
                        val raw = call.argument<List<Map<String, Any>>>("slots") ?: emptyList()
                        val slots = raw.map {
                            AzanSlot(it["name"] as String, (it["millis"] as Number).toLong())
                        }
                        AlarmScheduler.schedule(this, slots)
                        result.success(null)
                    }

                    "scheduleTest" -> {
                        val seconds = call.argument<Int>("seconds") ?: 60
                        val at = System.currentTimeMillis() + seconds * 1000L
                        AlarmScheduler.schedule(this, listOf(AzanSlot("Test", at)))
                        result.success(null)
                    }

                    "takePendingPrayed" -> {
                        result.success(AlarmScheduler.takePendingPrayed(this))
                    }

                    "requestNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= 33) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                1001,
                            )
                        }
                        result.success(null)
                    }

                    "cancelAll" -> {
                        AlarmScheduler.clear(this)
                        result.success(null)
                    }

                    "stopBlocker" -> {
                        stopService(Intent(this, PrayerBlockerService::class.java))
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(messenger, "com.fahadapps.waqt/health")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(DeviceHealth.status(this))

                    "openSettings" -> {
                        val key = call.argument<String>("key") ?: ""
                        try {
                            startActivity(DeviceHealth.settingsIntent(this, key))
                        } catch (e: Exception) {
                            startActivity(
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName"),
                                ),
                            )
                        }
                        result.success(null)
                    }

                    "lastAzanFired" -> {
                        val millis = getSharedPreferences("waqt_azan", Context.MODE_PRIVATE)
                            .getLong("last_fired", 0L)
                        result.success(if (millis == 0L) null else millis)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(messenger, "com.waqt/prayer_blocker")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val intent = Intent(this, PrayerBlockerService::class.java)
                        startService(intent)
                        result.success(true)
                    }
                    "stopService" -> {
                        stopService(Intent(this, PrayerBlockerService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
