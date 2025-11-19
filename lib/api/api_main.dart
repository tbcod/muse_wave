import 'dart:convert';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/uinew/main/u_home.dart';

import '../lang/my_tr.dart';
import '../main.dart';
import '../tool/tba/event_util.dart';
import '../tool/toast.dart';
// import 'base_api.dart';
// export 'base_api.dart';
import 'base_dio_api.dart';

class ApiMain extends BaseApi {
  ApiMain._internal() : super("");
  static final ApiMain _instance = ApiMain._internal();

  Map<String, dynamic> playbackMap = {};

  bool isFirstRequest = true;

  static ApiMain get instance {
    return _instance;
  }

  // Map<String, dynamic> playJsonData = {
  //   "context": {
  //     "client": {"clientName": "ANDROID", "clientVersion": "19.11.43", "platform": "MOBILE"}
  //   },
  //   "params": "8AEB",
  //   "contentCheckOk": true,
  //   "racyCheckOk": true
  // };
  Map<String, dynamic> playJsonData = {
    "context": {
      "client": {"clientName": "ANDROID", "clientVersion": "19.11.43", "platform": "MOBILE"}
    },
    "params": "gAQB8AUBygYQNTIxNTJCNDk0NkMyRjczRg%3D%3D",
    "contentCheckOk": true,
    "racyCheckOk": true
  };

  ///格式String ：1,2
  String blackVideoIds = "";

  initFirebaseData() {
    try {
      //获取无版权的id
      blackVideoIds = FirebaseRemoteConfig.instance.getString("musicmuse_song_block");

      var jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_play");
      if (jsonStr.isNotEmpty) {
        var data = jsonDecode(jsonStr);
        playJsonData = data;
      }
    } catch (e) {
      AppLog.e(e.toString());
    }
  }

  Future<BaseModel> getData(String browseId, {String? params, Map? nextData, String? videoId}) async {
    // String countryCode = Get.deviceLocale?.countryCode ?? "";
    // String languageCode = Get.deviceLocale?.languageCode ?? "";
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": _webRemixContext,
      "browseId": browseId,
    };

    if (params != null) {
      body["params"] = params;
    }
    if (videoId != null) {
      body["videoId"] = videoId;
    }

    var url = "https://music.youtube.com/youtubei/v1/browse?prettyPrint=false";

    if (nextData != null) {
      var continuation = nextData["continuation"] ?? "";
      var itct = nextData["clickTrackingParams"] ?? "";
      url += "&continuation=$continuation&type=next&itct=$itct";
    }

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    if (result.code == HttpCode.success) {
      //请求成功
      // AppLog.i("请求首页数据成功: $url, header: $_header , param：$body");

      if(nextData == null){
        EventUtils.instance.addEvent("source_get");
      }
    }

