import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/generated/assets.dart';
import 'package:muse_wave/ui/main/setting/feedback.dart';
import 'package:muse_wave/ui/main/setting/only_web.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../static/env.dart';
import '../../tool/log.dart';
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
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        top: 5.w,
                      ),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: ListView.separated(
                        itemBuilder: (_, i) {
                          return getItem(i);
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
                        itemCount: controller.listTitle.length,
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
            Text(
              controller.listTitle[i],
              style: TextStyle(fontSize: 14.w, color: Color(0xff4d4d4d)),
            ),
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
          var url =
              GetPlatform.isAndroid
                  ? "https://play.google.com/store/apps/details?id=com.musewave.player.music"
                  : "";
          await Clipboard.setData(ClipboardData(text: url));
          ToastUtil.showToast(msg: "Copy download link ok!");

          Share.share(url);
        } else if (itemTitle == "Evaluate") {
          var url =
              GetPlatform.isAndroid
                  ? "https://play.google.com/store/apps/details?id=com.musewave.player.music"
                  : "";
          if (await canLaunchUrl(Uri.parse(url))) {
            launchUrl(Uri.parse(url));
          } else {
            ToastUtil.showToast(msg: "No application found to open");
          }
        }
      },
    );
  }
}

class SettingPageController extends GetxController {
  // var listTitle = ["Privacy Policy", "Terms of Service", "Feedback"];
  var listTitle = ["Feedback", "Share", "Evaluate"];

  var listIcon = [Assets.imgIconMe1, Assets.imgIconMe2, Assets.imgIconMe3];

  @override
  void onInit() {
    super.onInit();
  }
}
