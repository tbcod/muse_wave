import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';

import '../../view/base_view.dart';
import '../log.dart';
import '../tba/tba_util.dart';

class MaxUtils {
  MaxUtils._internal();

  static final MaxUtils _instance = MaxUtils._internal();

  static MaxUtils get instance {
    return _instance;
  }

  Future init() async {

    DateTime start = DateTime.now();
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize("POzCPzJAQ_vi7vlPr0v6dpTw1giLvT2HKZcyQJ27U_0hDMdIeOgvScokaDvmqrXg8AogImcyxb9QMKF5TXSf8U");
    // AppLog.e("max初始化结束");
    AppLovinMAX.setMuted(true);
    AppLog.i("max初始化完成 isTestModeEnabled:${sdkConfiguration?.isTestModeEnabled}");

    EventUtils.instance.addEvent("ad_initsuc", data: {"ad_source_client": "max", "ad_init_time": DateTime.now().difference(start).inMilliseconds});

    //IDFA或gaid
    // AppLovinMAX.setTestDeviceAdvertisingIds([""]);
  }

  Future<bool> loadNativeAd(String adId, String key, AdScene adSense, Rx<Widget> adView) async {
    Completer<bool> completer = Completer();
    MaxNativeAdViewController nativeAdViewController = MaxNativeAdViewController();

    var view = Container();

    var adLoaded = false.obs;
    EventUtils.instance.addEvent("ad_request", data: {"ad_format": "native", "ad_source_client": "max", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId});
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
                      EventUtils.instance.addEvent("ad_return", data: {"ad_format": "native", "ad_source_client": "max", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId, "ad_request_time": DateTime.now().difference(now).inMilliseconds});
                    },
                    onAdLoadFailedCallback: (adUnitId, error) {
                      AppLog.e("max原生加载失败:$error");
                      completer.complete(false);
                      EventUtils.instance.addEvent("ad_return_fail", data: {"ad_format": "native", "ad_source_client": "max", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId, "ad_request_time": DateTime.now().difference(now).inMilliseconds, "reason": error.message});
                    },
                    onAdClickedCallback: (ad) {
                      EventUtils.instance.addEvent("ad_click", data: {"ad_format": "native", "ad_source_client": "max", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId});
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
                                    MaxNativeAdTitleView(style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.visible),
                                    MaxNativeAdAdvertiserView(style: TextStyle(color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.normal, fontSize: 10), maxLines: 1, overflow: TextOverflow.fade),
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

  Future<bool> loadBanner(String adId, String key, AdScene adSense, Rx<Widget> adView, {required bool isSmall}) {
    Completer<bool> completer = Completer();
    var adLoaded = false.obs;
    EventUtils.instance.addEvent("ad_request", data: {"ad_format": "banner", "ad_source_client": "max", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId});
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
                  EventUtils.instance.addEvent("ad_return", data: {"ad_format": "banner", "ad_sense": adSense.name, "ad_pos_id": key, "ad_id": adId, "ad_source_client": "max", "ad_request_time": DateTime.now().difference(now).inMilliseconds});
                  EventUtils.instance.addEvent("ad_chance", data: {"ad_sense": adSense.name, "ad_pos_id": key});
                },
                onAdLoadFailedCallback: (adUnitId, error) {
                  AppLog.e("原生广告max banner加载失败：$error");
                  completer.complete(false);
                  EventUtils.instance.addEvent("ad_return_fail", data: {"ad_format": "banner", "ad_sense": adSense.name, "ad_pos_id": key, "ad_id": adId, "ad_source_client": "max", "ad_request_time": DateTime.now().difference(now).inMilliseconds, "reason": error.message});
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
