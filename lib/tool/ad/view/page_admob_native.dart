import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtil;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/remote_utils.dart';

import 'full_admob_native.dart';

class PageAdmobNativeView extends GetView<PageAdmobNativeViewController> {
  const PageAdmobNativeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PageAdmobNativeViewController());
    return Container(alignment: Alignment.center, child: Obx(() => controller.adView.value));
  }
}

class PageAdmobNativeViewController extends GetxController {
  PageAdmobNativeViewController();

  Rx<Widget> adView = Container().obs;

  NativeAd? admobAd;
  StreamSubscription? _streamSubscription;

  final _closeType = CloseType.normal.obs;

  @override
  void onInit() {
    super.onInit();

    adView.value = Container();

    _streamSubscription = AdUtils.instance.pageNativeAdClicked.listen((val) {
      _closeType.value = CloseType.normal;
    });

    int screenClick = RemoteUtil.shareInstance.adPageNativeScreenClick;
    if (screenClick == 0) {
      _closeType.value = CloseType.normal;
    } else {
      if (screenClick >= 100) {
        _closeType.value = CloseType.disable;
      } else {
        final random = Random().nextInt(100);
        bool result = random < screenClick;
        AppLog.i("page native random=$random, screenClick=$screenClick, 跳转=$result");
        _closeType.value = result ? CloseType.disable : CloseType.normal;
      }
    }
  }

  @override
  void onReady() {
    // NativeAd? ad = AdUtils.instance.showNativeAd(AdPosition.NVPage_full.name, adScene: AdScene.play);
    // if (ad != null) {
    //   admobAd = ad;
    //   adView.value = _playAdWidget(ad);
    // } else {
    //
    // }
    AdUtils.instance.loadPageNativeAd(AdPosition.NVPage_full.name, positionKey: AdScene.play.name).then((v) {
      NativeAd? ad = AdUtils.instance.getPageNativeAd(AdPosition.NVPage_full.name, adScene: AdScene.play);
      if (ad != null) {
        admobAd = ad;
        adView.value = _playAdWidget(ad);
      }
    });
    super.onReady();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    await admobAd?.dispose();
    admobAd = null;
    // AdUtils.instance.loadPageNativeAd(AdPosition.NVPage_full.name, positionKey: AdScene.play.name);
  }

  Widget _playAdWidget(NativeAd ad) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(minWidth: 0, minHeight: 0, maxHeight: 350, maxWidth: ScreenUtil().screenWidth - 36),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: StatefulBuilder(
              builder: (context, a) {
                return SizedBox(
                  height: 600,
                  child: Builder(
                    builder: (_) {
                      try {
                        return AdWidget(ad: ad);
                      } catch (e) {
                        AppLog.e("AdWidget报错了：${e.toString()}");
                        _closeType.value = CloseType.normal;
                        adView.value = Container();
                        onClose();
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Obx(() {
            return Positioned(
              left: 24,
              top: 24,
              child:
                  _closeType.value == CloseType.disable
                      ? IgnorePointer(
                        ignoring: true,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                          child: const Padding(padding: EdgeInsets.all(2.0), child: Icon(Icons.close_rounded, size: 20, color: Colors.white)),
                        ),
                      )
                      : GestureDetector(
                        onTap: () {
                          _closeType.value = CloseType.normal;
                          adView.value = Container();
                          onClose();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: const Padding(padding: EdgeInsets.all(2.0), child: Icon(Icons.close_rounded, size: 20, color: Colors.white)),
                        ),
                      ),
            );
          }),
        ],
      ),
    );
  }
}
