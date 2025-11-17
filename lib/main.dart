import 'dart:math';
import 'dart:ui';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/static/db_key.dart';
import 'package:muse_wave/static/env.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/ad/admob_util.dart';
import 'package:muse_wave/tool/ad/max_util.dart';
import 'package:muse_wave/tool/ad/topon_util.dart';
import 'package:muse_wave/tool/history_util.dart';
import 'package:muse_wave/tool/like/like_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/tool/tba/tba_util.dart';
import 'package:muse_wave/ui/launch.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/uinew/main/u_home.dart';
import 'package:muse_wave/uinew/main/u_library.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'lang/my_tr.dart';
import 'tool/log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerMediaKit.ensureInitialized(android: true);
  await Get.putAsync(() => Application().init());
  runApp(const MyApp());
}

class MyApp extends GetView {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // bindData();
    Get.put(AppController());
    final botToastBuilder = BotToastInit();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, otherChild) {
        return GetMaterialApp(
          // color: Color(0xffECECF4),
          builder: (c, child) {
            child = GestureDetector(
              child: Container(
                // decoration: BoxDecoration(
                //     color: Color(0xffECECF4),
                //     image: DecorationImage(
                //         fit: BoxFit.fill,
                //         image: AssetImage("assets/img/bg_all.png"))),
                child: child,
              ),
              onTap: () {
                //空白处收起键盘
                Get.focusScope?.unfocus();
              },
            );

            child = botToastBuilder(c, child);
            return child;
          }, //1. call BotToastInit
          navigatorObservers: [
            BotToastNavigatorObserver(),
          ], //2. registered route observer
          theme: ThemeData(
            scaffoldBackgroundColor: Color(0xfff9f9f9),
            splashColor: Colors.transparent, // 点击时的高亮效果设置为透明
            highlightColor: Colors.transparent, // 长按时的扩散效果设置为透明

            textTheme: TextTheme(bodyMedium: TextStyle(height: 1.2)),
            bottomSheetTheme: BottomSheetThemeData(
              modalBarrierColor: Colors.red.withOpacity(0.43),
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: getWhiteBarStyle(),
              foregroundColor: Colors.black,
              scrolledUnderElevation: 0,
              titleSpacing: 0,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 18.w,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          title: Env.appName,
          home: LaunchPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: MyTranslations.locale,
          fallbackLocale: MyTranslations.fallbackLocale,
          translations: MyTranslations(),
          supportedLocales: const [
            // Locale('cn', 'US'),
            Locale('zh', 'CN'),
          ],

          routingCallback: (Routing? routing) async {
            //路由跳转
            if (routing?.current == "/MainPage" ||
                routing?.current == "/UserMain") {
              Get.find<Application>().isMainPage.value = true;
            } else {
              Get.find<Application>().isMainPage.value = false;
            }
          },
        );
      },
    );
  }
}

class AppController extends SuperController {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  void onInit() async {
    super.onInit();
    bindData();
  }

