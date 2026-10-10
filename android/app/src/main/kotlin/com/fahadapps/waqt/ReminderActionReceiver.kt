package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

/** "I prayed" and "Dismiss" buttons on the reminder notification. */
class ReminderActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationManagerCompat.from(context).cancel(intent.getIntExtra("nid", 0))
        if (intent.action == ReminderScheduler.ACTION_PRAYED) {
            val key = intent.getStringExtra("logKey") ?: return
            AlarmScheduler.addPendingPrayed(context, key)
            ReminderScheduler.markPrayed(context, key)
        }
    }
}
