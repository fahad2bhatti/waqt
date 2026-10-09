package com.fahadapps.waqt

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class PrayerBlockerService : Service() {
    private val CHANNEL = "com.waqt/prayer_blocker"
    private val handler = Handler(Looper.getMainLooper())
    private var isRunning = true

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startMonitoring()
        return START_STICKY
    }

    private fun startMonitoring() {
        handler.post(object : Runnable {
            override fun run() {
                if (!isRunning) return
                checkForegroundApp()
                handler.postDelayed(this, 2000) // Check every 2 seconds
            }
        })
    }

    private fun checkForegroundApp() {
        try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val time = System.currentTimeMillis()
            val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000 * 60, time)

            if (stats != null && stats.isNotEmpty()) {
                val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
                val topApp = sortedStats[0].packageName


                // Yahan hum check karenge ke app blocked hai ya nahi.
                // Abhi simulation ke liye hum seedha broadcast bhej rahe hain.
                val intent = Intent(BlockerBroadcastReceiver.ACTION_BLOCK_APP)
                sendBroadcast(intent)
            }
        } catch (e: Exception) {
            Log.e("PrayerBlocker", "Error checking app: ${e.message}")
        }
    }
    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
    }
}
