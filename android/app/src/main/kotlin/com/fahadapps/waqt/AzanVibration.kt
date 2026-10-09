package com.fahadapps.waqt

import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log

/** Silent-phone heartbeat: 0.7 s on, 1.3 s off for about as long as an Azan. */
object AzanVibration {
    private const val TOTAL_MS = 180_000L
    private const val ON_MS = 700L
    private const val OFF_MS = 1_300L

    private val handler = Handler(Looper.getMainLooper())

    @Suppress("DEPRECATION")
    private fun vibrator(context: Context): Vibrator =
        if (Build.VERSION.SDK_INT >= 31) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                .defaultVibrator
        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

    @Suppress("DEPRECATION")
    fun start(context: Context) {
        val app = context.applicationContext
        val v = vibrator(app)
        if (!v.hasVibrator()) return
        val cycles = (TOTAL_MS / (ON_MS + OFF_MS)).toInt()
        val pattern = LongArray(cycles * 2 + 1) { i ->
            when {
                i == 0 -> 0L
                i % 2 == 1 -> ON_MS
                else -> OFF_MS
            }
        }
        if (Build.VERSION.SDK_INT >= 26) {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            v.vibrate(VibrationEffect.createWaveform(pattern, -1), attrs)
        } else {
            v.vibrate(pattern, -1)
        }
        Log.d("WaqtAzan", "vibration start")
    }

    private fun cancelNow(context: Context) {
        runCatching {
            if (Build.VERSION.SDK_INT >= 31) {
                (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .cancel()
            }
        }
        runCatching { vibrator(context).cancel() }
    }

    fun stop(context: Context) {
        val app = context.applicationContext
        Log.d("WaqtAzan", "vibration stop")
        cancelNow(app)
        // Second cancel shortly after, in case the first one raced with the vibration starting.
        handler.postDelayed({ cancelNow(app) }, 300)
    }

    fun cancel(context: Context) = stop(context)
}
