package com.anythink.flutter.utils;

public class Const {
    public static final String X = "x";
    public static final String Y = "y";
    public static final String WIDTH = "width";
    public static final String HEIGHT = "height";
    public static final String EXTRA_DIC = "extraDic";
    public static final String PLACEMENT_ID = "placementID";
    public static final String PLACEMENT_ID_Multi = "placementIDMulti";
    public static final String SCENE_ID = "sceneID";
    public static final String SIZE = "size";
    public static final String POSITION = "position";
    public static final String POSITION_TOP = "kATBannerAdShowingPositionTop";
    public static final String POSITION_BOTTOM = "kATBannerAdShowingPositionBottom";
    public static final String CUSTOM_EXT = "customExt";
    public static final String SHOW_CUSTOM_EXT = "showCustomExt";

    public static final String BACKGROUND_COLOR = "backgroundColorStr";
    public static final String TEXT_COLOR = "textColorStr";
    public static final String TEXT_SIZE = "textSize";
    public static final String CUSTOM_CLICK = "isCustomClick";
    public static final String CORNER_RADIUS = "cornerRadius";
    public static final String CUSTOM_VIEW_TYPE = "type";
    public static final String IMAGE_PATH = "imagePath";
    public static final String TITLE = "title";
    public static final String DEBUGKEY = "debugKey";

    public static class CallbackKey {
        public static final String callbackName = "callbackName";
        public static final String placementID = "placementID";
        public static final String extraDic = "extraDic";
        public static final String requestMessage = "requestMessage";
        public static final String isDeeplinkSuccess = "isDeeplinkSuccess";

        public static final String isTimeout = "isTimeout";//only for splash
    }

    public static class TYPE_CUSTOM_VIEW {
        public static final String image = "0";
        public static final String label = "1";
        public static final String view = "2";
    }


    public static class RewardedVideo {
        public static final String USER_ID = "kATAdLoadingExtraUserIDKey";
        public static final String USER_DATA = "kATAdLoadingExtraUserDataKeywordKey";
    }

    public static class Interstitial {
        public static final String UseRewardedVideoAsInterstitialKey = "UseRewardedVideoAsInterstitialKey";
        public static final String SHOW_CUSTOM_EXT = "kATAdShowCustomExtKey";
    }

    public static class Native {
        public static final String parent = "parent";
        public static final String icon = "appIcon";
        public static final String mainImage = "mainImage";
        public static final String title = "title";
        public static final String desc = "desc";
        public static final String adLogo = "adLogo";
        public static final String cta = "cta";
        public static final String dislike = "dislike";

        public static final String elementsView = "elementsView";

        public static final String customView = "customView";

        public static final String isAdaptiveHeight = "isAdaptiveHeight";
    }

    public static class Banner {
        public static final String adaptiveWidth = "adaptive_width";
        public static final String adaptiveOrientation = "adaptive_orientation";
        public static final int adaptiveOrientationCurrent = 0;
        public static final int adaptiveOrientationPortrait = 1;
        public static final int adaptiveOrientationLandscape = 2;
    }

    public static class Splash {
        public static final String tolerateTimeout = "tolerateTimeout";
    }

    public static class Init {
        public static final String LOG_ENABLE = "logEnabled";
        public static final String CHANNEL_STR = "channelStr";
        public static final String SUB_CHANNEL_STR = "subchannelStr";
        public static final String CUSTOM_DATA_DIC = "customDataDic";
        public static final String EXLUDE_BUNDLE_ID_ARRAY = "exludeBundleIDArray";
        public static final String DENIED_UPLOAD_INFO_ARRAY = "deniedUploadInfoArray";
        public static final String PLACEMENT_CUSTOM_DATA_DIC = "placementCustomDataDic";
        public static final String PLACEMENT_ID_STR = "placementIDStr";
        public static final String GDPR_UPLOAD_DATA_LEVEL = "gdprLevel";
        public static final String APP_ID_STR = "appIdStr";
        public static final String APP_KEY_STR = "appKeyStr";
        public static final String PATH_STR = "pathStr";
    }

