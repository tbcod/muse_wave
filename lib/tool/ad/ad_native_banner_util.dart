
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/tba/event_util.dart';

import 'ad_util.dart';
import 'admob_util.dart';


class BannerNativeAdView extends GetView<BannerNativeAdViewController> {
  final AdPosId posId;
  final AdSense adScene;
  final bool isSmall;

  @override
  String? get tag => "${posId.name}_${adScene.name}";

  const BannerNativeAdView({super.key, required this.posId, required this.adScene, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BannerNativeAdViewController(posId, adScene, isSmall), tag: tag);
    return Container(alignment: Alignment.center, child: Obx(() => controller.adView.value));
  }
}


class BannerNativeAdViewController extends GetxController {
  BannerNativeAdViewController(this.adPosId, this.adScene, this.isSmall);

  AdPosId adPosId;
  AdSense adScene;
  var isSmall = false;
  var adId = "";

  Rx<Widget> adView = Container().obs;

  //0未加载 1.2admob 3.4max 5.6topon
  var loadType = 0.obs;

  Ad? admobAd;

  loadAd(AdPosId adPosId, AdSense adSense) async {
    String key = adPosId.name;
    AppLog.i("开始加载广告位:$key, ${adSense.name}");

    adView.value = Container();

    var adJson = AdUtils.instance.adJson;
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告:$key");
      return;
    }

    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      AppLog.e("广告key数据空");
      return;
    }

    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    var isOk = false;

    EventUtils.instance.addEvent("ad_request_total", data: {"ad_pos_id": adPosId.name});
    DateTime requestStartTime = DateTime.now();

    String type = '';
    String source = '';
    String ad_id = '';

    for (var item in configList) {
      type = item["adtype"];
      source = item["adsource"];
      ad_id = item["placementid"];
      AppLog.i("开始加载原生广告:$type, $source, ${adSense.name}, $ad_id");

      if (source == "admob") {
        if (type == "native") {
          var ad = await AdmobUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
          if (ad != null) {
            loadType.value = 1;
            isOk = true;
            admobAd = ad;
          }
        } else if (type == "banner") {
          var ad = await AdmobUtils.instance.loadBanner(ad_id, key, adSense, adView, isSmall: isSmall);
          if (ad != null) {
            loadType.value = 2;
            isOk = true;
            admobAd = ad;
          }
        }
      }
      // else if (source == "max") {
      //   if (type == "native") {
      //     var isLoadMaxAd = await MaxUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
      //     if (isLoadMaxAd) {
      //       isOk = true;
      //       loadType.value = 3;
      //     }
      //   } else if (type == "banner") {
      //     var isLoadMaxAd = await MaxUtils.instance.loadBanner(ad_id, key, adSense, adView, isSmall: isSmall);
      //     if (isLoadMaxAd) {
      //       isOk = true;
      //       loadType.value = 4;
      //     }
      //   }
      // }
      // else if (source == "topon") {
      //   if (type == "native") {
      //     var isLoadOk = await TopOnUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
      //     if (isLoadOk) {
      //       isOk = true;
      //       loadType.value = 5;
      //     }
      //   } else if (type == "banner") {
      //     var isLoadOk = await TopOnUtils.instance.loadBannerAd(ad_id, key, adSense, adView, isSmall: isSmall);
      //     if (isLoadOk) {
      //       isOk = true;
      //       loadType.value = 6;
      //     }
      //   }
      // }

      adId = ad_id;
      if (isOk) {
        AppLog.i("原生广告加载完成: ${isOk ? "成功" : "失败"}---$type, $source, $ad_id");
        break;
      } else {
        AppLog.e("原生广告加载: ${isOk ? "成功" : "失败"}---$type, $source, $ad_id");
        //加载失败加载下一条
        continue;
      }
    }

    if (!isOk) {
      EventUtils.instance.addEvent(
        "ad_impression_fail",
        data: {
          "ad_format": "",
          "ad_source_client": "",
          "ad_code_id": "",
          "ad_pos_id": adPosId.name,
          "ad_sense": adSense.name,
          "reason": "ad_nocache",
          "ad_function": "",
        },
      );
    } else {
      EventUtils.instance.addEvent(
        "ad_return_succ_toal",
        data: {
          "ad_pos_id": adPosId.name,
          "ad_format": type,
          "ad_source_client": source,
          "ad_code_id": ad_id,
          "ad_request_time": DateTime.now().difference(requestStartTime).inMilliseconds,
        },
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAd(adPosId, adScene);
  }

  @override
  void onClose() {
    super.onClose();
    // AppLog.i("原生广告页面关闭：${admobAd?.adUnitId}");

    admobAd?.dispose();
    //
    // if (loadType.value == 5 || loadType.value == 6) {
    //   //topon 删除
    //   TopOnUtils.instance.allCom.remove(adId);
    // }
  }
}