package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

/** Handles the "I prayed" and "Dismiss" notification buttons. */
class AzanActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationManagerCompat.from(context).cancel(intent.getIntExtra("nid", 0))
        if (intent.action == AlarmScheduler.ACTION_PRAYED) {
            val key = intent.getStringExtra("logKey") ?: return
            AlarmScheduler.addPendingPrayed(context, key)
        }
    }
}
