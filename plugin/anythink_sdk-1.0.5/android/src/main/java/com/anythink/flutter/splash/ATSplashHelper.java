package com.anythink.flutter.splash;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.anythink.core.api.ATAdInfo;
import com.anythink.core.api.ATAdStatusInfo;
import com.anythink.core.api.ATNetworkConfirmInfo;
import com.anythink.core.api.AdError;
import com.anythink.core.api.ATShowConfig;
import com.anythink.flutter.ATFlutterEventManager;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.FlutterPluginUtil;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.splashad.api.ATSplashAd;
import com.anythink.splashad.api.ATSplashAdExtraInfo;
import com.anythink.splashad.api.ATSplashExListener;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ATSplashHelper {

    Activity mActivity;
    ATSplashAd mSplashAd;
    String mPlacementId;
    ViewGroup mDecorView;
    ViewGroup mAdContainer;

    public ATSplashHelper() {
        mActivity = FlutterPluginUtil.getActivity();
    }

    private void initSplash(final String placementId, int fetchAdTimeout) {
        mPlacementId = placementId;
        ATSplashExListener splashExListener = new ATSplashExListener() {
            @Override
            public void onDeeplinkCallback(ATAdInfo atAdInfo, boolean isSuccess) {
                MsgTools.printMsg("splash onDeeplinkCallback: " + mPlacementId + ", isSuccess: " + isSuccess);

                Map<String, Object> extraMap = new HashMap<>();
                extraMap.put(Const.CallbackKey.isDeeplinkSuccess, isSuccess);

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.DeeplinkCallbackKey,
                        mPlacementId, atAdInfo.toString(), null, extraMap);
            }

            @Override
            public void onDownloadConfirm(Context context, ATAdInfo atAdInfo, ATNetworkConfirmInfo atNetworkConfirmInfo) {
                MsgTools.printMsg("splash onDownloadConfirm: " + mPlacementId);
            }

            @Override
            public void onAdLoaded(boolean isTimeout) {
                MsgTools.printMsg("onAdLoaded: " + mPlacementId + ", isTimeout: " + isTimeout);

                Map<String, Object> extraMap = new HashMap<>();
                extraMap.put(Const.CallbackKey.isTimeout, isTimeout);

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.LoadedCallbackKey,
                        mPlacementId, null, null, extraMap);
            }

            @Override
            public void onAdLoadTimeout() {
                MsgTools.printMsg("onAdLoadTimeout: " + mPlacementId);

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.TimeoutCallbackKey,
                        mPlacementId, null, null);
            }

            @Override
            public void onNoAdError(AdError adError) {
                MsgTools.printMsg("onNoAdError: " + mPlacementId + ", " + adError.getFullErrorInfo());

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.LoadFailCallbackKey,
                        mPlacementId, null, adError.getFullErrorInfo());
            }

            @Override
            public void onAdShow(ATAdInfo atAdInfo) {
                MsgTools.printMsg("onAdShow: " + mPlacementId);

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ShowCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }

            @Override
            public void onAdClick(ATAdInfo atAdInfo) {
                MsgTools.printMsg("onAdClick: " + mPlacementId);

                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ClickCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }

            @Override
            public void onAdDismiss(ATAdInfo atAdInfo, ATSplashAdExtraInfo atSplashAdExtraInfo) {
                MsgTools.printMsg("onAdDismiss: " + mPlacementId);

                if (mDecorView != null && mAdContainer != null) {
                    mAdContainer.removeAllViews();
                    mDecorView.removeView(mAdContainer);
                }


                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.CloseCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }
        };

        if (fetchAdTimeout > 0) {
            mSplashAd = new ATSplashAd(mActivity, placementId, splashExListener, fetchAdTimeout);
        } else {
            mSplashAd = new ATSplashAd(mActivity, placementId, splashExListener);
        }

        //download
