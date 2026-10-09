package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class AzanReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val name = intent.getStringExtra("name")?.takeIf { it.isNotEmpty() } ?: return
        val millis = intent.getLongExtra("millis", System.currentTimeMillis())

        // Remember when the last Azan alarm really fired (shown in Health check).
        val prefs = context.getSharedPreferences("waqt_azan", Context.MODE_PRIVATE)
        prefs.edit().putLong("last_fired", System.currentTimeMillis()).apply()

        val serviceIntent = Intent(context, AzanService::class.java).apply {
            putExtra(AzanService.EXTRA_NAME, name)
            putExtra(AzanService.EXTRA_MILLIS, millis)
            putExtra(AzanService.EXTRA_SOUND, prefs.getString("sound", "Makkah"))
            putExtra(AzanService.EXTRA_DIFFERENT_FAJR, prefs.getBoolean("different_fajr", false))
        }
        try {
            AzanService.prepare(name, millis)
            ContextCompat.startForegroundService(context, serviceIntent)
        } catch (e: Exception) {
            AzanService.update(AzanService.STATE_STOPPED)
            AlarmScheduler.showAzanNotification(context, name, millis)
        }

        // Open the app on the Azan screen (the notification full-screen intent covers the locked case).
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("alarm_name", name)
        }
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        val fsi = if (android.os.Build.VERSION.SDK_INT >= 34) nm.canUseFullScreenIntent() else true
        Log.d("WaqtAzan", "receiver name=$name overlay=${android.provider.Settings.canDrawOverlays(context)} fullScreenIntent=$fsi")
        context.startActivity(launchIntent)
    }
}