    return result;
  }

  Future<BaseModel> getVideoInfo(String videoId, {bool toastBlack = true}) async {
    var url = "https://music.youtube.com/youtubei/v1/player";
    // var url = "https://www.youtube.com/youtubei/v1/player";

    initFirebaseData();

    if (blackVideoIds.split(";").contains(videoId)) {
      //在黑名单内，不允许下载、播放、缓存等
      if (toastBlack) {
        ToastUtil.showToast(msg: "playCopyrightStr".tr);
      }
      return BaseModel(code: -1, message: "playCopyrightStr".tr);
    }

    // Map<String, dynamic> body = {
    //   "context": {
    //     "client": {
    //       'clientName': 'ANDROID_VR',
    //       'clientVersion': '1.56.21',
    //     }
    //   },
    //   "videoId": videoId,
    // };

    Map<String, dynamic> body = Map.of(playJsonData);
    body["videoId"] = videoId;

    // AppLog.i("request:$url,$body");
    BaseModel result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);

    //判断是否有链接
    String videoUrl = result.data?["streamingData"]?["formats"]?.first?["url"] ?? "";
    if ((result.code != HttpCode.success) || videoUrl.isEmpty) {
      return getVideoInfoYoutube(videoId);
    }
    return result;
  }

  Future<BaseModel> getVideoInfoYoutube(String videoId, {int retryCount = 0}) async {
    var url = "https://www.youtube.com/youtubei/v1/player";

    Map<String, dynamic> body = Map.of(playJsonData);
    body["videoId"] = videoId;
    // Map<String, dynamic> body = {
    //   "context": {
    //     "client": {
    //       'clientName': 'ANDROID_VR',
    //       'clientVersion': '1.56.21',
    //     }
    //   },
    //   "videoId": videoId
    // };

    AppLog.i("request:$url,$body");
    BaseModel result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);

    String videoUrl = result.data?["streamingData"]?["formats"]?.first?["url"] ?? "";

    if (videoUrl.isEmpty && retryCount < 1) {
      AppLog.e("获取url失败:$url,$body，重试：$retryCount");
      await Future.delayed(Duration(seconds: retryCount + 1));
      return getVideoInfoYoutube(videoId, retryCount: retryCount + 1);
    }
    return result;
  }

  Future<BaseModel> getSearchList(String input) {
    var url = "https://music.youtube.com/youtubei/v1/music/get_search_suggestions";
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {"context": _webRemixContext, "input": input};
    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getSearchResult(String input, {String params = "", Map? nextData}) {
    var url = "https://music.youtube.com/youtubei/v1/search";
    if (nextData != null) {
      url += "?continuation=${nextData["continuation"]}";
    }
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {"context": _webRemixContext, "query": input, "params": params};
    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getVideoNext(String videoId, {bool isMoreVideo = false, String continuation = ""}) {
    var url = "https://music.youtube.com/youtubei/v1/next";

    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": _webRemixContext,
      "continuation": continuation,
      "videoId": videoId,
    };
    if (isMoreVideo) {
      body.remove("videoId");
      body["playlistId"] = "RDAMVM$videoId";
    }

    return httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
  }

  Future<BaseModel> getYoutubeData(String browseId, {String? params, Map? nextData, String? videoId}) async {
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "browseId": browseId,
      "params": params,
      "videoId": videoId
    };

    var url = "https://www.youtube.com/youtubei/v1/browse";

    if (nextData != null) {
      body["continuation"] = nextData["continuation"] ?? "";
      body["clickTracking"] = {"clickTrackingParams": nextData["clickTrackingParams"] ?? ""};
    }

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    if (result.code == HttpCode.success) {
      //请求成功
      EventUtils.instance.addEvent("source_get");
    }

    return result;
  }

  Future<BaseModel> getYoutubeNext(String videoId, {String continuation = ""}) async {
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "videoId": videoId,
      "continuation": continuation
    };

    // body.remove(continuation.isEmpty?"continuation":"videoId");

    var url = "https://www.youtube.com/youtubei/v1/next";

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    return result;
  }

  Future<BaseModel> youtubeSearch(String word, {String? continuation}) async {
    // var nowTime = DateTime.now();
    // String date = "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": _hl,
          "gl": _gl,
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        }
      },
      "query": word,
      "continuation": continuation
    };

    if (continuation == null || continuation.isEmpty) {
      body.remove("continuation");
    }

    var url = "https://www.youtube.com/youtubei/v1/search";

    var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: _header);
    return result;
  }

  Future<void> postYoutubePlaybackInfo({required bool isWatchOnly}) async {
    UserPlayInfoController controller = Get.find<UserPlayInfoController>();
    if (controller.player == null) return;
    final videoId = controller.nowData["videoId"];
    if (videoId == null) return;
    final cnp = _generateRandomId;
    final playlistId = controller.playlistId;
    if (playbackMap[videoId] == null) {
      Map<String, dynamic> body = {
        "context": _webRemixContext,
        "videoId": videoId,
        "cpn": cnp,
        "playbackContext": {
          "contentPlaybackContext": {
            "html5Preference": "HTML5_PREF_WANTS",
          }
        },
      };
      if (controller.playlistId.isNotEmpty) {
        var playlistId = controller.playlistId;
        if (controller.playlistId.startsWith("VL")) {
          playlistId = controller.playlistId.replaceAll("VL", "");
        }
        body['playlistId'] = playlistId;
      }

      Map<String, dynamic> header = _header;
      header["Origin"] = "https://music.youtube.com/watch?v=$videoId&list=$playlistId";
      var url = "https://music.youtube.com/youtubei/v1/player?prettyPrint=false";
      var result = await httpRequest(url, method: HttpMethod.post, contentType: "application/json", body: body, headers: header);
      final data = result.data;
      final playbackUrl = data?["playbackTracking"]?["videostatsPlaybackUrl"]?['baseUrl'];
      final watchTimeUrl = data?["playbackTracking"]?["videostatsWatchtimeUrl"]?['baseUrl'];
      // AppLog.i("postYoutube player title:${controller.nowData["title"]},videoId:$videoId, url:$url, body:$body, header:$header");
      if (playbackUrl == null || watchTimeUrl == null) {
        final playabilityStatus = data?["playabilityStatus"]?["status"];
        final reason = data?["playabilityStatus"]?["reason"];
        AppLog.e("playabilityStatus:$playabilityStatus,$reason");
        return;
      }
      playbackMap[videoId] = {"playlistId": playlistId, "playbackUrl": playbackUrl, "watchTimeUrl": watchTimeUrl, "cpn": cnp};
    }

    final info = playbackMap[videoId];
    if (info != null) {
      double et = (controller.player?.value.position.inMilliseconds ?? 0) / 1000;
      et = double.parse(et.toStringAsFixed(3));
      if (et <= 0.001) {
        et = 0.001;
      }
      double st = info['positionSec'] ?? 0;
      if (st > et) {
        st = 0;
      }
      st = double.parse(st.toStringAsFixed(3));
      info['positionSec'] = et;
      if (!isWatchOnly) {
        await _postPlaybackUrl(
          info['playbackUrl'],
          vid: videoId,
          playlistId: info['playlistId'],
          cmt: et,
          cpn: info['cpn'] ?? cnp,
        );
        await Future.delayed(Duration(seconds: 1 + Random().nextInt(5)));
        _postWatchTime(
          info['watchTimeUrl'],
          vid: videoId,
          playlistId: info['playlistId'],
          isPlaying: controller.isPlaying.isTrue,
          st: st,
          et: et,
          cpn: info['cpn'] ?? cnp,
        );
      } else {
        _postWatchTime(
          info['watchTimeUrl'],
          vid: videoId,
          playlistId: info['playlistId'],
          isPlaying: controller.isPlaying.isTrue,
          st: st,
          et: et,
          cpn: info['cpn'] ?? cnp,
        );
      }
      if (isFirstRequest) {
        isFirstRequest = false;
        if(Get.isRegistered<UserHomeController>()){
          Future.delayed(const Duration(seconds: 2)).then((v) {
            UserHomeController controller = Get.find<UserHomeController>();
            controller.bindYoutubeMusicData(source: "visitor_play");
          });
        }

      }
    }
  }

  Future _postPlaybackUrl(String? url, {required String cpn, required String vid, String? playlistId, required double cmt}) async {
    if (url == null || !url.contains("http")) return;
    url = url.replaceFirst("s.youtube.com", "music.youtube.com");
    String path = "&cpn=$cpn"
        "&ver=2"
        "&c=WEB_REMIX"
    // "&c=ANDROID_MUSIC"
        "&volume=100"
        "&cmt=$cmt"
        "&hl=$_hl"
        "&cr=$_gl"
        "&muted=0";
    if (playlistId != null && playlistId.isNotEmpty) {
      if (playlistId.startsWith("VL")) {
        playlistId = playlistId.replaceAll("VL", "");
      }
      String p = "&list=$playlistId&referrer=${Uri.encodeFull('https://music.youtube.com/playlist?list=$playlistId')}";
      path = path + p;
    }
    url = url + path;

    Map<String, dynamic> header = _header;
    header["Origin"] = "https://music.youtube.com/watch?v=$vid&list=$playlistId";
    BaseModel result = await httpRequest(url, method: HttpMethod.get, contentType: "application/json", headers: header);

    // AppLog.i("postPlaybackUrl:$url, result:${result.code}");
  }

  _postWatchTime(String? url,
      {required String cpn, required String vid, String? playlistId, bool isPlaying = true, required double st, required double et}) async {
    if (url == null || !url.contains("http")) return;
    url = url.replaceFirst("s.youtube.com", "music.youtube.com");
    var path = "&cpn=$cpn"
        "&ver=2"
        "&cver=$_webRemixVersion"
        "&c=WEB_REMIX"
        "&cplatform=DESKTOP"
        "&volume=100"
        "&cmt=$et"
        "&state=${isPlaying ? 'playing' : 'paused'}"
        "&st=$st" //开始时间
        "&et=$et"
        "&hl=$_hl"
        "&cr=$_gl"
        "&muted=0"; //结束时间

    if (playlistId != null && playlistId.isNotEmpty) {
      if (playlistId.startsWith("VL")) {
        playlistId = playlistId.replaceAll("VL", "");
      }
      String p = "&list=$playlistId&referrer=${Uri.encodeComponent('https://music.youtube.com/playlist?list=$playlistId')}";
      path = path + p;
    }
    url = url + path;

    Map<String, dynamic> header = _header;
    header["Origin"] = "https://music.youtube.com/watch?v=$vid&list=$playlistId";
    BaseModel result = await httpRequest(url, method: HttpMethod.get, contentType: "application/json", headers: header);

    // AppLog.i("postWatchTime:$url, result:${result.code}");
  }

  Map<String, dynamic> get _header {
    Map<String, dynamic> header = {
      "X-Youtube-Client-Name": 67,
      "X-Youtube-Client-Version": _webRemixVersion,
      "Referer": "https://music.youtube.com/",
      "Origin": "https://music.youtube.com",
    };
    if (Get.find<Application>().visitorData.isNotEmpty) {
      header["X-Goog-Visitor-Id"] = Get.find<Application>().visitorData;
    }
    return header;
  }

  String get _hl {
    return MyTranslations.locale.languageCode;
  }

  String get _gl {
    // return MyTranslations.locale.countryCode?.toUpperCase() ?? 'US';
    final locale = WidgetsBinding.instance.window.locale;
    final c = locale.countryCode ?? 'US';
    if (c == "CN") {
      return "US";
    }
    return c;
  }

  Map<String, dynamic> get _webRemixContext {
    Map<String, dynamic> content = {
      "client": {
        "hl": _hl,
        "gl": _gl,
        "clientName": "WEB_REMIX",
        "clientVersion": _webRemixVersion,
        "platform": "DESKTOP",
        "originalUrl": "https://music.youtube.com/",
      }
    };
    if (Get.find<Application>().visitorData.isNotEmpty) {
      content["client"]["visitorData"] = Get.find<Application>().visitorData;
    }
    return content;
  }

  String get _webRemixVersion {
    return '1.20250804.03.00';
  }

  String get _generateRandomId {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const separators = ['_'];

    final rand = Random.secure();
    final buffer = StringBuffer();

    final r = Random().nextInt(10) + 2;

    // 生成随机字符
    for (int i = 0; i < 16; i++) {
      // 随机插入一个分隔符（可选）
      if (i == r && rand.nextBool()) {
        buffer.write(separators[rand.nextInt(separators.length)]);
      } else {
        buffer.write(chars[rand.nextInt(chars.length)]);
      }
    }

    return buffer.toString();
  }
}

