import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../api/api_main.dart';
import '../static/db_key.dart';
import '../uinew/main/u_home.dart';

class HistoryUtil {
  HistoryUtil._internal();

  static final HistoryUtil _instance = HistoryUtil._internal();

  static HistoryUtil get instance {
    return _instance;
  }

  var songHistoryList = [].obs;

  // var playlistHistoryList = [].obs;

  addHistorySong(Map item) {
    //判断是否有相同数据

    songHistoryList.removeWhere((e) => e["videoId"] == item["videoId"]);

    songHistoryList.insert(0, item);

    if (songHistoryList.length > 21) {
      songHistoryList.removeLast();
    }

    saveData();
  }

  addHistoryPlaylist(Map item, {bool isLoc = false}) {
    // AppLog.e("添加歌单到历史$item");
    // if (isLoc) {
    //   playlistHistoryList.removeWhere((e) => e["id"] == item["id"]);
    //   //设置本地歌单
    //   item["type"] = 0;
    //   playlistHistoryList.insert(0, item);
    // } else {
    //   playlistHistoryList.removeWhere((e) => e["browseId"] == item["browseId"]);
    //   playlistHistoryList
    //       .removeWhere((e) => e["playlistId"] == (item["playlistId"] ?? "-"));
    //   //设置网络歌单
    //   item["type"] = 1;
    //   playlistHistoryList.insert(0, item);
    // }
    saveData();
  }

  removeNetHistoryPlaylist(String browseId) {
    // playlistHistoryList.removeWhere((e) => e["browseId"] == browseId);
    saveData();
  }

  saveData() async {
    var box = await Hive.openBox(DBKey.myHistoryMusicData);
    await box.clear();
    await box.addAll(songHistoryList);

    // var box1 = await Hive.openBox(DBKey.myHistoryPlaylist);
    // await box1.clear();
    // await box1.addAll(playlistHistoryList);

    Get.find<UserHomeController>().reloadHistory();
  }

  Future initData() async {
    var box = await Hive.openBox(DBKey.myHistoryMusicData);
    songHistoryList.value = box.values.toList();

    if (songHistoryList.isEmpty) {
      //添加默认的12首歌
      songHistoryList.value = decodeList(locSong);
      saveData();
    }

    // var box1 = await Hive.openBox(DBKey.myHistoryPlaylist);
    // playlistHistoryList.value = box1.values.toList();
  }

  Future<List> getDData(List listId) async {
    var list = [];

    for (String videoId in listId) {
      BaseModel result = await ApiMain.instance.getVideoNext(videoId);
      if (result.code != HttpCode.success) {
        continue;
      }
      //解析音乐

      // var browseId =
      //     result.data["contents"]["singleColumnMusicWatchNextResultsRenderer"]
      //                         ["tabbedRenderer"]["watchNextTabbedResultsRenderer"]
      //                     ["tabs"][0]["tabRenderer"]["content"]
      //                 ["musicQueueRenderer"]["content"]["playlistPanelRenderer"]
      //             ["contents"][0]["playlistPanelVideoRenderer"]["longBylineText"]
      //         ["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];

      var title = result.data["contents"]
                              ["singleColumnMusicWatchNextResultsRenderer"]
                          ["tabbedRenderer"]["watchNextTabbedResultsRenderer"]
                      ["tabs"]
                  [0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]
              ["playlistPanelRenderer"]["contents"][0]
          ["playlistPanelVideoRenderer"]["title"]["runs"][0]["text"];
      //歌手
      var subtitle = result.data["contents"]
                              ["singleColumnMusicWatchNextResultsRenderer"]
                          ["tabbedRenderer"]["watchNextTabbedResultsRenderer"]
                      ["tabs"]
                  [0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]
              ["playlistPanelRenderer"]["contents"][0]
          ["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["text"];

      //封面
      var cover = result.data["contents"]
                              ["singleColumnMusicWatchNextResultsRenderer"]
                          ["tabbedRenderer"]["watchNextTabbedResultsRenderer"]
                      ["tabs"]
                  [0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]
              ["playlistPanelRenderer"]["contents"][0]
          ["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"];

      list.add({
        "title": title,
        "subtitle": subtitle,
        "cover": cover,
        "type": "MUSIC_VIDEO_TYPE_ATV",
        "videoId": videoId
      });
    }

    return list;
  }
}
