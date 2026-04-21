import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/static/data_config.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/tool/referrer_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'bus.dart';
import 'native_utils.dart';

const String mmAdJsonKey = "mmAdJson";
const String mmAdJsonRefKey = "mmAdJsonRef";

const String mmFullClickbait = "mmFullClickbait";
const String mmOpenAd = "mmOpenAd";

const String museSongRecommonedKey = "museSongRecommonedKeys";

const String mmPageNativeAdClickbait = "mmPageNativeAdClickbait";

const String mmHomeWebParams = "mmHomeWebParams";
const String mmReferParams = "mmReferParams";

const String mmSetRewardVideoCd = "mmSetRewardVideoCd";

class RemoteUtil {
  static RemoteUtil shareInstance = RemoteUtil._();

  RemoteUtil._();

  // Map<String, dynamic> _adJson = {};

  String _adJsonAnd = "";
  String _adJsonRef = "";

  String _bannerClickbait = "";

  String _pageNativeClickbait = "";

  // late SharedPreferences isp;

  String _listenNowRecom = "";

  String _openAdStr = "";

  String _homeWebParams = "";

  String _referParams = ""; //包含字段认定为买量用户，未包含该字段则认定为非买量用户；

  int _rewardVideoCd = 0;

  bool isInitSuc = false;

  init() async {
    // isp = await SharedPreferences.getInstance();

    // final jsonString = museSp.getString(mmAdJsonKey) ?? "";
    // if (jsonString.isNotEmpty) {
    //   try {
    //     Map oldMap = jsonDecode(jsonString);
    //     _adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
    //   } catch (e) {
    //     EventUtils.instance.addEvent("fb_ad_json_fail", data: {"reason": e.toString(), "code_type": 3});
    //     _adJson = MuseConfig.adJsonAnd;
    //   }
    // } else {
    //   _adJson = MuseConfig.adJsonAnd;
    // }

    _adJsonAnd = museSp.getString(mmAdJsonKey) ?? "";

    _adJsonRef = museSp.getString(mmAdJsonRefKey) ?? "";

    _bannerClickbait = museSp.getString(mmFullClickbait) ?? "";

    _pageNativeClickbait = museSp.getString(mmPageNativeAdClickbait) ?? "";

    _listenNowRecom = museSp.getString(museSongRecommonedKey) ?? "";

    _openAdStr = museSp.getString(mmOpenAd) ?? "";

    _homeWebParams = museSp.getString(mmHomeWebParams) ?? "";

    _referParams = museSp.getString(mmReferParams) ?? "";

    _rewardVideoCd = museSp.getInt(mmSetRewardVideoCd, def: 30);
  }

