package com.fahadapps.waqt

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AzanService : Service() {
    private var player: MediaPlayer? = null
    private var focusRequest: AudioFocusRequest? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopAzan()
                return START_NOT_STICKY
            }
            ACTION_PRAYED -> {
                intent.getStringExtra(EXTRA_LOG_KEY)?.let { AlarmScheduler.addPendingPrayed(this, it) }
                stopAzan()
                return START_NOT_STICKY
            }
        }

        val name = intent?.getStringExtra(EXTRA_NAME) ?: "Azan"
        val millis = intent?.getLongExtra(EXTRA_MILLIS, System.currentTimeMillis())
            ?: System.currentTimeMillis()
        val sound = intent?.getStringExtra(EXTRA_SOUND) ?: "Makkah"
        val differentFajr = intent?.getBooleanExtra(EXTRA_DIFFERENT_FAJR, false) ?: false

        val notification = buildNotification(name, millis)
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        play(rawFor(sound, name, differentFajr))
        return START_NOT_STICKY
    }

    private fun rawFor(sound: String, name: String, differentFajr: Boolean): Int = when {
        name == "Fajr" && differentFajr -> R.raw.azan_fajr
        sound == "Madinah" -> R.raw.azan_madinah
        sound == "Al-Aqsa" -> R.raw.azan_aqsa
        else -> R.raw.azan_makkah
    }

    private fun play(rawRes: Int) {
        releasePlayer()
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        if (Build.VERSION.SDK_INT >= 26) {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(attrs)
                .build()
            focusRequest = request
            audioManager.requestAudioFocus(request)
        }

        val mp = MediaPlayer.create(this, rawRes, attrs, AudioManager.AUDIO_SESSION_ID_GENERATE)
        if (mp == null) {
            stopAzan()
            return
        }
        mp.setOnCompletionListener { stopAzan() }
        mp.setOnErrorListener { _, _, _ ->
            stopAzan()
            true
        }
        player = mp
        mp.start()
    }

    private fun buildNotification(name: String, millis: Long): Notification {
        ensureChannel()
        val time = SimpleDateFormat("h:mm a", Locale.ENGLISH).format(Date(millis))
        val dayKey = SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH).format(Date(millis))
        val logName = if (name == "jummah") "Dhuhr" else name

        val open = PendingIntent.getActivity(
            this,
            1,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val stop = actionIntent(2, ACTION_STOP, null)
        val prayed = actionIntent(3, ACTION_PRAYED, "$dayKey|$logName")

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_waqt)
            .setColor(0xFFD9B26B.toInt())
            .setContentTitle("${name.uppercase(Locale.ENGLISH)}  $time")
            .setContentText("Azan is playing")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setContentIntent(open)
            .addAction(0, "Stop", stop)
            .addAction(0, "I prayed", prayed)
            .build()
    }

    private fun actionIntent(requestCode: Int, action: String, logKey: String?): PendingIntent {
        val intent = Intent(this, AzanService::class.java).apply {
            this.action = action
            if (logKey != null) putExtra(EXTRA_LOG_KEY, logKey)
        }
        return PendingIntent.getService(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < 26) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Azan playing", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Shown while the Azan is playing"
                setSound(null, null)
                enableVibration(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            },
        )
    }

    private fun releasePlayer() {
        player?.release()
        player = null
        if (Build.VERSION.SDK_INT >= 26) {
            focusRequest?.let {
                (getSystemService(Context.AUDIO_SERVICE) as AudioManager).abandonAudioFocusRequest(it)
            }
            focusRequest = null
        }
    }

    private fun stopAzan() {
        releasePlayer()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }

    companion object {
        const val EXTRA_NAME = "name"
        const val EXTRA_MILLIS = "millis"
        const val EXTRA_SOUND = "sound"
        const val EXTRA_DIFFERENT_FAJR = "different_fajr"
        private const val EXTRA_LOG_KEY = "logKey"
        private const val ACTION_STOP = "com.fahadapps.waqt.AZAN_STOP"
        private const val ACTION_PRAYED = "com.fahadapps.waqt.AZAN_PRAYED"
        private const val CHANNEL_ID = "azan_playing"
        private const val NOTIFICATION_ID = 4101
    }
}
