import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/uinew/main/u_home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../api/api_main.dart';
import '../../api/base_dio_api.dart';
import '../../static/db_key.dart';
import '../../uinew/main/u_library.dart';
import '../../view/base_view.dart';
import '../ad/ad_util.dart';
import '../dialog_util.dart';
import '../history_util.dart';
import '../log.dart';
import '../tba/event_util.dart';
import '../toast.dart';

enum DownloadStation {
  h_detail_artist,
  h_detail_playlist,
  h_detail_album,
  s_detail_artist,
  s_detail_playlist,
  s_detail_album,
  search,
  library,
  home,
  minibar,
  playpage,
  unknown,
}

class DownloadUtils {
  DownloadUtils._internal();

  static final DownloadUtils _instance = DownloadUtils._internal();

  static DownloadUtils get instance {
    return _instance;
  }

  // state:0未下载 1下载中 2完成 4下载错误 3下载暂停
  var allDownLoadingData = {}.obs;

  Future initData() async {
    var box = await Hive.openBox(DBKey.myDownloadMusicData);
    allDownLoadingData.value = box.toMap();

    // AppLog.i("初始化download:${allDownLoadingData.length}");

    var box1 = await Hive.openBox(DBKey.myCacheMusicData);
    allCacheData.value = box1.toMap();

    var sp = await SharedPreferences.getInstance();
    hasNewDownload.value = sp.getBool("hasNewDownload") ?? false;

    //重新下载未完成的数据
    reDownloadData();
  }

  reDownloadData() {
    //获取所有正在下载的
    var needDownloadData = allDownLoadingData.values.where((e) => e["state"] == 1 || e["state"] == 3).toList();

    AppLog.i("初始化download：${needDownloadData.length}");

    needDownloadData
        .map((e) {
          return e["videoId"];
        })
        .toList()
        .toString();

    for (var item in needDownloadData) {
      download(
        item["videoId"],
        item["infoData"],
        station: DownloadStation.unknown,
        showAd: false,
        adSense: AdSense.play_page,
      );
    }
  }

  //获取Url
  Future<String> getDownloadUrl(String videoId, bool isCache) async {
    var result = await ApiMain.instance.getVideoInfo(videoId, toastBlack: !isCache);

    if (result.code != HttpCode.success) {
      // ToastUtil.showToast(msg: result.message ?? "error");
      AppLog.e(result.code);
      AppLog.e("error");
      return "";
    }
    // AppLog.e("返回的下载数据:\n${result.data["streamingData"]["formats"]}");

    //获取url
    var url = result.data["streamingData"]?["formats"]?.first?["url"] ?? "";
    // int width = result.data["streamingData"]["formats"].first["width"];
    // int height = result.data["streamingData"]["formats"].first["height"];
    return url;
  }

  Future<Map> getCacheMap(String videoId) async {
    var result = await ApiMain.instance.getVideoInfo(videoId, toastBlack: false);

    if (result.code != HttpCode.success) {
      // ToastUtil.showToast(msg: result.message ?? "error");
      AppLog.e("getCacheMap error:${result.code}");
      return {};
    }
    // AppLog.e("返回的缓存数据:\n${result.data["streamingData"]?["formats"] ?? {}}");

    //获取url
    // var url = result.data["streamingData"]?["formats"]?.first?["url"] ?? "";
    // int width = result.data["streamingData"]["formats"].first["width"];
    // int height = result.data["streamingData"]["formats"].first["height"];
    return result.data["streamingData"]?["formats"]?.first ?? {};
  }

  var _box;

  Future saveVideoInfo({bool updateHomeUI = true}) async {
    _box ??= await Hive.openBox(DBKey.myDownloadMusicData);
    // await _box.clear();

    Map map = Map.of(allDownLoadingData);
    await _box.putAll(map);

    if (Get.isRegistered<UserHomeController>() && updateHomeUI) {
      Get.find<UserHomeController>().reloadHistory();
    }
  }

  var allCancelToken = {};

  var hasNewDownload = false.obs;

  String _resolveStationName(String videoId, DownloadStation station) {
    if (station != DownloadStation.unknown) {
      return station.name;
    }
    return allDownLoadingData[videoId]?["station"]?.toString() ?? DownloadStation.unknown.name;
  }