//        try {
//            if (ATSDK.isCnSDK()) {
//                mSplashAd.setAdDownloadListener(new ATAppDownloadListener() {
//                    @Override
//                    public void onDownloadStart(ATAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadStart: " + mPlacementId + ", " + totalBytes + ", " + currBytes + ", " + fileName + ", " + appName);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadStartKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadUpdate(ATAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadUpdate: " + mPlacementId);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadUpdateKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadPause(ATAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadPause: " + mPlacementId);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadPauseKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadFinish(ATAdInfo atAdInfo, long totalBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadFinish: " + mPlacementId + ", " + totalBytes  + ", " + fileName + ", " + appName);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadFinishedKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, -1, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadFail(ATAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadFail: " + mPlacementId + ", " + totalBytes + ", " + currBytes + ", " + fileName + ", " + appName);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadFailedKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onInstalled(ATAdInfo atAdInfo, String fileName, String appName) {
//                        MsgTools.printMsg("splash onInstalled: " + mPlacementId + ", " + fileName + ", " + appName);
//
//                        ATFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadInstalledKey,
//                                mPlacementId, atAdInfo.toString(), -1, -1, fileName, appName);
//                    }
//                });
//            }
//        } catch (Throwable e) {
//        }

    }

    public void loadSplash(final String placementId, final Map<String, Object> settings) {
        MsgTools.printMsg("loadSplash: " + placementId + ", settings: " + settings);


        int fetchAdTimeout = -1;
        if (settings != null) {
            try {
                fetchAdTimeout = Integer.parseInt(settings.get(Const.Splash.tolerateTimeout).toString());
            } catch (Throwable e) {
                e.printStackTrace();
            }
        }

        if (mSplashAd == null) {
            initSplash(placementId, fetchAdTimeout);
        }


        //todo
//        int adViewWidth;
//        int adViewHeight;
//        if (settings != null) {
//            try {
//                Map<String, Object> nativeAdSize = (Map<String, Object>) settings.get(Const.SIZE);
//
//                adViewWidth = Utils.dip2px(mActivity, (double) nativeAdSize.get(Const.WIDTH));
//                adViewHeight = Utils.dip2px(mActivity, (double) nativeAdSize.get(Const.HEIGHT));
//
//                MsgTools.printMsg("loadSplash: " + placementId + ", width: " + adViewWidth + ", height: " + adViewHeight);
//
//                settings.put(ATAdConst.KEY.AD_WIDTH, adViewWidth);
//                settings.put(ATAdConst.KEY.AD_HEIGHT, adViewHeight);
//            } catch (Throwable e) {
//                e.printStackTrace();
//            }
//        }


        mSplashAd.setLocalExtra(settings);
        mSplashAd.loadAd();
    }

    public void showSplash(final String scenario) {
        MsgTools.printMsg("showSplash: " + mPlacementId + ", scenario: " + scenario);
        showConfigSplash(scenario,null);
    }

    public void showConfigSplash(final String scenario, final String showCustomExt) {
        MsgTools.printMsg("showConfigSplash: " + mPlacementId + ", scenario: " + scenario+ ", showCustomExt: " + showCustomExt);

        if (mSplashAd != null) {
            try {
                mDecorView = mActivity.findViewById(android.R.id.content);
                if (mAdContainer == null) {
                    mAdContainer = new FrameLayout(mActivity);
                    mAdContainer.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                }
                mAdContainer.removeAllViews();
                if (mDecorView != null) {
                    mDecorView.removeView(mAdContainer);
                    mDecorView.addView(mAdContainer);
                }
                ATShowConfig.Builder builder = new ATShowConfig.Builder();
                builder.scenarioId(scenario);
                builder.showCustomExt(showCustomExt);
                mSplashAd.show(mActivity, mAdContainer, null, builder.build());
            } catch (Exception e) {
                MsgTools.printMsg("Splash showAd failed: " + e.getMessage());
                ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ShowFailedCallbackKey,
                        mPlacementId, null, e.getMessage());
            }
        }
    }

    public boolean isAdReady() {
        MsgTools.printMsg("splash isAdReady: " + mPlacementId);

        boolean isReady = false;
        if (mSplashAd != null) {
            isReady = mSplashAd.isAdReady();
        }

        MsgTools.printMsg("splash isAdReady: " + mPlacementId + ", " + isReady);
        return isReady;
    }

    public Map<String, Object> checkAdStatus() {
        MsgTools.printMsg("splash checkAdStatus: " + mPlacementId);

        Map<String, Object> map = new HashMap<>(5);

        if (mSplashAd != null) {
            ATAdStatusInfo atAdStatusInfo = mSplashAd.checkAdStatus();
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

        map.put("isLoading", false);
        map.put("isReady", false);

        return map;
    }

    public String checkValidAdCaches() {
        MsgTools.printMsg("splash checkValidAdCaches: " + mPlacementId);

        if (mSplashAd != null) {
            List<ATAdInfo> vaildAds = mSplashAd.checkValidAdCaches();
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
        return "";
    }

    public void entryScenario(final String placementId,final String sceneID) {
        MsgTools.printMsg("entrySplashScenario: " + mPlacementId + "sceneID: " + sceneID);
        ATSplashAd.entryAdScenario(placementId, sceneID);
    }
}
