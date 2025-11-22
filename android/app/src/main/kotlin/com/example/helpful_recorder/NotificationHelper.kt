package com.example.helpful_recorder

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationHelper(private val context: Context) {

    companion object {
        private const val CHANNEL_ID = "ScreenRecorderChannel"
    }

    fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Screen Recorder Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    fun createNotification(): Notification {
        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("Screen Recorder")
            .setContentText("Recording in progress...")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .build()
    }
}
