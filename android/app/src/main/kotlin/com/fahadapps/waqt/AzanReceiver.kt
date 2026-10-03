package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AzanReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val name = intent.getStringExtra("name")?.takeIf { it.isNotEmpty() } ?: return
        val millis = intent.getLongExtra("millis", System.currentTimeMillis())

        // Force start MainActivity for full-screen experience
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("alarm_name", name)
        }
        context.startActivity(launchIntent)

        // Remember when the last Azan alarm really fired (shown in Health check).
        context.getSharedPreferences("waqt_azan", Context.MODE_PRIVATE)
            .edit().putLong("last_fired", System.currentTimeMillis()).apply()

        AlarmScheduler.showAzanNotification(context, name, millis)
    }
}
