import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/view/base_view.dart';

import '../log.dart';
import '../tba/tba_util.dart';

class AdmobUtils {
  AdmobUtils._internal();

  static final AdmobUtils _instance = AdmobUtils._internal();

  static AdmobUtils get instance {
    return _instance;
  }

  Future init() async {
    DateTime start = DateTime.now();

    await MobileAds.instance.initialize();

    await MobileAds.instance.setAppMuted(true);

    EventUtils.instance.addEvent("ad_initsuc", data: {"ad_source_client": "admob", "ad_init_time":  DateTime.now().difference(start).inMilliseconds});

    AppLog.i("admob sdk 初始化 success");

    //IDFA或gaid
    // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    //     testDeviceIds: [""]));

    //Google UMP
    // ConsentInformation.instance.requestConsentInfoUpdate(
    //     ConsentRequestParameters(
    //         consentDebugSettings: ConsentDebugSettings(testIdentifiers: [])),
    //     () async {
    //   AppLog.e("UMP request success");
    //   AppLog.e(await ConsentInformation.instance.isConsentFormAvailable());
    //   if (await ConsentInformation.instance.isConsentFormAvailable()) {
    //     loadForm();
    //   }
    // }, (error) {
    //   AppLog.e("UMP request error");
    //   AppLog.e(error.message);
    // });
  }

  Future<Ad?> loadBanner(String adId, String key, AdScene adSense, Rx<Widget> adView, {bool isSmall = false}) {
    Widget view = Container();
    Completer<Ad?> completer = Completer();
    EventUtils.instance.addEvent(
      "ad_request",
      data: {"ad_format": "banner", "ad_source_client": "admob", "ad_sense": adSense.name, "ad_pos_id": key,  "ad_code_id": adId},
    );
    DateTime now = DateTime.now();
    view = Container(
      constraints: BoxConstraints(minWidth: 0, minHeight: 0, maxHeight: isSmall ? 50 : 250, maxWidth: double.infinity),
      child: AdWidget(
        ad: BannerAd(
          size: isSmall ? AdSize.banner : AdSize.mediumRectangle,
          adUnitId: adId,
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              AppLog.i("原生广告banner加载成功");
              adView.value = isSmall ? view : getAdCloseView(view);
              completer.complete(ad);
              EventUtils.instance.addEvent(
                "ad_return",
                data: {"ad_format": "banner","ad_sense": adSense.name, "ad_source_client": "admob", "ad_pos_id": key,  "ad_code_id": adId},
              );
              EventUtils.instance.addEvent("ad_chance", data: {"ad_sense": adSense.name, "ad_pos_id": key});
            },
            onAdFailedToLoad: (ad, e) {
              AppLog.e("原生广告banner加载失败,${e.message}");
              ad.dispose();
              completer.complete(null);
              EventUtils.instance.addEvent(
                "ad_return_fail",
                data: {
                  "ad_format": "banner",
                  "ad_source_client": "admob",
                  "ad_sense": adSense.name,
                  "ad_pos_id": key,
                  "ad_code_id": adId,
                  "reason": e.message,
                  "ad_request_time": DateTime.now().difference(now).inMilliseconds,
                },
              );
            },
            onAdClicked: (ad) {
              EventUtils.instance.addEvent(
                "ad_click",
                data: {"ad_format": "banner", "ad_source_client": "admob", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId},
              );
            },
            onAdClosed: (ad) {
              EventUtils.instance.addEvent(
                "ad_close",
                data: {"ad_format": "banner", "ad_source_client": "admob", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId},
              );
            },
            onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
              TbaUtils.instance.postAd(
                // ad_network: ad.responseInfo?.mediationAdapterClassName ?? "",
                ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
                adSense: adSense.name,
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_format: "banner",
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                adPosName: key,
                // precision_type: precision.name,
                //   positionKey: positionKey
              );
            },
          ),
          request: AdRequest(httpTimeoutMillis: 9000),
        )..load(),
      ),
    );

    return completer.future;
  }

  Future<Ad?> loadNativeAd(String adId, String key, AdScene adSense, Rx<Widget> adView) async {
    Widget view = Container();
    Completer<Ad?> completer = Completer();

    DateTime now = DateTime.now();
    EventUtils.instance.addEvent(
      "ad_request",
      data: {"ad_format": "native", "ad_source_client": "admob","ad_sense": adSense.name, "ad_pos_id": key,  "ad_code_id": adId},
    );

    view = Container(
      constraints: BoxConstraints(minWidth: 0, minHeight: 0, maxHeight: 350, maxWidth: 350),
      child: AdWidget(
        ad: NativeAd(
          nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
          nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.landscape),
          adUnitId: adId,
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              AppLog.i("admob native加载成功");

              adView.value = getAdCloseView(view);

              completer.complete(ad);
              EventUtils.instance.addEvent(
                "ad_return",
                data: {"ad_format": "banner","ad_sense": adSense.name, "ad_source_client": "admob", "ad_pos_id": key, "ad_code_id": adId},
              );
            },
            onAdFailedToLoad: (ad, e) {
              AppLog.e("admob native加载失败:${e.toString()}");
              ad.dispose();
              completer.complete(null);
              EventUtils.instance.addEvent(
                "ad_return_fail",
                data: {
                  "ad_format": "native",
                  "ad_source_client": "admob",
                  "ad_pos_id": key,
                  "ad_sense": adSense.name,
                  "ad_code_id": adId,
                  "reason": e.message,
                  "ad_request_time": DateTime.now().difference(now).inMilliseconds,
                },
              );
            },
            onAdClicked: (ad) {
              EventUtils.instance.addEvent(
                "ad_click",
                data: {"ad_format": "native", "ad_source_client": "admob", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId},
              );
            },
            onAdClosed: (ad) {
              EventUtils.instance.addEvent(
                "ad_close",
                data: {"ad_format": "native", "ad_source_client": "admob", "ad_pos_id": key, "ad_sense": adSense.name, "ad_code_id": adId},
              );
            },
            onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
              TbaUtils.instance.postAd(
                ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
                adSense: adSense.name,
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_format: "native",
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                adPosName: key,
                // precision_type: precision.name,
                //   positionKey: positionKey
              );
            },
          ),
          request: AdRequest(httpTimeoutMillis: 9000),
        )..load(),
      ),
    );

    return completer.future;
  }
}
