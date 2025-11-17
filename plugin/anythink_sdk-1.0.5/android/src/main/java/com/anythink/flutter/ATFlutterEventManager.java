package com.anythink.flutter;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.anythink.flutter.banner.ATAdBannerManger;
import com.anythink.flutter.init.ATAdInitManger;
import com.anythink.flutter.interstitial.ATAdInterstitialManger;
import com.anythink.flutter.nativead.ATAdNativeManger;
import com.anythink.flutter.reward.ATAdRewardVideoManger;
import com.anythink.flutter.splash.ATAdSplashManger;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.FlutterPluginUtil;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.flutter.utils.Utils;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ATFlutterEventManager {

    private static ATFlutterEventManager sInstance;

    private MethodChannel mMethodChannel;

    private ATFlutterEventManager() {

    }

    public synchronized static ATFlutterEventManager getInstance() {
        if (sInstance == null) {
            sInstance = new ATFlutterEventManager();
        }
        return sInstance;
    }

    public void init(BinaryMessenger binaryMessenger) {
        if (mMethodChannel == null) {
            mMethodChannel = new MethodChannel(binaryMessenger, "anythink_sdk");
            mMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
                    //receive message from flutter
                    try {
                        if (Utils.checkMethodInArray(Const.initMethodNames, methodCall.method)) {
                            ATAdInitManger.getInstance().handleMethodCall(methodCall, result);
                        } else if (Utils.checkMethodInArray(Const.rewardVideoMethodNames, methodCall.method)) {
                            ATAdRewardVideoManger.getInstance().handleMethodCall(methodCall, result);
                        } else if (Utils.checkMethodInArray(Const.interstitialMethodNames, methodCall.method)) {
                            ATAdInterstitialManger.getInstance().handleMethodCall(methodCall, result);
                        } else if (Utils.checkMethodInArray(Const.bannerMethodNames, methodCall.method)) {
                            ATAdBannerManger.getInstance().handleMethodCall(methodCall, result);
                        } else if (Utils.checkMethodInArray(Const.nativeMethodNames, methodCall.method)) {
                            ATAdNativeManger.getInstance().handleMethodCall(methodCall, result);
                        } else if (Utils.checkMethodInArray(Const.splashMethodNames, methodCall.method)) {
                            ATAdSplashManger.getInstance().handleMethodCall(methodCall, result);
                        }

                    } catch (Throwable e) {
                        MsgTools.printMsg("method call error: " + methodCall + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });
        }

    }

    public void sendDownloadMsgToFlutter(final String callName, String callbackName, String placementId, String atAdInfoString,
                                         long totalBytes, long currBytes, String fileName, String appName) {

        try {
            final Map<String, Object> paramsMap = new HashMap<>(10);
            paramsMap.put("callbackName", callbackName);
            paramsMap.put("placementID", placementId);

            if (atAdInfoString != null) {
                paramsMap.put("extraDic", Utils.jsonStrToMap(atAdInfoString));
            }

            if (totalBytes > 0) {
                paramsMap.put("totalBytes", totalBytes);
            }
            if (currBytes > 0) {
                paramsMap.put("currBytes", currBytes);
            }
            if (fileName != null) {
                paramsMap.put("fileName", fileName);
            }
            if (appName != null) {
                paramsMap.put("appName", appName);
            }

            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter invokeMethod error: " + callName + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });

        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter error: " + callbackName + ", " + e.getMessage());
            e.printStackTrace();
        }
    }


    public void sendCallbackMsgToFlutter(final String callName, String callbackName, String placementId, String atAdInfoString, String errorMsg, Map<String, Object> extra) {

        try {
            final Map<String, Object> paramsMap = new HashMap<>(8);
            paramsMap.put(Const.CallbackKey.callbackName, callbackName);
            paramsMap.put(Const.CallbackKey.placementID, placementId);

            if (atAdInfoString != null) {
                paramsMap.put(Const.CallbackKey.extraDic, Utils.jsonStrToMap(atAdInfoString));
            }

            if (errorMsg != null) {
                paramsMap.put(Const.CallbackKey.requestMessage, errorMsg);
            } else {
                paramsMap.put(Const.CallbackKey.requestMessage, "");
            }

            try {
                if (extra != null) {
                    Set<Map.Entry<String, Object>> entries = extra.entrySet();
                    for (Map.Entry<String, Object> entry : entries) {
                        String key = entry.getKey();
                        Object value = entry.getValue();

                        if (value instanceof Boolean) {
                            if (TextUtils.equals(key, Const.CallbackKey.isDeeplinkSuccess) || TextUtils.equals(key, Const.CallbackKey.isTimeout)) {
                                paramsMap.put(key, ((Boolean) value));
                            }
                        }
                    }
                }
            } catch (Throwable e) {
                e.printStackTrace();
            }

            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter invokeMethod error: " + callName + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });

        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter error: " + callbackName + ", " + e.getMessage());
            e.printStackTrace();
        }
    }


    /**
     * send message to flutter
     */
    public void sendCallbackMsgToFlutter(String callName, String callbackName, String placementId, String atAdInfoString, String errorMsg) {
        this.sendCallbackMsgToFlutter(callName, callbackName, placementId, atAdInfoString, errorMsg, null);
    }


    /**
     * send message to flutter
     */
    public void sendMsgToFlutter(final String callName, String key, Object extra) {
        try {
            final Map<String, Object> paramsMap = new HashMap<>(4);
            paramsMap.put(key, extra);


            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendMsgToFlutter invokeMethod error: " + key + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });
        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendMsgToFlutter error: " + key + ", " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void release() {
        if (mMethodChannel != null) {
            mMethodChannel.setMethodCallHandler(null);
            mMethodChannel = null;
        }
    }

}
