import 'dart:async';

import 'package:adjust_sdk/adjust.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/tba/event_util.dart';

import '../../view/base_view.dart';
import '../log.dart';
import '../tba/tba_util.dart';

class MaxUtils {
  MaxUtils._internal();

  static final MaxUtils _instance = MaxUtils._internal();

  late Completer<bool> initCompleter;
  final Map<String, _MaxLoadCallbacks> _pendingLoadCallbacks = {};
  final Map<String, _MaxShowCallbacks> _pendingShowCallbacks = {};

  static MaxUtils get instance {
    return _instance;
  }

  Future init() async {
    initCompleter = Completer();
    Future.delayed(Duration(seconds: 15)).then((v) {
      if (!initCompleter.isCompleted) {
        initCompleter.complete(false);
      }
    });
    EventUtils.instance.addEvent("ad_init",
        data: {"ad_source_client": "max", "start_time": DateTime.now().difference(bus.appLaunchTime).inMilliseconds});

    //IDFA或gaid
    if (!MuseConfig.isUser) {
      String? gaid = await Adjust.getGoogleAdId();
      if (gaid != null) {
        AppLog.i("max设置测试设备gaid:$gaid");
        AppLovinMAX.setTestDeviceAdvertisingIds([gaid]);
      }
    }

    _addAppOpenAdListener();
    _addInterstitialListener();
    _addRewardedAdListener();

    DateTime start = DateTime.now();
    String slatKey = "_2026_";
    String maxKey =
        "_2026_POzCPzJAQ_vi7vlPr0v6dpTw1gi_2026_LvT2HKZcyQJ27U_0hDMdIeOgvScokaDvmqrXg8AogImcyxb9QMKF5TXSf8U_2026_";
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize(maxKey.replaceAll(slatKey, ""));
    AppLovinMAX.setMuted(true);
    AppLog.i("max初始化完成 isTestModeEnabled:${sdkConfiguration?.isTestModeEnabled}");

    EventUtils.instance.addEvent("ad_initsuc", data: {
      "ad_source_client": "max",
      "ad_init_time": DateTime.now().difference(start).inMilliseconds,
    });

    if (!initCompleter.isCompleted) {
      initCompleter.complete(true);
    }
  }