  bindData() async {
    TbaUtils.instance.postSession();
    var sp = await SharedPreferences.getInstance();
    var isPostInstall = sp.getBool("isPostInstall") ?? false;

    AppLog.e("是否已经安装上报:$isPostInstall");

    if (!isPostInstall) {
      // var isNewUser = false;
      //安装时间
      await sp.setInt("installTimeMs", DateTime.now().millisecondsSinceEpoch);
      //安装上报
      TbaUtils.instance.postInstall().then((value) {
        AppLog.e("安装上报:${value.toJson()}");
        sp.setBool("isPostInstall", true);
        TbaUtils.instance.postUserData({"mw_new_user": "new"});
      });
    } else {
      //已经安装过了，先判断是否已经上报次留
      // var isPostRated = sp.getBool("isPostRated") ?? false;
      // if (!isPostRated) {
      //   //判断是否是次留
      //   var installTimeMs = sp.getInt("installTimeMs") ?? 0;
      //   var tempTime = DateTime.fromMillisecondsSinceEpoch(installTimeMs)
      //       .add(Duration(days: 1));
      //   var nowT = DateTime.now();
      //   if (tempTime.year == nowT.year &&
      //       tempTime.month == nowT.month &&
      //       tempTime.day == nowT.day) {
      //     //是次留
      //     FacebookAppEvents().logRated();
      //     sp.setBool("isPostRated", true);
      //   }
      // }

      //判断是否新用户
      var isNewUser = false;
      var installTimeMs = sp.getInt("installTimeMs") ?? 0;
      var tempD = DateTime.fromMillisecondsSinceEpoch(
        installTimeMs,
      ).difference(DateTime.now());
      isNewUser = tempD.inHours < 24;
      TbaUtils.instance.postUserData({
        "mw_new_user": isNewUser ? "new" : "old",
      });
    }

    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) async {
      if (state == AppState.foreground) {
        Get.find<Application>().isAppBack = false;
        AppLog.e("前台");
        TbaUtils.instance.postSession();

        //判断新老用户
        var isNewUser = false;
        var installTimeMs = sp.getInt("installTimeMs") ?? 0;
        var tempD = DateTime.fromMillisecondsSinceEpoch(
          installTimeMs,
        ).difference(DateTime.now());
        isNewUser = tempD.inHours < 24;
        TbaUtils.instance.postUserData({
          "mw_new_user": isNewUser ? "new" : "old",
        });

        AdUtils.instance.showAd("open", load_pos: "hotOpen");
      } else if (state == AppState.background) {
        Get.find<Application>().isAppBack = true;
        AppLog.e("后台");
        // if (Get.find<UserPlayInfoController>().player?.value.isPlaying ??
        //     false) {
        //   //后台播放
        //   Get.find<UserPlayInfoController>().playNext();
        //   EventUtils.instance.addEvent("background_play");
        // }

        //判断是否在播放
        // AppLog.e(Get.find<UserPlayInfoController>().player?.value.isPlaying);
        // try {
        //   if (Get.find<UserPlayInfoController>().player?.value.isPlaying ??
        //       false) {
        //     await Future.delayed(Duration(milliseconds: 100));
        //     await Get.find<UserPlayInfoController>().player?.play();
        //     await Future.delayed(Duration(milliseconds: 100));
        //     await Get.find<UserPlayInfoController>().player?.play();
        //     await Future.delayed(Duration(milliseconds: 100));
        //     await Get.find<UserPlayInfoController>().player?.play();
        //     EventUtils.instance.addEvent("background_play");
        //   }
        // } catch (e) {
        //   print(e);
        // }
      }
    });

    // TbaUtils.instance.postUserData({"mm_new_user": "old"});
    // TbaUtils.instance.postUserData({"mm_type_so": "ytm"});
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() async {}

  @override
  void onResumed() async {}

  @override
  void onHidden() {}
}

class Application extends GetxService {
  String userAppUuid = "";

  var isMainPage = false.obs;

  var visitorData = "";

  //使用的资源  no/yt/ytm
  var typeSo = "no";

  var isAppBack = false;

  Future initNetPush() async {
    if (!Env.isUser) {
      return;
    }

    AppLog.e("开始初始化推送");
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    AppLog.e(settings.authorizationStatus.name);

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      AppLog.e("推送token:$fcmToken");
      // await Clipboard.setData(ClipboardData(text: fcmToken ?? ""));
      // a terminated state.
    } catch (e) {
      print(e);
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      //点击消息进入
      EventUtils.instance.addEvent("push_click");
    }

    FirebaseMessaging.onMessage.listen((event) {
      //前台收到消息
      EventUtils.instance.addEvent("push_show");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      //后台收到消息
      EventUtils.instance.addEvent("push_show");
    });
    // FirebaseMessaging.onBackgroundMessage(())

