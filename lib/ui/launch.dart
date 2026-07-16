import 'dart:async';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/api/base_api.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/ad/admob_util.dart';
import 'package:muse_wave/tool/adjust_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/native_utils.dart';
import 'package:muse_wave/tool/referrer_util.dart';
import 'package:muse_wave/tool/remote_utils.dart';
import 'package:muse_wave/ui/main_page.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tool/ad/ad_util.dart';
import '../tool/log.dart';
import '../tool/tba/c_util.dart';
import '../tool/tba/event_util.dart';
import '../uinew/u_main.dart';

class LaunchPageController extends GetxController {
  var progress = 0.0.obs;
  static const int _maxAppLaunchTime = 7;

  bool get isB => bus.isBMode;

  bool get isA => !isB;

  bool _isCloakComplete = false;

  @override
  void onInit() {
    super.onInit();
    bus.setAppLaunchCount();
    ReferrerUtil.sh.init();
    _requestCloak();
  }

  @override
  void onReady() async {
    AppLog.i("App开始加载");
    bus.appLaunchTime = DateTime.now();
    countdown();
    try {
      AdmobUtils.instance.init();
      await loadAd().timeout(Duration(seconds: _maxAppLaunchTime));
      await _userCheck();
      await showAd();
    } on TimeoutException catch (e) {
      AppLog.e("loadAd time out: ${e.duration?.inSeconds}s");
    } catch (e) {
      AppLog.e("加载广告失败: $e");
    }

    toMainPage();

    super.onReady();
  }

  @override
  onClose() {
    AppLog.i("LaunchPageController onClose");
    super.onClose();
  }

  Future _userCheck() async {
    if (isA && !_isCloakComplete) {
      double diff = (DateTime.now().difference(bus.appLaunchTime)).inMilliseconds / 1000;
      if (diff < _maxAppLaunchTime) {
        AppLog.i("等待user请求完成，已等待${diff}s");
        await Future.delayed(const Duration(milliseconds: 500));
        await _userCheck();
        return;
      }
    }
  }

  Future _requestCloak() async {
    if (isB) {
      //已经是用户模式，不用再请求
      Get.find<Application>().initNetPush();
      NativeUtils.instance.startSearchNotificationBar();
      _isCloakComplete = true;
      return;
    }

    var tempTime = DateTime.now();
    BaseModel result = await CUtil.instance.checkCloak();
    // if (result.data == null) {
    //   await Future.delayed(Duration(seconds: 1));
    //   result = await CUtil.instance.checkCloak();
    // }
    while (result.data == null && DateTime.now().difference(tempTime).inSeconds < _maxAppLaunchTime - 1) {
      AppLog.e("cloak请求失败，重试中...");
      await Future.delayed(Duration(seconds: 1));
      result = await CUtil.instance.checkCloak();
    }

    //命中黑名单：sardonic
    //正常模式：excerpt
    var okStr = GetPlatform.isIOS ? "excerpt" : "diesel";

    if (result.data == okStr) {
      await museSp.setBool("isOpenUser", true);
    }
    AppLog.i("获取user结果:${result.data}， ${result.data == 'diesel' ? "b" : "a"}");
    var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
    EventUtils.instance.addEvent("cloak_get", data: {"time": doTime});
    _isCloakComplete = true;
  }

  Future loadAd() async {
    await AdUtils.instance.loadAd(
      AdPosId.open,
      adSense: bus.isFirstAppLaunch ? AdSense.first : AdSense.cold,
      forceLocalJson: bus.isFirstAppLaunch,
    );
  }

  Future showAd() async {
    if (isToMain) {
      AppLog.i("已经跳转到首页, 不显示广告");
      return;
    }

    if (isA) {
      //A面不展示冷启动广告
    } else {
      AppLog.i("准备展示开屏广告(B展示open)");
      await AdUtils.instance.showAd(
        AdPosId.open,
        adSense: bus.isFirstAppLaunch ? AdSense.first : AdSense.cold,
        forceLocalJson: bus.isFirstAppLaunch,
        adFunction: AdFunction.unknown,
      );
    }
  }

  Future countdown() async {
    //倒计时7秒加载进度条
    int seconds = _maxAppLaunchTime;
    int count = seconds * 20;
    for (int i = 0; i < count; i++) {
      await Future.delayed(Duration(milliseconds: seconds * 1000 ~/ count));
      progress.value += 1 / count;
    }
    progress.value = 1;
    return true;
  }

  var isAdShow = false;
  var isToMain = false;

  toMainPage() async {
    if (isToMain) return;
    isToMain = true;
    progress.value = 1;
    if (isB) {
      Get.off(const UserMain(), routeName: "/UserMain");
      //预加载广告
      AdUtils.instance.loadAd(AdPosId.behavior, adSense: AdSense.play_page, forceLocalJson: bus.isFirstAppLaunch);
    } else {
      Get.off(const MainPage(), routeName: "/MainPage");
    }
    EventUtils.instance
        .addEvent("home_sh", data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "mode": isB ? "B" : "A"});
    EventUtils.instance.addEvent("open_click");
  }
}

class LaunchPage extends GetView<LaunchPageController> {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.lazyPut(() => LaunchPageController());
    Get.put(LaunchPageController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: Get.mediaQuery.padding.top),
            SizedBox(height: 150.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.w)),
                  child: Image.asset("assets/img/logo.png", fit: BoxFit.cover, width: 36.w, height: 36.w),
                ),
                SizedBox(width: 12.w),
                Text(MuseConfig.appName, style: TextStyle(fontSize: 16.w)),
              ],
            ),

            Spacer(),

            //进度条
            Text("Resource loading…".tr, style: TextStyle(color: Colors.black, fontSize: 14.w)),

            SizedBox(height: 16.w),
            SizedBox(
              width: 200.w,
              height: 4.w,
              child: Obx(
                () => LinearProgressIndicator(
                  value: controller.progress.value,
                  // minHeight: 4.w,
                  borderRadius: BorderRadius.circular(2.w),
                  color: Colors.black,
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                ),
              ),
            ),
            SizedBox(height: 100.w),
          ],
        ),
      ),
    );
  }
}
