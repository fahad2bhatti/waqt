package com.fahadapps.waqt

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class AzanSlot(val name: String, val millis: Long)

object AlarmScheduler {
    private const val PREFS = "waqt_azan"
    private const val KEY_SLOTS = "slots"
    private const val KEY_PENDING_PRAYED = "pending_prayed"
    private const val MAX_SLOTS = 64
    private const val GOLD = 0xFFD9B26B // AppColors.gold

    const val CHANNEL_ID = "azan"
    const val ACTION_AZAN = "com.fahadapps.waqt.AZAN"
    const val ACTION_PRAYED = "com.fahadapps.waqt.PRAYED"
    const val ACTION_DISMISS = "com.fahadapps.waqt.DISMISS"

    fun schedule(context: Context, slots: List<AzanSlot>) {
        cancelAll(context)
        save(context, slots)
        arm(context, slots)
    }

    fun scheduleAlarm(context: Context, seconds: Int) {
        val at = System.currentTimeMillis() + seconds * 1000L
        schedule(context, listOf(AzanSlot("Test", at)))
    }

    fun rescheduleFromStorage(context: Context) {
        arm(context, load(context))
    }

    private fun arm(context: Context, slots: List<AzanSlot>) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val now = System.currentTimeMillis()
        val showIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        slots
            .filter { it.millis > now }
            .sortedBy { it.millis }
            .take(MAX_SLOTS)
            .forEachIndexed { index, slot ->
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(slot.millis, showIntent),
                    pendingFor(context, index, slot),
                )
            }
    }

    private fun cancelAll(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (index in 0 until MAX_SLOTS) {
            val pending = pendingFor(context, index, AzanSlot("", 0L))
            alarmManager.cancel(pending)
            pending.cancel()
        }
    }

    fun clear(context: Context) {
        cancelAll(context)
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().clear().apply()
    }

    private fun pendingFor(context: Context, requestCode: Int, slot: AzanSlot): PendingIntent {
        val intent = Intent(context, AzanReceiver::class.java).apply {
            action = ACTION_AZAN
            putExtra("name", slot.name)
            putExtra("millis", slot.millis)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun save(context: Context, slots: List<AzanSlot>) {
        val array = JSONArray()
        slots.forEach {
            array.put(JSONObject().put("name", it.name).put("millis", it.millis))
        }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(KEY_SLOTS, array.toString()).apply()
    }

    private fun load(context: Context): List<AzanSlot> {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_SLOTS, null) ?: return emptyList()
        val array = JSONArray(raw)
        return (0 until array.length()).map {
            val item = array.getJSONObject(it)
            AzanSlot(item.getString("name"), item.getLong("millis"))
        }
    }

    // "I prayed" taps from the notification, handed to Flutter on next resume.

    fun addPendingPrayed(context: Context, key: String) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val updated = (prefs.getStringSet(KEY_PENDING_PRAYED, emptySet()) ?: emptySet()) + key
        prefs.edit().putStringSet(KEY_PENDING_PRAYED, updated).apply()
    }

    fun takePendingPrayed(context: Context): List<String> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val keys = prefs.getStringSet(KEY_PENDING_PRAYED, emptySet())?.toList() ?: emptyList()
        prefs.edit().remove(KEY_PENDING_PRAYED).apply()
        return keys
    }

    // Notification (matches the Figma Azan screen)

    fun showAzanNotification(context: Context, name: String, millis: Long) {
        if (Build.VERSION.SDK_INT >= 33 &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) return

        ensureChannel(context)
        val id = name.hashCode()
        val time = SimpleDateFormat("h:mm a", Locale.ENGLISH).format(Date(millis))
        val dayKey = SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH).format(Date(millis))

        val open = PendingIntent.getActivity(
            context,
            1,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val prayed = actionIntent(context, id, ACTION_PRAYED, "$dayKey|$name")
        val dismiss = actionIntent(context, id + 1, ACTION_DISMISS, null, id)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setColor(GOLD.toInt())
            .setContentTitle("${name.uppercase(Locale.ENGLISH)}  $time")
            .setContentText("Time for Azan")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(open, true)
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
        notificationId: Int = requestCode,
    ): PendingIntent {
        val intent = Intent(context, AzanActionReceiver::class.java).apply {
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
            NotificationChannel(CHANNEL_ID, "Azan", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Prayer time alerts"
                setBypassDnd(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            },
        )
    }
}
