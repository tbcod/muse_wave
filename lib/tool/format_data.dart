import 'log.dart';

class FormatMyData {
  FormatMyData._internal();

  static final FormatMyData _instance = FormatMyData._internal();

  static FormatMyData get instance {
    return _instance;
  }

  List getMusicList(List oldList) {
    var list = [];

    AppLog.e(oldList.first);
    for (var item in oldList) {
      try {
        var title =
            item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
        var subtitle =
            item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
        var cover =
            item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
                .last["url"];
        var videoId =
            item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

        list.add({
          "title": title,
          "subtitle": subtitle,
          "cover": cover,
          "videoId": videoId,
        });
      } catch (e) {
        print(e);
      }
    }

    return list;
  }

  List getOtherList(List oldList) {
    var list = [];

    for (var item in oldList) {
      var title = item["musicTwoRowItemRenderer"]["title"]["runs"][0]["text"];

      List subtitleList = item["musicTwoRowItemRenderer"]["subtitle"]["runs"];
      var subtitle = subtitleList.map((e) => e["text"]).toList().join("");

      var cover =
          item["musicTwoRowItemRenderer"]["thumbnailRenderer"]["musicThumbnailRenderer"]["thumbnail"]?["thumbnails"]
              .last["url"] ??
          "";

      try {
        var browseId =
            item["musicTwoRowItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
        var type =
            item["musicTwoRowItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseEndpointContextSupportedConfigs"]["browseEndpointContextMusicConfig"]["pageType"];
        list.add({
          "title": title,
          "subtitle": subtitle,
          "cover": cover,
          "browseId": browseId,
          "type": type,
        });
      } catch (e) {
        print(e);
        //视频结构不一样
        var type =
            item["musicTwoRowItemRenderer"]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
        var videoId =
            item["musicTwoRowItemRenderer"]["navigationEndpoint"]["watchEndpoint"]["videoId"];

        list.add({
          "title": title,
          "subtitle": subtitle,
          "cover": cover,
          "videoId": videoId,
          "type": type,
        });
      }
    }

    return list;
  }

  List getAllSearchList(List oldList) {
    var list = [];

    for (var item in oldList) {
      if (item["musicResponsiveListItemRenderer"]["navigationEndpoint"] !=
          null) {
        //不是歌曲和视频
        var browseId =
            item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
        var type =
            item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseEndpointContextSupportedConfigs"]["browseEndpointContextMusicConfig"]["pageType"];

        var title =
            item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
        List subtitleList =
            item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
        var subtitle = subtitleList.map((e) => e["text"]).toList().join("");
        var cover =
            item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
                .last["url"];

        list.add({
          "title": title,
          "subtitle": subtitle,
          "cover": cover,
          "browseId": browseId,
          "type": type,
        });
        continue;
      }
      var title =
          item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var subtitle =
          item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var cover =
          item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
              .last["url"];
      var videoId =
          item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];
      var type =
          item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]?["watchEndpointMusicSupportedConfigs"]?["watchEndpointMusicConfig"]["musicVideoType"] ??
          "";

      var timeStr =
          item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"]
              .last["text"];

      list.add({
        "title": title,
        "subtitle": subtitle,
        "cover": cover,
        "videoId": videoId,
        "timeStr": timeStr,
        "type": type,
      });
    }

