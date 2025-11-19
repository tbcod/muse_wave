import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/uinew/main/u_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../static/db_key.dart';
import '../../uinew/main/u_library.dart';
import '../dialog_util.dart';
import '../history_util.dart';
import '../tba/event_util.dart';
import '../toast.dart';

class LikeUtil {
  LikeUtil._internal();

  static final LikeUtil _instance = LikeUtil._internal();

  static LikeUtil get instance {
    return _instance;
  }

  var allVideoMap = {}.obs;
  var allPlaylistMap = {}.obs;
  var allArtistMap = {}.obs;

  var hasNewLikeVideo = false.obs;
  var hasNewLikeArtist = false.obs;
  likeVideo(String videoId, Map infoData) {
    //好评引导
    MyDialogUtils.instance.showRateDialog();

    var blackVideoIds = FirebaseRemoteConfig.instance.getString(
      "musicmuse_song_block",
    );

    if (blackVideoIds.split(";").contains(videoId)) {
      //在黑名单内，不允许收藏
      ToastUtil.showToast(msg: "playCopyrightStr".tr);
      return;
    }

    allVideoMap[videoId] = infoData;

    HistoryUtil.instance.addHistorySong(infoData);
    saveData();

    EventUtils.instance.addEvent(
      "liked_click",
      data: {"type": "track", "song_id": videoId},
    );
    hasNewLikeVideo.value = true;

    ToastUtil.showToast(msg: "Followed this song".tr);

    saveLikeState();
  }

  saveLikeState() async {
    var sp = await SharedPreferences.getInstance();
    await sp.setBool("hasNewLikeVideo", hasNewLikeVideo.value);
    await sp.setBool("hasNewLikeArtist", hasNewLikeArtist.value);
    //更新lib页面
    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindNewData();
    }
  }

  ///1song 2artist
  removeNewState(int type) async {
    if (type == 1) {
      hasNewLikeVideo.value = false;
    } else if (type == 2) {
      hasNewLikeArtist.value = false;
    }
    saveLikeState();
  }

  unlikeVideo(String videoId) {
    allVideoMap.remove(videoId);
    saveData();
    ToastUtil.showToast(msg: "You have canceled following this song".tr);
    saveLikeState();
  }

  likeList(String browseId, Map infoData, String subtitle) async {
    //好评引导
    MyDialogUtils.instance.showRateDialog();

    EventUtils.instance.addEvent(
      "liked_click",
      data: {"type": "playlist", "playlist_id": browseId},
    );

    allPlaylistMap[browseId] = infoData;
    HistoryUtil.instance.addHistoryPlaylist(infoData);
    // saveData();
    ToastUtil.showToast(msg: "Followed this playlist".tr);

    //保存到本地歌单

    var box = await Hive.openBox(DBKey.myPlayListData);

    await box.put(browseId, {
      "title": infoData["title"],
      "date": DateTime.now(),
      "id": browseId,
      "browseId": infoData["browseId"],
      "playlistId": infoData["playlistId"],
      "type": 1,
      "cover": infoData["cover"],
      "list": [],
      "subtitle": subtitle,
    });
    //刷新lib本地歌单
    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindMyPlayListData();
    }
  }

  unlikeList(String browseId) async {
    allPlaylistMap.remove(browseId);
    saveData();
    ToastUtil.showToast(msg: "You have canceled following this playlist".tr);

    HistoryUtil.instance.removeNetHistoryPlaylist(browseId);

    //保存到本地歌单
    var box = await Hive.openBox(DBKey.myPlayListData);
    await box.delete(browseId);
    //刷新lib本地歌单
    if (Get.isRegistered<UserLibraryController>()) {
      Get.find<UserLibraryController>().bindMyPlayListData();
    }

    saveLikeState();
  }

  likeArtist(String browseId, Map infoData) {
    //好评引导
    MyDialogUtils.instance.showRateDialog();

    EventUtils.instance.addEvent(
      "liked_click",
      data: {"type": "artist", "artist_id": browseId},
    );
    allArtistMap[browseId] = infoData;
    saveData();

    hasNewLikeArtist.value = true;
    ToastUtil.showToast(msg: "Followed this singer".tr);

    saveLikeState();
  }

  unlikeArtist(String browseId) {
    allArtistMap.remove(browseId);
    saveData();
    ToastUtil.showToast(msg: "You have canceled following this singer".tr);
    saveLikeState();
  }

  //保存到本地数据
  saveData() async {
    var box1 = await Hive.openBox(DBKey.myLikeMusicData);
    box1.clear();
    await box1.putAll(allVideoMap);

    var box2 = await Hive.openBox(DBKey.myLikePlayListData);
    box2.clear();
    await box2.putAll(allPlaylistMap);

    var box3 = await Hive.openBox(DBKey.myLikeArtistData);
    box3.clear();
    await box3.putAll(allArtistMap);

    Get.find<UserHomeController>().reloadHistory();
  }

  initData() async {
    var box1 = await Hive.openBox(DBKey.myLikeMusicData);

    allVideoMap.value = box1.toMap();

    var box2 = await Hive.openBox(DBKey.myLikePlayListData);
    allPlaylistMap.value = box2.toMap();

    var box3 = await Hive.openBox(DBKey.myLikeArtistData);
    allArtistMap.value = box3.toMap();

    //是否新数据
    var sp = await SharedPreferences.getInstance();
    hasNewLikeVideo.value = sp.getBool("hasNewLikeVideo") ?? false;
    hasNewLikeArtist.value = sp.getBool("hasNewLikeArtist") ?? false;
  }

  Future clearAll() async {
    var box1 = await Hive.openBox(DBKey.myLikeMusicData);
    allVideoMap.clear();
    await box1.clear();

    var box2 = await Hive.openBox(DBKey.myLikePlayListData);
    allPlaylistMap.clear();
    await box2.clear();

    var box3 = await Hive.openBox(DBKey.myLikeArtistData);
    allArtistMap.clear();
    await box3.clear();
  }
}
