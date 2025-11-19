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

class DownloadUtils {
  DownloadUtils._internal();

  static final DownloadUtils _instance = DownloadUtils._internal();

  static DownloadUtils get instance {
    return _instance;
  }

  Future initData() async {
    var box = await Hive.openBox(DBKey.myDownloadMusicData);
    allDownLoadingData.value = box.toMap();

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

    needDownloadData
        .map((e) {
      return e["videoId"];
    })
        .toList()
        .toString();

    // AppLog.e("需要重新下载的数据${needDownloadData.length}");
    // AppLog.e(needDownloadData
    //     .map((e) {
    //       return e["videoId"];
    //     })
    //     .toList()
    //     .toString());
    for (var item in needDownloadData) {
      download(item["videoId"], item["infoData"], clickType: "", showAd: false);
    }
  }

  // state:0未下载1下载中2完成4下载错误3下载暂停
  var allDownLoadingData = {}.obs;

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
      AppLog.e(result.code);
      AppLog.e("error");
      return {};
    }
    // AppLog.e("返回的缓存数据:\n${result.data["streamingData"]?["formats"] ?? {}}");

    //获取url
    // var url = result.data["streamingData"]?["formats"]?.first?["url"] ?? "";
    // int width = result.data["streamingData"]["formats"].first["width"];
    // int height = result.data["streamingData"]["formats"].first["height"];
    return result.data["streamingData"]?["formats"]?.first ?? {};
  }

  Future saveVideoInfo() async {
    var box = await Hive.openBox(DBKey.myDownloadMusicData);
    await box.clear();
    await box.putAll(Map.of(allDownLoadingData));

    if (Get.isRegistered<UserHomeController>()) {
      Get.find<UserHomeController>().reloadHistory();
    }
  }

  var allCancelToken = {};

  var hasNewDownload = false.obs;

  //添加下载
  download(String videoId, Map infoData, {required String clickType, bool showAd = true, bool isRetry = false}) async {
    if (infoData.isEmpty) {
      return;
    }
    infoData = Map.of(infoData);

    // final List<ConnectivityResult> connectivityResult =
    //     await (Connectivity().checkConnectivity());
    //
    // AppLog.e("下载网络：$connectivityResult");
    // if (!connectivityResult.contains(ConnectivityResult.wifi) &&
    //     !connectivityResult.contains(ConnectivityResult.mobile)) {
    //   //没有网络
    //   ToastUtil.showToast(msg: "There is no internet connection".tr);
    //
    //   return;
    // }

    if (videoId != infoData["videoId"]) {
      videoId = infoData["videoId"];
    }

    if (clickType.isNotEmpty) {
      // type分类
      //loc_playlist
      //net_playlist
      //search
      //liked
      //download
      //artist_more_song
      //artist
      EventUtils.instance.addEvent("save_click", data: {"station": clickType, "song_id": videoId});
      ToastUtil.showToast(msg: "addedDownloadQueue".tr);
    }

    if (showAd) {
      AdUtils.instance.showAd("behavior", adScene: AdScene.download);
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
          allDownLoadingData[videoId] = {"url": url, "videoId": videoId, "infoData": infoData, "progress": 1.0, "state": 2, "time": DateTime.now(), "path": fileName};
          await saveVideoInfo();

          hasNewDownload.value = true;

          saveNewState();

          HistoryUtil.instance.addHistorySong(infoData);

          ToastUtil.showToast(msg: "downloadCompleted".tr);
          EventUtils.instance.addEvent("save_succ", data: {"song_id": videoId});
          return;
        }
      }
      //获取url

      var fileName = "${const Uuid().v8()}.mp4";
      allDownLoadingData[videoId] = {"url": "", "videoId": videoId, "infoData": infoData, "progress": 0.0, "state": 1, "time": DateTime.now(), "path": fileName};
      // LoadingUtil.showLoading();
      allDownLoadingData.refresh();

      var url = await getDownloadUrl(videoId, false);
      // LoadingUtil.hideAllLoading();
      if (url.isEmpty) {
        allDownLoadingData[videoId]["state"] = 0;
        allDownLoadingData.refresh();

        if (clickType.isNotEmpty) {
          ToastUtil.showToast(msg: "Get url error".tr);
        }
        EventUtils.instance.addEvent("save_fail", data: {"reason": "Get url fail"});
        return;
      }
      allDownLoadingData[videoId]["url"] = url;

      //添加到下载列表

      // var fileName = "${Uuid().v8()}.mp4";
      // allDownLoadingData[videoId] = {
      //   "url": url,
      //   "videoId": videoId,
      //   "infoData": infoData,
      //   "progress": 0.0,
      //   "state": 0,
      //   "time": DateTime.now(),
      //   "path": fileName
      // };
    }

    var url = allDownLoadingData[videoId]["url"] ?? "";
    var fileName = "${const Uuid().v8()}.mp4";
    AppLog.i("下载链接$url");
    allDownLoadingData[videoId]["state"] = 1;
    allDownLoadingData.refresh();
    await saveVideoInfo();

    var dic = await getApplicationDocumentsDirectory();

    var filePath = "${dic.path}/$fileName";

    AppLog.i("开始下载");

    var downloadedLength = 0;
    if (File(filePath).existsSync()) {
      downloadedLength = (await File(filePath).length());
    }

    if (allCancelToken[videoId] != null) {
      CancelToken ct = allCancelToken[videoId];
      ct.cancel();
    }

    allCancelToken[videoId] = CancelToken();
    try {
      Dio().download(
        url, filePath, cancelToken: allCancelToken[videoId],
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
            saveVideoInfo();

            ToastUtil.showToast(msg: "downloadCompleted".tr);
            EventUtils.instance.addEvent("save_succ", data: {"song_id": videoId});
            hasNewDownload.value = true;
            saveNewState();
            HistoryUtil.instance.addHistorySong(infoData);
          } else {
            allDownLoadingData[videoId]["progress"] = count / total;
            allDownLoadingData.refresh();
            //存本地
            saveVideoInfo();
          }
        },
        // options: Options(headers: {"Range": "bytes=$downloadedLength-"})
      );
    } on DioException catch (e) {
      if (isRetry) {
        AppLog.e("下载失败Dio：${e.toString()}");
        ToastUtil.showToast(msg: "downloadFailed".tr);
        EventUtils.instance.addEvent("save_fail", data: {"song_id": videoId, "reason": "Http Exception", "message": "1.${e.toString()}"});
      } else {
        AppLog.e("下载失败：${e.toString()}，开始重试");
        //删除下载文件
        // try {
        //   var fileName = allDownLoadingData[videoId]?["path"] ?? "";
        //   var dic = await getApplicationDocumentsDirectory();
        //   var path = "${dic.path}/$fileName";
        //   if (await File(path).exists()) {
        //     await File(path).delete();
        //   }
        // } catch (e) {
        //   print(e);
        // }
        // allDownLoadingData.remove(videoId);
        // allDownLoadingData.refresh();
        // await saveVideoInfo();
        EventUtils.instance.addEvent("download_exc", data: {"song_id": videoId, "reason": "Http Exception, Retry!", "message": "1.${e.toString()}"});
        return download(videoId, infoData, clickType: clickType, isRetry: true);
      }
    } catch (e) {
      AppLog.e("下载失败：${e.toString()}");
      //下载失败
      // allDownLoadingData[videoId]["state"] = 4;
      // allDownLoadingData.refresh();
      // //存本地
      // saveVideoInfo();
      ToastUtil.showToast(msg: "downloadFailed".tr);
      EventUtils.instance.addEvent("save_fail", data: {"song_id": videoId, "reason": "network error", "message": "2.${e.toString()}"});
    }

    // ALDownloader.download(url,
    //     directoryPath: dic.path,
    //     fileName: "${Uuid().v8()}.mp4",
    //     handlerInterface: ALDownloaderHandlerInterface(progressHandler: (p) {
    //       AppLog.e("下载中$p");
    //
    //       allDownLoadingData[videoId]["progress"] = p;
    //       allDownLoadingData.refresh();
    //       //存本地
    //       saveVideoInfo();
    //     }, succeededHandler: () {
    //       AppLog.e("下载成功");
    //       allDownLoadingData[videoId]["state"] = 2;
    //       allDownLoadingData.refresh();
    //       //存本地
    //       HistoryUtil.instance.addHistorySong(infoData);
    //       saveVideoInfo();
    //       EventUtils.instance.addEvent("save_succ", data: {"song_id": videoId});
    //     }, failedHandler: () {
    //       AppLog.e("下载失败");
    //       allDownLoadingData[videoId]["state"] = 4;
    //       allDownLoadingData.refresh();
    //       //存本地
    //       saveVideoInfo();
    //
    //       EventUtils.instance.addEvent("save_fail",
    //           data: {"song_id": videoId, "reason": "network error"});
    //     }, pausedHandler: () {
    //       AppLog.e("下载暂停");
    //       allDownLoadingData[videoId]["state"] = 3;
    //       allDownLoadingData.refresh();
    //       //存本地
    //       saveVideoInfo();
    //     }));
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

        allDownLoadingData.remove(videoId);
        allDownLoadingData.refresh();
        await saveVideoInfo();

        ToastUtil.showToast(msg: "Delete ok".tr);
        if (state == 1) {
          EventUtils.instance.addEvent("save_fail", data: {"song_id": videoId, "reason": "User Cancel!"});
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

  var allCacheData = {}.obs;

  //添加缓存,不更新下载状态
  cacheSong(String videoId, Map infoData) async {
    if (infoData.isEmpty) {
      return;
    }

    //判断是否已经下载
    if (allDownLoadingData.containsKey(videoId)) {
      if (allDownLoadingData[videoId]["state"] == 2) {
        AppLog.e("已经下载，不缓存");
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
      allCacheData[videoId] = {"url": url, "videoId": videoId, "infoData": infoData, "progress": 0.0, "state": 0, "time": DateTime.now()};

      saveCacheVideoInfo();
    }

    //当前下载为空
    var url = allCacheData[videoId]["url"] ?? "";

    String? path = allCacheData[videoId]["path"];

    if (path != null && (await File("${dic.path}/$path").exists())) {
      // AppLog.e("已经缓存");
      return;
    }

    // AppLog.e("开始缓存$url");

    var fileName = "${Uuid().v8()}.mp4";

    Dio().download(url, dic.path + "/$fileName", onReceiveProgress: (int count, int total) {
      // AppLog.e("缓存$count/$total");

      if (count == total) {
        // AppLog.e("缓存完成");
        //下载完成
        allCacheData[videoId]["state"] = 2;
        allCacheData[videoId]["path"] = fileName;
        allCacheData.refresh();
        saveCacheVideoInfo();
      }
    });

    // ALDownloader.download(url,
    //     directoryPath: dic.path,
    //     fileName: "${Uuid().v8()}.mp4",
    //     handlerInterface: ALDownloaderHandlerInterface(
    //         progressHandler: (p) {
    //           AppLog.e("缓存进度$p");
    //         },
    //         succeededHandler: () {
    //           AppLog.e("缓存成功");
    //           allCacheData[videoId]["state"] = 2;
    //           allCacheData.refresh();
    //           //存本地
    //           saveCacheVideoInfo();
    //         },
    //         failedHandler: () {},
    //         pausedHandler: () {}));
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
