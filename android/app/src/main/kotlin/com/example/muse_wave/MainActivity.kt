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
//        val factoryIds = listOf("admob_full_native")
//        for (id in factoryIds) {
//            GoogleMobileAdsPlugin.registerNativeAdFactory(
//                flutterEngine,
//                id,
//                MuseNativeAdmobAd(applicationContext)
//            )
//        }

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
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method.equals("initFacebook")) {
            val appId = call.argument("fbid") as String?
            val token = call.argument("fbtoken") as String?
            if (token != null && appId != null) {
                initFacebookSdk(appId, token)
            }
            result.success(true)
        } else {
            result.success(false)
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
        Log.i("MuseAndroid",  "android facebook sdk init res：$isFBInitFinished, $appId, $token")
    }


}