    return list;
  }

  List getYoutubeHomeList(List oldList) {
    List realList = [];
    // for (Map item in oldList) {
    //   //大标题
    //   var bigTitle =
    //       item["itemSectionRenderer"]?["contents"][0]["shelfRenderer"]["title"]["runs"][0]["text"] ??
    //       "";
    //
    //   // moreId = item["musicCarouselShelfRenderer"]?["header"]
    //   //                     ?["musicCarouselShelfBasicHeaderRenderer"]
    //   //                 ?["moreContentButton"]?["buttonRenderer"]
    //   //             ?["navigationEndpoint"]?["watchPlaylistEndpoint"]
    //   //         ?["playlistId"] ??
    //   //     "";
    //
    //   List childList =
    //       item["itemSectionRenderer"]?["contents"][0]["shelfRenderer"]["content"]["horizontalListRenderer"]["items"] ??
    //       [];
    //
    //   List realChildList = [];
    //
    //   //判断类型
    //   var type = "";
    //
    //   // AppLog.e(childList.first);
    //
    //   for (Map childItem in childList) {
    //     //小内容
    //
    //     if (childItem.containsKey("gridVideoRenderer")) {
    //       //多个视频
    //       //LOCKUP_CONTENT_TYPE_ALBUM
    //       type = "Video";
    //
    //       var childItemTitle =
    //           childItem["gridVideoRenderer"]["title"]["simpleText"] ?? "";
    //
    //       // var childItemSubTitle = childItem["lockupViewModel"]["metadata"]
    //       //                 ["lockupMetadataViewModel"]["metadata"]
    //       //             ["contentMetadataViewModel"]["metadataRows"][0]
    //       //         ["metadataParts"]["text"]["content"] ??
    //       //     "";
    //       var childItemSubTitle =
    //           childItem["gridVideoRenderer"]["title"]["accessibilityData"]?["label"] ??
    //           "";
    //
    //       var childItemCover =
    //           childItem["gridVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ??
    //           "";
    //
    //       var videoId = childItem["gridVideoRenderer"]?["videoId"] ?? "";
    //
    //       if (type.isNotEmpty) {
    //         realChildList.add({
    //           "title": childItemTitle,
    //           "subtitle": childItemSubTitle,
    //           "cover": childItemCover,
    //           "type": type,
    //           "browseId": "",
    //           "videoId": videoId,
    //         });
    //       }
    //
    //       continue;
    //     }
    //
    //     if (!childItem.containsKey("lockupViewModel")) {
    //       AppLog.e(childItem);
    //       continue;
    //     }
    //
    //     //LOCKUP_CONTENT_TYPE_ALBUM
    //     type = childItem["lockupViewModel"]["contentType"];
    //
    //     var childItemTitle =
    //         childItem["lockupViewModel"]["metadata"]["lockupMetadataViewModel"]["title"]["content"] ??
    //         "";
    //     // var childItemSubTitle = childItem["lockupViewModel"]["metadata"]
    //     //                 ["lockupMetadataViewModel"]["metadata"]
    //     //             ["contentMetadataViewModel"]["metadataRows"][0]
    //     //         ["metadataParts"]["text"]["content"] ??
    //     //     "";
    //     var childItemSubTitle = "";
    //
    //     var childItemCover =
    //         childItem["lockupViewModel"]["contentImage"]["collectionThumbnailViewModel"]["primaryThumbnail"]["thumbnailViewModel"]["image"]["sources"][0]["url"];
    //
    //     var playlistId = childItem["lockupViewModel"]?["contentId"] ?? "";
    //
    //     if (type.isNotEmpty) {
    //       realChildList.add({
    //         "title": childItemTitle,
    //         "subtitle": childItemSubTitle,
    //         "cover": childItemCover,
    //         "type": type,
    //         "browseId": "",
    //         "playlistId": playlistId,
    //       });
    //     }
    //   }
    //
    //   if (realChildList.isNotEmpty) {
    //     realList.add({
    //       "title": bigTitle,
    //       "list": realChildList,
    //       // "moreId": moreId,
    //       "type": type,
    //     });
    //   }
    // }

    //新的

    for (Map item in oldList) {
      //大标题
      var bigTitle =
          item["richSectionRenderer"]?["content"]["richShelfRenderer"]["title"]["runs"][0]["text"] ??
          "";

      // moreId = item["musicCarouselShelfRenderer"]?["header"]
      //                     ?["musicCarouselShelfBasicHeaderRenderer"]
      //                 ?["moreContentButton"]?["buttonRenderer"]
      //             ?["navigationEndpoint"]?["watchPlaylistEndpoint"]
      //         ?["playlistId"] ??
      //     "";

      List childList =
          item["richSectionRenderer"]?["content"]["richShelfRenderer"]["contents"] ??
          [];

      List realChildList = [];

      //判断类型
      var type = "";

      // AppLog.e(childList.first);

      for (Map ci in childList) {
        //小内容
        Map childItem = ci["richItemRenderer"]["content"] ?? {};

        if (childItem.containsKey("gridVideoRenderer")) {
          //多个视频
          //LOCKUP_CONTENT_TYPE_ALBUM
          type = "Video";

          var childItemTitle =
              childItem["gridVideoRenderer"]["title"]["simpleText"] ?? "";

          // var childItemSubTitle = childItem["lockupViewModel"]["metadata"]
          //                 ["lockupMetadataViewModel"]["metadata"]
          //             ["contentMetadataViewModel"]["metadataRows"][0]
          //         ["metadataParts"]["text"]["content"] ??
          //     "";
          var childItemSubTitle =
              childItem["gridVideoRenderer"]["title"]["accessibilityData"]?["label"] ??
              "";

          var childItemCover =
              childItem["gridVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ??
              "";

          var videoId = childItem["gridVideoRenderer"]?["videoId"] ?? "";

          if (type.isNotEmpty) {
            realChildList.add({
              "title": childItemTitle,
              "subtitle": childItemSubTitle,
              "cover": childItemCover,
              "type": type,
              "browseId": "",
              "videoId": videoId,
            });
          }

          continue;
        }

        if (!childItem.containsKey("lockupViewModel")) {
          AppLog.e(childItem);
          continue;
        }

        //LOCKUP_CONTENT_TYPE_ALBUM
        type = childItem["lockupViewModel"]["contentType"];

        var childItemTitle =
            childItem["lockupViewModel"]["metadata"]["lockupMetadataViewModel"]["title"]["content"] ??
            "";
        // var childItemSubTitle = childItem["lockupViewModel"]["metadata"]
        //                 ["lockupMetadataViewModel"]["metadata"]
        //             ["contentMetadataViewModel"]["metadataRows"][0]
        //         ["metadataParts"]["text"]["content"] ??
        //     "";
        var childItemSubTitle = "";

        var childItemCover =
            childItem["lockupViewModel"]["contentImage"]["collectionThumbnailViewModel"]["primaryThumbnail"]["thumbnailViewModel"]["image"]["sources"][0]["url"];

        var playlistId = childItem["lockupViewModel"]?["contentId"] ?? "";

        if (type.isNotEmpty) {
          realChildList.add({
            "title": childItemTitle,
            "subtitle": childItemSubTitle,
            "cover": childItemCover,
            "type": type,
            "browseId": "",
            "playlistId": playlistId,
          });
        }
      }

      if (realChildList.isNotEmpty) {
        realList.add({
          "title": bigTitle,
          "list": realChildList,
          // "moreId": moreId,
          "type": type,
        });
      }
    }

    return realList;
  }
}
