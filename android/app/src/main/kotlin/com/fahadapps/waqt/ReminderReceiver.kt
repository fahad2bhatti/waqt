package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val name = intent.getStringExtra("name") ?: return
        val logKey = intent.getStringExtra("logKey") ?: return
        val azanMillis = intent.getLongExtra("millis", 0L)
        val minutes = intent.getIntExtra("minutes", 10)
        ReminderScheduler.onFired(context, name, azanMillis, logKey, minutes)
    }
}
