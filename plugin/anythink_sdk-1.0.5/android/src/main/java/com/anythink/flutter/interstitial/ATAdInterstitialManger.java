package com.anythink.flutter.interstitial;

import androidx.annotation.NonNull;
import android.text.TextUtils;

import com.anythink.flutter.HandleAnyThinkMethod;
import com.anythink.flutter.utils.Const;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Collections;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.anythink.flutter.utils.MsgTools;

public class ATAdInterstitialManger implements HandleAnyThinkMethod {
    static Map<String, ATInterstitialHelper> pidHelperMap = new ConcurrentHashMap<>();

    private static class SingletonClassInstance {
        private static final ATAdInterstitialManger instance = new ATAdInterstitialManger();
    }

    private ATAdInterstitialManger() {
    }

    public static ATAdInterstitialManger getInstance() {
        return SingletonClassInstance.instance;
    }

    @Override
    public boolean handleMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        String placementID = methodCall.argument(Const.PLACEMENT_ID);
        String placementIDs = methodCall.argument(Const.PLACEMENT_ID_Multi);

        String[] placementIdArr = null;

        boolean isAutoFlag = false;

        if (!TextUtils.isEmpty(placementID) && ATAutoLoadInterstitialHelper.getInstance().containsPlacementID(placementID)) {
            //全自动加载的操作
            isAutoFlag = true;
            placementIdArr = new String[1];
            placementIdArr[0] = placementID;
        }
        if (TextUtils.isEmpty(placementID) && !TextUtils.isEmpty(placementIDs)) {
            //全自动加载的操作
            isAutoFlag = true;
            placementIdArr = placementIDs.split("\\s*,\\s*");
        }

        if (isAutoFlag) {
            routeAutoLoad(placementIdArr,methodCall,result);
        }else {
            routeNormal(placementID,methodCall,result);
        }

        return true;
    }

    private void routeNormal(String placementID, @NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        if (TextUtils.isEmpty(placementID)) {
            MsgTools.printMsg("ATAdInterstitialManger routeNormal: The placementID parameter is null or empty.");
            return;
        }

        ATInterstitialHelper helper = getHelper(placementID);
        Map<String, Object> settingMap = methodCall.argument(Const.EXTRA_DIC);

        switch (methodCall.method) {
            case "loadInterstitialAd":
                if (helper != null) {
                    helper.loadInterstitial(placementID, settingMap);
                }
                break;
            case "showInterstitialAd":
                if (helper != null) {
                    helper.showInterstitialAd("");
                }
                break;
            case "showSceneInterstitialAd":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.showInterstitialAd(scenario);
                }
                break;
            case "showInterstitialAdWithShowConfig":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    String showCustomExt = methodCall.argument(Const.SHOW_CUSTOM_EXT);
                    helper.showConfigInterstitialAd(scenario,showCustomExt);
                }
                break;
            case "hasInterstitialAdReady":
                if (helper != null) {
                    boolean adReady = helper.isAdReady();
                    result.success(adReady);
                } else {
                    result.success(false);
                }
                break;
            case "getInterstitialValidAds":
                if (helper != null) {
                    String s = helper.checkValidAdCaches();
                    result.success(s);
                } else {
                    result.success("");
                }
                break;
            case "checkInterstitialLoadStatus":
                if (helper != null) {
                    Map<String, Object> map = helper.checkAdStatus();
                    result.success(map);
                } else {
                    result.success(new HashMap<String, Object>(1));
                }
                break;
            case "entryInterstitialScenario":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.entryScenario(placementID,scenario);
                }
                break;
        }
    }

    private void routeAutoLoad(String[] placementIDArr,@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        ATAutoLoadInterstitialHelper helper = ATAutoLoadInterstitialHelper.getInstance();

        String placementID = placementIDArr[0];
        String scenario = methodCall.argument(Const.SCENE_ID);

        switch (methodCall.method) {
            case "hasInterstitialAdReady":
                boolean adReady = helper.isAdReady(placementID);
                result.success(adReady);
                break;
            case "checkInterstitialLoadStatus":
                Map<String, Object> map = helper.checkAdStatus(placementID);
                result.success(map);
                break;
            case "getInterstitialValidAds":
                String s = helper.checkValidAdCaches(placementID);
                result.success(s);
                break;
            case "entryInterstitialScenario":
                helper.entryScenario(placementID,scenario);
                break;
            case "autoLoadInterstitialAD":
                if (helper != null) {
                    helper.autoLoadInterstitial(placementIDArr);
                }
                break;
            case "cancelAutoLoadInterstitialAD":
                if (helper != null) {
                    helper.removePlacementId(placementIDArr);
                }
                break;
            case "showAutoLoadInterstitialAD":
                if (helper != null) {
                    helper.showAutoLoadInterstitialAD(placementID,scenario);
                }
                break;
            case "autoLoadInterstitialADSetLocalExtra":
                if (helper != null) {
                    Map<String, Object> settingMap = methodCall.argument(Const.EXTRA_DIC);
                    helper.autoLoadInterstitialSetLocalExtra(placementID,settingMap);
                }
                break;
        }
    }

    private ATInterstitialHelper getHelper(String placementId) {
        ATInterstitialHelper helper;

        if (!pidHelperMap.containsKey(placementId)) {
            helper = new ATInterstitialHelper();
            pidHelperMap.put(placementId, helper);
        } else {
            helper = pidHelperMap.get(placementId);
        }
        return helper;
    }
}
