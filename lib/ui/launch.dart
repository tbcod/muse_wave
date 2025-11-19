import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/ui/main_page.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tool/ad/ad_util.dart';
import '../tool/log.dart';
import '../tool/tba/c_util.dart';
import '../tool/tba/event_util.dart';
import '../uinew/u_main.dart';

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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Image.asset(
                    "assets/img/logo.png",
                    fit: BoxFit.cover,
                    width: 36.w,
                    height: 36.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(MuseConfig.appName, style: TextStyle(fontSize: 16.w)),
              ],
            ),

            Spacer(),

            //进度条
            Text(
              "Resource loading…".tr,
              style: TextStyle(color: Colors.black, fontSize: 14.w),
            ),

            SizedBox(height: 16.w),
            Container(
              width: 200.w,
              height: 4.w,
              child: Obx(
                () => LinearProgressIndicator(
                  value: controller.progress.value,
                  minHeight: 4.w,
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

class LaunchPageController extends GetxController {
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // IdfaUtil.instance.showIdfaDialog();
    bindData();
  }

  var isB = false;
  bindData() async {
    EventUtils.instance.addEvent("open_click");

    var sp = await SharedPreferences.getInstance();

    var isOpenUser = sp.getBool("isOpenUser") ?? false;
    if (isOpenUser) {
      //已经是用户模式，不用再请求
      isB = true;
      return;
    }

    var tempTime = DateTime.now();
    var result = await CUtil.instance.checkCloak();

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

    loadAd();
    await countdown();
  }

  loadAd() async {
    AppLog.e("启动页加载广告");
    isAdShow = false;

    //判断第一次是否加载
    var sp = await SharedPreferences.getInstance();
    var isFirstLoadAd = sp.getBool("isFirstLoadAd") ?? true;

    var openAdStr = FirebaseRemoteConfig.instance.getString(
      "musicmuse_open_ad",
    );

    if (openAdStr.isEmpty) {
      //默认为close,
      openAdStr = "close";
    }

    if (isFirstLoadAd && openAdStr == "close") {
      AppLog.e("第一次不加载广告");
      sp.setBool("isFirstLoadAd", false);
      return;
    }
    AppLog.e("不是第一次启动或者开关打开了，即将加载广告");
    sp.setBool("isFirstLoadAd", false);

    var showAdNum = 0;
    AdUtils.instance.loadAd(
      "open",
      onLoad: (adId, isOk, e) {
        AppLog.e("启动页加载广告结果$isOk, $adId");
        AppLog.e("$adId");
        // AppLog.e("${e}");

        if (showAdNum != 0) {
          return;
        }
        showAdNum++;

        if (isOk) {
          if (isAdShow) {
            AppLog.e("已经显示过广告");
            return;
          }
          if (isToMain) {
            AppLog.e("已经跳转到首页");
            return;
          }

          //显示广告
          AdUtils.instance.showAd(
            "open",
            onShow: ShowCallback(
              onShowFail: (adId, e) {
                toMainPage();
              },
              onClose: (adId) {
                toMainPage();
              },
              onShow: (adId) {
                isAdShow = true;
              },
            ),
            adScene: AdScene.openCool,
          );
        }
      },
      positionKey: 'open',
    );
  }

  Future countdown() async {
    //倒计时7秒加载进度条

    int seconds = AdUtils.instance.adJson["timeout"] ?? 7;

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

      if (!MuseConfig.isUser) {
        //TODO 测试A
        // Get.off(const MainPage(), routeName: "/MainPage");
        // return;

        EventUtils.instance.addEvent("enter_home");
        EventUtils.instance.addEvent("home_source");
        Get.off(const UserMain(), routeName: "/UserMain");
        return;
      }

      var sp = await SharedPreferences.getInstance();

      var isOpenUser = sp.getBool("isOpenUser") ?? false;

      if (isOpenUser) {
        EventUtils.instance.addEvent("enter_home");
        EventUtils.instance.addEvent("home_source");
        Get.off(const UserMain(), routeName: "/UserMain");
        return;
      }
      EventUtils.instance.addEvent("enter_home");
      EventUtils.instance.addEvent("home_no");

      Get.off(
        isOpenUser ? const UserMain() : const MainPage(),
        routeName: isOpenUser ? "/UserMain" : "/MainPage",
      );
    }
  }
}
