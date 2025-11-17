package com.anythink.flutter.interstitial;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;

//import com.anythink.china.api.ATAppDownloadListener;
import com.anythink.core.api.ATAdInfo;
import com.anythink.core.api.ATAdStatusInfo;
import com.anythink.core.api.ATNetworkConfirmInfo;
import com.anythink.core.api.ATShowConfig;
//import com.anythink.core.api.ATSDK;
import com.anythink.core.api.AdError;
import com.anythink.flutter.ATFlutterEventManager;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.FlutterPluginUtil;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.flutter.commonlistener.AdRevenueListenerImpl;

import com.anythink.interstitial.api.ATInterstitial;
import com.anythink.interstitial.api.ATInterstitialAutoAd;
import com.anythink.interstitial.api.ATInterstitialAutoEventListener;
import com.anythink.interstitial.api.ATInterstitialAutoLoadListener;
import com.anythink.interstitial.api.ATInterstitialExListener;
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

public class ATAutoLoadInterstitialHelper {

    Activity mActivity;
    //当前全自动加载的所有广告位ID
    public Set<String> placementIDs = Collections.synchronizedSet(new HashSet<>());
    // 使用Map存储每个placementID对应的settingMap
    private final Map<String, Map<String, Object>> placementSettings = new HashMap<>();

    private static ATAutoLoadInterstitialHelper instance;

    private ATAutoLoadInterstitialHelper() {
        mActivity = FlutterPluginUtil.getActivity();
    }

    public static ATAutoLoadInterstitialHelper getInstance() {
        if (instance == null) {
            synchronized (ATAutoLoadInterstitialHelper.class) {
                if (instance == null) {
                    instance = new ATAutoLoadInterstitialHelper();
                }
            }
        }
        return instance;
    }

