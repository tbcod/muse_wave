
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/log.dart';

class NativeUtils {
  NativeUtils._() : super();
  static final NativeUtils _instance = NativeUtils._();

  static NativeUtils get instance {
    return _instance;
  }

  static const channel = MethodChannel('player.musicmuse.nativemethod');

  test() async {
    var result = await channel.invokeMethod("testTT");
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
