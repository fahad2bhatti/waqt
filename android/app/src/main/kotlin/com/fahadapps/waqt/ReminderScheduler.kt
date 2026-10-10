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
 * Keeps reminding the user to pray after the Azan ends, until the prayer is
 * marked as prayed, the next prayer starts, or an hour has passed.
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
    const val ACTION_DISMISS = "com.fahadapps.waqt.REMINDER_DISMISS"

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

    /** Called by [ReminderReceiver] when a reminder alarm fires. */
    fun onFired(
        context: Context,
        name: String,
        azanMillis: Long,
        logKey: String,
        minutes: Int,
    ) {
        if (!canRemind(context, azanMillis, logKey, System.currentTimeMillis())) {
            cancel(context, name)
            return
        }
        showNotification(context, name, logKey)
        schedule(context, name, azanMillis, logKey, minutes)
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

    private fun showNotification(context: Context, name: String, logKey: String) {
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
        val prayed = actionIntent(context, id, ACTION_PRAYED, logKey, id)
        val dismiss = actionIntent(context, id + 100, ACTION_DISMISS, null, id)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_waqt)
            .setColor(GOLD.toInt())
            .setContentTitle("Time to pray $display")
            .setContentText("Have you prayed? Tap \"I prayed\" when you are done.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(open)
            .addAction(0, "I prayed", prayed)
            .addAction(0, "Dismiss", dismiss)
            .build()
        NotificationManagerCompat.from(context).notify(id, notification)
    }

    private fun actionIntent(
        context: Context,
        requestCode: Int,
        action: String,
        logKey: String?,
        notificationId: Int,
    ): PendingIntent {
        val intent = Intent(context, ReminderActionReceiver::class.java).apply {
            this.action = action
            putExtra("nid", notificationId)
            if (logKey != null) putExtra("logKey", logKey)
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
