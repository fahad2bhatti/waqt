package com.fahadapps.waqt

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray

/**
 * Reminds the user to pray after the Azan ends. The reminder notification stays
 * until "I prayed" or "Remind again" is tapped, the next prayer starts, or an
 * hour has passed.
 */
object ReminderScheduler {
    private const val PREFS = "waqt_azan"
    private const val KEY_PRAYED = "prayed_keys"
    private const val KEY_PENDING_PRAYED = "pending_prayed"
    private const val KEY_MINUTES = "reminder_minutes"
    private const val KEY_SLOTS = "slots"
    private const val DEFAULT_MINUTES = 10
    private const val WINDOW_MS = 60L * 60 * 1000
    private const val REQUEST_BASE = 2000
    private const val NOTIFICATION_BASE = 5000
    private const val CHANNEL_ID = "azan_reminder"
    private const val GOLD = 0xFFD9B26B // AppColors.gold

    const val ACTION_REMINDER = "com.fahadapps.waqt.REMINDER"
    const val ACTION_PRAYED = "com.fahadapps.waqt.REMINDER_PRAYED"
    const val ACTION_AGAIN = "com.fahadapps.waqt.REMINDER_AGAIN"

    private val names = arrayOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Test")

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun slotIndex(name: String) = when (name) {
        "Fajr" -> 0
        "Dhuhr", "jummah" -> 1
        "Asr" -> 2
        "Maghrib" -> 3
        "Isha" -> 4
        else -> 5
    }

    private fun savedMinutes(context: Context) =
        prefs(context).getInt(KEY_MINUTES, DEFAULT_MINUTES)

    /** The Azan ended without "I prayed": remind after the usual interval. */
    fun afterAzan(context: Context, name: String, azanMillis: Long, logKey: String?) {
        schedule(context, name, azanMillis, logKey, savedMinutes(context))
    }

    /** The user picked "Remind me in N min" on the Azan screen. */
    fun remindIn(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String?,
        minutes: Int,
    ) {
        prefs(context).edit().putInt(KEY_MINUTES, minutes).apply()
        schedule(context, name, azanMillis, logKey, minutes)
    }

