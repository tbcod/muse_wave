import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/native_utils.dart';
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

  var isB = false;

  bool get isA => !isB;

  bool _isCloakComplete = false;

  bindData() async {
    EventUtils.instance.addEvent("open_click");
    bus.setAppLaunchCount();

    var sp = await SharedPreferences.getInstance();

    var isOpenUser = sp.getBool("isOpenUser") ?? false;
    if (isOpenUser) {
      //已经是用户模式，不用再请求
      await Get.find<Application>().initNetPush();
      NativeUtils.instance.startSearchNotificationBar();
      isB = true;
      _isCloakComplete = true;
      return;
    }

    var tempTime = DateTime.now();
    var result = await CUtil.instance.checkCloak();
    _isCloakComplete = true;

    AppLog.i("获取cloak结果:${result.data}， ${result.data == 'diesel' ? "user" : "cloak"}");

    var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
    EventUtils.instance.addEvent("cloak_get", data: {"time": doTime});
    //命中黑名单：sardonic
    //正常模式：excerpt
    var okStr = GetPlatform.isIOS ? "excerpt" : "diesel";

    if (result.data == okStr) {
      //缓存
      await sp.setBool("isOpenUser", true);
      isB = true;
    } else {
      isB = false;
    }
  }

  @override
  void onReady() async {
    super.onReady();
    countdown();
    try {
      await loadAd().timeout(Duration(seconds: _maxAppLaunchTime));
      await showAd();
    } on TimeoutException catch (e) {
      AppLog.e("loadAd time out: ${e.duration?.inSeconds}s");
    } catch (e) {
      AppLog.e("加载广告失败: $e");
    }
    toMainPage();
  }

  Future loadAd() async {
    // AppLog.e("启动页加载广告");
    //
    // //判断第一次是否加载
    // // var sp = await SharedPreferences.getInstance();
    // // var isFirstLoadAd = sp.getBool("isFirstLoadAd") ?? true;
    //
    // if (bus.isFirstAppLaunch && !RemoteUtil.shareInstance.isShowOpenAd) {
    //   AppLog.i("第一次不加载广告");
    //   // sp.setBool("isFirstLoadAd", false);
    //   AdUtils.instance.loadAd(AdPosId.open, adSense: AdScene.open_cool);
    //   return;
    // }
    // AppLog.i("不是第一次启动或者开关打开了，即将加载广告");
    // // sp.setBool("isFirstLoadAd", false);
    // await AdUtils.instance.loadAd(AdPosId.open, adSense: AdScene.open_cool);

    bool isBShowOpenAd = RemoteUtil.shareInstance.isShowOpenAd;
    AppLog.i("启动页加载广告 isB：$isB, isBShowOpenAd:$isBShowOpenAd，isFirstAppLaunch:${bus.isFirstAppLaunch}");

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

    if (!_isCloakComplete && isA) {
      int diff = (DateTime.now().difference(startTime)).inSeconds;
      if (diff >= _maxAppLaunchTime) {
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      return showAd();
    }

    if (isA) {
      if (!bus.isFirstAppLaunch) {
        AppLog.i("准备展示开屏广告(A非首次展示本地&local int)： ");
        await AdUtils.instance.showAd(AdPosId.open, adSense: AdScene.open_cool, forceLocalJson: true);
      }
    } else {
      if (!bus.isFirstAppLaunch || RemoteUtil.shareInstance.isShowOpenAd) {
        AppLog.i("准备展示开屏广告(B展示open");
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

    if (!isAdShow) {
      //没有显示广告时才跳转
      toMainPage();
    }

    return true;
  }

  var isAdShow = false;
  var isToMain = false;

  toMainPage() async {
    if (!isToMain && !isClosed) {
      isToMain = true;
      progress.value = 1;

      // Get.off(const MainPage());
      // return;

      // if (!MuseConfig.isUser) {
      //   //TODO 测试A
      //   // Get.off(const MainPage(), routeName: "/MainPage");
      //   // return;
      //
      //   // EventUtils.instance.addEvent("enter_home");
      //   // EventUtils.instance.addEvent("home_source");
      //   Get.off(const UserMain(), routeName: "/UserMain");
      //   return;
      // }

      var sp = await SharedPreferences.getInstance();

      var isOpenUser = sp.getBool("isOpenUser") ?? false;

      if (isB) {
        // EventUtils.instance.addEvent("enter_home");
        // EventUtils.instance.addEvent("home_source");
        Get.off(const UserMain(), routeName: "/UserMain");
        return;
      }
      // EventUtils.instance.addEvent("enter_home");
      // EventUtils.instance.addEvent("home_no");

      Get.off(isOpenUser ? const UserMain() : const MainPage(), routeName: isOpenUser ? "/UserMain" : "/MainPage");
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
                Container(clipBehavior: Clip.hardEdge, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.w)), child: Image.asset("assets/img/logo.png", fit: BoxFit.cover, width: 36.w, height: 36.w)),
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