    public final ATInterstitialAutoLoadListener autoLoadListener = new ATInterstitialAutoLoadListener() {
        @Override
        public void onInterstitialAutoLoaded(String placementId) {
            MsgTools.printMsg("onInterstitialAutoLoaded: " + placementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.LoadedCallbackKey,
                    placementId, null, null);
        }

        @Override
        public void onInterstitialAutoLoadFail(String placementId, AdError adError) {
            MsgTools.printMsg("onInterstitialAutoLoadFail: " + placementId + ", " + adError.getFullErrorInfo());

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.LoadFailCallbackKey,
                    placementId, null, adError.getFullErrorInfo());
        }
    };

    public final ATInterstitialAutoEventListener autoEventListener = new ATInterstitialAutoEventListener() {

        @Override
        public void onInterstitialAdClicked(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAutoInterstitialAdClicked: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.ClickCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onInterstitialAdShow(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAutoInterstitialAdShow: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.ShowCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onInterstitialAdClose(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAutoInterstitialAdClose: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.CloseCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onInterstitialAdVideoStart(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAutoInterstitialAdVideoStart: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.PlayStartCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onInterstitialAdVideoEnd(ATAdInfo atAdInfo) {
            String mPlacementId = atAdInfo.getPlacementId();
            MsgTools.printMsg("onAutoInterstitialAdVideoEnd: " + mPlacementId);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.PlayEndCallbackKey,
                    mPlacementId, atAdInfo.toString(), null);
        }

        @Override
        public void onInterstitialAdVideoError(AdError adError) {
            MsgTools.printMsg("onAutoInterstitialAdVideoError: " + adError.getFullErrorInfo());

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.PlayFailCallbackKey,
                    null, null, adError.getFullErrorInfo());
        }

        public void onDeeplinkCallback(ATAdInfo atAdInfo, boolean isSuccess) {
            String mPlacementId = atAdInfo.getPlacementId();

            Map<String, Object> extraMap = new HashMap<>();
            extraMap.put(Const.CallbackKey.isDeeplinkSuccess, isSuccess);

            MsgTools.printMsg("onAutoDeeplinkCallback: " + mPlacementId + "isSuccess" + isSuccess);

            ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                    Const.CallbackMethodCall.InterstitialCall, Const.InterstitialCallback.DeeplinkCallbackKey,
                    mPlacementId, atAdInfo.toString(), null, extraMap);
        }

        public void onDownloadConfirm(Context context, ATAdInfo atAdInfo, ATNetworkConfirmInfo networkConfirmInfo) {

        }
    };

    // 检查给定的placementID是否在集合中
    public boolean containsPlacementID(String placementID) {
        return placementIDs.contains(placementID);
    }

    public void autoLoadInterstitial(String[] placementIds) {
        if (placementIds == null && placementIds.length <= 0) {
            MsgTools.printMsg("autoLoadInterstitial autoLoadInterstitial: The placementIds parameter is null or empty.");
            return;
        }
        for (String id : placementIds) {
            if (!TextUtils.isEmpty(id)) { // 检查元素既不是null也不是空字符串
                MsgTools.printMsg("autoLoadInterstitial add: " + id);
                placementIDs.add(id);
            }
        }
        ATInterstitialAutoAd.init(mActivity, placementIds, autoLoadListener);
        ATInterstitialAutoAd.addPlacementId(placementIds);
    }

    public void removePlacementId(String[] placementIds) {
        if (placementIds == null && placementIds.length <= 0) {
            // Handle the case where placementIds parameter is null or empty.
            MsgTools.printMsg("autoLoadInterstitial removePlacementId: The placementIds parameter is null or empty.");
            return;
        }
        for (String id : placementIds) {
            if (!TextUtils.isEmpty(id)) { // 检查元素既不是null也不是空字符串
                MsgTools.printMsg("autoLoadInterstitial remove: " + id);
                placementIDs.remove(id);
            }
        }
        ATInterstitialAutoAd.removePlacementId(placementIds);
    }

    public void showAutoLoadInterstitialAD(final String placementId, final String scenario) {

        String showCustomExt = null;

        try {
            Map<String, Object> settings = placementSettings.get(placementId);
            if (settings.containsKey(Const.Interstitial.SHOW_CUSTOM_EXT)) {
                showCustomExt = settings.get(Const.Interstitial.SHOW_CUSTOM_EXT).toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        String scenarioID = scenario;
        if (!TextUtils.isEmpty(scenarioID)) {
            scenarioID = "";
        }
        ATShowConfig.Builder builder = new ATShowConfig.Builder();
        builder.scenarioId(scenarioID);
        builder.showCustomExt(showCustomExt);
        MsgTools.printMsg("auto load inter showAutoLoadInterstitialAD: " + placementId + ", " + scenarioID + "， " +showCustomExt);
        ATInterstitialAutoAd.show(mActivity, placementId, builder.build(), autoEventListener, new AdRevenueListenerImpl(placementId));
    }

    public boolean isAdReady(String placementId) {
        boolean isReady = false;
        if (TextUtils.isEmpty(placementId)) {
            return isReady;
        }
        isReady = ATInterstitialAutoAd.isAdReady(placementId);
        MsgTools.printMsg("auto load inter isAdReady: " + placementId + ", " + isReady);
        return isReady;
    }

    public Map<String, Object> checkAdStatus(String mPlacementId) {
        MsgTools.printMsg("auto load inter checkAdStatus: " + mPlacementId);

        Map<String, Object> map = new HashMap<>(5);

        if (TextUtils.isEmpty(mPlacementId)) {
            map.put("isLoading", false);
            map.put("isReady", false);

            return map;
        }

        ATAdStatusInfo atAdStatusInfo = ATInterstitialAutoAd.checkAdStatus(mPlacementId);
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
        MsgTools.printMsg("auto load inter checkValidAdCaches: " + mPlacementId);

        if (TextUtils.isEmpty(mPlacementId)) {
            return "";
        }

        List<ATAdInfo> vaildAds = ATInterstitialAutoAd.checkValidAdCaches(mPlacementId);
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
            MsgTools.printMsg("auto load inter entryInterstitialScenario empty placementId");
            return;
        }
        MsgTools.printMsg("auto load inter entryInterstitialScenario: " + placementId + "sceneID: " + sceneID);
        ATInterstitialAutoAd.entryAdScenario(placementId, sceneID);
    }

    // autoLoadInterstitialSetLocalExtra 方法，用于记录placementID对应的settingMap
    public void autoLoadInterstitialSetLocalExtra(String placementID, Map<String, Object> settingMap) {
        if (!TextUtils.isEmpty(placementID) && settingMap != null) {
            // 将settingMap放入placementSettings中
            placementSettings.put(placementID, settingMap);
        }
    }
}