  _addAppOpenAdListener() {
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (ad) {
          final loadCallbacks = _consumeLoadCallbacks("open", ad.adUnitId);
          AdUtils.instance.loadedAdMap[ad.adUnitId] = {
            "admob_ad": ad,
            "timeMs": DateTime.now().millisecondsSinceEpoch,
          };
          loadCallbacks?.onLoaded(ad);
        },
        onAdLoadFailedCallback: (adId, e) {
          final loadCallbacks = _consumeLoadCallbacks("open", adId);
          loadCallbacks?.onLoadFailed(adId, e);
        },
        onAdDisplayedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("open", ad.adUnitId);
          showCallbacks?.onDisplayed?.call(ad);
        },
        onAdDisplayFailedCallback: (ad, e) {
          final showCallbacks = _consumeShowCallbacks("open", ad.adUnitId);
          showCallbacks?.onDisplayFailed?.call(ad, e);
        },
        onAdClickedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("open", ad.adUnitId);
          showCallbacks?.onClicked?.call(ad);
        },
        onAdHiddenCallback: (ad) {
          final showCallbacks = _consumeShowCallbacks("open", ad.adUnitId);
          showCallbacks?.onHidden?.call(ad);
        },
        onAdRevenuePaidCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("open", ad.adUnitId);
          showCallbacks?.onRevenuePaid?.call(ad);
        },
      ),
    );
  }

  _addInterstitialListener() {
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) {
          final loadCallbacks = _consumeLoadCallbacks("interstitial", ad.adUnitId);
          AdUtils.instance.loadedAdMap[ad.adUnitId] = {
            "admob_ad": ad,
            "timeMs": DateTime.now().millisecondsSinceEpoch,
          };
          loadCallbacks?.onLoaded(ad);
        },
        onAdLoadFailedCallback: (adId, e) {
          final loadCallbacks = _consumeLoadCallbacks("interstitial", adId);
          loadCallbacks?.onLoadFailed(adId, e);
        },
        onAdDisplayedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("interstitial", ad.adUnitId);
          showCallbacks?.onDisplayed?.call(ad);
        },
        onAdDisplayFailedCallback: (ad, e) {
          final showCallbacks = _consumeShowCallbacks("interstitial", ad.adUnitId);
          showCallbacks?.onDisplayFailed?.call(ad, e);
        },
        onAdClickedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("interstitial", ad.adUnitId);
          showCallbacks?.onClicked?.call(ad);
        },
        onAdHiddenCallback: (ad) {
          final showCallbacks = _consumeShowCallbacks("interstitial", ad.adUnitId);
          showCallbacks?.onHidden?.call(ad);
        },
        onAdRevenuePaidCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("interstitial", ad.adUnitId);
          showCallbacks?.onRevenuePaid?.call(ad);
        },
      ),
    );
  }

  _addRewardedAdListener() {
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (ad) {
          final loadCallbacks = _consumeLoadCallbacks("rewarded", ad.adUnitId);
          AdUtils.instance.loadedAdMap[ad.adUnitId] = {
            "admob_ad": ad,
            "timeMs": DateTime.now().millisecondsSinceEpoch,
          };
          loadCallbacks?.onLoaded(ad);
        },
        onAdLoadFailedCallback: (adId, e) {
          final loadCallbacks = _consumeLoadCallbacks("rewarded", adId);
          loadCallbacks?.onLoadFailed(adId, e);
        },
        onAdDisplayedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onDisplayed?.call(ad);
        },
        onAdDisplayFailedCallback: (ad, e) {
          final showCallbacks = _consumeShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onDisplayFailed?.call(ad, e);
        },
        onAdClickedCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onClicked?.call(ad);
        },
        onAdHiddenCallback: (ad) {
          final showCallbacks = _consumeShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onHidden?.call(ad);
        },
        onAdRevenuePaidCallback: (ad) {
          final showCallbacks = _peekShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onRevenuePaid?.call(ad);
        },
        onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
          final showCallbacks = _peekShowCallbacks("rewarded", ad.adUnitId);
          showCallbacks?.onReceivedReward?.call(ad, reward);
        },
      ),
    );
  }

  String _slotKey(String adType, String adUnitId) {
    return "$adType::$adUnitId";
  }

  void bindLoadCallbacks({
    required String adType,
    required String adUnitId,
    required void Function(MaxAd ad) onLoaded,
    required void Function(String adUnitId, MaxError error) onLoadFailed,
  }) {
    _pendingLoadCallbacks[_slotKey(adType, adUnitId)] = _MaxLoadCallbacks(
      onLoaded: onLoaded,
      onLoadFailed: onLoadFailed,
    );
  }

  void clearLoadCallbacks({
    required String adType,
    required String adUnitId,
  }) {
    _pendingLoadCallbacks.remove(_slotKey(adType, adUnitId));
  }

  _MaxLoadCallbacks? _consumeLoadCallbacks(String adType, String adUnitId) {
    return _pendingLoadCallbacks.remove(_slotKey(adType, adUnitId));
  }

  void bindShowCallbacks({
    required String adType,
    required String adUnitId,
    void Function(MaxAd ad)? onDisplayed,
    void Function(MaxAd ad, MaxError error)? onDisplayFailed,
    void Function(MaxAd ad)? onClicked,
    void Function(MaxAd ad)? onHidden,
    void Function(MaxAd ad)? onRevenuePaid,
    void Function(MaxAd ad, MaxReward reward)? onReceivedReward,
  }) {
    _pendingShowCallbacks[_slotKey(adType, adUnitId)] = _MaxShowCallbacks(
      onDisplayed: onDisplayed,
      onDisplayFailed: onDisplayFailed,
      onClicked: onClicked,
      onHidden: onHidden,
      onRevenuePaid: onRevenuePaid,
      onReceivedReward: onReceivedReward,
    );
  }

  void clearShowCallbacks({
    required String adType,
    required String adUnitId,
  }) {
    _pendingShowCallbacks.remove(_slotKey(adType, adUnitId));
  }

  _MaxShowCallbacks? _peekShowCallbacks(String adType, String adUnitId) {
    return _pendingShowCallbacks[_slotKey(adType, adUnitId)];
  }

  _MaxShowCallbacks? _consumeShowCallbacks(String adType, String adUnitId) {
    return _pendingShowCallbacks.remove(_slotKey(adType, adUnitId));
  }

  Future<bool> loadNativeAd(String adId, String key, AdSense adSense, Rx<Widget> adView) async {
    Completer<bool> completer = Completer();
    MaxNativeAdViewController nativeAdViewController = MaxNativeAdViewController();

    var view = Container();

    var adLoaded = false.obs;
    EventUtils.instance.addEvent("ad_request", data: {
      "ad_format": "native",
      "ad_source_client": "max",
      "ad_pos_id": key,
      "ad_sense": adSense.name,
      "ad_code_id": adId
    });
    DateTime now = DateTime.now();

    view = Container(
      child: Obx(
        () => Visibility(
          visible: adLoaded.value,
          maintainState: true,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: double.infinity, maxHeight: 250),
                child: MaxNativeAdView(
                  adUnitId: adId,
                  controller: nativeAdViewController,
                  listener: NativeAdListener(
                    onAdLoadedCallback: (ad) {
                      AppLog.e("max native加载成功");
                      adLoaded.value = true;
                      completer.complete(true);
                      EventUtils.instance.addEvent("ad_return_sucess", data: {
                        "ad_pos_id": key,
                        "ad_format": "native",
                        "ad_source_client": "max",
                        "ad_sense": adSense.name,
                        "ad_code_id": adId,
                        "ad_request_time": DateTime.now().difference(now).inMilliseconds
                      });
                    },
                    onAdLoadFailedCallback: (adUnitId, error) {
                      AppLog.e("max原生加载失败:$error");
                      completer.complete(false);
                      EventUtils.instance.addEvent("ad_return_fail", data: {
                        "ad_format": "native",
                        "ad_source_client": "max",
                        "ad_pos_id": key,
                        "ad_sense": adSense.name,
                        "ad_code_id": adId,
                        "ad_request_time": DateTime.now().difference(now).inMilliseconds,
                        "reason": error.message
                      });
                    },
                    onAdClickedCallback: (ad) {
                      EventUtils.instance.addEvent("ad_click", data: {
                        "ad_format": "native",
                        "ad_source_client": "max",
                        "ad_pos_id": key,
                        "ad_sense": adSense.name,
                        "ad_code_id": adId
                      });
                    },
                    onAdRevenuePaidCallback: (ad) {
                      TbaUtils.instance.postAd(
                        ad_network: ad.networkName,
                        adSense: adSense.name,
                        ad_source: "max",
                        ad_unit_id: ad.adUnitId,
                        ad_format: "native",
                        ad_pre_ecpm: ad.revenue.toString(),
                        currency: "",
                        adPosName: key,
                        adFunction: "",
                        // precision_type: ad.revenuePrecision,
                        // positionKey: positionKey,
                      );
                    },
                  ),
                  child: Container(
                    color: const Color(0xff141414).withOpacity(0.5),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(child: Container(child: MaxNativeAdMediaView())),
                        Container(
                          height: 60,
                          child: Row(
                            children: [
                              MaxNativeAdIconView(width: 36, height: 36),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MaxNativeAdTitleView(
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.visible),
                                    MaxNativeAdAdvertiserView(
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(0.75),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade),
                                  ],
                                ),
                              ),
                              MaxNativeAdCallToActionView(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Color(0xff985CFF)),
                                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                                  textStyle: MaterialStatePropertyAll(
                                    TextStyle(
                                      // color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    nativeAdViewController.loadAd();
    adView.value = getAdCloseView(view);
    return completer.future;
  }

  Future<bool> loadBanner(String adId, String key, AdSense adSense, Rx<Widget> adView, {required bool isSmall}) {
    Completer<bool> completer = Completer();
    var adLoaded = false.obs;
    EventUtils.instance.addEvent("ad_request", data: {
      "ad_format": "banner",
      "ad_source_client": "max",
      "ad_pos_id": key,
      "ad_sense": adSense.name,
      "ad_code_id": adId
    });
    DateTime now = DateTime.now();

    var adC = Container(
      child: Obx(
        () => Visibility(
          visible: adLoaded.value,
          maintainState: true,
          child: Container(
            alignment: Alignment.center,
            child: MaxAdView(
              adUnitId: adId,
              adFormat: isSmall ? AdFormat.banner : AdFormat.mrec,
              listener: AdViewAdListener(
                onAdLoadedCallback: (ad) {
                  AppLog.i("原生广告max banner加载完成");
                  adLoaded.value = true;
                  completer.complete(true);
                  EventUtils.instance.addEvent("ad_return_sucess", data: {
                    "ad_format": "banner",
                    "ad_sense": adSense.name,
                    "ad_pos_id": key,
                    "ad_id": adId,
                    "ad_source_client": "max",
                    "ad_request_time": DateTime.now().difference(now).inMilliseconds
                  });
                  EventUtils.instance.addEvent("ad_chance", data: {"ad_sense": adSense.name, "ad_pos_id": key});
                },
                onAdLoadFailedCallback: (adUnitId, error) {
                  AppLog.e("原生广告max banner加载失败：$error");
                  completer.complete(false);
                  EventUtils.instance.addEvent("ad_return_fail", data: {
                    "ad_format": "banner",
                    "ad_sense": adSense.name,
                    "ad_pos_id": key,
                    "ad_id": adId,
                    "ad_source_client": "max",
                    "ad_request_time": DateTime.now().difference(now).inMilliseconds,
                    "reason": error.message
                  });
                },
                onAdClickedCallback: (ad) {},
                onAdRevenuePaidCallback: (ad) {
                  TbaUtils.instance.postAd(
                    ad_network: ad.networkName,
                    adSense: adSense.name,
                    ad_source: "max",
                    ad_unit_id: ad.adUnitId,
                    ad_format: "banner",
                    ad_pre_ecpm: ad.revenue.toString(),
                    currency: "",
                    adPosName: key,
                    adFunction: "",
                    // precision_type: ad.revenuePrecision,
                    // positionKey: positionKey,
                  );
                },
                onAdExpandedCallback: (ad) {},
                onAdCollapsedCallback: (ad) {},
              ),
            ),
          ),
        ),
      ),
    );
    adView.value = isSmall ? adC : getAdCloseView(adC);
    return completer.future;
  }
}

class _MaxLoadCallbacks {
  final void Function(MaxAd ad) onLoaded;
  final void Function(String adUnitId, MaxError error) onLoadFailed;

  _MaxLoadCallbacks({
    required this.onLoaded,
    required this.onLoadFailed,
  });
}

class _MaxShowCallbacks {
  final void Function(MaxAd ad)? onDisplayed;
  final void Function(MaxAd ad, MaxError error)? onDisplayFailed;
  final void Function(MaxAd ad)? onClicked;
  final void Function(MaxAd ad)? onHidden;
  final void Function(MaxAd ad)? onRevenuePaid;
  final void Function(MaxAd ad, MaxReward reward)? onReceivedReward;

  _MaxShowCallbacks({
    this.onDisplayed,
    this.onDisplayFailed,
    this.onClicked,
    this.onHidden,
    this.onRevenuePaid,
    this.onReceivedReward,
  });
}
