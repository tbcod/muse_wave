import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/static/app_color.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/referrer_util.dart';
import 'package:muse_wave/tool/remote_utils.dart';
import 'package:muse_wave/tool/toast.dart';
import 'package:muse_wave/view/debug_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../lang/my_tr.dart';
import '../../tool/ad/ad_util.dart';
import '../../tool/cache_util.dart';
import '../../tool/log.dart';
import '../../ui/main/setting/feedback.dart';
import '../../ui/main/setting/only_web.dart';
import '../../view/base_view.dart';
import '../u_main.dart';
import 'home/u_play.dart';

class UserSetting extends GetView<UserSettingController> {
  const UserSetting({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserSettingController());
    return VisibilityDetector(
      key: Key("UserSettingPage"),
      onVisibilityChanged: (VisibilityInfo info) async {
        if (info.visibleFraction != 0) {
          //每次显示刷新缓存大小
          controller.cacheNum.value = await CacheUtils.instance.loadCacheSize();
        }
      },
      child: Container(
        decoration:
            BoxDecoration(image: DecorationImage(image: AssetImage("assets/oimg/all_page_bg.png"), fit: BoxFit.fill)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            title: Text("Setting".tr),
            titleSpacing: 12.w,
            actions: [
              GestureDetector(
                onDoubleTap: () {
                  controller._clickCount++;
                  if (controller._clickCount > 5) {
                    controller._clickCount = 0;
                    Get.to(() => UDebugPage());
                  }
                },
                child:
                    Container(color: MuseConfig.isUser ? Colors.transparent : Colors.white30, width: 100, height: 44),
              ),
            ],
          ),
          body: Container(
            child: Obx(
              () => ListView.separated(
                itemBuilder: (_, i) {
                  if (i == 0) return _videoRewardItem();
                  return getItem(i - 1);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(height: 1);
                },
                itemCount: controller.listTitle.length + 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getItem(int i) {
    String itemTitle = controller.listTitle[i];

    var rightText = "".obs;

    var isRightText = false;
    if (itemTitle == "Cache clean".tr) {
      isRightText = true;
      rightText = controller.cacheNum;
    } else if (itemTitle == "Version".tr) {
      isRightText = true;
      rightText = controller.versionName;
    } else if (itemTitle == "Language".tr) {
      isRightText = true;
      //获取当前语言
      // var str="${MyTranslations.locale.toString()}";
      rightText = controller.langStr;
    }

    return InkWell(
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Text(controller.listTitle[i], style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500)),
            Spacer(),
            isRightText
                ? Obx(
                    () => Text(rightText.value, style: TextStyle(fontSize: 12.w, color: Colors.black.withOpacity(0.5))))
                : Image.asset("assets/img/icon_right.png", width: 24.w, height: 24.w),
          ],
        ),
      ),
      onTap: () async {
        if (itemTitle == "Feedback".tr) {
          //反馈
          Get.to(FeedbackPage());
        } else if (itemTitle == "Privacy Policy".tr) {
          Get.to(OnlyWeb(), arguments: 2);
        } else if (itemTitle == "Terms of Service".tr) {
          Get.to(OnlyWeb(), arguments: 1);
        } else if (itemTitle == "Language".tr) {
          //不显示播放控件
          Get.find<UserPlayInfoController>().hideFloatingWidget();
          var nowIndex = 0;
          await Get.bottomSheet(
            Container(
              height: 300.w,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text("Cancel".tr),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          var listLocale = [
                            Get.deviceLocale,
                            Locale("zh", "CN"),
                            Locale("en", "US"),
                            Locale("fr", "FR"),
                            Locale("es", "ES"),
                            Locale("pt", "PT"),
                            Locale("de", "DE"),
                          ];

                          AppLog.e(nowIndex);

                          var nowLocale = listLocale[nowIndex] ?? Locale("en", "US");
                          MyTranslations.locale = nowLocale;
                          await Get.updateLocale(nowLocale);
                          controller.langStr.value = listLocale[nowIndex].toString();
                          var sp = await SharedPreferences.getInstance();
                          sp.setString("lastLangCode", nowLocale.languageCode);
                          sp.setString("lastLangCountryCode", nowLocale.countryCode ?? "");

                          Get.find<UserMainController>().reloadData();

                          AppLog.e(controller.langStr.value);
                          Get.back();
                        },
                        child: Text("Confirm".tr),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 30.w,
                      onSelectedItemChanged: (index) {
                        nowIndex = index;
                      },
                      children: [
                        Text("system"),
                        Text("zh_CN"),
                        Text("en_US"),
                        Text("fr_FR"),
                        Text("es_ES"),
                        Text("pt_PT"),
                        Text("de_DE")
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          //不显示播放控件
          Get.find<UserPlayInfoController>().showFloatingWidget();
        } else if (itemTitle == "Version".tr) {
          // MyDialogUtils.instance.showOtherAppDialog();
          // MyDialogUtils.instance.showRateDialog();
          // return;
          // var result =
          //     await ApiMain.instance.getYoutubeData("UC-9-kyTW8ZkZNDHQJ6FgpwQ");
          // AppLog.e(result.data);
          //
          // return;

          // var yt = YoutubeExplode();
          // AppLog.e(await yt.videos.streams
          //     .getHttpLiveStreamUrl(VideoId("VuNIsY6JdUw")));
          // var video = await yt.videos.streams.getManifest(
          //   "VuNIsY6JdUw",
          //   ytClients: [YoutubeApiClient.ios],
          //   requireWatchPage: false,
          // );

          // var video = await yt.videos.get('VuNIsY6JdUw'); // Example video ID
          // AppLog.e(video);
          AppLog.e(AdUtils.instance.loadedAdMap);
          AppLog.e(AdUtils.instance.adJson);

          // if (MuseConfig.isUser) {
          //   return;
          // }
          // Get.dialog(
          //   BaseDialog(
          //     title: "Tip",
          //     content: "choose",
          //     lBtnText: "Max",
          //     rBtnText: "TopOn",
          //     lBtnOnTap: () {
          //       Get.back();
          //       AppLovinMAX.showMediationDebugger();
          //     },
          //     rBtnOnTap: () {
          //       Get.back();
          //       ATInitManger.showDebuggerUI(debugKey: "");
          //       // MobileAds.instance.openAdInspector((p0) {
          //       //   // ToastUtil.showToast(msg: p0?.message ?? "error");
          //       // });
          //     },
          //   ),
          //   barrierDismissible: true,
          // );
        } else if (itemTitle == "Cache clean".tr) {
          Get.dialog(
            BaseDialog(
              title: "Cache clean".tr,
              content: "${"Cache clean".tr}:${controller.cacheNum.value}",
              lBtnText: "Cancel".tr,
              rBtnText: "Clear".tr,
              rBtnOnTap: () async {
                await CacheUtils.instance.clearCache();
                controller.cacheNum.value = await CacheUtils.instance.loadCacheSize();
              },
            ),
          );

          // List songList = await HistoryUtil.instance.getDData([
          //   "VuNIsY6JdUw",
          //   "H5v3kku4y6Q",
          //   "saGYMhApaH8",
          //   "Il0S8BoucSA",
          //   "A_g3lMcWVy0",
          //   "l6_w3887Rwo",
          //   "p38WgakuYDo",
          //   "OD3F7J2PeYU",
          //   "pw0PVm1CcH8",
          //   "kTbRnDwkR0Y",
          //   "Oa_RSwwpPaA",
          //   "o5thu6-7y3Q",
          // ]);
          // AppLog.e(songList);
        }
      },
    );
  }

  Widget _videoRewardItem() {
    if (ReferrerUtil.sh.isBuyReferrer) return Container();
    return GestureDetector(
      onTap: () {
        controller.onClickReward();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                direction: Axis.vertical,
                spacing: 0,
                children: [
                  Text("Rewarded Ad",
                      style: const TextStyle(
                          height: 1, color: Color(0xff141414), fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Obx(() {
                    return Text(
                      "Remaining：${controller.curRemindHour.value}h",
                      style: TextStyle(fontSize: 10.w, color: Color(0xff141414).withOpacity(0.75)),
                    );
                  }),
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColor.mainColor),
                    child: Text("Rewarded AD",
                        style: TextStyle(fontSize: 12, color: Color(0xff333333), fontWeight: FontWeight.w500)),
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

class UserSettingController extends GetxController {
  var listTitle = [
    "Privacy Policy".tr,
    "Terms of Service".tr,
    "Feedback".tr,
    "Cache clean".tr,
    "Version".tr,
    // "Language".tr
  ].obs;

  var versionName = "".obs;
  var cacheNum = "".obs;
  var langStr = "".obs;
  int _clickCount = 0;

  var curRemindHour = 12.obs;

  DateTime? lastVideoAdTime;

  int rewardCd = 0;

  @override
  void onInit() async {
    super.onInit();

    var pInfo = await PackageInfo.fromPlatform();
    versionName.value = "v${pInfo.version}";

    // cacheNum.value = "0M";
    cacheNum.value = await CacheUtils.instance.loadCacheSize();

    langStr.value = MyTranslations.locale.toString();

    curRemindHour.value = museSp.getInt('keyRemindListenTimeHours', def: 12);

    rewardCd = RemoteUtil.shareInstance.rewardVideoCd;
  }

  @override
  onReady() {
    super.onReady();
    AdUtils.instance.loadAd(AdPosId.muse_local_reward, adSense: AdSense.setting);
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
        rBtnOnTap: () async {
          Get.back();
          if (lastVideoAdTime != null) {
            var diff = DateTime.now().difference(lastVideoAdTime!).inSeconds;
            if (diff < rewardCd) {
              ToastUtil.showToast(msg: "Please try again after $rewardCd seconds");
              return;
            }
          }
          bool isSuccess = await AdUtils.instance.showAd(
            AdPosId.muse_local_reward,
            adSense: AdSense.setting,
            adFunction: AdFunction.unknown,
          );
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