    public static class CallbackMethodCall {
        public static final String rewardedVideoCall = "RewardedVideoCall";
        public static final String InterstitialCall = "InterstitialCall";
        public static final String BannerCall = "BannerCall";
        public static final String NativeCall = "NativeCall";
        public static final String SplashCall = "SplashCall";
        public static final String InitCallName = "InitCallName";
        public static final String DownloadCall = "DownloadCall";
        public static final String CommonADCall = "CommonADCall";
    }

    public static class InitCallback {
        public static final String locationCallbackKey = "location";
        public static final String consentSetCallbackKey = "consentSet";
        public static final String consentDismissCallbackKey = "consentDismiss";
    }

    public static class CommonADCallBack {
        public static final String AdShowRevenueCallbackKey = "adShowRevenueCallbackKey";
    }

    public static class RewardVideoCallback {
        public static final String LoadedCallbackKey = "rewardedVideoDidFinishLoading";
        public static final String LoadFailCallbackKey = "rewardedVideoDidFailToLoad";
        public static final String PlayStartCallbackKey = "rewardedVideoDidStartPlaying";
        public static final String PlayEndCallbackKey = "rewardedVideoDidEndPlaying";
        public static final String PlayFailCallbackKey = "rewardedVideoDidFailToPlay";
        public static final String CloseCallbackKey = "rewardedVideoDidClose";
        public static final String ClickCallbackKey = "rewardedVideoDidClick";
        public static final String RewardCallbackKey = "rewardedVideoDidRewardSuccess";
        public static final String DeeplinkCallbackKey = "rewardedVideoDidDeepLink";

        public static final String AgainPlayStartCallbackKey = "rewardedVideoDidAgainStartPlaying";
        public static final String AgainPlayEndCallbackKey = "rewardedVideoDidAgainEndPlaying";
        public static final String AgainPlayFailCallbackKey = "rewardedVideoDidAgainFailToPlay";
        public static final String AgainClickCallbackKey = "rewardedVideoDidAgainClick";
        public static final String AgainRewardCallbackKey = "rewardedVideoDidAgainRewardSuccess";

    }

    public static class InterstitialCallback {
        public static final String LoadedCallbackKey = "interstitialAdDidFinishLoading";
        public static final String LoadFailCallbackKey = "interstitialAdFailToLoadAD";
        public static final String PlayStartCallbackKey = "interstitialAdDidStartPlaying";
        public static final String PlayEndCallbackKey = "interstitialAdDidEndPlaying";
        public static final String PlayFailCallbackKey = "interstitialDidFailToPlayVideo";
        public static final String CloseCallbackKey = "interstitialAdDidClose";
        public static final String ClickCallbackKey = "interstitialAdDidClick";
        public static final String ShowCallbackKey = "interstitialDidShowSucceed";
        public static final String ShowFailCallbackKey = "interstitialFailedToShow";//no use
        public static final String DeeplinkCallbackKey = "interstitialAdDidDeepLink";
    }

    public static class BannerCallback {
        public static final String LoadedCallbackKey = "bannerAdDidFinishLoading";
        public static final String LoadFailCallbackKey = "bannerAdFailToLoadAD";
        public static final String CloseCallbackKey = "bannerAdTapCloseButton";
        public static final String ClickCallbackKey = "bannerAdDidClick";
        public static final String ShowCallbackKey = "bannerAdDidShowSucceed";
        public static final String RefreshCallbackKey = "bannerAdAutoRefreshSucceed";
        public static final String RefreshFailCallbackKey = "bannerAdAutoRefreshFail";
        public static final String DeeplinkCallbackKey = "bannerAdDidDeepLink";
    }

    public static class NativeCallback {
        public static final String LoadedCallbackKey = "nativeAdDidFinishLoading";
        public static final String LoadFailCallbackKey = "nativeAdFailToLoadAD";
        public static final String CloseCallbackKey = "nativeAdDidTapCloseButton";
        public static final String ClickCallbackKey = "nativeAdDidClick";
        public static final String ShowCallbackKey = "nativeAdDidShowNativeAd";
        public static final String VideoStartKey = "nativeAdDidStartPlayingVideo";
        public static final String VideoEndKey = "nativeAdDidEndPlayingVideo";
        public static final String VideoProgressKey = "NativeVideoProgress";//no use
        public static final String DeeplinkCallbackKey = "nativeAdDidDeepLink";
    }

