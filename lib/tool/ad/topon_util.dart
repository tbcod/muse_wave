import 'dart:async';

import 'package:anythink_sdk/at_banner.dart';
import 'package:anythink_sdk/at_banner_response.dart';
import 'package:anythink_sdk/at_common.dart';
import 'package:anythink_sdk/at_init.dart';
import 'package:anythink_sdk/at_listener.dart';
import 'package:anythink_sdk/at_native.dart';
import 'package:anythink_sdk/at_native_response.dart';
import 'package:anythink_sdk/at_platformview/at_banner_platform_widget.dart';
import 'package:anythink_sdk/at_platformview/at_native_platform_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import '../../view/base_view.dart';
import '../log.dart';
import '../tba/tba_util.dart';

class TopOnUtils {
  TopOnUtils._internal();

  static final TopOnUtils _instance = TopOnUtils._internal();

  static TopOnUtils get instance {
    return _instance;
  }

  StreamSubscription? interstitialStream;
  StreamSubscription? rewardedStream;

  Future init() async {
    if (MuseConfig.isUser) {
      //正式环境
      ATInitManger.initAnyThinkSDK(
        appidStr: 'h67d906f010107',
        appidkeyStr: 'a683874a73857b711c0b8df1b71deb07b',
      );
    } else {
      // AppLog.e("topon init start");
      try {
        ATInitManger.setLogEnabled(logEnabled: false);
        var str = await ATInitManger.initAnyThinkSDK(
          appidStr: 'h67d9062a4e687',
          appidkeyStr: 'a78e55da0d7a8109c4be7fb6e6877ad26',
        );
        AppLog.i("topon init ok---$str");
      } catch (e) {
        AppLog.e("topon init error");
        print(e);
      }
    }
  }

  StreamSubscription? nativeStream;
  StreamSubscription? bannerStream;

  Map<String, Completer> allCom = {};
  Future<bool> loadBannerAd(
    String adId,
    String key,
    AdScene adScene,
    Rx<Widget> adView, {
    var isSmall = false,
  }) async {
    if (allCom[adId] != null) {
      //只能显示一个
      AppLog.e("topon banner只能显示一个");
      return false;
    }
    AppLog.i("topon banner开始加载");
    EventUtils.instance.addEvent("ad_request", data: {"ad_format": "banner", "ad_source_client": "topon", "ad_pos_id": key, "ad_sense": adScene.name, "ad_code_id": adId});
    DateTime now = DateTime.now();


    allCom[adId] = Completer<bool>();

    bannerStream ??= ATListenerManager.bannerEventHandler.listen((e) {
      AppLog.i("topon banner ${e.bannerStatus},${e.placementID},${e.requestMessage}");
      // AppLog.e("topon ${e.placementID}");
      // AppLog.e("${e.requestMessage}");
      if (e.bannerStatus == BannerStatus.bannerAdDidFinishLoading) {
        EventUtils.instance.addEvent("ad_return", data: {"ad_format": "banner", "ad_sense": adScene.name, "ad_id": adId, "ad_source_client": "topon", "ad_request_time": DateTime.now().difference(now).inMilliseconds});
        allCom[e.placementID]?.complete(true);
      } else if (e.bannerStatus == BannerStatus.bannerAdFailToLoadAD) {
          EventUtils.instance.addEvent("ad_return_fail", data: {"ad_format": "banner", "ad_sense": adScene.name, "ad_id": adId, "ad_source_client": "topon", "ad_request_time": DateTime.now().difference(now).inMilliseconds, "reason": e.requestMessage});
        allCom[e.placementID]?.complete(false);
      } else if (e.bannerStatus == BannerStatus.bannerAdUnknown) {
        allCom[e.placementID]?.complete(false);
      } else if (e.bannerStatus == BannerStatus.bannerAdDidShowSucceed) {
        //展示成功
        var revenueData = e.extraMap;
        //上传收益
        TbaUtils.instance.postAd(
          ad_network: revenueData["network_name"] ?? "",
          adSense: adScene.name,
          ad_source: "topon",
          ad_unit_id: revenueData["adunit_id"] ?? "",
          ad_format: "banner",
          ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
          currency: revenueData["currency"] ?? "USD",
          adPosName: key,
          // precision_type: revenueData["precision"] ?? "",
          // positionKey: positionKey,
        );
      }
    });
    var adSize = isSmall ? AdSize.banner : AdSize.mediumRectangle;

    ATBannerManager.loadBannerAd(
      placementID: adId,
      extraMap: {
        ATCommon.getAdSizeKey():
        // 该高度是根据横幅宽高比为320:50来计算，如果是其他宽高比请按实际来计算。
        ATBannerManager.createLoadBannerAdSize(
          adSize.width.toDouble(),
          adSize.height.toDouble(),
        ),
      },
    );

    bool isOk = await allCom[adId]?.future;
    if (isOk) {
      var view = Container(
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        alignment: Alignment.center,
        child: PlatformBannerWidget(adId, sceneID: adScene.name),
      );
      adView.value = isSmall ? view : getAdCloseView(view, toponAdId: adId);
    } else {
      allCom.remove(adId);
    }
    return isOk;
  }

