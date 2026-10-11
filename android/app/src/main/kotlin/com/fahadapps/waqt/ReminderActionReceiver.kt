package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

/** "I prayed" and "Remind again" on the reminder notification. */
class ReminderActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationManagerCompat.from(context).cancel(intent.getIntExtra("nid", 0))
        val logKey = intent.getStringExtra("logKey") ?: return

        when (intent.action) {
            ReminderScheduler.ACTION_PRAYED -> {
                AlarmScheduler.addPendingPrayed(context, logKey)
                ReminderScheduler.markPrayed(context, logKey)
            }

            ReminderScheduler.ACTION_AGAIN -> {
                val name = intent.getStringExtra("name") ?: return
                ReminderScheduler.remindAgain(
                    context,
                    name,
                    intent.getLongExtra("millis", 0L),
                    logKey,
                    intent.getIntExtra("minutes", 10),
                )
            }
        }
    }
}
