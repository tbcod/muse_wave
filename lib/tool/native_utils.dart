import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/uinew/main/search/u_search.dart';
import 'package:muse_wave/uinew/u_main.dart';

class NativeUtils {
  NativeUtils._() : super();
  static final NativeUtils _instance = NativeUtils._();

  static NativeUtils get instance {
    return _instance;
  }

  bool isStartInForegroundSearch = false;

  static const channel = MethodChannel('player.musicmuse.nativemethod');

  void init() {
    channel.setMethodCallHandler((MethodCall methodCall) async {
      AppLog.i("MethodCall:${methodCall.method}");
      switch (methodCall.method) {
        case 'ForegroundToSearchPage':
          {
            if (Get.isRegistered<UserMainController>()) {
              Get.to(() => const UserSearch());
            } else {
              isStartInForegroundSearch = true;
            }
            break;
          }
      }
    });
  }

  test() async {
    var result = await channel.invokeMethod("testTT");
  }

  Future startSearchNotificationBar() async {
    channel.invokeMethod('startSearchNotificationBarService');
  }

  initFacebook() async {
    var jsonMap = {};
    try {
      var jsonStr = FirebaseRemoteConfig.instance.getString("muse_fb_id");
      if (jsonStr.isNotEmpty) {
        jsonMap = jsonDecode(jsonStr);
      }
    } catch (e) {
      AppLog.e(e.toString());
    }

    String fbId = jsonMap["id"] ?? "";
    String fbToken = jsonMap["token"] ?? "";

    if (fbId.isEmpty || fbToken.isEmpty) {
      fbId = MuseConfig.fbIdDef;
      fbToken = MuseConfig.fbTokenDef;
    }

    var result = await channel.invokeMethod("initFacebook", {"fbid": fbId, "fbtoken": fbToken});
    AppLog.i("原生返回的：$result, fb id:$fbId,fb token:$fbToken");
  }
}
