package com.example.waveandsosa

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import va.us.ass.Jii
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import android.app.Activity
import android.content.Context
import java.io.File
import android.view.ViewGroup


/** WaveandsosaPlugin */
class WaveandsosaPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var activity: Activity? = null
    private var context: Context? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.wave.and.sosa")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android version: ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "bbGo") {
            val name = context?.packageName
            val file = File("/data/data/$name/wac")
            println("【WavePlugin】packageName：$name")
            if (!file.exists()) {
//                println("【WavePlugin】开始创建文件")
                try {
                    file.createNewFile()
                } catch (e: Throwable) {
                    e.printStackTrace()
                }
            }
            if (!file.exists()) {
//                println("【WavePlugin】文件不存在不存在不存在！！！")
                result.success(false)
            } else {
                Jii.dmsMia(activity,6)
                println("【WavePlugin】bbGo 开始so ")
                result.success(true)
            }
        } else if (call.method == "bbStop") {
            result.success(true)
        } else if (call.method == "startPP") {
            val packageName = context?.packageName
            println("【WavePlugin】startPP packageName：$packageName")
            result.success(true)
        } else if (call.method == "endPP") {
            var version = call.argument<String>("version")
            println("【WavePlugin】endPP version：$version")
            result.success(version)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
//        println("【WavePlugin】开始释放onDetachedFromActivity")
        Jii.sdVV(37)
        val activity = this.activity
        if (activity != null) {
            try {
                (activity.window.decorView as? ViewGroup)?.removeAllViews()
            } catch (e: Throwable) {
                // 异常处理
//                println("【WavePlugin】onDetachedFromActivity：${e.toString()}")
            }
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Activity 因配置更改重新绑定
//        onAttachedToActivity(binding)
//        println("【WavePlugin】onReattachedToActivityForConfigChanges")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//        println("【WavePlugin】onAttachedToActivity")
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Activity 因配置更改（如屏幕旋转）分离
//        onDetachedFromActivity()
//        println("【WavePlugin】onDetachedFromActivityForConfigChanges")
    }


}