    public static class SplashCallback {
        public static final String LoadedCallbackKey = "splashDidFinishLoading";
        public static final String LoadFailCallbackKey = "splashDidFailToLoad";
        public static final String TimeoutCallbackKey = "splashDidTimeout";
        public static final String ShowCallbackKey = "splashDidShowSuccess";
        public static final String ShowFailedCallbackKey = "splashDidShowFailed";
        public static final String CloseCallbackKey = "splashDidClose";
        public static final String ClickCallbackKey = "splashDidClick";
        public static final String DeeplinkCallbackKey = "splashDidDeepLink";
    }

    public static class DownloadCallCallback {
        public static final String DownloadStartKey = "downloadStart";
        public static final String DownloadUpdateKey = "downloadUpdate";
        public static final String DownloadPauseKey = "downloadPause";
        public static final String DownloadFinishedKey = "downloadFinished";
        public static final String DownloadFailedKey = "downloadFailed";
        public static final String DownloadInstalledKey = "downloadInstalled";
    }

    public static class PlatformViewName {
        public static final String Banner = "at_banner_platform_view";
        public static final String Native = "at_native_platform_view";
    }

    public static class PlatformViewKeys {
        public static final String PlacementID = "placementID";
        public static final String SceneID = "sceneID";
        public static final String ExtraMap = "extraMap";
        public static final String isAdaptiveHeight = Native.isAdaptiveHeight;
    }


    public static String[] initMethodNames = {"setLogEnabled", "setChannelStr", "setSubchannelStr", "setCustomDataDic",
            "setExludeBundleIDArray", "setPlacementCustomData", "getGDPRLevel", "getUserLocation", "setDataConsentSet",
            "showGDPRAuth", "initAnyThinkSDK", "deniedUploadDeviceInfo","setPresetPlacementConfigPath","showGDPRConsentDialog", "showDebuggerUI"};

    public static String[] interstitialMethodNames = {"loadInterstitialAd", "showInterstitialAd","showInterstitialAdWithShowConfig",
            "showSceneInterstitialAd", "hasInterstitialAdReady", "getInterstitialValidAds", "checkInterstitialLoadStatus" ,"entryInterstitialScenario","autoLoadInterstitialAD","cancelAutoLoadInterstitialAD","showAutoLoadInterstitialAD","autoLoadInterstitialADSetLocalExtra"};

    public static String[] rewardVideoMethodNames = {"loadRewardedVideo", "showRewardedVideo", "showSceneRewardedVideo","showRewardedVideoWithShowConfig",
            "rewardedVideoReady", "checkRewardedVideoLoadStatus", "getRewardedVideoValidAds", "entryRewardedVideoScenario", "autoLoadRewardedVideoAD", "cancelAutoLoadRewardedVideoAD", "showAutoLoadRewardedVideoAD", "autoLoadRewardedVideoADSetLocalExtra"};

    public static String[] bannerMethodNames = {"loadBannerAd", "bannerAdReady", "checkBannerLoadStatus", "getBannerValidAds",
            "showBannerInRectangle", "showSceneBannerInRectangle", "showAdInPosition", "showSceneBannerAdInPosition", "removeBannerAd", "hideBannerAd", "afreshShowBannerAd", "entryBannerScenario"};

    public static String[] nativeMethodNames = {"loadNativeAd", "nativeAdReady", "checkNativeAdLoadStatus", "getNativeValidAds",
            "showNativeAd", "showSceneNativeAd", "removeNativeAd", "showSceneNativeAdWithCustomExt", "entryNativeScenario"};

    public static String[] splashMethodNames = {"loadSplash", "splashReady", "checkSplashLoadStatus", "getSplashValidAds","showSplashAdWithShowConfig",
            "showSplash", "showSceneSplash", "entrySplashScenario"};


}
