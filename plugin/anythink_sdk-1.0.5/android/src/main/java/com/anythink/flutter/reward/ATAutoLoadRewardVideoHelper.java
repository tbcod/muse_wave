package com.anythink.flutter.reward;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;

//import com.anythink.china.api.ATAppDownloadListener;
import com.anythink.core.api.ATAdInfo;
import com.anythink.core.api.ATAdStatusInfo;
import com.anythink.core.api.ATNetworkConfirmInfo;
import com.anythink.core.api.ATShowConfig;
import com.anythink.core.api.ATAdConst;
//import com.anythink.core.api.ATSDK;
import com.anythink.core.api.AdError;
import com.anythink.flutter.ATFlutterEventManager;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.FlutterPluginUtil;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.flutter.commonlistener.AdRevenueListenerImpl;

import com.anythink.rewardvideo.api.ATRewardVideoAd;
import com.anythink.rewardvideo.api.ATRewardVideoExListener;
import com.anythink.rewardvideo.api.ATRewardVideoAutoAd;
import com.anythink.rewardvideo.api.ATRewardVideoAutoEventListener;
import com.anythink.rewardvideo.api.ATRewardVideoAutoLoadListener;
import com.anythink.flutter.commonlistener.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Collections;
import java.util.HashSet;

public class ATAutoLoadRewardVideoHelper {

    Activity mActivity;
    //当前全自动加载的所有广告位ID
    public Set<String> placementIDs = Collections.synchronizedSet(new HashSet<>());

    private static ATAutoLoadRewardVideoHelper instance;

    private ATAutoLoadRewardVideoHelper() {
        mActivity = FlutterPluginUtil.getActivity();
    }

    public static ATAutoLoadRewardVideoHelper getInstance() {
        if (instance == null) {
            synchronized (ATAutoLoadRewardVideoHelper.class) {
                if (instance == null) {
                    instance = new ATAutoLoadRewardVideoHelper();
                }
            }
        }
        return instance;
    }

