package com.fahadapps.waqt

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var blockerChannel: MethodChannel
    private var azanChannel: MethodChannel? = null
    private var launchedForAzan = false

    private val blockerReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BlockerBroadcastReceiver.ACTION_BLOCK_APP) {
                // Flutter ko batao ke blocked app open hui hai
                blockerChannel.invokeMethod("onAppBlocked", null)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        launchedForAzan = markAzanLaunch(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (markAzanLaunch(intent)) azanChannel?.invokeMethod("onAzanOpen", null)
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

    override fun onDestroy() {
        AzanService.stateListener = null
        azanChannel = null
        super.onDestroy()
    }

    // Launched for an active Azan: show over the lock screen and wake the display.
    private fun markAzanLaunch(intent: Intent?): Boolean {
        val azan = intent?.hasExtra("alarm_name") == true && AzanService.isActive()
        if (azan && Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        return azan
    }

    private fun sendToAzanService(action: String, logKey: String? = null) {
        startService(
            Intent(this, AzanService::class.java).apply {
                this.action = action
                if (logKey != null) putExtra(AzanService.EXTRA_LOG_KEY, logKey)
            },
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // Proper initialization with binaryMessenger
        blockerChannel = MethodChannel(messenger, "com.waqt/prayer_blocker")

        val azan = MethodChannel(messenger, "com.fahadapps.waqt/azan")
        azanChannel = azan
        AzanService.stateListener = { snapshot ->
            azan.invokeMethod("onAzanState", snapshot)
            if (snapshot["state"] == AzanService.STATE_STOPPED && Build.VERSION.SDK_INT >= 27) {
                setShowWhenLocked(false)
                setTurnScreenOn(false)
            }
        }
        azan.setMethodCallHandler { call, result ->
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
                    AlarmScheduler.scheduleTestAlarm(this, seconds)
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

                "azanState" -> result.success(AzanService.snapshot())

                "consumeAzanLaunch" -> {
                    val open = launchedForAzan && AzanService.isActive()
                    launchedForAzan = false
                    result.success(open)
                }

                "azanToggle" -> {
                    sendToAzanService(AzanService.ACTION_TOGGLE)
                    result.success(null)
                }

                "azanStop" -> {
                    sendToAzanService(AzanService.ACTION_STOP)
                    result.success(null)
                }

                "azanPrayed" -> {
                    sendToAzanService(AzanService.ACTION_PRAYED, AzanService.prayedKey())
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
