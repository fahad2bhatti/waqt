package com.fahadapps.waqt

import android.app.AlarmManager
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat

/** Real status of the permissions Azan and Prayer Mode depend on. */
object DeviceHealth {
    fun status(context: Context): Map<String, Boolean> = mapOf(
        "notifications" to NotificationManagerCompat.from(context).areNotificationsEnabled(),
        "exactAlarms" to exactAlarmsAllowed(context),
        "battery" to ignoringBatteryOptimizations(context),
        "usageAccess" to usageAccessGranted(context),
        "overlay" to Settings.canDrawOverlays(context),
    )

    fun settingsIntent(context: Context, key: String): Intent {
        val uri = Uri.parse("package:${context.packageName}")
        return when (key) {
            "notifications" ->
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)

            "exactAlarms" ->
                if (Build.VERSION.SDK_INT >= 31) {
                    Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, uri)
                } else {
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, uri)
                }

            "battery" -> Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            "usageAccess" -> Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            "overlay" -> Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, uri)
            else -> Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, uri)
        }
    }

    private fun exactAlarmsAllowed(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < 31) return true
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return alarmManager.canScheduleExactAlarms()
    }

    private fun ignoringBatteryOptimizations(context: Context): Boolean {
        val power = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return power.isIgnoringBatteryOptimizations(context.packageName)
    }

    @Suppress("DEPRECATION")
    private fun usageAccessGranted(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= 29) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
