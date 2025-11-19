import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../main.dart';
import '../tool/ad/ad_util.dart';
import '../tool/download/download_util.dart';
import '../tool/history_util.dart';
import '../tool/keep_view.dart';
import '../tool/like/like_util.dart';
import '../tool/log.dart';
import '../tool/tba/event_util.dart';
import '../tool/toast.dart';
import 'main/home/u_play.dart';
import 'main/u_home.dart';
import 'main/u_library.dart';
import 'main/u_setting.dart';

class UserMain extends GetView<UserMainController> {
  const UserMain({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserMainController());
    return WillPopScope(
      onWillPop: () async {
        if (GetPlatform.isIOS) {
          return true;
        }

        // 返回桌面逻辑
        AppLog.e("back");
        AndroidIntent intent = const AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: "android.intent.category.HOME",
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        intent.launch();
        AppLog.e("back1");

        // await SystemNavigator.pop();

        return false;
      },
      child: Scaffold(
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => BottomNavigationBar(
                elevation: 0,
                currentIndex: controller.nowIndex.value,
                backgroundColor: Colors.white,
                onTap: (index) {
                  if (controller.nowIndex.value == index) {
                    return;
                  }
                  if (controller.nowIndex.value == 1 && index == 0) {
                    if (Get.isRegistered<UserHomeController>()) {
                      Get.find<UserHomeController>().bindYoutubeMusicData(source: "click_bottomtab");
                    }
                  }

                  controller.nowIndex.value = index;
                  controller.pageC.jumpToPage(index);

                  if (index == 1) {
                    //lib页面
                    EventUtils.instance.addEvent("library_home");
                  }
                },
                unselectedItemColor: Color(0xffC4C5D5),
                selectedItemColor: Color(0xff141414),
                selectedLabelStyle: TextStyle(
                  color: Color(0xff141414),
                  fontSize: 12.w,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Color(0xffC4C5D5),
                  fontSize: 12.w,
                ),
                items:
                    controller.bottomList.map((e) {
                      return BottomNavigationBarItem(
                        icon: Image.asset(
                          e["icon"].toString(),
                          width: 24.w,
                          height: 24.w,
                        ),
                        activeIcon: Image.asset(
                          e["c_icon"].toString(),
                          width: 24.w,
                          height: 24.w,
                        ),
                        label: e["name"],
                      );
                    }).toList(),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: MyNativeAdView(
                adKey: "normalbanner",
                positionKey: "homeBottom",
                isSmall: true,
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),

        body: PlayerBottomBarView(
          child: Container(
            child: Obx(
              () => PageView(
                controller: controller.pageC,
                physics: NeverScrollableScrollPhysics(),
                children:
                    controller.bottomList.map((e) {
                      if (e["name"] == "Home".tr) {
                        return const KeepStateView(child: UserHome());
                      } else if (e["name"] == "Library".tr) {
                        return const KeepStateView(child: UserLibrary());
                      } else if (e["name"] == "Setting".tr) {
                        return const KeepStateView(child: UserSetting());
                      } else {
                        return Container();
                      }
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserMainController extends GetxController {
  var bottomList =
      [
        {
          "name": "Home".tr,
          "icon": "assets/img/icon_b_1_off.png",
          "c_icon": "assets/img/icon_b_1.png",
        },
        {
          "name": "Library".tr,
          "icon": "assets/oimg/icon_lib_off.png",
          "c_icon": "assets/oimg/icon_lib_on.png",
        },
        {
          "name": "Setting".tr,
          "icon": "assets/img/icon_b_2_off.png",
          "c_icon": "assets/img/icon_b_2.png",
        },
      ].obs;

  var pageC = PageController();
  var nowIndex = 0.obs;

  ConnectivityResult? lastResult;
  @override
  void onInit() {
    super.onInit();

    Get.put(UserPlayInfoController());

    //注册下载
    initData();

    //预加载广告
    AdUtils.instance.loadAd("behavior", positionKey: "B_Preloaded");

    StreamSubscription<List<ConnectivityResult>>
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      AppLog.e("网络变化${result}");

      //网络变化
      if (result.contains(ConnectivityResult.wifi)) {
        // ToastUtil.showToast(msg: "The current network is wifi");
        if (lastResult == ConnectivityResult.none) {
          //重新下载全部
          Debounce(5000).run(() {
            DownloadUtils.instance.reDownloadData();
          });

          //重新播放
          // Get.find<UserPlayInfoController>().reLoadAndPlay();
        }
        lastResult = ConnectivityResult.wifi;
      } else if (result.contains(ConnectivityResult.mobile)) {
        // ToastUtil.showToast(msg: "The current network is mobile");
        if (lastResult == ConnectivityResult.none) {
          //重新下载全部
          Debounce(5000).run(() {
            DownloadUtils.instance.reDownloadData();
          });
          // DownloadUtils.instance.reDownloadData();
          //重新播放
          // Get.find<UserPlayInfoController>().reLoadAndPlay();
        }
        if (lastResult == ConnectivityResult.wifi) {
          //wifi变流量
          ToastUtil.showToast(msg: "noWifiStr".tr);
        }

        lastResult = ConnectivityResult.mobile;
      } else if (!result.contains(ConnectivityResult.wifi) &&
          !result.contains(ConnectivityResult.mobile)) {
        // ToastUtil.showToast(msg: "Network interruption, check the network");
        if (lastResult == ConnectivityResult.mobile ||
            lastResult == ConnectivityResult.wifi) {
          //获取是否有正在下载的数据
          var oldList = DownloadUtils.instance.allDownLoadingData.values;
          var downloadingList =
              oldList.where((e) {
                return e["state"] != 2;
              }).toList();

          if (downloadingList.isNotEmpty) {
            ToastUtil.showToast(msg: "noNetworkStr1".tr);
          } else {
            ToastUtil.showToast(msg: "noNetworkStr2".tr);
          }

          //暂停播放

          // if (Get.isRegistered<UserLibraryController>() &&
          //     (Get.find<UserPlayInfoController>().player?.value.isPlaying ??
          //         false)) {
          //   //前台播放toast
          //   if (!Get.find<Application>().isAppBack) {
          //     ToastUtil.showToast(msg: "noNetworkStr2".tr);
          //   }
          //   Get.find<UserPlayInfoController>().player?.pause();
          // }
        }
        lastResult = ConnectivityResult.none;
      }
    });
    //设置网络监听
    // Connectivity()
    //     .onConnectivityChanged
    //     .listen((List<ConnectivityResult> result) async {
    //   if (result.contains(ConnectivityResult.none)) {
    //     //无网
    //     ToastUtil.showToast(msg: "Network outage, download paused");
    //   } else if (result.contains(ConnectivityResult.wifi)) {
    //   } else if (result.contains(ConnectivityResult.mobile)) {
    //     ToastUtil.showToast(
    //         msg: "non-WiFi environment, pay attention to data consumption");
    //   }
    // });
  }

  initData() async {
    // ALDownloader.initialize();
    // ALDownloader.configurePrint(true);
    await DownloadUtils.instance.initData();

    // ALDownloader.cancelAll();

    await LikeUtil.instance.initData();

    await HistoryUtil.instance.initData();

    await Get.find<Application>().initLocPush();
    await Get.find<Application>().initNetPush();

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    //TODO 测试
    // var tzDateT =
    //     tz.TZDateTime.from(DateTime(2024, 12, 20, 10, 15, 0), tz.local);
    // await FlutterLocalNotificationsPlugin().cancelAll();
    // Get.find<Application>().pushLocNotification(tzDateT, 0);
    // return;

    var now = DateTime.now();
    var tzDate = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, 10, 0, 0),
      tz.local,
    );
    var tzDate2 = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, 15, 0, 0),
      tz.local,
    );
    var tzDate3 = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, 18, 0, 0),
      tz.local,
    );
    var tzDate4 = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, 20, 0, 0),
      tz.local,
    );
    await FlutterLocalNotificationsPlugin().cancelAll();

    //获取云控push次数
    //  0-不出现；1-出现两次，2-出现4次
    var pushNum = FirebaseRemoteConfig.instance.getInt("musicmuse_push");

    if (pushNum == 0) {
      return;
    }

    //pushNum==1
    Get.find<Application>().pushLocNotification(tzDate, 1);
    Get.find<Application>().pushLocNotification(tzDate2, 2);

    if (pushNum == 2) {
      Get.find<Application>().pushLocNotification(tzDate3, 3);
      Get.find<Application>().pushLocNotification(tzDate4, 4);
    }
  }

  reloadData() {
    bottomList.value = [
      {
        "name": "Home".tr,
        "icon": "assets/img/icon_b_1_off.png",
        "c_icon": "assets/img/icon_b_1.png",
      },
      {
        "name": "Library".tr,
        "icon": "assets/oimg/icon_lib_off.png",
        "c_icon": "assets/oimg/icon_lib_on.png",
      },
      {
        "name": "Setting".tr,
        "icon": "assets/img/icon_b_2_off.png",
        "c_icon": "assets/img/icon_b_2.png",
      },
    ];

    if (Get.isRegistered<UserSettingController>()) {
      Get.find<UserSettingController>().listTitle.value = [
        "Privacy Policy".tr,
        "Terms of Service".tr,
        "Feedback".tr,
        "Cache clean".tr,
        "Version".tr,
        // "Language".tr
      ];
    }

    if (Get.isRegistered<UserHomeController>()) {
      Get.find<UserHomeController>().reloadHistory();
    }
  }
}

class Debounce {
  final int milliseconds;
  Timer? _timer;

  Debounce(this.milliseconds);

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
