import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/generated/assets.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/ad/ump_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/ad/ad_util.dart';
import '../tool/keep_view.dart';
import '../tool/log.dart';
import '../tool/tba/c_util.dart';
import '../uinew/u_main.dart';
import 'main/home.dart';
import 'main/home/play.dart';
import 'main/setting.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MainPageController());
    return WillPopScope(
      onWillPop: () async {
        if (GetPlatform.isIOS) {
          return true;
        }

        // 返回桌面逻辑
        AppLog.e("back");
        AndroidIntent intent = const AndroidIntent(action: 'android.intent.action.MAIN', category: "android.intent.category.HOME", flags: [Flag.FLAG_ACTIVITY_NEW_TASK]);
        intent.launch();
        AppLog.e("back1");

        // await SystemNavigator.pop();

        return false;
      },
      child: Scaffold(
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            currentIndex: controller.nowIndex.value,
            backgroundColor: Colors.white,
            onTap: (index) {
              // IdfaUtil.instance.showIdfaDialog();
              controller.nowIndex.value = index;
              controller.pageC.jumpToPage(index);
            },
            unselectedItemColor: Color(0xff8B94A7),
            selectedItemColor: Color(0xff558CFF),
            selectedLabelStyle: TextStyle(color: Color(0xff558CFF), fontSize: 12.w),
            unselectedLabelStyle: TextStyle(color: Color(0xff8B94A7), fontSize: 12.w),
            items: [
              BottomNavigationBarItem(icon: Image.asset(Assets.imgHomeOff, width: 24.w, height: 24.w), activeIcon: Image.asset(Assets.imgHomeOn, width: 24.w, height: 24.w), label: "Home"),
              BottomNavigationBarItem(icon: Image.asset(Assets.imgSettingOff, width: 24.w, height: 24.w), activeIcon: Image.asset(Assets.imgSettingOn, width: 24.w, height: 24.w), label: "Setting"),
            ],
          );
        }),
        body: PageView(controller: controller.pageC, physics: NeverScrollableScrollPhysics(), children: [KeepStateView(child: HomePage()), KeepStateView(child: SettingPage())]),
      ),
    );
  }
}

class MainPageController extends GetxController {
  var pageC = PageController();
  var nowIndex = 0.obs;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void onInit() {
    super.onInit();
    Get.put(PlayPageController());

    EventUtils.instance.addEvent("enter_home", data: {"source": "a"});
    EventUtils.instance.addEvent("home_no");

    UmpUtil.sh.showUMP();


    //设置网络监听，成功后打开B面
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {

      // if (kDebugMode && !MuseConfig.isUser) {
      //   await Future.delayed(Duration(seconds: 1));
      //   await museSp.setBool("isOpenUser", false);
      //   return;
      // }


      var result = await CUtil.instance.checkCloak();

      //监听到网络变化重新请求一次
      var okStr = GetPlatform.isIOS ? "excerpt" : "diesel";

      if (result.data == okStr) {
        //缓存
        var sp = await SharedPreferences.getInstance();
        await sp.setBool("isOpenUser", true);
        Get.off(const UserMain());
      }
    });
  }

  @override
  void onReady() {
    //预加载广告
    AdUtils.instance.loadAd(AdPosId.behavior, adFirstType: AdFirstType.int_main_first, adSense: AdSense.play_page, forceLocalJson: bus.isFirstAppLaunch);
    AdUtils.instance.loadAd(AdPosId.muse_local_int,adFirstType: AdFirstType.launch_first, adSense: AdSense.hot,forceLocalJson: bus.isFirstAppLaunch);
    AdUtils.instance.loadAd(AdPosId.muse_local_reward, adSense: AdSense.set);
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();

    subscription?.cancel();

    //关闭播放页面
    if (Get.isRegistered<PlayPageController>()) {
      Get.find<PlayPageController>().onClose();
      Get.delete<PlayPageController>();
    }
  }
}