    public final ATRewardVideoAutoLoadListener autoLoadListener = new ATRewardVideoAutoLoadListener() {
        @Override
        public void onRewardVideoAutoLoaded(String placementId) {
            MsgTools.printMsg("onRewardVideoAutoLoaded: " + placementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.LoadedCallbackKey,
                    placementId, null, null);
        }

        @Override
        public void onRewardVideoAutoLoadFail(String placementId, AdError adError) {
            MsgTools.printMsg("onRewardVideoAutoLoadFail: " + placementId + ", " + adError.getFullErrorInfo());

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.LoadFailCallbackKey,
                    placementId, null, adError.getFullErrorInfo());
        }
    };

    public final ATRewardVideoAutoEventListener autoEventListener = new ATRewardVideoAutoEventListener() {

        @Override
        public void onRewardedVideoAdPlayStart(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdPlayStart: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.PlayStartCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onRewardedVideoAdPlayEnd(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdPlayEnd: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.PlayEndCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onRewardedVideoAdPlayFailed(AdError adError, ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdPlayFailed: " + mPlacementId + ", " + adError.getFullErrorInfo());

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.PlayFailCallbackKey,
                    mPlacementId, atAdInfo.toString(), adError.getFullErrorInfo());
        }

        @Override
        public void onRewardedVideoAdClosed(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdClosed: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.CloseCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onRewardedVideoAdPlayClicked(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdPlayClicked: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.ClickCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onReward(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onReward: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.RewardCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onRewardFailed(ATAdInfo atAdInfo) {
            //todo
        }

        public void onDeeplinkCallback(ATAdInfo atAdInfo, boolean isSuccess) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("video onDeeplinkCallback: " + mPlacementId);

            Map<String, Object> extraMap = new HashMap<>();
            extraMap.put(Const.CallbackKey.isDeeplinkSuccess, isSuccess);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.DeeplinkCallbackKey,
                    mPlacementId, atAdInfo.toString(), null, extraMap);
        }

        public void onDownloadConfirm(Context context, ATAdInfo atAdInfo, ATNetworkConfirmInfo networkConfirmInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("video onDownloadConfirm: " + mPlacementId);
        }

        //again listener
        public void onRewardedVideoAdAgainPlayStart(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdAgainPlayStart: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.AgainPlayStartCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        public void onRewardedVideoAdAgainPlayEnd(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdAgainPlayEnd: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.AgainPlayEndCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        public void onRewardedVideoAdAgainPlayFailed(AdError adError, ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdAgainPlayFailed: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.AgainPlayFailCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        public void onRewardedVideoAdAgainPlayClicked(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onRewardedVideoAdAgainPlayClicked: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.AgainClickCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        public void onAgainReward(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAgainReward: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.rewardedVideoCall, Const.RewardVideoCallback.AgainRewardCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onAgainRewardFailed(ATAdInfo atAdInfo) {
            //todo
        }
    };

    // 检查给定的placementID是否在集合中
    public boolean containsPlacementID(String placementID) {
        return placementIDs.contains(placementID);
    }

    public void autoLoadRewardedVideo(String[] placementIds) {
        if (placementIds == null && placementIds.length <= 0) {
            MsgTools.printMsg("autoLoadRewardedVideo autoLoadRewardedVideo: The placementIds parameter is null or empty.");
            return;
        }
        for (String id : placementIds) {
            if (!TextUtils.isEmpty(id)) { // 检查元素既不是null也不是空字符串
                MsgTools.printMsg("autoLoadRewardedVideo add: " + id);
                placementIDs.add(id);
            }
        }
        ATRewardVideoAutoAd.init(mActivity, placementIds, autoLoadListener);
        ATRewardVideoAutoAd.addPlacementId(placementIds);
    }

    public void removePlacementId(String[] placementIds) {
        if (placementIds == null && placementIds.length <= 0) {
            // Handle the case where placementIds parameter is null or empty.
            MsgTools.printMsg("autoLoadRewardedVideo removePlacementId: The placementIds parameter is null or empty.");
            return;
        }
        for (String id : placementIds) {
            if (!TextUtils.isEmpty(id)) { // 检查元素既不是null也不是空字符串
                MsgTools.printMsg("autoLoadRewardedVideo remove: " + id);
                placementIDs.remove(id);
            }
        }
        ATRewardVideoAutoAd.removePlacementId(placementIds);
    }

    public void showAutoLoadRewardedVideoAD(final String placementId, final String scenario) {
        String scenceID = scenario;
        if (!TextUtils.isEmpty(scenario)) {
            scenceID = "";
        }
        ATShowConfig.Builder builder = new ATShowConfig.Builder();
        builder.scenarioId(scenceID);
        builder.showCustomExt(null);
        ATRewardVideoAutoAd.show(mActivity, placementId, builder.build(), autoEventListener, new AdRevenueListenerImpl(placementId));
    }

    public void autoLoadRewardedVideoSetLocalExtra(final String placementId,final Map<String, Object> settings) {
        String userId = "";
        String userData = "";
        try {
            if (settings.containsKey(Const.RewardedVideo.USER_ID)) {
                userId = settings.get(Const.RewardedVideo.USER_ID).toString();
                settings.remove(Const.RewardedVideo.USER_ID);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            if (settings.containsKey(Const.RewardedVideo.USER_DATA)) {
                userData = settings.get(Const.RewardedVideo.USER_DATA).toString();
                settings.remove(Const.RewardedVideo.USER_DATA);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        MsgTools.printMsg("autoLoadRewardedVideoSetLocalExtra: " + placementId + ", userId: " + userId + ", userData: " + userData);

        settings.put(ATAdConst.KEY.USER_ID, userId);
        settings.put(ATAdConst.KEY.USER_CUSTOM_DATA, userData);

        ATRewardVideoAutoAd.setLocalExtra(placementId, settings);
    }

    public boolean isAdReady(String placementId) {
        boolean isReady = false;
        if (TextUtils.isEmpty(placementId)) {
            return isReady;
        }
        isReady = ATRewardVideoAutoAd.isAdReady(placementId);
        MsgTools.printMsg("auto load video isAdReady: " + placementId + ", " + isReady);
        return isReady;
    }

    public Map<String, Object> checkAdStatus(String mPlacementId) {
        MsgTools.printMsg("auto load video checkAdStatus: " + mPlacementId);

        Map<String, Object> map = new HashMap<>(5);

        if (TextUtils.isEmpty(mPlacementId)) {
            map.put("isLoading", false);
            map.put("isReady", false);

            return map;
        }

        ATAdStatusInfo atAdStatusInfo = ATRewardVideoAutoAd.checkAdStatus(mPlacementId);
        boolean loading = atAdStatusInfo.isLoading();
        boolean ready = atAdStatusInfo.isReady();
        ATAdInfo atTopAdInfo = atAdStatusInfo.getATTopAdInfo();

        map.put("isLoading", loading);
        map.put("isReady", ready);

        if (atTopAdInfo != null) {
            map.put("adInfo", atTopAdInfo.toString());
        }

        return map;
    }

    public String checkValidAdCaches(String mPlacementId) {
        MsgTools.printMsg("auto load video checkValidAdCaches: " + mPlacementId);

        if (TextUtils.isEmpty(mPlacementId)) {
            return "";
        }

        List<ATAdInfo> vaildAds = ATRewardVideoAutoAd.checkValidAdCaches(mPlacementId);
        if (vaildAds == null) {
            return "";
        }

        JSONArray jsonArray = new JSONArray();

        int size = vaildAds.size();
        for (int i = 0; i < size; i++) {
            try {
                jsonArray.put(new JSONObject(vaildAds.get(i).toString()));
            } catch (Throwable e) {
                e.printStackTrace();
            }
        }
        return jsonArray.toString();
    }

    public void entryScenario(final String placementId,final String sceneID) {
        if (TextUtils.isEmpty(placementId)) {
            MsgTools.printMsg("auto load video entryRewardVideoScenario empty placementId");
            return;
        }
        MsgTools.printMsg("auto load video entryRewardVideoScenario: " + placementId + "sceneID: " + sceneID);
        ATRewardVideoAutoAd.entryAdScenario(placementId, sceneID);
    }
}



