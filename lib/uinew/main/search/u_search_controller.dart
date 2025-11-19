import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/api/api_main.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/static/db_key.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/dialog_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muse_wave/tool/format_data.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/tool/tba/tba_util.dart';
import 'package:muse_wave/tool/toast.dart';
import '../../../api/base_dio_api.dart';
import '../../../tool/log.dart';

class UserSearchController extends GetxController with StateMixin {
  var list = [].obs;
  var historyList = [].obs;

  //搜索结果
  var resultList = [];
  var tabList = [].obs;
  var tabEnList = [];

  var showSuggestions = false.obs;

  var tabKey = GlobalKey();

  var inputC = TextEditingController();

  Map<String, dynamic> _tabParamsMap = {};

  // Map<String, dynamic> bestResultList = {};

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindHistoryData();

    //好评引导
    MyDialogUtils.instance.showRateDialog();

    EventUtils.instance.addEvent("search_home");

    TbaUtils.instance.checkUnFinishedEvent();
  }

  void getSearchList(String str) async {
    BaseModel result = await ApiMain.instance.getSearchList(str);
    if (result.code == HttpCode.success) {
      //解析搜索联想词

      //第一条为联想词，第二条为有图片的联想
      List contents = result.data["contents"] ?? [];
      List oldList = contents.firstOrNull?["searchSuggestionsSectionRenderer"]?["contents"] ?? [];
      var newList = [];
      for (var item in oldList) {
        List childTextList = item["searchSuggestionRenderer"]["suggestion"]["runs"];
        var itemTextView = RichText(
            text: TextSpan(
                children: childTextList
                    .map((e) => TextSpan(text: e["text"], style: TextStyle(fontSize: 14.w, color: Colors.black, fontWeight: e["bold"] == true ? FontWeight.bold : FontWeight.normal)))
                    .toList()));
        var itemText = item["searchSuggestionRenderer"]["navigationEndpoint"]["searchEndpoint"]["query"];

        newList.add({"view": itemTextView, "text": itemText});
      }
      list.value = newList;
      showSuggestions.value = list.isNotEmpty;
    }
  }

  saveHistory(String data) async {
    var box = await Hive.openBox(DBKey.mySearchHistoryData);

    if (data.isEmpty) {
      return;
    }

    await box.put(data, {"str": data, "date": DateTime.now()});

    bindHistoryData();
  }

  Future bindHistoryData() async {
    var box = await Hive.openBox(DBKey.mySearchHistoryData);
    var oldList = box.values.toList();

    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });
    if (oldList.length > 10) {
      historyList.value = oldList.sublist(0, 10);
    } else {
      historyList.value = oldList;
    }

    AppLog.e("共有以下条数历史记录");
    AppLog.e(historyList.length);
  }

  String youtubeMoreToken = "";

  void toSearch(String str) async {
    //收起键盘
    Get.focusScope?.unfocus();

    await Future.delayed(const Duration(milliseconds: 500));

    EventUtils.instance.addEvent("search_content", data: {"content": str});

    //保存搜索历史记录
    saveHistory(str);

    AdUtils.instance.showAd("behavior", adScene: AdScene.search);

    if (Get.find<Application>().typeSo == "yt") {
      //youtube的搜索

      // LoadingUtil.showLoading();
      isLoading.value = true;
      var result = await ApiMain.instance.youtubeSearch(str);
      isLoading.value = false;
      showSuggestions.value = false;
      lastWords = str;
      // LoadingUtil.hideAllLoading();
      if (result.code != HttpCode.success) {
        change("", status: RxStatus.error());
        return;
      }

      //解析数据
      var oldList = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"] ?? [];
      //更多数据token
      try {
        youtubeMoreToken = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][1]["continuationItemRenderer"]?["continuationEndpoint"]
        ?["continuationCommand"]?["token"] ??
            "";
      } catch (e, s) {
        AppLog.e("$e,$s");
        youtubeMoreToken = "";
      }

      var newList = [];
      for (Map item in oldList) {
        if (item.containsKey("videoRenderer")) {
          //视频
          // AppLog.e(item);

          var videoId = item["videoRenderer"]["videoId"];
          var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
          var title = item["videoRenderer"]["title"]["runs"][0]["text"];
          var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
          var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";

          newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
        } else {
          //reelShelfRenderer
          //lockupViewModel
          //shelfRenderer
          //channelRenderer

          AppLog.e(item.keys);
        }
      }

      ytList.value = newList;
      change("", status: RxStatus.success());

      EventUtils.instance.addEvent("search_result");

      return;
    }

    // "Songs": "Songs",
    // "Videos": "Videos",
    // "Albums": "Albums",
    // "Artists": "Artists",
    // "playlists": "playlists"

    //设置上方tab
    tabList.value = ["All".tr];
    tabList.addAll(["Songs".tr, "Videos".tr, "Artists".tr, "Albums".tr, "playlists".tr]);

    tabEnList = ["all", "song", "video", "artist", "album", "playlist"];

    //清空搜索记录
    resultList.clear();
    // bestResultList.clear();

    Map<String, dynamic> bestResultList = {};

    //搜索结果
    // LoadingUtil.showLoading();
    isLoading.value = true;
    var result = await ApiMain.instance.getSearchResult(str);
    // LoadingUtil.hideAllLoading();
    isLoading.value = false;

    if (result.code == HttpCode.success) {
      //解析搜索结果
      try {
        List tabs = result.data["contents"]?["tabbedSearchResultsRenderer"]?["tabs"] ?? [];
        List oldList = tabs.firstOrNull?["tabRenderer"]?["content"]?["sectionListRenderer"]?["contents"] ?? [];

        for (Map item in oldList) {
          if (item.containsKey("musicCardShelfRenderer")) {
            try {
              //best
              final musicCardShelfRenderer = item["musicCardShelfRenderer"];

              List runs = musicCardShelfRenderer["title"]?["runs"] ?? [];
              if (runs.isEmpty) continue;

              final title = runs.first["text"];

              List childSubtitleList = item["musicCardShelfRenderer"]["subtitle"]["runs"] ?? [];
              var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

              var cover = musicCardShelfRenderer["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

              var type = runs.first["navigationEndpoint"]?["watchEndpoint"]?["watchEndpointMusicSupportedConfigs"]?["watchEndpointMusicConfig"]?["musicVideoType"];
              var videoId = runs.first["navigationEndpoint"]?["watchEndpoint"]?["videoId"];
              if (videoId == null || type == null) {
                type = runs.first["navigationEndpoint"]?["browseEndpoint"]?["browseEndpointContextSupportedConfigs"]?["browseEndpointContextMusicConfig"]?["pageType"];
                videoId = runs.first["navigationEndpoint"]["browseEndpoint"]["browseId"];
              }
              if (videoId == null) {
                continue;
              }
              if (type == null || !_isNeedType(type)) {
                continue;
              }

              List contents = [];

              List list = musicCardShelfRenderer["contents"] ?? [];
              for (Map item2 in list) {
                if (item2.containsKey("messageRenderer")) {
                  // contents.add({
                  //   "title": item2["messageRenderer"]?["text"]?["runs"][0]["text"],
                  //   "type": "more",
                  // });
                  continue;
                }
                if (item2.containsKey("musicResponsiveListItemRenderer")) {
                  final musicResponsiveListItemRenderer = item2["musicResponsiveListItemRenderer"];
                  List flexColumns = musicResponsiveListItemRenderer?["flexColumns"] ?? [];
                  if (flexColumns.isEmpty) continue;
                  var cover = musicResponsiveListItemRenderer["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
                  final title = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
                  final vid = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["te"
                      "xt"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["videoId"];
                  final type = flexColumns.first["musicResponsiveListItemFlexColumnRenderer"]["te"
                      "xt"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
                  var subTitle = "";
                  if (flexColumns.length > 1) {
                    List runs = flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"] ?? [];
                    subTitle = runs.map((e) => e["text"]).toList().join("");
                  }

                  contents.add({
                    "title": title,
                    "subtitle": subTitle,
                    "cover": cover,
                    "videoId": vid,
                    "type": type,
                  });
                }
              }

              bestResultList = {
                "header": {
                  "title": title,
                  "subtitle": childSubtitle,
                  "cover": cover,
                  "videoId": videoId,
                  "browseId": videoId,
                  "type": type,
                },
                "content": contents,
                "type": "best",
              };
              resultList.add(bestResultList);
            } catch (e) {
              AppLog.e(e);
              continue;
            }

            if (item.containsKey("itemSectionRenderer")) {
              //didYouMean，没有内容
              continue;
            }
          }

          if (item.containsKey("musicShelfRenderer")) {
            List childList = item["musicShelfRenderer"]?["contents"] ?? [];

            //解析childList
            var newChildList = FormatMyData.instance.getAllSearchList(childList);
            resultList.addAll(newChildList);
            // resultList.add({
            //   "title": "list",
            //   "list": newChildList,
            //   "type": "content",
            // });
          }
        }
        // AppLog.e(resultList);

        showSuggestions.value = false;
        change("", status: RxStatus.success());

        EventUtils.instance.addEvent("search_result");

        List chips = tabs.firstOrNull?["tabRenderer"]?["content"]?["sectionListRenderer"]?["header"]?["chipCloudRenderer"]?["chips"] ?? [];
        for (final chip in chips) {
          Map render = chip?["chipCloudChipRenderer"] ?? {};
          String? uniqueId = render["uniqueId"];
          if (uniqueId != null) {
            final params = render["navigationEndpoint"]?["searchEndpoint"]?["params"];
            if (params != null) {
              _tabParamsMap[uniqueId] = params;
            }
          }
        }
      } catch (e) {
        AppLog.e(e.toString());
      }
    } else {
      showSuggestions.value = false;
      change("", status: RxStatus.error());
    }

    lastWords = str;

    await searchOtherList(str);
  }

  bool _isNeedType(type) {
    if (type != "MUSIC_VIDEO_TYPE_OMV" &&
        type != "MUSIC_VIDEO_TYPE_UGC" &&
        type != "MUSIC_VIDEO_TYPE_ATV" &&
        type != "MUSIC_PAGE_TYPE_PLAYLIST" &&
        type != "MUSIC_PAGE_TYPE_ALBUM" &&
        type != "MUSIC_PAGE_TYPE_ARTIST") {
      return false;
    }
    return true;
  }

  String? getTabParams(String title) {
    String fullTitle = title;
    for (final key in _tabParamsMap.keys) {
      if (key.contains(title)) {
        fullTitle = key;
        break;
      }
    }
    final param = _tabParamsMap[fullTitle];
    AppLog.i("title:$title,param:$param");
    return param;
  }

  // void toSearch(String str) async {
  //   //收起键盘
  //   Get.focusScope?.unfocus();
  //
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   EventUtils.instance.addEvent("search_content", data: {"content": str});
  //
  //   //保存搜索历史记录
  //   saveHistory(str);
  //
  //   AdUtils.instance.showAd("behavior", adScene: AdScene.search);
  //
  //   if (Get.find<Application>().typeSo == "yt") {
  //     //youtube的搜索
  //
  //     LoadingUtil.showLoading();
  //     var result = await ApiMain.instance.youtubeSearch(str);
  //     showSuggestions.value = false;
  //     lastWords = str;
  //     LoadingUtil.hideAllLoading();
  //     if (result.code != HttpCode.success) {
  //       change("", status: RxStatus.error());
  //       return;
  //     }
  //
  //     //解析数据
  //     var oldList = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][0]
  //             ["itemSectionRenderer"]["contents"] ??
  //         [];
  //     //更多数据token
  //     try {
  //       youtubeMoreToken = result.data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][1]
  //               ["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
  //           "";
  //     } catch (e) {
  //       print(e);
  //       youtubeMoreToken = "";
  //     }
  //
  //     var newList = [];
  //     for (Map item in oldList) {
  //       if (item.containsKey("videoRenderer")) {
  //         //视频
  //         AppLog.e(item);
  //
  //         var videoId = item["videoRenderer"]["videoId"];
  //         var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
  //         var title = item["videoRenderer"]["title"]["runs"][0]["text"];
  //         var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
  //         var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
  //
  //         newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
  //       } else {
  //         //reelShelfRenderer
  //         //lockupViewModel
  //         //shelfRenderer
  //         //channelRenderer
  //
  //         AppLog.e(item.keys);
  //       }
  //     }
  //
  //     ytList.value = newList;
  //     change("", status: RxStatus.success());
  //
  //     EventUtils.instance.addEvent("search_result");
  //
  //     return;
  //   }
  //
  //   //设置上方tab
  //   tabList.value = ["All".tr];
  //   tabList.addAll(["Tracks".tr, "Video".tr, "Artist".tr, "Album".tr, "Playlist".tr]);
  //
  //   //清空搜索记录
  //   resultList.clear();
  //   //搜索结果
  //   LoadingUtil.showLoading();
  //   var result = await ApiMain.instance.getSearchResult(str);
  //   LoadingUtil.hideAllLoading();
  //
  //   if (result.code == HttpCode.success) {
  //     //解析搜索结果
  //     try {
  //       var oldList = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"];
  //
  //       for (Map item in oldList) {
  //         if (item.containsKey("musicCardShelfRenderer")) {
  //           //精准搜索
  //           String bigTitle = item["musicCardShelfRenderer"]["header"]["musicCardShelfHeaderBasicRenderer"]["title"]["runs"][0]["text"];
  //           // List childList = item["musicShelfRenderer"]["contents"];
  //
  //           var childTitle = item["musicCardShelfRenderer"]["title"]["runs"][0]["text"];
  //
  //           List childSubtitleList = item["musicCardShelfRenderer"]["subtitle"]["runs"];
  //           var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");
  //
  //           var cover = item["musicCardShelfRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
  //
  //           try {
  //             var type = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]
  //                 ["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
  //             var videoId = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["videoId"];
  //             resultList.add({
  //               "title": bigTitle,
  //               "list": [
  //                 {"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": type}
  //               ],
  //               "type": type
  //             });
  //           } catch (e) {
  //             print(e);
  //
  //             var type = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]
  //                 ["browseEndpointContextSupportedConfigs"]["browseEndpointContextMusicConfig"]["pageType"];
  //             var browseId = item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];
  //             resultList.add({
  //               "title": bigTitle,
  //               "list": [
  //                 {"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": type}
  //               ],
  //               "type": type
  //             });
  //           }
  //
  //           continue;
  //         }
  //
  //         if (item.containsKey("itemSectionRenderer")) {
  //           //didYouMean，没有内容
  //           continue;
  //         }
  //
  //         //列表
  //         String bigTitle = item["musicShelfRenderer"]["title"]["runs"][0]["text"];
  //         List childList = item["musicShelfRenderer"]["contents"];
  //
  //         //解析childList
  //         var newChildList = FormatMyData.instance.getAllSearchList(childList);
  //         resultList.add({"title": bigTitle, "list": newChildList, "type": newChildList.first["type"]});
  //       }
  //
  //       // AppLog.e(resultList);
  //
  //       showSuggestions.value = false;
  //       change("", status: RxStatus.success());
  //
  //       EventUtils.instance.addEvent("search_result");
  //     } catch (e) {
  //       AppLog.e(e.toString());
  //     }
  //   } else {
  //     showSuggestions.value = false;
  //     change("", status: RxStatus.error());
  //   }
  //
  //   lastWords = str;
  //
  //   await searchOtherList(str);
  // }

  Future moreYoutubeSearch() async {
    AppLog.e(youtubeMoreToken);

    if (youtubeMoreToken.isEmpty) {
      AppLog.e("没有更多了");
      return;
    }

    var str = lastWords;

    var result = await ApiMain.instance.youtubeSearch(str, continuation: youtubeMoreToken);
    showSuggestions.value = false;
    lastWords = str;
    LoadingUtil.hideAllLoading();
    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    //解析数据

    var oldList = result.data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][0]["itemSectionRenderer"]["contents"] ?? [];
    //更多数据token
    try {
      youtubeMoreToken = result.data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][1]["continuationItemRenderer"]?["continuationEndpoint"]
      ?["continuationCommand"]?["token"] ??
          "";
    } catch (e) {
      print(e);
      youtubeMoreToken = "";
    }

    var newList = [];
    for (Map item in oldList) {
      if (item.containsKey("videoRenderer")) {
        //视频
        var videoId = item["videoRenderer"]["videoId"];
        var cover = item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
        var title = item["videoRenderer"]["title"]["runs"][0]["text"];
        var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
        var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
        newList.add({"title": title, "subtitle": subtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": "Video"});
      } else {
        AppLog.e(item.keys);
      }
    }

    ytList.addAll(newList);
  }

  Future searchOtherList(String str) async {
    await Future.wait([searchSong(str), searchVideo(str), searchArtist(str), searchAlbum(str), searchPlaylist(str)]);
  }

  var songList = [].obs;
  var songNextData = {};
  var videoList = [].obs;
  var videoNextData = {};
  var artistList = [].obs;
  var artistNextData = {};
  var albumList = [].obs;
  var albumNextData = {};
  var playlistList = [].obs;
  var playlistNextData = {};

  var lastWords = "";

  var ytList = [].obs;

  var inputFocusNode = FocusNode();
  var showClearBtn = false.obs;

  Future searchSong(String str, {String? param}) async {
    //搜索结果

    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIIAWoMEAMQBBAOEAoQCRAF");

    if (result.code == HttpCode.success) {
      songList.clear();
      songNextData = {};

      try {
        //解析搜索结果
        List oldList = [];

        List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
        for (Map item in contents) {
          if (item.containsKey("musicShelfRenderer")) {
            oldList = item["musicShelfRenderer"]?["contents"] ?? [];
            songNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
          }
        }

        var childList = [];
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          // var childSubtitle =
          //     childSubtitleList.map((e) => e["text"]).toList().join("");
          var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": ""});
        }
        songList.addAll(childList);
      } catch (e) {
        AppLog.e(e);
      }
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreSong({String? param}) async {
    if (songNextData.isEmpty) {
      return;
    }
    var result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIIAWoMEAMQBBAOEAoQCRAF", nextData: songNextData);

    if (result.code == HttpCode.success) {
      try {
        //解析搜索结果
        List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

        if (oldList.isEmpty) {
          return;
        }

        songNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

        var childList = [];
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "type": ""});
        }
        songList.addAll(childList);
      } catch (e) {
        AppLog.e(e);
      }
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchVideo(String str, {String? param}) async {
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIQAWoMEAMQBBAOEAoQCRAF");

    videoList.clear();
    videoNextData = {};

    if (result.code == HttpCode.success) {
      try {
        //解析搜索结果
        List oldList = [];

        List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
        for (Map item in contents) {
          if (item.containsKey("musicShelfRenderer")) {
            oldList = item["musicShelfRenderer"]?["contents"] ?? [];
            videoNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
          }
        }

        if (oldList.isEmpty) {
          return;
        }

        var childList = [];
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          // var childSubtitle =
          //     childSubtitleList.map((e) => e["text"]).toList().join("");
          var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
          var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "timeStr": timeStr, "videoId": videoId, "type": ""});
        }
        videoList.addAll(childList);
      } catch (e) {
        AppLog.e(e);
      }
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreVideo({String? param}) async {
    if (videoNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIQAWoMEAMQBBAOEAoQCRAF", nextData: videoNextData);

    if (result.code == HttpCode.success) {
      try {
        //解析搜索结果
        List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

        if (oldList.isEmpty) {
          return;
        }

        videoNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

        var childList = [];
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          // var childSubtitle =
          //     childSubtitleList.map((e) => e["text"]).toList().join("");
          var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
          var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "videoId": videoId, "timeStr": timeStr, "type": ""});
        }
        videoList.addAll(childList);
      } catch (e) {
        AppLog.e(e);
      }
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchArtist(String str, {String? param}) async {
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIgAWoMEAMQBBAOEAoQCRAF");

    artistList.clear();
    artistNextData = {};

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      try {
        List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
        for (Map item in contents) {
          if (item.containsKey("musicShelfRenderer")) {
            oldList = item["musicShelfRenderer"]?["contents"] ?? [];
            artistNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
          }
        }

        if (oldList.isEmpty) {
          return;
        }
      } catch (e) {
        AppLog.e(e);
      }

      var childList = [];
      try {
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

          // var videoId = item["musicResponsiveListItemRenderer"]
          //     ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
      } catch (e) {
        AppLog.e(e);
      }
      artistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreArtist({String? param}) async {
    if (artistNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIgAWoMEAMQBBAOEAoQCRAF", nextData: artistNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      try {
        List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

        if (oldList.isEmpty) {
          return;
        }

        artistNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

        var childList = [];
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          // var videoId = item["musicResponsiveListItemRenderer"]
          // ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
        artistList.addAll(childList);
      } catch (e) {
        AppLog.e(e);
      }
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchAlbum(String str, {String? param}) async {
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIYAWoMEAMQBBAOEAoQCRAF");

    albumList.clear();
    albumNextData = {};

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      try {
        List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
        for (Map item in contents) {
          if (item.containsKey("musicShelfRenderer")) {
            oldList = item["musicShelfRenderer"]?["contents"] ?? [];
            albumNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
          }
        }
      } catch (e) {
        AppLog.e(e);
      }

      if (oldList.isEmpty) {
        return;
      }

      // albumNextData = result.data["contents"]["tabbedSearchResultsRenderer"]
      //                 ["tabs"][0]["tabRenderer"]["content"]
      //             ["sectionListRenderer"]["contents"][0]["musicShelfRenderer"]
      //         ["continuations"]?[0]["nextContinuationData"] ??
      //     {};

      var childList = [];
      try {
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

          // var videoId = item["musicResponsiveListItemRenderer"]
          //     ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
      } catch (e) {
        AppLog.e(e);
      }
      albumList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future moreAlbum({String? param}) async {
    if (albumNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgWKAQIYAWoMEAMQBBAOEAoQCRAF", nextData: albumNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data?["continuationContents"]?["musicShelfContinuation"]?["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      try {
        albumNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};
      } catch (e) {
        AppLog.e(e);
      }

      var childList = [];
      try {
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          // var videoId = item["musicResponsiveListItemRenderer"]
          // ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
      } catch (e) {
        AppLog.e(e);
      }
      albumList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future searchPlaylist(String str, {String? param}) async {
    BaseModel result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=");

    playlistList.clear();
    playlistNextData = {};

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = [];

      try {
        List contents = result.data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ?? [];
        for (Map item in contents) {
          if (item.containsKey("musicShelfRenderer")) {
            oldList = item["musicShelfRenderer"]?["contents"] ?? [];
            playlistNextData = item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ?? {};
          }
        }
      } catch (e) {
        AppLog.e(e);
      }

      if (oldList.isEmpty) {
        return;
      }

      var childList = [];
      try {
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];

          // var videoId = item["musicResponsiveListItemRenderer"]
          //     ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
      } catch (e) {
        AppLog.e(e);
      }
      playlistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  Future morePlaylist({String? param}) async {
    if (playlistNextData.isEmpty) {
      return;
    }

    var result = await ApiMain.instance.getSearchResult(lastWords, params: param ?? "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=", nextData: playlistNextData);

    if (result.code == HttpCode.success) {
      //解析搜索结果
      List oldList = result.data["continuationContents"]["musicShelfContinuation"]["contents"] ?? [];

      if (oldList.isEmpty) {
        return;
      }

      playlistNextData = result.data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ?? {};

      var childList = [];
      try {
        for (Map item in oldList) {
          var childTitle = item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];

          List childSubtitleList = item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
          var childSubtitle = childSubtitleList.map((e) => e["text"]).toList().join("");

          var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"].last["url"];
          // var videoId = item["musicResponsiveListItemRenderer"]
          // ["playlistItemData"]["videoId"];

          var browseId = item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
          childList.add({"title": childTitle, "subtitle": childSubtitle, "cover": cover, "browseId": browseId, "type": ""});
        }
      } catch (e) {
        AppLog.e(e);
      }
      playlistList.addAll(childList);
    } else {
      AppLog.e("请求失败");
    }
  }

  toIndex(int index) {
    DefaultTabController.of(tabKey.currentContext!).animateTo(index);
  }
}