    //订阅频道
    // await FirebaseMessaging.instance.subscribeToTopic("");
  }

  Future initLocPush() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings("ic_launcher"),
        );

    var d =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (d != null) {
      EventUtils.instance.addEvent("push_click");
    }
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // 处理用户点击通知后的回调逻辑，例如打开对应的页面等，按需编写逻辑
        EventUtils.instance.addEvent("push_click");
      },
    );

    // initializeTimeZones();
  }

  Future<Map> getRandomItem(List list) async {
    var sp = await SharedPreferences.getInstance();

    var rIndex = Random().nextInt(list.length);
    String lastId = sp.getString("lastPushSongId") ?? "-";

    String nowId = list[rIndex]["videoId"] ?? "";
    if (nowId == lastId) {
      //重新随机
      return getRandomItem(list);
    }
    await sp.setString("lastPushSongId", nowId);
    return list[rIndex];
  }

  pushLocNotification(tz.TZDateTime tzDate, int nId) async {
    await HistoryUtil.instance.initData();

    List historySongList = List.of(HistoryUtil.instance.songHistoryList);
    if (historySongList.isEmpty) {
      //没有历史数据推送
      return;
    }

    //随机一首
    Map item = await getRandomItem(historySongList);

    // EventUtils.instance.addEvent("push_show");

    await FlutterLocalNotificationsPlugin().zonedSchedule(
      nId,
      "Music Muse",
      "${"Listen now".tr}\n${item["title"]}",
      tzDate,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentBadge: true,
          badgeNumber: 1,
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails("google play", "android"),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  Future<void> initSdk() async {
    await Firebase.initializeApp();
    AppLog.e("firebase初始化完成");
    //异步，否则会卡在启动
    initFireBaseOther();

    initAd();
  }

  initFireBaseOther() async {
    //测试环境异常上报
    if (!Env.isUser) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    if (Env.isUser) {
      AdUtils.instance.adJson = AdUtils.instance.adJsonRelease;
      if (GetPlatform.isIOS) {
        AdUtils.instance.adJson = AdUtils.instance.adJsonIosRelease;
      }
      var adData = await AdUtils.instance.initJsonByFireBase();
      AppLog.e("广告配置");
      AppLog.e(adData);
    } else {
      if (GetPlatform.isIOS) {
        AdUtils.instance.adJson = AdUtils.instance.adJsonIos;
      }
      var adData = await AdUtils.instance.initJsonByFireBase();
      AppLog.e("广告配置");
      AppLog.e(adData);
    }
  }

  initAd() {
    AdmobUtils.instance.init();
    MaxUtils.instance.init();
    TopOnUtils.instance.init();
  }

  changeTypeSo(String str) async {
    if (typeSo == str) {
      //和上次一样不切换源
      return;
    }
    AppLog.e("typeSo切换了数据：$typeSo");

    typeSo = str;
    //保存到本地

    TbaUtils.instance.postUserData({"mw_type_so": typeSo});
    var sp = await SharedPreferences.getInstance();
    sp.setString("lastTypeSo", typeSo);
    //删除之前源的所有
    //删除各种收藏
    await LikeUtil.instance.clearAll();
    LikeUtil.instance.removeNewState(1);
    LikeUtil.instance.removeNewState(2);
    //删除本地歌单
    var box = await Hive.openBox(DBKey.myPlayListData);
    await box.clear();

    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindMyPlayListData();
    } else if (Get.isRegistered<UserHomeController>()) {
      Get.find<UserHomeController>().reloadHistory();
    }

    AppLog.e("nowtypeso:$typeSo");
  }

  Future initLocTypeSo() async {
    var sp = await SharedPreferences.getInstance();
    typeSo = sp.getString("lastTypeSo") ?? "no";

    AppLog.e("nowtypeso:$typeSo");
  }

  Future<Application> init() async {
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        1024 * 1024 * 1024 * 5; //设置缓存为5GB，避免图片太多经常重新加载
    //竖屏
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //沉浸状态栏
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final sp = await SharedPreferences.getInstance();
    //设置设备的uuid,每次重新安装后不一样
    userAppUuid = sp.getString("userAppUuid") ?? "";
    if (userAppUuid.isEmpty) {
      userAppUuid = const Uuid().v4();
      await sp.setString("userAppUuid", userAppUuid);
    }

    //设置语言
    var lastLangCode = sp.getString("lastLangCode") ?? "";
    var lastLangCountryCode = sp.getString("lastLangCountryCode") ?? "";
    if (lastLangCode.isNotEmpty) {
      MyTranslations.locale = Locale(lastLangCode, lastLangCountryCode);
    }

    await initLocTypeSo();

    // //设置下拉刷新
    EasyRefresh.defaultHeaderBuilder = () {
      return const ClassicHeader(
        iconTheme: IconThemeData(color: Color(0xff8569FF)),
        showMessage: false,
        showText: false,
        infiniteHitOver: true,
        processedDuration: Duration.zero,
      );
    };

    EasyRefresh.defaultFooterBuilder = () {
      return ClassicFooter(
        iconTheme: IconThemeData(color: Color(0xff8569FF)),
        failedText: "loadMoreFailStr".tr,
        noMoreText: "noMoreStr".tr,
        textStyle: TextStyle(color: Colors.black),
        showMessage: false,
        infiniteHitOver: true,
        processedDuration: Duration.zero,
      );
    };

    await initHive();
    await initAppsflyer();

    await initSdk();

    return this;
  }

  AppsflyerSdk? appsflyerSdk;
  initAppsflyer() async {
    if (!Env.isUser) {
      return;
    }

    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: Env.isUser ? "XrT2fnS7Vhxh9w3YLjHtGS" : "",
      showDebug: !Env.isUser,
    );
    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    var appsflyerData = await appsflyerSdk?.initSdk(
      registerConversionDataCallback: true,
      // registerOnAppOpenAttributionCallback: true,
      // registerOnDeepLinkingCallback: true,
    );
    AppLog.e("appsflyerSdk init ok,$appsflyerData");
    appsflyerSdk?.setCustomerUserId(userAppUuid);
  }

  Future initHive() async {
    var path = await getApplicationSupportDirectory();
    Hive.init(path.path);
  }
}

getWhiteBarStyle() {
  return SystemUiOverlayStyle(
    //设置状态栏颜色
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );
}

getBlackBarStyle() {
  return SystemUiOverlayStyle(
    //设置状态栏颜色
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  );
}
