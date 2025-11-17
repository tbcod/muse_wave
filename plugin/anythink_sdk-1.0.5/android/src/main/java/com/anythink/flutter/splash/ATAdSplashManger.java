package com.anythink.flutter.splash;

import androidx.annotation.NonNull;

import com.anythink.flutter.HandleAnyThinkMethod;
import com.anythink.flutter.utils.Const;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ATAdSplashManger implements HandleAnyThinkMethod {
    Map<String, ATSplashHelper> pidHelperMap = new ConcurrentHashMap<>();


    private static class SingletonClassInstance {
        private static final ATAdSplashManger instance = new ATAdSplashManger();
    }

    private ATAdSplashManger() {
    }

    public static ATAdSplashManger getInstance() {
        return SingletonClassInstance.instance;
    }

    @Override
    public boolean handleMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        String placementID = methodCall.argument(Const.PLACEMENT_ID);
        ATSplashHelper helper = getHelper(placementID);
        Log.d("！！ handleMethodCall", "placementID: " + methodCall.method);
        switch (methodCall.method) {
            case "loadSplash":
                if (helper != null) {
                    Map<String, Object> settingMap = methodCall.argument(Const.EXTRA_DIC);

                    helper.loadSplash(placementID, settingMap);
                }
                break;
            case "showSplash":
                Log.d("！！ showSplash", "placementID: " + placementID);
                if (helper != null) {
                    helper.showSplash("");
                }
                break;
            case "showSceneSplash":
                Log.d("！！ showSceneSplash", "placementID: " + placementID);
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.showSplash(scenario);
                }
                break;
            case "showSplashAdWithShowConfig":
                Log.d("！！ showSplashAdWithShowConfig", "placementID: " + placementID);
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    String showCustomExt = methodCall.argument(Const.SHOW_CUSTOM_EXT);
                    Log.d("showSplashAdWithShowConfig", "sceneId: " + scenario + ", showCustomExt: " + showCustomExt);
                    helper.showConfigSplash(scenario,showCustomExt);
                }
                break;
            case "splashReady":
                if (helper != null) {
                    boolean adReady = helper.isAdReady();
                    result.success(adReady);
                } else {
                    result.success(false);
                }
                break;
            case "checkSplashLoadStatus":
                if (helper != null) {
                    Map<String, Object> map = helper.checkAdStatus();
                    result.success(map);
                } else {
                    result.success(new HashMap<String, Object>(1));
                }
                break;
            case "getSplashValidAds":
                if (helper != null) {
                    String s = helper.checkValidAdCaches();
                    result.success(s);
                } else {
                    result.success("");
                }
                break;
            case "entrySplashScenario":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.entryScenario(placementID,scenario);
                }
                break;
        }
        return true;
    }

    private ATSplashHelper getHelper(String placementId) {

        ATSplashHelper helper;

        if (!pidHelperMap.containsKey(placementId)) {
            helper = new ATSplashHelper();
            pidHelperMap.put(placementId, helper);
        } else {
            helper = pidHelperMap.get(placementId);
        }

        return helper;
    }

}
