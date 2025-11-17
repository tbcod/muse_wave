import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import '../lang/my_tr.dart';
import '../main.dart';
import '../tool/tba/event_util.dart';
import '../tool/toast.dart';
import 'base_api.dart';
export 'base_api.dart';

class ApiMain extends BaseApi {
  ApiMain._internal() : super("");
  static final ApiMain _instance = ApiMain._internal();
  static ApiMain get instance {
    return _instance;
  }

  Map<String, dynamic> playJsonData = {
    "context": {
      "client": {
        "clientName": "ANDROID",
        "clientVersion": "19.11.43",
        "platform": "MOBILE",
      },
    },
    "params": "8AEB",
    "contentCheckOk": true,
    "racyCheckOk": true,
  };

  ///格式String ：1,2
  String blackVideoIds = "";
  initFirebaseData() {
    try {
      var jsonStr = FirebaseRemoteConfig.instance.getString("musicmuse_play");
      var data = jsonDecode(jsonStr);
      playJsonData = data;

      //获取无版权的id
      blackVideoIds = FirebaseRemoteConfig.instance.getString(
        "musicmuse_song_block",
      );
    } catch (e) {
      print(e);
    }
  }

  Future<BaseModel> getData(
    String browseId, {
    String? params,
    Map? nextData,
    String? videoId,
  }) async {
    // String countryCode = Get.deviceLocale?.countryCode ?? "";
    // String languageCode = Get.deviceLocale?.languageCode ?? "";
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20250101.01.00",
          "visitorData": Get.find<Application>().visitorData,
        },
      },
      "browseId": browseId,
      "params": params,
      "videoId": videoId,
    };

    var url = "https://music.youtube.com/youtubei/v1/browse";

    if (nextData != null) {
      var continuation = nextData["continuation"] ?? "";
      var itct = nextData["clickTrackingParams"] ?? "";
      url += "?continuation=$continuation&type=next&itct=$itct";
    }

    var result = await httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
    if (result.code == HttpCode.success) {
      //请求成功
      EventUtils.instance.addEvent("source_get");
    }

    return result;
  }

  Future<BaseModel> getVideoInfo(
    String videoId, {
    bool toastBlack = true,
  }) async {
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

    BaseModel result = await httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );

    //判断是否有链接
    String videoUrl =
        result.data?["streamingData"]?["formats"]?.first?["url"] ?? "";
    if ((result.code != HttpCode.success) || videoUrl.isEmpty) {
      return getVideoInfoYoutube(videoId);
    }

    return result;
  }

  Future<BaseModel> getVideoInfoYoutube(String videoId) {
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

    return httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
  }

  Future<BaseModel> getSearchList(String input) {
    var url =
        "https://music.youtube.com/youtubei/v1/music/get_search_suggestions";
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20250101.01.00",
          "visitorData": Get.find<Application>().visitorData,
        },
      },
      "input": input,
    };
    return httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
  }

  Future<BaseModel> getSearchResult(
    String input, {
    String params = "",
    Map? nextData,
  }) {
    var url = "https://music.youtube.com/youtubei/v1/search";
    if (nextData != null) {
      url += "?continuation=${nextData["continuation"]}";
    }
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20250101.01.00",
          // "visitorData": Get.find<Application>().visitorData,
        },
      },
      "query": input,
      "params": params,
    };
    return httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
  }

  Future<BaseModel> getVideoNext(
    String videoId, {
    bool isMoreVideo = false,
    String continuation = "",
  }) {
    var url = "https://music.youtube.com/youtubei/v1/next";

    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20250101.01.00",
          // "visitorData": Get.find<Application>().visitorData,
        },
      },
      "continuation": continuation,
      "videoId": videoId,
    };
    if (isMoreVideo) {
      body.remove("videoId");
      body["playlistId"] = "RDAMVM$videoId";
    }

    return httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
  }

  Future<BaseModel> getYoutubeData(
    String browseId, {
    String? params,
    Map? nextData,
    String? videoId,
  }) async {
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        },
      },
      "browseId": browseId,
      "params": params,
      "videoId": videoId,
    };

    var url = "https://www.youtube.com/youtubei/v1/browse";

    if (nextData != null) {
      body["continuation"] = nextData["continuation"] ?? "";
      body["clickTracking"] = {
        "clickTrackingParams": nextData["clickTrackingParams"] ?? "",
      };
    }

    var result = await httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
    if (result.code == HttpCode.success) {
      //请求成功
      EventUtils.instance.addEvent("source_get");
    }

    return result;
  }

  Future<BaseModel> getYoutubeNext(
    String videoId, {
    String continuation = "",
  }) async {
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        },
      },
      "videoId": videoId,
      "continuation": continuation,
    };

    // body.remove(continuation.isEmpty?"continuation":"videoId");

    var url = "https://www.youtube.com/youtubei/v1/next";

    var result = await httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
    return result;
  }

  Future<BaseModel> youtubeSearch(String word, {String? continuation}) async {
    var nowTime = DateTime.now();
    String date =
        "${nowTime.year}${nowTime.month.toString().padLeft(2, "0")}${nowTime.day.toString().padLeft(2, "0")}";

    Map<String, dynamic> body = {
      "context": {
        "client": {
          "hl": MyTranslations.locale.languageCode,
          "gl": "US",
          "clientName": "WEB",
          "clientVersion": "2.20250101.07.00",
          "visitorData": Get.find<Application>().visitorData,
        },
      },
      "query": word,
      "continuation": continuation,
    };

    if (continuation == null || continuation.isEmpty) {
      body.remove("continuation");
    }

    var url = "https://www.youtube.com/youtubei/v1/search";

    var result = await httpRequest(
      url,
      method: HttpMethod.post,
      contentType: "application/json",
      body: body,
    );
    return result;
  }
}
