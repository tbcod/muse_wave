import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/static/data_config.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bus.dart';
import 'native_utils.dart';

const String mmAdJsonKey = "mmAdJson";
const String mmFullClickbait = "mmFullClickbait";
const String mmOpenAd = "mmOpenAd";

const String museSongRecommonedKey = "museSongRecommonedKeys";

const String mmPageNativeAdClickbait = "mmPageNativeAdClickbait";

class RemoteUtil {
  static RemoteUtil shareInstance = RemoteUtil._();

  RemoteUtil._();

  Map<String, dynamic> _adJson = {};

  String _bannerClickbait = "";

  String _pageNativeClickbait = "";

  // late SharedPreferences isp;

  String _listenNowRecom = "";

  String _openAdStr = "";

  bool isInitSuc = false;

  init() async {
    // isp = await SharedPreferences.getInstance();

    final jsonString = museSp.getString(mmAdJsonKey) ?? "";
    if (jsonString.isNotEmpty) {
      Map oldMap = jsonDecode(jsonString);
      _adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
    } else {
      _adJson = MuseConfig.adJsonAnd;
    }

    _bannerClickbait = museSp.getString(mmFullClickbait) ?? "";

    _pageNativeClickbait = museSp.getString(mmPageNativeAdClickbait) ?? "";

    _listenNowRecom = museSp.getString(museSongRecommonedKey) ?? "";

    _openAdStr = museSp.getString(mmOpenAd) ?? "";
  }

  Future<void> initFirebaseRemoteSdk() async {
    var tempTime = DateTime.now();
    //获取云控字段
    try {
      await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(seconds: 15), minimumFetchInterval: const Duration(seconds: 30)));
      try {
        await FirebaseRemoteConfig.instance.fetchAndActivate();
        FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
           try {
             await FirebaseRemoteConfig.instance.activate();
          } catch (_) {}

          // Use the new config values here.
          String jsonString1 = FirebaseRemoteConfig.instance.getString("ad_json_and");
          if(jsonString1.isNotEmpty){
            Map oldMap1 = jsonDecode(jsonString1);
            // AppLog.i(oldMap1);
            //map key转为小写
            _adJson = oldMap1.map((key, value) => MapEntry(key.toLowerCase(), value));
          }
        });
        isInitSuc = true;
      } catch (e, s) {
        AppLog.e("Remote Config error: $e");
      }


      //初始化facebook
      NativeUtils.instance.initFacebook();

      var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
      EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});

      //使用json
      var jsonString = FirebaseRemoteConfig.instance.getString("ad_json_and");

      if (jsonString.isNotEmpty) {
        AppLog.i("获取到云控广告:$jsonString");
        museSp.setString(mmAdJsonKey, jsonString);
        Map oldMap = jsonDecode(jsonString);
        //map key转为小写
        _adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
      }

      String bannerClickbait = FirebaseRemoteConfig.instance.getString("NVfull_Clickbait");
      if (bannerClickbait.isNotEmpty) {
        museSp.setString(mmFullClickbait, bannerClickbait);
        _bannerClickbait = bannerClickbait;
      }

      String pageNativeClickbait = FirebaseRemoteConfig.instance.getString("NVPage_Clickbait");
      if (pageNativeClickbait.isNotEmpty) {
        museSp.setString(mmPageNativeAdClickbait, pageNativeClickbait);
        _pageNativeClickbait = pageNativeClickbait;
      }

      String listenNowSongs = FirebaseRemoteConfig.instance.getString("muse_song_recom");
      museSp.setString(museSongRecommonedKey, listenNowSongs);
      _listenNowRecom = listenNowSongs;

      String openAdStr = FirebaseRemoteConfig.instance.getString("musicmuse_open_ad");
      museSp.setString(mmOpenAd, openAdStr);
      _openAdStr = openAdStr;
    } catch (e) {
      AppLog.e(e);
    }
  }

  Map<String, dynamic> get adJson {
    if (kDebugMode) return MuseConfig.adJsonAnd;
    // if (bus.isFirstAppLaunch) return MuseConfig.adJsonIos;
    return _adJson;
  }

  //参数值：0、10、20、30……100 参数值=10：有10%的概率跳转
  int get adNativeScreenClick {
    if (_bannerClickbait.isEmpty) return 0;
    final Map<String, dynamic> config = jsonDecode(_bannerClickbait);
    return config["ScreenClick"] ?? 0;
  }

  //0、1、2、3……10  参数值=0，广告左上角直接展示正常关闭按钮
  int get adNativeCountDown {
    if (_bannerClickbait.isEmpty) return 0;
    final Map<String, dynamic> config = jsonDecode(_bannerClickbait);
    return config["Countdown"] ?? 0;
  }


  //参数值：0、10、20、30……100 参数值=10：有10%的概率跳转
  int get adPageNativeScreenClick {
    if (_pageNativeClickbait.isEmpty) return 0;
    final Map<String, dynamic> config = jsonDecode(_pageNativeClickbait);
    return config["ScreenClick"] ?? 0;
  }

  List<Map> get listenNowRecommend {
    if (_listenNowRecom.isNotEmpty) {
      try {
        List list = jsonDecode(_listenNowRecom);
        List<Map> newList = List.from(list);
        return newList;
      } catch (e) {
        AppLog.e(e.toString());
      }
    }
    return DataConfig.listenMusic;
  }

  bool get isShowOpenAd {
    if (_openAdStr == "close") {
      return false;
    }
    return true;
  }
}
