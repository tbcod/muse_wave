import 'dart:async';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/muse_config.dart';
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
  late DateTime startTime;
  static const int _maxAppLaunchTime = 7;

  @override
  void onInit() {
    super.onInit();
    // IdfaUtil.instance.showIdfaDialog();
    startTime = DateTime.now();
    bindData();
  }

  bool get isB => bus.isBMode;

  bool get isA => !isB;

  bool _isCloakComplete = false;

  bindData() async {
    EventUtils.instance.addEvent("open_click");
    bus.setAppLaunchCount();
    ReferrerUtil.sh.init();

    var sp = await SharedPreferences.getInstance();

    var isOpenUser = sp.getBool("isOpenUser") ?? false;
    if (isOpenUser) {
      //已经是用户模式，不用再请求
      await Get.find<Application>().initNetPush();
      NativeUtils.instance.startSearchNotificationBar();
      _isCloakComplete = true;
      return;
    }

    var tempTime = DateTime.now();
    var result = await CUtil.instance.checkCloak();
    if (result.data == null) {
      await Future.delayed(Duration(seconds: 1));
      result = await CUtil.instance.checkCloak();
    }

    // if (kDebugMode && !MuseConfig.isUser) {
    //   await Future.delayed(Duration(seconds: 3));
    //   await sp.setBool("isOpenUser", false);
    //   _isCloakComplete = true;
    //   return;
    // }


    //命中黑名单：sardonic
    //正常模式：excerpt
    var okStr = GetPlatform.isIOS ? "excerpt" : "diesel";

    if (result.data == okStr) {
      await sp.setBool("isOpenUser", true);
    }
    AppLog.i("获取user结果:${result.data}， ${result.data == 'diesel' ? "user" : "cloak"}");
    var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
    EventUtils.instance.addEvent("cloak_get", data: {"time": doTime});
    _isCloakComplete = true;
  }

  @override
  void onReady() async {
    super.onReady();
    countdown();
    await _userCheck();
    try {
      int timeoutSeconds = max(1, _maxAppLaunchTime - DateTime.now().difference(startTime).inSeconds);
      AppLog.i("开始加载广告，剩余时间: ${timeoutSeconds}s");
      await loadAd().timeout(Duration(seconds: timeoutSeconds));
      await showAd();
    } on TimeoutException catch (e) {
      AppLog.e("loadAd time out: ${e.duration?.inSeconds}s");
    } catch (e) {
      AppLog.e("加载广告失败: $e");
    }
    toMainPage();
  }

  Future _userCheck() async {
    if (isA && !_isCloakComplete) {
      double diff = (DateTime.now().difference(startTime)).inMilliseconds / 1000;
      if (diff < _maxAppLaunchTime) {
        AppLog.i("等待user请求完成，已等待${diff}s");
        await Future.delayed(const Duration(milliseconds: 500));
        await _userCheck();
        return;
      }
    }
  }

  Future loadAd() async {
    bool isBShowOpenAd = RemoteUtil.shareInstance.isShowOpenAd;
    AppLog.i("启动页加载广告 isB：$isB，首次启动:${bus.isFirstAppLaunch}, first open:$isBShowOpenAd");

    if (isA) {
      if (bus.isFirstAppLaunch) {
        AdUtils.instance.loadAd(AdPosId.muse_local_int, forceLocalJson: true, adSense: AdScene.open_cool).then((v) {
          AdUtils.instance.loadAd(AdPosId.open, forceLocalJson: true, adSense: AdScene.open_cool);
        });
      } else {
        await AdUtils.instance.loadAd(AdPosId.muse_local_int, adSense: AdScene.open_cool);
        AdUtils.instance.loadAd(AdPosId.open, adSense: AdScene.open_cool);
      }
      return;
    }

    if (isB) {
      if (bus.isFirstAppLaunch) {
        if (isBShowOpenAd) {
          await AdUtils.instance.loadAd(AdPosId.open, forceLocalJson: true, adSense: AdScene.open_cool);
        } else {
          AdUtils.instance.loadAd(AdPosId.open, forceLocalJson: true, adSense: AdScene.open_cool);
        }
      } else {
        await AdUtils.instance.loadAd(AdPosId.open, adSense: AdScene.open_cool);
      }
      return;
    }
  }

  Future showAd() async {
    if (isToMain) {
      AppLog.i("已经跳转到首页, 不显示广告");
      return;
    }

    if (isA) {
      if (!bus.isFirstAppLaunch) {
        AppLog.i("准备展示开屏广告(A非首次展示本地&local int)： ");
        await AdUtils.instance.showAd(AdPosId.open, adSense: AdScene.open_cool, forceLocalJson: true);
      }
    } else {
      if (!bus.isFirstAppLaunch || RemoteUtil.shareInstance.isShowOpenAd) {
        AppLog.i("准备展示开屏广告(B展示open)");
        await AdUtils.instance.showAd(AdPosId.open, adSense: AdScene.open_cool, forceLocalJson: bus.isFirstAppLaunch);
      }
    }
  }

  Future countdown() async {
    //倒计时7秒加载进度条

    int seconds = _maxAppLaunchTime;

    // seconds = seconds * 1000;
    for (int i = 0; i < seconds * 100; i++) {
      await Future.delayed(Duration(milliseconds: 10));
      progress.value += 1 / seconds / 100;
    }

    // if (!isAdShow) {
    //   //没有显示广告时才跳转
    //   toMainPage();
    // }

    progress.value = 1;

    return true;
  }

  var isAdShow = false;
  var isToMain = false;

  toMainPage() async {
    // if (!isToMain && !isClosed) {
    //
    // }
    isToMain = true;
    progress.value = 1;
    if (isB) {
      Get.off(const UserMain(), routeName: "/UserMain");
    } else {
      Get.off(const MainPage(), routeName: "/MainPage");
    }
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
            Container(
              width: 200.w,
              height: 4.w,
              child: Obx(
                () => LinearProgressIndicator(
                  value: controller.progress.value,
                  // minHeight: 4.w,
                  borderRadius: BorderRadius.circular(2.w),
                  color: Colors.black,
                  backgroundColor: Colors.black.withOpacity(0.2),
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