// class ApiMain extends BaseApi {
//   ApiMain._internal() : super("");
//   static final ApiMain _instance = ApiMain._internal();
//   static ApiMain get instance {
//     return _instance;
//   }
//
//   Map<String, dynamic> playJsonData = {
//     "context": {
//       "client": {
//         "clientName": "ANDROID",
//         "clientVersion": "19.11.43",
//         "platform": "MOBILE",
//       },
//     },
//     "params": "8AEB",
//     "contentCheckOk": true,
//     "racyCheckOk": true,
//   };
//
//   ///格式String ：1,2
//   String blackVideoIds = "";
//   initFirebaseData() {
//     try {
//       var jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_play");
//       var data = jsonDecode(jsonStr);
//       playJsonData = data;
//
//       //获取无版权的id
//       blackVideoIds = FirebaseRemoteConfig.instance.getString(
//         "musicmuse_song_block",
//       );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<BaseModel> getData(
//     String browseId, {
//     String? params,
//     Map? nextData,
//     String? videoId,
//   }) async {
//     // String countryCode = Get.deviceLocale?.countryCode ?? "";
//     // String languageCode = Get.deviceLocale?.languageCode ?? "";
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB_REMIX",
//           "clientVersion": "1.20250101.01.00",
//           "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "browseId": browseId,
//       "params": params,
//       "videoId": videoId,
//     };
//
//     var url = "https://music.youtube.com/youtubei/v1/browse";
//
//     if (nextData != null) {
//       var continuation = nextData["continuation"] ?? "";
//       var itct = nextData["clickTrackingParams"] ?? "";
//       url += "?continuation=$continuation&type=next&itct=$itct";
//     }
//
//     var result = await httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//     if (result.code == HttpCode.success) {
//       //请求成功
//       EventUtils.instance.addEvent("source_get");
//     }
//
//     return result;
//   }
//
//   Future<BaseModel> getVideoInfo(
//     String videoId, {
//     bool toastBlack = true,
//   }) async {
//     var url = "https://music.youtube.com/youtubei/v1/player";
//     // var url = "https://www.youtube.com/youtubei/v1/player";
//
//     initFirebaseData();
//
//     if (blackVideoIds.split(";").contains(videoId)) {
//       //在黑名单内，不允许下载、播放、缓存等
//       if (toastBlack) {
//         ToastUtil.showToast(msg: "playCopyrightStr".tr);
//       }
//       return BaseModel(code: -1, message: "playCopyrightStr".tr);
//     }
//
//     // Map<String, dynamic> body = {
//     //   "context": {
//     //     "client": {
//     //       'clientName': 'ANDROID_VR',
//     //       'clientVersion': '1.56.21',
//     //     }
//     //   },
//     //   "videoId": videoId,
//     // };
//
//     Map<String, dynamic> body = Map.of(playJsonData);
//     body["videoId"] = videoId;
//
//     BaseModel result = await httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//
//     //判断是否有链接
//     String videoUrl =
//         result.data?["streamingData"]?["formats"]?.first?["url"] ?? "";
//     if ((result.code != HttpCode.success) || videoUrl.isEmpty) {
//       return getVideoInfoYoutube(videoId);
//     }
//
//     return result;
//   }
//
//   Future<BaseModel> getVideoInfoYoutube(String videoId) {
//     var url = "https://www.youtube.com/youtubei/v1/player";
//
//     Map<String, dynamic> body = Map.of(playJsonData);
//     body["videoId"] = videoId;
//     // Map<String, dynamic> body = {
//     //   "context": {
//     //     "client": {
//     //       'clientName': 'ANDROID_VR',
//     //       'clientVersion': '1.56.21',
//     //     }
//     //   },
//     //   "videoId": videoId
//     // };
//
//     return httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//   }
//
//   Future<BaseModel> getSearchList(String input) {
//     var url =
//         "https://music.youtube.com/youtubei/v1/music/get_search_suggestions";
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB_REMIX",
//           "clientVersion": "1.20250101.01.00",
//           "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "input": input,
//     };
//     return httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//   }
//
//   Future<BaseModel> getSearchResult(
//     String input, {
//     String params = "",
//     Map? nextData,
//   }) {
//     var url = "https://music.youtube.com/youtubei/v1/search";
//     if (nextData != null) {
//       url += "?continuation=${nextData["continuation"]}";
//     }
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB_REMIX",
//           "clientVersion": "1.20250101.01.00",
//           // "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "query": input,
//       "params": params,
//     };
//     return httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//   }
//
//   Future<BaseModel> getVideoNext(
//     String videoId, {
//     bool isMoreVideo = false,
//     String continuation = "",
//   }) {
//     var url = "https://music.youtube.com/youtubei/v1/next";
//
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB_REMIX",
//           "clientVersion": "1.20250101.01.00",
//           // "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "continuation": continuation,
//       "videoId": videoId,
//     };
//     if (isMoreVideo) {
//       body.remove("videoId");
//       body["playlistId"] = "RDAMVM$videoId";
//     }
//
//     return httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//   }
//
//   Future<BaseModel> getYoutubeData(
//     String browseId, {
//     String? params,
//     Map? nextData,
//     String? videoId,
//   }) async {
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB",
//           "clientVersion": "2.20250101.07.00",
//           "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "browseId": browseId,
//       "params": params,
//       "videoId": videoId,
//     };
//
//     var url = "https://www.youtube.com/youtubei/v1/browse";
//
//     if (nextData != null) {
//       body["continuation"] = nextData["continuation"] ?? "";
//       body["clickTracking"] = {
//         "clickTrackingParams": nextData["clickTrackingParams"] ?? "",
//       };
//     }
//
//     var result = await httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//     if (result.code == HttpCode.success) {
//       //请求成功
//       EventUtils.instance.addEvent("source_get");
//     }
//
//     return result;
//   }
//
//   Future<BaseModel> getYoutubeNext(
//     String videoId, {
//     String continuation = "",
//   }) async {
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB",
//           "clientVersion": "2.20250101.07.00",
//           "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "videoId": videoId,
//       "continuation": continuation,
//     };
//
//     // body.remove(continuation.isEmpty?"continuation":"videoId");
//
//     var url = "https://www.youtube.com/youtubei/v1/next";
//
//     var result = await httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//     return result;
//   }
//
//   Future<BaseModel> youtubeSearch(String word, {String? continuation}) async {
//     var nowTime = DateTime.now();
//     String date =
//         "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";
//
//     Map<String, dynamic> body = {
//       "context": {
//         "client": {
//           "hl": MyTranslations.locale.languageCode,
//           "gl": "US",
//           "clientName": "WEB",
//           "clientVersion": "2.20250101.07.00",
//           "visitorData": Get.find<Application>().visitorData,
//         },
//       },
//       "query": word,
//       "continuation": continuation,
//     };
//
//     if (continuation == null || continuation.isEmpty) {
//       body.remove("continuation");
//     }
//
//     var url = "https://www.youtube.com/youtubei/v1/search";
//
//     var result = await httpRequest(
//       url,
//       method: HttpMethod.post,
//       contentType: "application/json",
//       body: body,
//     );
//     return result;
//   }
// }
