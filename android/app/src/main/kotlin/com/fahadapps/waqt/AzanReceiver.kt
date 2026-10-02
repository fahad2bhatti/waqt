package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AzanReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val name = intent.getStringExtra("name")?.takeIf { it.isNotEmpty() } ?: return
        val millis = intent.getLongExtra("millis", System.currentTimeMillis())

        // Remember when the last Azan alarm really fired (shown in Health check).
        context.getSharedPreferences("waqt_azan", Context.MODE_PRIVATE)
            .edit().putLong("last_fired", System.currentTimeMillis()).apply()

        AlarmScheduler.showAzanNotification(context, name, millis)
    }
}
