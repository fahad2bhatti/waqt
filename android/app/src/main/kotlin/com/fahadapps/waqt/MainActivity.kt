package com.fahadapps.waqt

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
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
    companion object {
        private const val NOTIFICATION_REQUEST = 1001
    }

    private lateinit var blockerChannel: MethodChannel
    private var azanChannel: MethodChannel? = null
    private var launchedForAzan = false
    private var visible = false
    private var closeAfterAzan = false
    private var pendingNotificationResult: MethodChannel.Result? = null

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
        visible = true
        ContextCompat.registerReceiver(
            this,
            blockerReceiver,
            IntentFilter(BlockerBroadcastReceiver.ACTION_BLOCK_APP),
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
    }

    override fun onStop() {
        super.onStop()
        visible = false
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
        if (azan && !visible) closeAfterAzan = true
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

    // Asks for POST_NOTIFICATIONS. Answers "granted", "denied" (can be asked
    // again) or "blocked" (Android will not show the dialog any more).
    private fun requestNotifications(result: MethodChannel.Result?) {
        val permission = Manifest.permission.POST_NOTIFICATIONS
        val granted = Build.VERSION.SDK_INT < 33 ||
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            result?.success("granted")
            return
        }
        val prefs = getSharedPreferences("waqt_azan", Context.MODE_PRIVATE)
        val blocked = prefs.getBoolean("notification_asked", false) &&
            !ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
        if (blocked || pendingNotificationResult != null) {
            result?.success(if (blocked) "blocked" else "denied")
            return
        }
        prefs.edit().putBoolean("notification_asked", true).apply()
        pendingNotificationResult = result
        ActivityCompat.requestPermissions(this, arrayOf(permission), NOTIFICATION_REQUEST)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_REQUEST) return
        val pending = pendingNotificationResult ?: return
        pendingNotificationResult = null
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        pending.success(if (granted) "granted" else "denied")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        io.flutter.plugin.common.EventChannel(messenger, "com.fahadapps.waqt/compass")
            .setStreamHandler(CompassStream(this))

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
                    requestNotifications(null)
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

                "setSound" -> {
                    getSharedPreferences("waqt_azan", Context.MODE_PRIVATE).edit()
                        .putString("sound", call.argument<String>("sound") ?: "Makkah")
                        .putBoolean("different_fajr", call.argument<Boolean>("differentFajr") ?: false)
                        .apply()
                    result.success(null)
                }

                "azanState" -> result.success(AzanService.snapshot())

                "consumeAzanLaunch" -> {
                    val open = launchedForAzan && AzanService.isActive()
                    launchedForAzan = false
                    result.success(open)
                }

                "azanScreenClosed" -> {
                    val locked = (getSystemService(Context.KEYGUARD_SERVICE) as android.app.KeyguardManager).isKeyguardLocked
                    if (closeAfterAzan || locked) {
                        closeAfterAzan = false
                        moveTaskToBack(true)
                    }
                    if (Build.VERSION.SDK_INT >= 27) {
                        setShowWhenLocked(false)
                        setTurnScreenOn(false)
                    }
                    result.success(null)
                }

                "azanToggle" -> {
                    sendToAzanService(AzanService.ACTION_TOGGLE)
                    result.success(null)
                }

                "azanStop" -> {
                    sendToAzanService(AzanService.ACTION_STOP)
                    result.success(null)
                }

                "azanRemind" -> {
                    startService(
                        Intent(this, AzanService::class.java).apply {
                            action = AzanService.ACTION_REMIND
                            putExtra(AzanService.EXTRA_MINUTES, call.argument<Int>("minutes") ?: 10)
                        },
                    )
                    result.success(null)
                }

                "syncPrayed" -> {
                    ReminderScheduler.syncPrayed(this, call.argument<List<String>>("keys") ?: emptyList())
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

                    "requestNotifications" -> requestNotifications(result)

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
