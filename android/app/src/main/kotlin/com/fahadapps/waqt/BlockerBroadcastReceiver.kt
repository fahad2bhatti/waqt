package com.fahadapps.waqt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BlockerBroadcastReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_BLOCK_APP = "com.waqt.ACTION_BLOCK_APP"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("PrayerBlocker", "Broadcast received: Block App")
        // The MainActivity will listen for this broadcast and tell Flutter to navigate
    }
}
