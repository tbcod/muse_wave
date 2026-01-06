package com.example.muse_wave

import com.ryanheise.audioservice.AudioServiceActivity


//import io.flutter.Log
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.os.Bundle
import android.util.Log
import com.example.muse_wave.MuseNativePageAd
import com.example.muse_wave.MuseNativeAdmobAd
import com.example.muse_wave.MuseSearchBar
import android.content.ServiceConnection
import android.content.ComponentName
import android.content.Intent
import android.os.IBinder
import android.os.Build

class MainActivity : AudioServiceActivity(), MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel

    private var isFBInitFinished = false

    private lateinit var fbAppEventsLogger: AppEventsLogger

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (flutterEngine != null) {
            methodChannel =
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "player.musicmuse.nativemethod")
            methodChannel.setMethodCallHandler(this)
        }

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "admob_full_native",
            MuseNativeAdmobAd(applicationContext)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "admob_page_native",
            MuseNativePageAd(applicationContext)
        )
        handleIntent(intent)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method.equals("initFacebook")) {
            val appId = call.argument("fbid") as String?
            val token = call.argument("fbtoken") as String?
            if (token != null && appId != null) {
                initFacebookSdk(appId, token)
            }
            result.success(true)
        } else if (call.method.equals("startSearchNotificationBarService")) {
            Log.i("MuseAndroid", "startSearchNotificationBarService")
            val intent = Intent(this, MuseForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            result.success(null)
        } else {
            result.success(false)
        }
    }


    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        val value = intent.getStringExtra("Arg")
        Log.i("MuseAndroid", "onNewIntent Foreground service start with value = $value")
        if (value == "ClickSearchBar") {
            methodChannel.invokeMethod("ForegroundToSearchPage", emptyMap<String, String>())
        }
    }

    private fun initFacebookSdk(appId: String, token: String) {
        FacebookSdk.setApplicationId(appId)
        FacebookSdk.setClientToken(token)
        FacebookSdk.sdkInitialize(applicationContext)
        isFBInitFinished = FacebookSdk.isInitialized()
        if (isFBInitFinished) {
            fbAppEventsLogger = AppEventsLogger.newLogger(applicationContext)
        }
        Log.i("MuseAndroid", "android facebook sdk init res：$isFBInitFinished, $appId, $token")
    }


}