  // Future _reportSaveClickIfNeeded(String videoId, DownloadStation station) async {
  //   var item = allDownLoadingData[videoId];
  //   if (item == null) {
  //     return;
  //   }
  //   if (item["save_click_reported"] == true) {
  //     return;
  //   }
  //   var stationName = _resolveStationName(videoId, station);
  //   EventUtils.instance.addEvent("save_click", data: {"station": stationName, "song_id": videoId});
  //   item["save_click_reported"] = true;
  //   item["station"] = stationName;
  //   allDownLoadingData.refresh();
  //   await saveVideoInfo();
  // }

  void _emitSaveSucc(String videoId, DownloadStation station) {
    EventUtils.instance
        .addEvent("save_succ", data: {"song_id": videoId, "station": _resolveStationName(videoId, station)});
  }

  void _emitSaveFail(String videoId, String reason, {String message = ""}) {
    Map<String, Object> data = {"song_id": videoId, "reason": reason};
    if (message.isNotEmpty) {
      data["message"] = message;
    }
    EventUtils.instance.addEvent("save_fail", data: data);
  }

  //添加下载
  download(
    String videoId,
    Map data, {
    required DownloadStation station,
    required AdSense adSense,
    bool showAd = true,
    bool isRetry = false,
  }) async {
    if (data.isEmpty) {
      return;
    }
    Map infoData = Map.of(data);

    if (videoId != infoData["videoId"]) {
      videoId = infoData["videoId"];
    }

    if (station != DownloadStation.unknown && !isRetry) {
      ToastUtil.showToast(msg: "addedDownloadQueue".tr);
      EventUtils.instance.addEvent("save_click", data: {"station": station.name, "song_id": videoId});
    }

    if (showAd) {
      AdUtils.instance.showAd(AdPosId.behavior, adSense: adSense, adFunction: AdFunction.download);
      //好评引导
      Future.delayed(const Duration(milliseconds: 500)).then((_) {
        //延迟后显示好评引导
        MyDialogUtils.instance.showRateDialog();
      });
    }

    if (!allDownLoadingData.containsKey(videoId)) {
      //没有添加过下载

      //获取是否缓存
      if (allCacheData.containsKey(videoId)) {
        var url = allCacheData[videoId]["url"];
        var path = allCacheData[videoId]["path"];

        var cdic = await getTemporaryDirectory();
        if (path != null && (await File("${cdic.path}/$path").exists())) {
          //有缓存,复制到下载目录
          var cFile = File("${cdic.path}/$path");
          var fileName = "${Uuid().v8()}.mp4";
          var ddic = await getApplicationDocumentsDirectory();
          await cFile.copy("${ddic.path}/$fileName");

          //已有缓存
          allDownLoadingData[videoId] = {
            "url": url,
            "videoId": videoId,
            "infoData": infoData,
            "progress": 1.0,
            "state": 2,
            "time": DateTime.now(),
            "path": fileName,
            "adSense": adSense.name,
            "station": station.name,
            "save_click_reported": false,
          };
          // await _reportSaveClickIfNeeded(videoId, station);
          await saveVideoInfo(updateHomeUI: true);

          hasNewDownload.value = true;

          saveNewState();

          HistoryUtil.instance.addHistorySong(infoData);

          ToastUtil.showToast(msg: "downloadCompleted".tr);
          // EventUtils.instance.addEvent("save_click", data: {"station": station.name, "song_id": videoId});
          _emitSaveSucc(videoId, station);
          return;
        }
      }

      //获取url
      var fileName = "${const Uuid().v8()}.mp4";
      allDownLoadingData[videoId] = {
        "url": "",
        "videoId": videoId,
        "infoData": infoData,
        "progress": 0.0,
        "state": 1,
        "time": DateTime.now(),
        "path": fileName,
        "adSense": adSense.name,
        "station": station.name,
        "save_click_reported": false,
      };
      allDownLoadingData.refresh();
    } else {
      allDownLoadingData[videoId]["station"] ??= station.name;
      allDownLoadingData[videoId]["save_click_reported"] ??= false;
      allDownLoadingData[videoId]["path"] ??= "${const Uuid().v8()}.mp4";
      allDownLoadingData.refresh();
    }
    await saveVideoInfo();

    String url = allDownLoadingData[videoId]["url"] ?? "";

    if (url.isEmpty) {
      url = await getDownloadUrl(videoId, false);
      // url =
      // "https://rr2---sn-ipoxu-un5ed.googlevideo.com/videoplayback?expire=1788441359&ei=rx6ZavaeEuiSvcAPrdWYwAY&ip=36.227.232.112&id=o-AOtJW_DmvlESDqDS-EWOGbQxa1JqQd45IoHQOW_kBQYc&itag=18&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%253D%253D&cps=220&met=1788419759%252C&mh=Kc&mm=31%252C26&mn=sn-ipoxu-un5ed%252Csn-ojhoai-5i&ms=au%252Conr&mv=m&mvi=2&pl=24&rms=au%252Cau&gcr=tw&initcwndbps=3158750&bui=AR3QkAmLYVVYKEmtqLllf-wV_uhnsf3n_EPae6ZIkOOXCNsF4tC7S_qTLIL4PeGRqGYTNUZueKy5oFvy&spc=I-rgIT0ZIOwzoaV51R5pPq-E7jlFJ6-Bt4aDOb1BYC-Bu4hQBraaaVek3BLQehUR&vprv=1&svpuc=1&xtags=heaudio%253Dtrue&mime=video%252Fmp4&rqh=1&cnr=14&ratebypass=yes&dur=197.604&lmt=1664163092702501&mt=1788419078&fvip=5&epbp=1&fexp=51565116%252C52135441&c=ANDROID&txp=5538434&sparams=expire%252Cei%252Cip%252Cid%252Citag%252Csource%252Crequiressl%252Cxpc%252Cgcr%252Cbui%252Cspc%252Cvprv%252Csvpuc%252Cxtags%252Cmime%252Crqh%252Ccnr%252Cratebypass%252Cdur%252Clmt&sig=AE0s2JYwRgIhAJ3_03Y5BgQBKD28Tz0aZ7AC1Mx-3BfOV8ZWamCYlPzHAiEArhrUAR9hnxINUjnd2U2cFqvxk4sy1HV1ruIJeTJSREw%253D&lsparams=cps%25";
    }

    if (url.isEmpty) {
      _emitSaveFail(videoId, "Get url fail");
      // allDownLoadingData.remove(videoId);
      allDownLoadingData[videoId]["state"] = 0;
      allDownLoadingData.refresh();
      await saveVideoInfo();
      if (station != DownloadStation.unknown) {
        ToastUtil.showToast(msg: "Get url error".tr);
      }
      return;
    }
    // final uri = Uri.parse(url);
    //
    // final expire = int.tryParse(uri.queryParameters['expire'] ?? '');
    // if (expire != null) {
    //   final expireTime = DateTime.fromMillisecondsSinceEpoch(expire * 1000, isUtc: true).toLocal();
    //   AppLog.i('Url过期时间: $expireTime');
    // }

    AppLog.i("开始下载:$videoId");

    allDownLoadingData[videoId]["url"] = url;
    var fileName = allDownLoadingData[videoId]["path"]?.toString() ?? "";
    if (fileName.isEmpty) {
      fileName = "${const Uuid().v8()}.mp4";
      allDownLoadingData[videoId]["path"] = fileName;
    }
    // AppLog.i("下载链接$url");
    allDownLoadingData[videoId]["state"] = 1;
    allDownLoadingData.refresh();
    await saveVideoInfo();

    var dic = await getApplicationDocumentsDirectory();

    var filePath = "${dic.path}/$fileName";

    if (allCancelToken[videoId] != null) {
      CancelToken ct = allCancelToken[videoId];
      ct.cancel();
    }
    allCancelToken[videoId] = CancelToken();

    final file = File(filePath);
    final downloadedLength = await file.exists() ? await file.length() : 0;

    try {
      await Dio().download(
        url, filePath, cancelToken: allCancelToken[videoId],
        fileAccessMode: downloadedLength > 0 ? FileAccessMode.append : FileAccessMode.write,
        options: Options(
          headers: downloadedLength > 0 ? {'Range': 'bytes=$downloadedLength-'} : null,
        ),
        onReceiveProgress: (int count, int total) {
          // AppLog.e("缓存$count/$total");
          if (count == total) {
            AppLog.i("下载完成");
            //下载完成
            allDownLoadingData[videoId]["progress"] = 1.0;
            allDownLoadingData[videoId]["state"] = 2;
            allDownLoadingData[videoId]["oktime"] = DateTime.now();
            allDownLoadingData[videoId]["path"] = fileName;
            allDownLoadingData.refresh();
            saveVideoInfo(updateHomeUI: true);

            ToastUtil.showToast(msg: "downloadCompleted".tr);
            // EventUtils.instance.addEvent("save_click", data: {"station": station.name, "song_id": videoId});
            _emitSaveSucc(videoId, station);
            hasNewDownload.value = true;
            saveNewState();
            HistoryUtil.instance.addHistorySong(infoData);
          } else {
            allDownLoadingData[videoId]["progress"] = count / total;
            allDownLoadingData.refresh();
            //存本地
            // print("下载中,${allDownLoadingData[videoId]["progress"]}, ${count / total}");
            saveVideoInfo(updateHomeUI: false);
          }
        },
        // options: Options(headers: {"Range": "bytes=$downloadedLength-"})
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        EventUtils.instance.addEvent("download_exc",
            data: {"song_id": videoId, "reason": "Token Cancelled", "message": "1.${e.toString()}"});
        return;
      }

      int? statusCode = e.response?.statusCode;

      if (isRetry) {
        AppLog.e("下载失败Dio：${e.toString()}");
        ToastUtil.showToast(msg: "downloadFailed".tr);
        EventUtils.instance.addEvent("download_exc",
            data: {"song_id": videoId, "reason": "${statusCode ?? "DioException"}", "message": "3.${e.toString()}"});
        _emitSaveFail(videoId, "${statusCode ?? "Http Exception"}", message: "1.${e.toString()}");
        //删除下载文件
        try {
          var fileName = allDownLoadingData[videoId]?["path"] ?? "";
          var dic = await getApplicationDocumentsDirectory();
          var path = "${dic.path}/$fileName";
          if (await File(path).exists()) {
            await File(path).delete();
          }
        } catch (e) {
          print(e);
        }
        allDownLoadingData[videoId]["state"] = 0;
        // allDownLoadingData.remove(videoId);
        allDownLoadingData.refresh();
        await saveVideoInfo();
      } else {
        AppLog.e("下载失败，开始重试：${e.toString()}");
        EventUtils.instance.addEvent("download_exc",
            data: {"song_id": videoId, "reason": "Http Exception, Retry!", "message": "1.${e.toString()}"});
        await Future.delayed(Duration(seconds: 2));
        // allDownLoadingData.remove(videoId);
        allDownLoadingData[videoId]["url"] = null;
        allDownLoadingData[videoId]["state"] = 0;
        await saveVideoInfo(updateHomeUI: false);
        return download(videoId, data, station: station, isRetry: true, adSense: adSense, showAd: false);
      }
    } catch (e) {
      AppLog.e("下载失败：${e.toString()}");
      //下载失败
      // allDownLoadingData[videoId]["state"] = 4;
      // allDownLoadingData.refresh();
      // //存本地
      // saveVideoInfo();
      EventUtils.instance.addEvent("download_exc",
          data: {"song_id": videoId, "reason": "Http Exception2", "message": "2.${e.toString()}"});
      ToastUtil.showToast(msg: "downloadFailed".tr);
      _emitSaveFail(videoId, "network error", message: "2.${e.toString()}");
      // allDownLoadingData[videoId]["state"] = 0;
      // allDownLoadingData.remove(videoId);
      allDownLoadingData[videoId]["state"] = 0;
      allDownLoadingData.refresh();
      saveVideoInfo();
    }
  }