  Future<void> initFirebaseRemoteSdk() async {
    var tempTime = DateTime.now();
    //获取云控字段
    try {
      await FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(fetchTimeout: const Duration(seconds: 15), minimumFetchInterval: Duration(seconds: MuseConfig.isUser ? 60 * 30 : 30)),
      );
      try {
        await FirebaseRemoteConfig.instance.fetchAndActivate();
        FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
          try {
            await FirebaseRemoteConfig.instance.activate();
            updateData();
          } catch (err) {
            AppLog.e("activate remote config error: $err");
          }
        });
        isInitSuc = true;
      } catch (e, s) {
        EventUtils.instance.addEvent("firebase_remote_fail", data: {"reason": e.toString(), "code_type": 2});
        AppLog.e("Remote Config error: $e");
      }

      //初始化facebook
      NativeUtils.instance.initFacebook();

      var doTime = DateTime.now().difference(tempTime).inMilliseconds / 1000;
      EventUtils.instance.addEvent("firebase_get", data: {"time": doTime});

      updateData();
    } catch (e) {
      AppLog.e("Remote Config init error: $e");
      EventUtils.instance.addEvent("firebase_remote_fail", data: {"reason": e.toString(), "code_type": 1});
    }
  }

  updateData() {
    String referParams = FirebaseRemoteConfig.instance.getString("muse_ref");
    if (referParams.isNotEmpty) {
      museSp.setString(mmReferParams, referParams);
      _referParams = referParams;
    }

    String adJsonAnd = FirebaseRemoteConfig.instance.getString("ad_json_and");
    if (adJsonAnd.isNotEmpty) {
      museSp.setString(mmAdJsonKey, adJsonAnd);
      _adJsonAnd = adJsonAnd;
    }

    String adJsonRef = FirebaseRemoteConfig.instance.getString("muse_refer_ad_config");
    if (adJsonRef.isNotEmpty) {
      museSp.setString(mmAdJsonRefKey, adJsonRef);
      _adJsonRef = adJsonRef;
    }

    // //使用json
    // var jsonString = FirebaseRemoteConfig.instance.getString("ad_json_and");
    // try {
    //   if (jsonString.isNotEmpty) {
    //     // AppLog.i("获取到云控广告:$jsonString");
    //     Map oldMap = jsonDecode(jsonString);
    //     //map key转为小写
    //     _adJson = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value)); //key.toLowerCase()
    //     museSp.setString(mmAdJsonKey, jsonString);
    //   }
    // } catch (e, s) {
    //   EventUtils.instance.addEvent("fb_ad_json_fail", data: {"reason": e.toString(), "code_type": 0});
    //   AppLog.e("Remote Config error: $e");
    // }

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

    String homeWebParams = FirebaseRemoteConfig.instance.getString("musewave_web_params");
    if (homeWebParams.isNotEmpty) {
      museSp.setString(mmHomeWebParams, homeWebParams);
      _homeWebParams = homeWebParams;
    }

    int rewardVideoCd = FirebaseRemoteConfig.instance.getInt("muse_local_reward_cd");
    if (rewardVideoCd > 0) {
      museSp.setInt(mmSetRewardVideoCd, rewardVideoCd);
      _rewardVideoCd = rewardVideoCd;
    }else if(rewardVideoCd < 0){
      museSp.setInt(mmSetRewardVideoCd, 0);
      _rewardVideoCd = 0;
    }
  }

  // Map<String, dynamic> get adJson {
  //   if (kDebugMode) return MuseConfig.adJsonAnd;
  //   // if (bus.isFirstAppLaunch) return MuseConfig.adJsonIos;
  //   return _adJson;
  // }

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

  Map<String, dynamic> get homeWebParams {
    if (_homeWebParams.isNotEmpty) {
      try {
        Map<String, dynamic> config = jsonDecode(_homeWebParams);
        return config;
      } catch (e) {
        AppLog.e("parse home web params error: $e");
      }
    }
    return {
      "context": {
        "client": {"clientName": "WEB_REMIX", "clientVersion": "1.20260316.00.00", "platform": "DESKTOP"},
      },
      "playbackContext": {
        "contentPlaybackContext": {
          "html5Preference": "HTML5_PREF_WANTS",
          "lactMilliseconds": "23",
          "signatureTimestamp": 20527,
          "autoCaptionsDefaultOn": false,
          "vis": 10,
        },
        "devicePlaybackCapabilities": {"supportsVp9Encoding": true, "supportXhr": true},
      },
    };
  }

  List<String> get referParams {
    if (_referParams.isNotEmpty) {
      try {
        List tmp = json.decode(_referParams);
        List<String> list = List.from(tmp);
        return list;
      } catch (e) {
        AppLog.e("解析 refConfig json fail：${e.toString()}");
      }
    }
    return ['%7B%22', 'bytedance', 'not%20set', 'youtubeads', 'gclid', "adjust", "fb4a", "abytedancesdi"];
  }

  Map<String, dynamic> get adJson {

    if(kDebugMode){
      return MuseConfig.adJsonAnd;
    }

    if (_adJsonRef.isNotEmpty && ReferrerUtil.sh.isBuyReferrer && bus.isBMode) {
      try {
        Map oldMap = jsonDecode(_adJsonAnd);
        Map<String, dynamic> newMap = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
        return newMap;
      } catch (e) {
        AppLog.e("解析 adJsonRef 失败：${e.toString()}");
        EventUtils.instance.addEvent("ad_json_decode_fail", data: {"reason": e.toString(), "code_type": 1});
      }
    }

    if (_adJsonAnd.isNotEmpty) {
      try {
        Map oldMap = jsonDecode(_adJsonAnd);
        Map<String, dynamic> newMap = oldMap.map((key, value) => MapEntry(key.toLowerCase(), value));
        return newMap;
      } catch (e) {
        AppLog.e("解析 adJsonAnd 失败：${e.toString()}");
        EventUtils.instance.addEvent("ad_json_decode_fail", data: {"reason": e.toString(), "code_type": 0});
      }
    }
    return MuseConfig.adJsonAnd;
  }

  int get rewardVideoCd {
    return _rewardVideoCd;
  }

}
