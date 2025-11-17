import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/assets.dart';
import '../ui/main/setting/feedback.dart';
import '../uinew/main/home/u_play.dart';
import 'ad/ad_util.dart';
import 'log.dart';

class MyDialogUtils {
  MyDialogUtils._internal() : super();
  static final MyDialogUtils _instance = MyDialogUtils._internal();

  static MyDialogUtils get instance {
    return _instance;
  }

  showRateDialog({bool isPlayPage = false}) async {
    if (AdUtils.instance.adIsShowing) {
      AppLog.e("广告已显示，不显示好评");
      return;
    }

    var sp = await SharedPreferences.getInstance();
    //判断首次安装时间是否今天
    var installTimeMs = sp.getInt("installTimeMs") ?? 0;
    var nowD = DateTime.now();
    var lastInstallDate = DateTime.fromMillisecondsSinceEpoch(installTimeMs);
    if (lastInstallDate.year == nowD.year &&
        lastInstallDate.month == nowD.month &&
        lastInstallDate.day == nowD.day) {
      AppLog.e("安装当天不显示");
      //安装当天不显示
      return;
    }

    var isShowed = sp.getBool("IsShowedRateDialog") ?? false;
    //获取上次弹窗时间
    var ms = sp.getInt("LastRateDialogDateMs") ?? 0;
    //获取弹窗次数
    var showNum = sp.getInt("RateDialogShowNum") ?? 0;

    if (isShowed) {
      AppLog.e("已经评价过");
      return;
    }
    if (showNum >= 5) {
      AppLog.e("已经显示过5次");
      return;
    }
    //判断上次弹窗时间，一天一次
    var lastHours =
        DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(ms))
            .inHours;
    if (lastHours < 24) {
      // AppLog.e(lastHours);
      AppLog.e("${DateTime.fromMillisecondsSinceEpoch(ms)}\n${DateTime.now()}");
      AppLog.e("今天已经弹过，不显示好评弹窗");
      return;
    }

    //不显示播放控件
    Get.find<UserPlayInfoController>().hideFloatingWidget();
    await sp.setInt(
      "LastRateDialogDateMs",
      DateTime.now().millisecondsSinceEpoch,
    );
    await sp.setInt("RateDialogShowNum", showNum + 1);
    await Get.dialog(RateDialog());
    //不显示播放控件
    //判断是否在播放页面
    if (!isPlayPage) {
      Get.find<UserPlayInfoController>().showFloatingWidget();
    }
  }

  showOtherAppDialog() async {
    // 0-不导量
    // 1-非强制
    // 2-强制

    await FirebaseRemoteConfig.instance.fetchAndActivate();

    var importCode = FirebaseRemoteConfig.instance.getInt("musicmuse_import");

    AppLog.e("导量:$importCode");
    if (importCode == 0) {
      return;
    }

    // var isOk = await FirebaseRemoteConfig.instance.fetchAndActivate();
    // AppLog.e(isOk);
    // if (isOk) {
    //   AppLog.e(isOk);
    // }

    // AppLog.e(FirebaseRemoteConfig.instance.getString("musicmuse_update_link"));
    //TODO 测试
    // var importCode = 1;

    //不显示播放控件
    Get.find<UserPlayInfoController>().hideFloatingWidget();
    await Get.dialog(
      OtherAppDialog(canClose: importCode == 1),
      barrierDismissible: importCode == 1,
    );
    //不显示播放控件
    Get.find<UserPlayInfoController>().showFloatingWidget();
  }
}

class OtherAppDialog extends GetView {
  final bool canClose;

  const OtherAppDialog({super.key, required this.canClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Get.back();
      },
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 37.w),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Center(
            child: Container(
              width: double.infinity,
              // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
              decoration: BoxDecoration(
                // color: Color(0xff202020),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 396.w,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            Assets.oimgBgDialogOapp,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 127.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 30.w),
                                  child: Text(
                                    "New App".tr,
                                    style: TextStyle(
                                      fontSize: 26.w,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28.w),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Text(
                                      !canClose
                                          ? "otherAppDialogText1".tr
                                          : "otherAppDialogText2".tr,
                                      style: TextStyle(
                                        fontSize: 16.w,
                                        height: 1.5,
                                        color: Color(
                                          0xff141414,
                                        ).withOpacity(0.75),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28.w),
                                //按钮
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    // 当前应用6667107568
                                    // var link =
                                    //     "https://apps.apple.com/app/id6667107568";

                                    var link = FirebaseRemoteConfig.instance
                                        .getString("musicmuse_update_link");

                                    await launchUrl(Uri.parse(link));
                                  },
                                  child: Container(
                                    height: 48.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.w),
                                      color: Color(0xff985CFF),
                                    ),
                                    child: Text(
                                      "Confirm".tr,
                                      style: TextStyle(
                                        fontSize: 16.w,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 45.w),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.w),
                  if (canClose)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Image.asset(
                        Assets.oimgIconDialogClose,
                        width: 32.w,
                        height: 32.w,
                      ),
                      onTap: () {
                        Get.back();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RateDialog extends GetView {
  const RateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Get.back();
      },
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 48.w),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Center(
            child: Container(
              width: double.infinity,
              // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
              decoration: BoxDecoration(
                // color: Color(0xff202020),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 348.w,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            Assets.oimgBgDialogRate,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 149.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                Text(
                                  "Enjoying Our App".tr,
                                  style: TextStyle(fontSize: 22.w),
                                ),
                                SizedBox(height: 20.w),
                                Text(
                                  "ratingStr".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    height: 1.4,
                                    color: Color(0xff141414).withOpacity(0.75),
                                  ),
                                ),
                                Spacer(),
                                RatingBar(
                                  allowHalfRating: false,
                                  initialRating: 1,
                                  itemCount: 5,
                                  itemSize: 34.w,
                                  itemPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  ratingWidget: RatingWidget(
                                    full: Image.asset(Assets.oimgIconRateOn),
                                    half: Container(),
                                    empty: Image.asset(Assets.oimgIconRateOff),
                                  ),
                                  onRatingUpdate: (value) async {
                                    Get.back();

                                    //点击了评分，下次不再弹出
                                    var sp =
                                        await SharedPreferences.getInstance();
                                    sp.setBool("IsShowedRateDialog", true);
                                    int starNum = value.toInt();
                                    if (starNum < 4) {
                                      Get.to(FeedbackPage());
                                    } else {
                                      var url =
                                          GetPlatform.isAndroid
                                              ? "https://play.google.com/store/apps/details?id=com.musewave.player.music"
                                              : "https://apps.apple.com/app/id6667107568?action=write-review";
                                      launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                                SizedBox(height: 41.w),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.w),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Image.asset(
                      Assets.oimgIconDialogClose,
                      width: 32.w,
                      height: 32.w,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