  saveNewState() async {
    var sp = await SharedPreferences.getInstance();
    await sp.setBool("hasNewDownload", hasNewDownload.value);
    //更新lib页面
    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindNewData();
    }
  }

  removeNewState() async {
    hasNewDownload.value = false;
    saveNewState();
  }

  //删除、取消下载
  Future remove(String videoId, {required int state}) async {
    // var url = allDownLoadingData[videoId]?["url"] ?? "";
    // ALDownloader.remove(url);

    Get.dialog(BaseDialog(
      title: "Delete".tr,
      content: "Delete this download?".tr,
      rBtnText: "Delete".tr,
      lBtnText: "Cancel".tr,
      rBtnOnTap: () async {
        var downloadItem = allDownLoadingData[videoId];
        bool hasSaveClick = downloadItem?["save_click_reported"] == true;
        CancelToken? cancelToken = allCancelToken[videoId];
        cancelToken?.cancel();

        //删除下载文件
        try {
          var fileName = allDownLoadingData[videoId]?["path"] ?? "";
          var dic = await getApplicationDocumentsDirectory();
          var path = "${dic.path}/$fileName";
          if (await File(path).exists()) {
            await File(path).delete();
          }
        } catch (e) {
          print(e);
        }

        // allDownLoadingData.remove(videoId);
        allDownLoadingData[videoId]["progress"] = 0.0;
        allDownLoadingData[videoId]["state"] = 0;
        allDownLoadingData[videoId]["url"] = null;
        allDownLoadingData.refresh();
        await saveVideoInfo(updateHomeUI: true);
        if (state == 1) {
          _emitSaveFail(videoId, "User Cancel!");
          ToastUtil.showToast(msg: "Delete ok".tr);
        } else {
          ToastUtil.showToast(msg: "Delete ok".tr);
        }
      },
    ));
  }

  // removeAll() async {
  //   ALDownloader.removeAll();
  //   allDownLoadingData.clear();
  //   allDownLoadingData.refresh();
  //   await saveVideoInfo();
  // }

  // pause(String videoId) async {
  //   var url = allDownLoadingData[videoId]?["url"] ?? "";
  //   ALDownloader.pause(url);
  //   allDownLoadingData.remove(videoId);
  //   allDownLoadingData.refresh();
  //   await saveVideoInfo();
  // }

  bool isUrlExpired(String? url) {
    if (url == null || url.isEmpty) {
      return true;
    }
    final expire = int.tryParse(Uri.parse(url).queryParameters['expire'] ?? '');
    if (expire == null) {
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expire - now <= 120;
  }

  var allCacheData = {}.obs;

  //添加缓存,不更新下载状态
  Future cacheSong(String videoId, Map infoData) async {
    if (infoData.isEmpty) {
      return;
    }

    //判断是否已经下载
    if (allDownLoadingData.containsKey(videoId)) {
      if (allDownLoadingData[videoId]["state"] == 2) {
        AppLog.i("已经下载，不缓存");
        return;
      }
    }

    var dic = await getTemporaryDirectory();

    if (!allCacheData.containsKey(videoId)) {
      //没有添加过下载
      //获取url

      // AppLog.e("缓存获取url");
      // var url = await getDownloadUrl(videoId, true);
      Map vData = await getCacheMap(videoId);
      if (vData.isEmpty) {
        return;
      }
      int videoMs = int.tryParse(vData["approxDurationMs"].toString()) ?? 0;

      if (videoMs > 1000 * 60 * 10) {
        AppLog.e("视频大于10分钟不缓存");
        return;
      }

      var url = vData["url"] ?? "";
      if (url.isEmpty) {
        return;
      }
      // AppLog.e("缓存获取url==$url");

      //添加到下载列表
      allCacheData[videoId] = {
        "url": url,
        "videoId": videoId,
        "infoData": infoData,
        "progress": 0.0,
        "state": 0,
        "time": DateTime.now()
      };

      saveCacheVideoInfo();
    }

    //当前下载为空
    String url = allCacheData[videoId]["url"] ?? "";

    if (url.isEmpty) {
      allCacheData[videoId]["state"] = 0;
      allCacheData.refresh();
      return;
    }

    String? path = allCacheData[videoId]["path"];

    if (path != null && (await File("${dic.path}/$path").exists())) {
      AppLog.i("已经缓存");
      return;
    }

    if (isUrlExpired(url)) {
      AppLog.e("缓存url过期，重新获取");
      EventUtils.instance.addEvent("cache_exc", data: {"reason": "2", "message": "url expired"});
    }

    AppLog.i("开始缓存: $videoId");

    var fileName = "${Uuid().v8()}.mp4";

    try {
      await Dio().download(url, "${dic.path}/$fileName", onReceiveProgress: (int count, int total) {
        // AppLog.e("缓存$count/$total");
        if (count == total) {
          AppLog.i("缓存完成:$videoId");
          //下载完成
          allCacheData[videoId]["state"] = 2;
          allCacheData[videoId]["path"] = fileName;
          allCacheData.refresh();
          saveCacheVideoInfo();
        }
      });
    } on DioException catch (e) {
      String error = "${e.type.name}, ${e.message ?? ""}";
      EventUtils.instance.addEvent("cache_exc",
          data: {"reason": "1", "message": error.length > 100 ? error.substring(0, 100) : error});
      AppLog.e("缓存失败：$error");
    }
  }

  clearCache() {
    allCacheData.clear();
    saveCacheVideoInfo();
  }

  Future saveCacheVideoInfo() async {
    var box = await Hive.openBox(DBKey.myCacheMusicData);
    await box.clear();
    await box.putAll(Map.of(allCacheData));
  }
}
