package com.example.muse_wave

import com.ryanheise.audioservice.AudioServiceActivity

import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.app.ForegroundServiceStartNotAllowedException
import android.os.Bundle
import android.util.Log
//import com.example.muse_wave.MuseNativePageAd
import com.example.muse_wave.MuseNativeAdmobAd
import com.example.muse_wave.MuseSearchBar
import android.content.ServiceConnection
import android.content.ComponentName
import android.content.Intent
import android.os.IBinder
import android.os.Build
import java.util.Currency
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.lifecycle.Lifecycle

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
//        GoogleMobileAdsPlugin.registerNativeAdFactory(
//            flutterEngine,
//            "admob_page_native",
//            MuseNativePageAd(applicationContext)
//        )
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
            if (!isAppForeground()) {
                Log.w("MuseAndroid", "Skip startSearchNotificationBarService: app is background")
                result.success(null)
                return
            }
            try {
                val intent = Intent(this, MuseForegroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent)
                } else {
                    startService(intent)
                }
            } catch (e: ForegroundServiceStartNotAllowedException) {
                Log.e("MuseAndroid", "Foreground service start not allowed: ${e.message}")
            } catch (e: Exception) {
                Log.e("MuseAndroid", "Failed to start search foreground service", e)
            }
            result.success(null)
        }else if (call.method.equals("facebookLogPurchase")) {
            logPurchaseEventForFacebook(call, result)
        }  else if (call.method.equals("facebookLogEvent")) {
            logEventForFacebook(call, result)
        }  else {
            result.success(false)
        }
    }

    fun isAppForeground(): Boolean {
        return ProcessLifecycleOwner.get()
            .lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)
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
            Log.i("MuseAndroid", "Facebook initFacebookSdk res：$isFBInitFinished, $appId, $token")
        }else{
            Log.e("MuseAndroid", "Facebook initFacebookSdk res：$isFBInitFinished, $appId, $token")
        }
    }


        private fun logEventForFacebook(call: MethodCall, result: MethodChannel.Result) {
        if (isFBInitFinished) {
            val eventName = call.argument("name") as? String
            val valueToSum = call.argument("_valueToSum") as? Double
            val parameters = call.argument("parameters") as? Map<String, Any>
            if (valueToSum != null && parameters != null) {
                val parameterBundle = createBundleFromFacebookMap(parameters)
                fbAppEventsLogger.logEvent(eventName, valueToSum, parameterBundle)
            } else if (valueToSum != null) {
                fbAppEventsLogger.logEvent(eventName, valueToSum)
            } else if (parameters != null) {
                val parameterBundle = createBundleFromFacebookMap(parameters)
                fbAppEventsLogger.logEvent(eventName, parameterBundle)
            } else {
                fbAppEventsLogger.logEvent(eventName)
            }
            Log.i("MuseAndroid", "Facebook logEventForFacebook：$$eventName, $isFBInitFinished")
        }else{
            Log.e("MuseAndroid", "Facebook logEventForFacebook isFBInitFinished: $isFBInitFinished")
        }
        result.success(isFBInitFinished)
    }

    private fun logPurchaseEventForFacebook(call: MethodCall, result: MethodChannel.Result) {
        if (isFBInitFinished) {
            val parameters = call.argument("parameters") as? Map<String, Any>
            val parameterBundle = createBundleFromFacebookMap(parameters) ?: Bundle()
            var amount = (call.argument("amount") as? Double)?.toBigDecimal()
            var currency = Currency.getInstance(call.argument("currency") as? String)
            fbAppEventsLogger.logPurchase(amount, currency, parameterBundle)
            Log.i("MuseAndroid", "Facebook Purchase amount：$amount, $currency")
        }else{
            Log.e("MuseAndroid", "Facebook Purchase isFBInitFinished:$isFBInitFinished")
        }

        result.success(isFBInitFinished)
    }

    private fun createBundleFromFacebookMap(parameterMap: Map<String, Any>?): Bundle? {
        if (parameterMap == null) {
            return null
        }
        val bundle = Bundle()
        for (jsonParam in parameterMap.entries) {
            val value = jsonParam.value
            val key = jsonParam.key
            when (value) {
                is Map<*, *> -> {
                    val nestedBundle = createBundleFromFacebookMap(value as Map<String, Any>)
                    bundle.putBundle(key, nestedBundle as Bundle)
                }
                is String -> {
                    bundle.putString(key, value as String)
                }
                is Int -> {
                    bundle.putInt(key, value as Int)
                }
                is Long -> {
                    bundle.putLong(key, value as Long)
                }
                is Double -> {
                    bundle.putDouble(key, value as Double)
                }
                is Boolean -> {
                    bundle.putBoolean(key, value as Boolean)
                }
                else -> {
                    throw IllegalArgumentException(
                        "IllegalArgumentException value type: " + value.javaClass.kotlin
                    )
                }
            }
        }
        return bundle
    }

}
