

package com.example.muse_wave

import android.annotation.TargetApi
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.app.ForegroundServiceStartNotAllowedException
import io.flutter.Log
import androidx.core.app.NotificationCompat
import com.example.muse_wave.MuseSearchBar

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager

class MuseForegroundService : Service() {

    companion object {
        var service: MuseForegroundService? = null
//        const val CHANNEL_ID = "music_foreground_channel_id"
//        const val NOTIFICATION_ID = 110
    }

    override fun onCreate() {
        super.onCreate()
        service = this

    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 可以在这里更新通知
//        updateNotification()
        val notification = buildNotification()
        try {
            startForeground(MuseSearchBar.SEARCH_BAR_FOREGROUND_ID, notification)
        } catch (e: ForegroundServiceStartNotAllowedException) {
            Log.e("MuseAndroid", "startForeground not allowed: ${e.message}")
            stopSelfResult(startId)
            return START_NOT_STICKY
        } catch (e: Exception) {
            Log.e("MuseAndroid", "startForeground failed", e)
            stopSelfResult(startId)
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        service = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ⚡ 构建通知
    fun buildNotification(): Notification {
       return  MuseSearchBar.get().buildNotification(this)
    }

    // ⚡ 更新通知
    fun updateNotification() {
//        val notification = buildNotification()
//        val manager = getSystemService(NotificationManager::class.java)
//        manager.notify(NOTIFICATION_ID, notification)
    }
}