    /** "Remind again" on the reminder notification: hide it and remind later. */
    fun remindAgain(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
    ) {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_BASE + slotIndex(name))
        schedule(context, name, azanMillis, logKey, minutes)
    }

    /**
     * Called by [ReminderReceiver] when a reminder alarm fires. The notification
     * stays on screen; the next reminder is only scheduled by "Remind again".
     */
    fun onFired(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
    ) {
        val now = System.currentTimeMillis()
        if (!canRemind(context, azanMillis, logKey, now)) {
            cancel(context, name)
            return
        }
        showNotification(
            context,
            name,
            azanMillis,
            logKey,
            minutes,
            windowEnd(context, azanMillis) - now,
        )
    }

    private fun schedule(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String?,
        minutes: Int,
    ) {
        if (logKey == null || name.isEmpty()) return
        val fireAt = System.currentTimeMillis() + minutes * 60_000L
        if (!canRemind(context, azanMillis, logKey, fireAt)) {
            cancel(context, name)
            return
        }
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val show = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        alarmManager.setAlarmClock(
            AlarmManager.AlarmClockInfo(fireAt, show),
            pendingFor(context, name, azanMillis, logKey, minutes),
        )
        prefs(context).edit().putString("reminder_key_${slotIndex(name)}", logKey).apply()
    }

    private fun canRemind(
        context: Context,
        azanMillis: Long,
        logKey: String,
        atMillis: Long,
    ): Boolean {
        if (isPrayed(prayedSet(context), logKey)) return false
        if (atMillis > azanMillis + WINDOW_MS) return false
        val next = nextSlotMillis(context, azanMillis)
        return next == null || atMillis < next
    }

    /** The reminder is pointless after this: next prayer starts or an hour passes. */
    private fun windowEnd(context: Context, azanMillis: Long): Long {
        val end = azanMillis + WINDOW_MS
        val next = nextSlotMillis(context, azanMillis)
        return if (next != null) minOf(end, next) else end
    }

    private fun nextSlotMillis(context: Context, after: Long): Long? {
        val raw = prefs(context).getString(KEY_SLOTS, null) ?: return null
        return runCatching {
            val array = JSONArray(raw)
            (0 until array.length())
                .map { array.getJSONObject(it).getLong("millis") }
                .filter { it > after }
                .minOrNull()
        }.getOrNull()
    }

    // ---- prayed state (kept in sync from Flutter and from notification buttons) ----

    private fun prayedSet(context: Context): Set<String> =
        prefs(context).getStringSet(KEY_PRAYED, emptySet()) ?: emptySet()

    private fun isPrayed(set: Set<String>, key: String): Boolean {
        if (set.contains(key)) return true
        // Fridays: Flutter logs "jummah", native logs "Dhuhr".
        return key.endsWith("|Dhuhr") && set.contains(key.removeSuffix("|Dhuhr") + "|jummah")
    }

    fun markPrayed(context: Context, key: String) {
        val updated = prayedSet(context) + key
        prefs(context).edit().putStringSet(KEY_PRAYED, updated).apply()
        cancelMatching(context, updated)
    }

    /** Flutter sends the recent prayed keys whenever the prayer log changes. */
    fun syncPrayed(context: Context, keys: List<String>) {
        val pending = prefs(context).getStringSet(KEY_PENDING_PRAYED, emptySet()) ?: emptySet()
        val updated = keys.toSet() + pending
        prefs(context).edit().putStringSet(KEY_PRAYED, updated).apply()
        cancelMatching(context, updated)
    }

    private fun cancelMatching(context: Context, prayed: Set<String>) {
        for (i in names.indices) {
            val key = prefs(context).getString("reminder_key_$i", null) ?: continue
            if (isPrayed(prayed, key)) cancel(context, names[i])
        }
    }

    // ---- alarms ----

    fun cancel(context: Context, name: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pending = pendingFor(context, name, 0L, "", 0)
        alarmManager.cancel(pending)
        pending.cancel()
        prefs(context).edit().remove("reminder_key_${slotIndex(name)}").apply()
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_BASE + slotIndex(name))
    }

    fun cancelAll(context: Context) {
        names.forEach { cancel(context, it) }
    }

    private fun pendingFor(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
    ): PendingIntent {
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            action = ACTION_REMINDER
            putExtra("name", name)
            putExtra("millis", azanMillis)
            putExtra("logKey", logKey)
            putExtra("minutes", minutes)
        }
        return PendingIntent.getBroadcast(
            context,
            REQUEST_BASE + slotIndex(name),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    // ---- notification ----

    private fun showNotification(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
        timeoutMs: Long,
    ) {
        if (Build.VERSION.SDK_INT >= 33 &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) return

        ensureChannel(context)
        val id = NOTIFICATION_BASE + slotIndex(name)
        val display = if (name == "jummah") "Jummah" else name

        val open = PendingIntent.getActivity(
            context,
            7,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val prayed = actionIntent(context, id, ACTION_PRAYED, name, azanMillis, logKey, minutes, id)
        val again = actionIntent(context, id + 100, ACTION_AGAIN, name, azanMillis, logKey, minutes, id)
        // If the notification is cleared some other way, the reminder must not be lost.
        val cleared = actionIntent(context, id + 200, ACTION_AGAIN, name, azanMillis, logKey, minutes, id)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_waqt)
            .setColor(GOLD.toInt())
            .setContentTitle("Time to pray $display")
            .setContentText("Tap \"I prayed\" when you are done, or remind again in $minutes min.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setOngoing(true)
            .setAutoCancel(false)
            .setTimeoutAfter(timeoutMs.coerceAtLeast(60_000L))
            .setContentIntent(open)
            .setDeleteIntent(cleared)
            .addAction(0, "I prayed", prayed)
            .addAction(0, "Remind again", again)
            .build()
        NotificationManagerCompat.from(context).notify(id, notification)
    }

    private fun actionIntent(
        context: Context,
        requestCode: Int,
        action: String,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
        notificationId: Int,
    ): PendingIntent {
        val intent = Intent(context, ReminderActionReceiver::class.java).apply {
            this.action = action
            putExtra("nid", notificationId)
            putExtra("name", name)
            putExtra("millis", azanMillis)
            putExtra("logKey", logKey)
            putExtra("minutes", minutes)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Prayer reminders", NotificationManager.IMPORTANCE_HIGH)
                .apply { description = "Reminders until you mark the prayer as prayed" },
        )
    }
}
