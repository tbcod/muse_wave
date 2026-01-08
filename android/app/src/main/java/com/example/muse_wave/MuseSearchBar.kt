package com.example.muse_wave

import android.app.Notification
import android.app.NotificationChannel
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import com.example.muse_wave.MainActivity


class MuseSearchBar {

    private var notificationManager: android.app.NotificationManager? = null
    private var mBuilder: NotificationCompat.Builder? = null
    private var largeIconBitmap: Bitmap? = null
    private var notification: Notification? = null

    companion object {
        const val SEARCH_CHANNEL_ID = "MuseSearchBarForegroundChannelId"
        const val SEARCH_BAR_FOREGROUND_ID = 110

        private var manager: MuseSearchBar? = null

        fun get(): MuseSearchBar {
            if (manager == null) {
                manager = MuseSearchBar()
            }
            return manager!!
        }
    }

    fun buildNotification(context: Context): Notification {

        if (notification != null) {
            // 已经创建过，直接返回
            return notification!!
        }

        if (notificationManager == null) {
            notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager?
            largeIconBitmap = BitmapFactory.decodeResource(context.resources, R.mipmap.ic_launcher)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //只在Android O之上需要渠道
            val notificationChannel = NotificationChannel(
                SEARCH_CHANNEL_ID,
                javaClass.simpleName, android.app.NotificationManager.IMPORTANCE_HIGH
            )
            notificationChannel.setShowBadge(false)
            if (notificationManager != null) {
                notificationManager!!.createNotificationChannel(notificationChannel)
            }
        }
        val remoteViews = RemoteViews(context.packageName, R.layout.muse_search_bar)
        val intent = Intent(context, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        intent.putExtra("Arg","ClickSearchBar")

        val pendingIntent = PendingIntent.getActivity(
            context, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )

        mBuilder = NotificationCompat.Builder(context, SEARCH_CHANNEL_ID)
            .setContent(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setContentIntent(pendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .setPriority(Notification.PRIORITY_HIGH)
        notification = mBuilder!!.build()
        notification?.flags = NotificationCompat.FLAG_NO_CLEAR or NotificationCompat.FLAG_ONGOING_EVENT
        notificationManager?.notify(SEARCH_BAR_FOREGROUND_ID, notification!!)

        return notification!!
    }
}