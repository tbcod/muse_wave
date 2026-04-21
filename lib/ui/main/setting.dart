import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/generated/assets.dart';
import 'package:muse_wave/static/app_color.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/remote_utils.dart';
import 'package:muse_wave/ui/main/setting/feedback.dart';
import 'package:muse_wave/ui/main/setting/only_web.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../tool/toast.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SettingPageController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   title: const Text("标题"),
        // ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              AppBar(
                centerTitle: false,
                titleSpacing: 12.w,
                title: Text("Setting"),
                actions: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                      child: Image.asset("assets/img/icon_set_game.png", width: 32, height: 32),
                    ),
                    onTap: () async {
                      Get.to(() => OnlyWeb(), arguments: 3);
                    },
                  ),
                ],
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 5.w),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.w)),
                      child: ListView.separated(
                        itemBuilder: (_, i) {
                          if(i == 0) return _videoRewardItem();
                          return getItem(i - 1);
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, i) {
                          return Container(
                            width: double.infinity,
                            height: 1.w,
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            color: Color(0xfff7f7f7),
                          );
                        },
                        itemCount: controller.listTitle.length + 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getItem(int i) {
    var itemTitle = controller.listTitle[i];
    return InkWell(
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Image.asset(controller.listIcon[i], width: 24.w, height: 24.w),
            SizedBox(width: 16.w),
            Text(controller.listTitle[i], style: TextStyle(fontSize: 14.w, color: Color(0xff4d4d4d))),
            Spacer(),
            Image.asset(Assets.imgIconMeR, width: 16.w, height: 16.w),
          ],
        ),
      ),
      onTap: () async {
        if (itemTitle == "Feedback") {
          //反馈
          Get.to(FeedbackPage());
        } else if (itemTitle == "Privacy Policy") {
          Get.to(OnlyWeb(), arguments: 2);
        } else if (itemTitle == "Terms of Service") {
          Get.to(OnlyWeb(), arguments: 1);
        } else if (itemTitle == "Ad Tools") {
          // AppLog.e(AdUtils.instance.loadedAdMap);
          // AppLog.e(AdUtils.instance.adJson);
          //
          // Get.dialog(
          //     BaseDialog(
          //       title: "Tip",
          //       content: "choose",
          //       lBtnText: "Max",
          //       rBtnText: "Admob",
          //       lBtnOnTap: () {
          //         Get.back();
          //         AppLovinMAX.showMediationDebugger();
          //       },
          //       rBtnOnTap: () {
          //         Get.back();
          //         MobileAds.instance.openAdInspector((p0) {
          //           // ToastUtil.showToast(msg: p0?.message ?? "error");
          //         });
          //       },
          //     ),
          //     barrierDismissible: true);
        } else if (itemTitle == "Share") {
          var url = GetPlatform.isAndroid ? "https://play.google.com/store/apps/details?id=com.musewave.player.music" : "";
          await Clipboard.setData(ClipboardData(text: url));
          ToastUtil.showToast(msg: "Copy download link ok!");

          Share.share(url);
        } else if (itemTitle == "Evaluate") {
          var url = GetPlatform.isAndroid ? "https://play.google.com/store/apps/details?id=com.musewave.player.music" : "";
          if (await canLaunchUrl(Uri.parse(url))) {
            launchUrl(Uri.parse(url));
          } else {
            ToastUtil.showToast(msg: "No application found to open");
          }
        }
      },
    );
  }

  Widget _videoRewardItem() {
    return GestureDetector(
      onTap: () {
        controller.onClickReward();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset('assets/img/set_rewarded.png', width: 24.w, height: 24.w),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 0,
                      children: [
                        Text("Rewarded Ad", style: const TextStyle(height: 1, color: Color(0xff4d4d4d), fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Obx(() {
                          return Text(
                            "Remaining：${controller.curRemindHour.value}h",
                            style: TextStyle(fontSize: 12, color: Color(0xff3B7BFF),fontWeight: FontWeight.w500),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            Align(
              alignment: Alignment.centerRight,
              child: UnconstrainedBox(
                child: GestureDetector(
                  onTap: () {
                    controller.onClickReward();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xff3B7BFF)),
                    child: Text("Rewarded AD", style: TextStyle(fontSize: 12, color: Color(0xffffffff), fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingPageController extends GetxController {
  // var listTitle = ["Privacy Policy", "Terms of Service", "Feedback"];
  var listTitle = ["Feedback", "Share", "Evaluate"];

  var listIcon = [Assets.imgIconMe1, Assets.imgIconMe2, Assets.imgIconMe3];


  var curRemindHour = 12.obs;

  DateTime? lastVideoAdTime;

  int rewardCd = 0;

  @override
  void onInit() {
    super.onInit();

    curRemindHour.value = museSp.getInt('keyRemindListenTimeHours', def: 12);

    rewardCd = RemoteUtil.shareInstance.rewardVideoCd;

  }


  changeRemindHour(int hour) {
    curRemindHour.value = hour;
    museSp.setInt('keyRemindListenTimeHours', hour);
  }

  onClickReward() {
    Get.dialog(
      BaseDialog(
        title: "Rewarded Ad".tr,
        content: "Watch the video to increase listening time by 1h".tr,
        rBtnText: "Confirm".tr,
        lBtnText: "Cancel".tr,
        mainColor: AppColor.themeBlue,
        rBtnOnTap: () async {
          Get.back();
          if (lastVideoAdTime != null) {
            var diff = DateTime.now().difference(lastVideoAdTime!).inSeconds;
            if (diff < rewardCd) {
              ToastUtil.showToast(msg: "Please try again after $rewardCd seconds");
              return;
            }
          }
          bool isSuccess = await AdUtils.instance.showAd(AdPosId.muse_local_reward, adSense: AdScene.set);
          if (isSuccess) {
            lastVideoAdTime = DateTime.now();
            changeRemindHour(curRemindHour.value + 1);
            ToastUtil.showToast(msg: "Added 1h listening time. \nRemaining listening time：${curRemindHour.value}h");
          } else {
            lastVideoAdTime = null;
            ToastUtil.showToast(msg: "Ads loading failed, try again later");
          }
        },
      ),
    );
  }
}
