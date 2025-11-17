package com.anythink.flutter.reward;

import androidx.annotation.NonNull;
import android.text.TextUtils;

import com.anythink.flutter.HandleAnyThinkMethod;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.MsgTools;

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

import com.anythink.flutter.reward.ATAutoLoadRewardVideoHelper;

public class ATAdRewardVideoManger implements HandleAnyThinkMethod {

    Map<String, ATRewardVideoHelper> pidHelperMap = new ConcurrentHashMap<>();

    private static class SingletonClassInstance {
        private static final ATAdRewardVideoManger instance = new ATAdRewardVideoManger();
    }

    private ATAdRewardVideoManger() {
    }

    public static ATAdRewardVideoManger getInstance() {
        return SingletonClassInstance.instance;
    }

    @Override
    public boolean handleMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        String placementID = methodCall.argument(Const.PLACEMENT_ID);
        String placementIDs = methodCall.argument(Const.PLACEMENT_ID_Multi);

        String[] placementIdArr = null;

        boolean isAutoFlag = false;

        if (!TextUtils.isEmpty(placementID) && ATAutoLoadRewardVideoHelper.getInstance().containsPlacementID(placementID)) {
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

    private ATRewardVideoHelper getHelper(String placementId) {

        ATRewardVideoHelper helper;

        if (!pidHelperMap.containsKey(placementId)) {
            helper = new ATRewardVideoHelper();
            pidHelperMap.put(placementId, helper);
        } else {
            helper = pidHelperMap.get(placementId);
        }

        return helper;
    }

    private void routeNormal(String placementID, @NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        if (TextUtils.isEmpty(placementID)) {
            MsgTools.printMsg("ATAdRewardVideoManger routeNormal: The placementID parameter is null or empty.");
            return;
        }

        ATRewardVideoHelper helper = getHelper(placementID);

        switch (methodCall.method) {
            case "loadRewardedVideo":
                if (helper != null) {
                    Map<String, Object> settingMap = methodCall.argument(Const.EXTRA_DIC);

                    helper.loadRewardedVideo(placementID, settingMap);
                }
                break;
            case "showRewardedVideo":
                if (helper != null) {
                    helper.showRewardedVideo("");
                }
                break;
            case "showSceneRewardedVideo":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.showRewardedVideo(scenario);
                }
                break;
            case "showRewardedVideoWithShowConfig":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    String showCustomExt = methodCall.argument(Const.SHOW_CUSTOM_EXT);
                    helper.showConfigRewardedVideo(scenario,showCustomExt);
                }
                break;
            case "rewardedVideoReady":
                if (helper != null) {
                    boolean adReady = helper.isAdReady();
                    result.success(adReady);
                } else {
                    result.success(false);
                }
                break;
            case "checkRewardedVideoLoadStatus":
                if (helper != null) {
                    Map<String, Object> map = helper.checkAdStatus();
                    result.success(map);
                } else {
                    result.success(new HashMap<String, Object>(1));
                }
                break;
            case "getRewardedVideoValidAds":
                if (helper != null) {
                    String s = helper.checkValidAdCaches();
                    result.success(s);
                } else {
                    result.success("");
                }
                break;
            case "entryRewardedVideoScenario":
                if (helper != null) {
                    String scenario = methodCall.argument(Const.SCENE_ID);
                    helper.entryScenario(placementID,scenario);
                }
                break;
        }
    }

    private void routeAutoLoad(String[] placementIDArr,@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {

        ATAutoLoadRewardVideoHelper helper = ATAutoLoadRewardVideoHelper.getInstance();

        String placementID = placementIDArr[0];
        String scenario = methodCall.argument(Const.SCENE_ID);

        switch (methodCall.method) {
            case "rewardedVideoReady":
                boolean adReady = helper.isAdReady(placementID);
                result.success(adReady);
                break;
            case "checkRewardedVideoLoadStatus":
                Map<String, Object> map = helper.checkAdStatus(placementID);
                result.success(map);
                break;
            case "getRewardedVideoValidAds":
                String s = helper.checkValidAdCaches(placementID);
                result.success(s);
                break;
            case "entryRewardedVideoScenario":
                helper.entryScenario(placementID,scenario);
                break;
            case "autoLoadRewardedVideoAD":
                if (helper != null) {
                    helper.autoLoadRewardedVideo(placementIDArr);
                }
                break;
            case "cancelAutoLoadRewardedVideoAD":
                if (helper != null) {
                    helper.removePlacementId(placementIDArr);
                }
                break;
            case "showAutoLoadRewardedVideoAD":
                if (helper != null) {
                    helper.showAutoLoadRewardedVideoAD(placementID,scenario);
                }
                break;
            case "autoLoadRewardedVideoADSetLocalExtra":
                if (helper != null) {
                    Map<String, Object> settingMap = methodCall.argument(Const.EXTRA_DIC);
                    helper.autoLoadRewardedVideoSetLocalExtra(placementID,settingMap);
                }
                break;
        }
    }
}
