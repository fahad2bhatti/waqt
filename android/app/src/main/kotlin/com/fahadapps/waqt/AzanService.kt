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
import android.view.View
import android.widget.RemoteViews
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
                AzanVibration.stop(this)
                stopAzan()
                return START_NOT_STICKY
            }
            ACTION_REMIND -> {
                val minutes = intent.getIntExtra(EXTRA_MINUTES, 10)
                ReminderScheduler.remindIn(this, currentName, currentMillis, prayedKey(), minutes)
                stopAzan(scheduleReminder = false)
                return START_NOT_STICKY
            }
            ACTION_PRAYED -> {
                AzanVibration.stop(this)
                intent.getStringExtra(EXTRA_LOG_KEY)?.let {
                    AlarmScheduler.addPendingPrayed(this, it)
                    ReminderScheduler.markPrayed(this, it)
                }
                stopAzan()
                return START_NOT_STICKY
            }
            ACTION_TOGGLE -> {
                val mp = player
                if (mp == null) {
                    stopAzan()
                } else {
                    val pause = state != STATE_PAUSED
                    if (pause) mp.pause() else mp.start()
                    update(if (pause) STATE_PAUSED else STATE_PLAYING)
                    notificationManager().notify(NOTIFICATION_ID, buildNotification())
                }
                return START_NOT_STICKY
            }
        }

        currentName = intent?.getStringExtra(EXTRA_NAME) ?: "Azan"
        currentMillis = intent?.getLongExtra(EXTRA_MILLIS, System.currentTimeMillis())
            ?: System.currentTimeMillis()
        val sound = intent?.getStringExtra(EXTRA_SOUND) ?: "Makkah"
        val differentFajr = intent?.getBooleanExtra(EXTRA_DIFFERENT_FAJR, false) ?: false

        val silent = (getSystemService(Context.AUDIO_SERVICE) as AudioManager).ringerMode !=
            AudioManager.RINGER_MODE_NORMAL
        update(if (silent) STATE_SILENT else STATE_PLAYING)

        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (silent) {
            vibrate()
            stopForeground(STOP_FOREGROUND_DETACH)
            notificationManager().notify(NOTIFICATION_ID, notification)
            stopSelf()
            return START_NOT_STICKY
        }

        play(rawFor(sound, currentName, differentFajr))
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
            .setUsage(AudioAttributes.USAGE_MEDIA)
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

    private fun vibrate() {
        AzanVibration.start(this)
    }

    private fun buildNotification(): Notification {
        ensureChannel()
        val silent = state == STATE_SILENT
        val paused = state == STATE_PAUSED
        val time = SimpleDateFormat("h:mm a", Locale.ENGLISH).format(Date(currentMillis))
        val title = "${currentName.uppercase(Locale.ENGLISH)}  $time"
        val text = when {
            silent -> "Phone is silent"
            paused -> "Paused"
            else -> "Azan is playing"
        }

        val open = PendingIntent.getActivity(
            this,
            1,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("alarm_name", currentName)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val toggle = actionIntent(2, ACTION_TOGGLE, null)
        val prayed = actionIntent(3, ACTION_PRAYED, prayedKey())
        val stop = actionIntent(4, ACTION_STOP, null)

        val small = RemoteViews(packageName, R.layout.notification_azan_small)
        val big = RemoteViews(packageName, R.layout.notification_azan_big)
        for (views in listOf(small, big)) {
            views.setTextViewText(R.id.azan_title, title)
            views.setTextViewText(R.id.azan_text, text)
            views.setOnClickPendingIntent(R.id.azan_prayed, prayed)
        }
        if (silent) {
            small.setViewVisibility(R.id.azan_pause, View.GONE)
            big.setViewVisibility(R.id.azan_row, View.GONE)
        } else {
            val label = if (paused) "Resume" else "Pause"
            small.setTextViewText(R.id.azan_pause, label)
            small.setOnClickPendingIntent(R.id.azan_pause, toggle)
            big.setTextViewText(R.id.azan_pause, label)
            big.setOnClickPendingIntent(R.id.azan_pause, toggle)
            big.setOnClickPendingIntent(R.id.azan_stop, stop)
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_waqt)
            .setColor(0xFFD9B26B.toInt())
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(small)
            .setCustomBigContentView(big)
            .setOngoing(!silent)
            .setAutoCancel(silent)
            .setOnlyAlertOnce(true)
            .setFullScreenIntent(open, true)
            .setContentIntent(open)
        if (silent) builder.setDeleteIntent(stop)
        return builder.build()
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

    private fun notificationManager() =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < 26) return
        val manager = notificationManager()
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Azan", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Shown while the Azan is playing or when the phone is silent"
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

    private fun stopAzan(scheduleReminder: Boolean = true) {
        AzanVibration.stop(this)
        releasePlayer()
        stopForeground(STOP_FOREGROUND_REMOVE)
        notificationManager().cancel(NOTIFICATION_ID)
        // Azan ended without "I prayed": keep reminding until it is marked.
        if (scheduleReminder && state != STATE_STOPPED) {
            ReminderScheduler.afterAzan(this, currentName, currentMillis, prayedKey())
        }
        update(STATE_STOPPED)
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
        const val EXTRA_LOG_KEY = "logKey"
        const val ACTION_STOP = "com.fahadapps.waqt.AZAN_STOP"
        const val ACTION_PRAYED = "com.fahadapps.waqt.AZAN_PRAYED"
        const val ACTION_TOGGLE = "com.fahadapps.waqt.AZAN_TOGGLE"
        const val ACTION_REMIND = "com.fahadapps.waqt.AZAN_REMIND"
        const val EXTRA_MINUTES = "minutes"
        const val STATE_STOPPED = "stopped"
        const val STATE_STARTING = "starting"
        const val STATE_PLAYING = "playing"
        const val STATE_PAUSED = "paused"
        const val STATE_SILENT = "silent"
        private const val CHANNEL_ID = "azan_playing_v2"
        private const val NOTIFICATION_ID = 4101

        var state: String = STATE_STOPPED
            private set
        var currentName: String = ""
        var currentMillis: Long = 0L
        var stateListener: ((Map<String, Any>) -> Unit)? = null

        fun isActive(): Boolean = state != STATE_STOPPED

        fun snapshot(): Map<String, Any> =
            mapOf("state" to state, "name" to currentName, "millis" to currentMillis)

        fun update(newState: String) {
            state = newState
            stateListener?.invoke(snapshot())
        }

        fun prepare(name: String, millis: Long) {
            currentName = name
            currentMillis = millis
            update(STATE_STARTING)
        }

        fun prayedKey(): String? {
            if (currentMillis == 0L) return null
            val day = SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH).format(Date(currentMillis))
            val logName = if (currentName == "jummah") "Dhuhr" else currentName
            return "$day|$logName"
        }
    }
}