  Future<bool> loadNativeAd(
    String adId,
    String key,
    AdScene adScene,
    Rx<Widget> adView,
  ) async {
    if (allCom[adId] != null) {
      //只能显示一个
      AppLog.e("topon 原生只能显示一个");
      return false;
    }

    EventUtils.instance.addEvent("ad_request", data: {"ad_format": "native", "ad_source_client": "topon", "ad_pos_id": key, "ad_sense": adScene.name, "ad_code_id": adId});
    DateTime now = DateTime.now();

    // var nativeCom = Completer<bool>();

    allCom[adId] = Completer<bool>();
    AppLog.e("topon原生 开始加载");
    nativeStream ??= ATListenerManager.nativeEventHandler.listen((e) {
      AppLog.e("topon原生 ${e.nativeStatus}");
      AppLog.e("topon ${e.placementID}");
      AppLog.e("${e.requestMessage}");
      if (e.nativeStatus == NativeStatus.nativeAdDidFinishLoading) {
        allCom[e.placementID]?.complete(true);
        EventUtils.instance.addEvent("ad_return", data: {"ad_format": "native", "ad_sense": adScene.name, "ad_id": adId, "ad_source_client": "topon", "ad_request_time": DateTime.now().difference(now).inMilliseconds});
      } else if (e.nativeStatus == NativeStatus.nativeAdFailToLoadAD) {
        allCom[e.placementID]?.complete(false);
        EventUtils.instance.addEvent("ad_return_fail", data: {"ad_format": "native", "ad_sense": adScene.name, "ad_id": adId, "ad_source_client": "topon", "ad_request_time": DateTime.now().difference(now).inMilliseconds, "reason": e.requestMessage});
      } else if (e.nativeStatus == NativeStatus.nativeAdUnknown) {
        allCom[e.placementID]?.complete(false);
      } else if (e.nativeStatus == NativeStatus.nativeAdDidShowNativeAd) {
        //展示成功
        var revenueData = e.extraMap;

        //上传收益
        TbaUtils.instance.postAd(
          ad_network: revenueData["network_name"] ?? "",
          adSense: adScene.name,
          ad_source: "topon",
          ad_unit_id: revenueData["adunit_id"] ?? "",
          ad_format: "native",
          ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
          currency: revenueData["currency"] ?? "USD",
          adPosName: key
          // precision_type: revenueData["precision"] ?? "",
          // positionKey: positionKey,
        );
      }
    });
    var adSize = AdSize(width: 300, height: 250);

    ATNativeManager.loadNativeAd(
      placementID: adId,
      extraMap: {
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          adSize.width.toDouble(),
          adSize.height.toDouble(),
        ),
        ATNativeManager.isAdaptiveHeight(): true,
      },
    );

    bool isOk = await allCom[adId]?.future;
    if (isOk) {
      var view = Container(
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        alignment: Alignment.center,
        child: PlatformNativeWidget(
          adId,
          {
            ATNativeManager.parent():
                ATNativeManager.createNativeSubViewAttribute(
                  adSize.width.toDouble(),
                  adSize.height.toDouble(),
                  backgroundColorStr: '#FFFFFF',
                ),
            ATNativeManager.appIcon():
                ATNativeManager.createNativeSubViewAttribute(
                  50,
                  50,
                  x: 10,
                  y: 10,
                  backgroundColorStr: 'clearColor',
                ),
            ATNativeManager.mainTitle():
                ATNativeManager.createNativeSubViewAttribute(
                  adSize.width - 190,
                  20,
                  x: 70,
                  y: 10,
                  textSize: 15,
                ),
            ATNativeManager.desc():
                ATNativeManager.createNativeSubViewAttribute(
                  adSize.width - 190,
                  20,
                  x: 70,
                  y: 40,
                  textSize: 15,
                ),
            ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
              100,
              50,
              x: adSize.width - 110,
              y: 10,
              textSize: 15,
              textColorStr: "#FFFFFF",
              backgroundColorStr: "#2095F1",
            ),
            ATNativeManager.mainImage():
                ATNativeManager.createNativeSubViewAttribute(
                  adSize.width - 20,
                  adSize.height - 80,
                  x: 10,
                  y: 70,
                  backgroundColorStr: '#00000000',
                ),
            ATNativeManager.adLogo():
                ATNativeManager.createNativeSubViewAttribute(
                  20,
                  10,
                  x: 10,
                  y: 10,
                  backgroundColorStr: '#50000000',
                ),
            ATNativeManager.dislike():
                ATNativeManager.createNativeSubViewAttribute(
                  20,
                  20,
                  x: adSize.width - 30,
                  y: 10,
                ),
            ATNativeManager.elementsView():
                ATNativeManager.createNativeSubViewAttribute(
                  adSize.width.toDouble(),
                  25,
                  x: 0,
                  y: adSize.height - 25,
                  textSize: 12,
                  textColorStr: "#FFFFFF",
                  backgroundColorStr: "#7F000000",
                ),
          },
          sceneID: adScene.name,
          isAdaptiveHeight: true,
        ),
      );
      adView.value = getAdCloseView(view, toponAdId: adId);
    } else {
      allCom.remove(adId);
    }
    return isOk;
  }
}
