import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/remote_utils.dart';

enum CloseType { normal, disable, hide }

class FullAdmobNativePage extends StatefulWidget {
  const FullAdmobNativePage({super.key, required this.ad, required this.onClose});

  final NativeAd ad;
  final VoidCallback onClose;

  @override
  State<FullAdmobNativePage> createState() => _FullAdmobNativePageState();
}

class _FullAdmobNativePageState extends State<FullAdmobNativePage> {
  int maxSec = 0;
  final _curSec = 0.obs;
  Timer? _timer;
  bool _isDarkMode = false;
  StreamSubscription? _streamSubscription;

  late NativeAd nativeAd;

  final _closeType = CloseType.normal.obs;

  @override
  void initState() {
    nativeAd = widget.ad;
    maxSec = RemoteUtil.shareInstance.adNativeCountDown;
    _isDarkMode = true;
    if (maxSec == 0) {
      _curSec.value = -1;
      _showCloseBtn();
    } else {
      _curSec.value = maxSec;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        _curSec.value = _curSec.value - 1;
        if (_curSec.value < 0) {
          _curSec.value = -1;
          _timer?.cancel();
          _timer = null;
          _showCloseBtn();
        }
      });
    }

    _streamSubscription = AdUtils.instance.fullNativeAdClicked.listen((val) {
      _closeType.value = CloseType.normal;
      _curSec.value = -1;
    });
    super.initState();
  }

  _showCloseBtn() {
    if (RemoteUtil.shareInstance.adNativeScreenClick == 0) {
      _closeType.value = CloseType.normal;
    } else {
      int rate = RemoteUtil.shareInstance.adNativeScreenClick;
      if (rate >= 100) {
        _closeType.value = CloseType.disable;
      } else {
        final random = Random().nextInt(100);
        bool result = random < rate;
        AppLog.i("random=$random,rate=$rate, 跳转=$result");
        _closeType.value = result ? CloseType.disable : CloseType.normal;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
          decoration: const BoxDecoration(gradient: LinearGradient(end: Alignment.bottomCenter, begin: Alignment.topCenter, colors: [Color(0xffb79efe), Color(0xff5e60dc)])),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: StatefulBuilder(
                  builder: (context, a) {
                    return SizedBox(
                      height: 620,
                      child: Builder(
                        builder: (_) {
                          try {
                            return AdWidget(ad: widget.ad);
                          } catch (e) {
                            AppLog.e("AdWidget报错了：${e.toString()}");
                            _closeType.value = CloseType.normal;
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Obx(() {
                return Visibility(
                  visible: _curSec.value >= 0,
                  child: Positioned(
                    right: 20,
                    top: 24,
                    child: Container(
                      alignment: Alignment.center,
                      width: 24,
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 1.5,
                            value: 1 - _curSec.value / maxSec,
                            backgroundColor: _isDarkMode ? Colors.white24 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation(_isDarkMode ? Colors.white : Colors.black45),
                          ),
                          Text("${max(_curSec.value, 0)}s", style: const TextStyle(fontSize: 10, color: Color(0xffbfbfbf))),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                return Positioned(
                  left: 24,
                  top: 28,
                  child:
                      _closeType.value == CloseType.disable
                          ? IgnorePointer(
                            ignoring: true,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(11)),
                              child: const Padding(padding: EdgeInsets.all(2.0), child: Icon(Icons.close_rounded, size: 20, color: Colors.black38)),
                            ),
                          )
                          : GestureDetector(
                            onTap: () {
                              AppLog.i("关闭点击广告");
                              // AppLog.i("关闭点击广告2 ${Get.currentRoute}, ${Get.previousRoute}, isBottomSheet:${Get.routing.isBottomSheet}, removed:${Get.routing.removed}");
                              Get.back();
                              // AppLog.i("关闭点击广告3 ${Get.currentRoute}, ${Get.previousRoute}, isBottomSheet:${Get.routing.isBottomSheet}, removed:${Get.routing.removed}");
                              if (Get.previousRoute == "LaunchLoad") {
                                Get.back();
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(11)),
                              child: const Padding(padding: EdgeInsets.all(2.0), child: Icon(Icons.close_rounded, size: 20, color: Colors.black54)),
                            ),
                          ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    widget.onClose.call();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _timer?.cancel();
    _timer = null;
    AdUtils.instance.adIsShowing = false;
    super.dispose();
  }
}
