import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
    await MobileAds.instance.initialize();

    await MobileAds.instance.setAppMuted(true);
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

  Future<Ad?> loadBanner(
    String adId,
    String key,
    String positionKey,
    Rx<Widget> adView, {
    bool isSmall = false,
  }) {
    Widget view = Container();
    Completer<Ad?> completer = Completer();
    view = Container(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
        maxHeight: isSmall ? 50 : 250,
        maxWidth: double.infinity,
      ),
      child: AdWidget(
        ad: BannerAd(
          size: isSmall ? AdSize.banner : AdSize.mediumRectangle,
          adUnitId: adId,
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              AppLog.e("原生广告banner加载成功");
              adView.value = isSmall ? view : getAdCloseView(view);
              completer.complete(ad);
            },
            onAdFailedToLoad: (ad, e) {
              AppLog.e("原生广告banner加载失败");
              ad.dispose();
              completer.complete(null);
            },
            onPaidEvent: (
              Ad ad,
              double valueMicros,
              PrecisionType precision,
              String currencyCode,
            ) {
              TbaUtils.instance.postAd(
                // ad_network: ad.responseInfo?.mediationAdapterClassName ?? "",
                ad_network:
                    ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                    "",
                ad_pos_id: positionKey,
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_format: "banner",
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                ad_sence: key
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

  Future<Ad?> loadNativeAd(
    String adId,
    String key,
    String positionKey,
    Rx<Widget> adView,
  ) async {
    Widget view = Container();
    Completer<Ad?> completer = Completer();


    view = Container(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
        maxHeight: 350,
        maxWidth: 350,
      ),
      child: AdWidget(
        ad: NativeAd(
          nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
          ),
          nativeAdOptions: NativeAdOptions(
            mediaAspectRatio: MediaAspectRatio.landscape,
          ),
          adUnitId: adId,
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              AppLog.e("admob native加载成功");

              adView.value = getAdCloseView(view);

              completer.complete(ad);
            },
            onAdFailedToLoad: (ad, e) {
              AppLog.e("admob native加载失败");
              AppLog.e(e);
              ad.dispose();
              completer.complete(null);
            },
            onPaidEvent: (
              Ad ad,
              double valueMicros,
              PrecisionType precision,
              String currencyCode,
            ) {
              TbaUtils.instance.postAd(
                ad_network:
                    ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                    "",
                ad_pos_id: positionKey,
                ad_source: "admob",
                ad_unit_id: ad.adUnitId,
                ad_format: "native",
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                ad_sence: key
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
