import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    //TODO 注意切换正式的app key;
    AppLog.e("max初始化开始");
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize(
      "POzCPzJAQ_vi7vlPr0v6dpTw1giLvT2HKZcyQJ27U_0hDMdIeOgvScokaDvmqrXg8AogImcyxb9QMKF5TXSf8U",
    );
    AppLog.e("max初始化结束");
    AppLovinMAX.setMuted(true);
    AppLog.e(sdkConfiguration?.toString());

    //IDFA或gaid
    // AppLovinMAX.setTestDeviceAdvertisingIds([""]);
  }

  Future<bool> loadNativeAd(
    String adId,
    String key,
    String positionKey,
    Rx<Widget> adView,
  ) async {
    Completer<bool> completer = Completer();
    MaxNativeAdViewController nativeAdViewController =
        MaxNativeAdViewController();

    var view = Container();

    var adLoaded = false.obs;

    view = Container(
      child: Obx(
        () => Visibility(
          visible: adLoaded.value,
          maintainState: true,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: 250,
                ),
                child: MaxNativeAdView(
                  adUnitId: adId,
                  controller: nativeAdViewController,
                  listener: NativeAdListener(
                    onAdLoadedCallback: (ad) {
                      AppLog.e("max native加载成功");
                      adLoaded.value = true;
                      completer.complete(true);
                    },
                    onAdLoadFailedCallback: (adUnitId, error) {
                      AppLog.e("max原生加载失败");
                      AppLog.e(error);
                      completer.complete(false);
                    },
                    onAdClickedCallback: (ad) {},
                    onAdRevenuePaidCallback: (ad) {
                      TbaUtils.instance.postAd(
                        ad_network: ad.networkName,
                        ad_pos_id: positionKey,
                        ad_source: "max",
                        ad_unit_id: ad.adUnitId,
                        ad_format: "native",
                        ad_pre_ecpm: ad.revenue.toString(),
                        currency: "",
                        ad_sence: positionKey,
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
                        Expanded(
                          child: Container(child: MaxNativeAdMediaView()),
                        ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                    MaxNativeAdAdvertiserView(
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ),
                              MaxNativeAdCallToActionView(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Color(0xff985CFF),
                                  ),
                                  foregroundColor: MaterialStatePropertyAll(
                                    Colors.white,
                                  ),
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

  Future<bool> loadBanner(
    String adId,
    String key,
    String positionKey,
    Rx<Widget> adView, {
    required bool isSmall,
  }) {
    Completer<bool> completer = Completer();
    var adLoaded = false.obs;

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
                  AppLog.e("原生广告max banner加载失败");
                  adLoaded.value = true;
                  completer.complete(true);
                },
                onAdLoadFailedCallback: (adUnitId, error) {
                  AppLog.e("原生广告max banner加载失败");
                  AppLog.e(error);
                  completer.complete(false);
                },
                onAdClickedCallback: (ad) {},
                onAdRevenuePaidCallback: (ad) {
                  TbaUtils.instance.postAd(
                    ad_network: ad.networkName,
                    ad_pos_id: key,
                    ad_source: "max",
                    ad_unit_id: ad.adUnitId,
                    ad_format: "banner",
                    ad_pre_ecpm: ad.revenue.toString(),
                    currency: "",
                    ad_sence: key
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
