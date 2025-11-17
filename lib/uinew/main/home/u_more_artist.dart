import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_artist.dart';

import '../../../api/api_main.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';
import '../u_home.dart';

class UserMoreArtist extends GetView<UserMoreArtistController> {
  const UserMoreArtist({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserMoreArtistController());
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff1ffff),
        image: DecorationImage(
          image: AssetImage("assets/oimg/all_page_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Image.asset(
              "assets/oimg/icon_back.png",
              width: 24.w,
              height: 24.w,
            ),
          ),
          title: Text("Artist".tr),
        ),
        body: Container(
          child: controller.obxView(
            (s) => ListView.separated(
              padding: EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom + 60.w,
              ),
              itemBuilder: (_, i) {
                return getItem(i);
              },
              separatorBuilder: (_, i) {
                return SizedBox(height: 10.w);
              },
              itemCount: controller.list.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget getItem(int i) {
    var item = controller.list[i];
    return InkWell(
      onTap: () {
        AppLog.e(item);
        EventUtils.instance.addEvent("det_artist_show", data: {"form": "more"});
        Get.to(UserArtistInfo(), arguments: item);
      },
      child: Container(
        height: 70.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: NetAvatarView(imgUrl: item["cover"], size: 52.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    item["title"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 9.w),
                  Row(
                    children: [
                      // if (isLike)
                      //   Container(
                      //     width: 16.w,
                      //     height: 16.w,
                      //     margin:
                      //     EdgeInsets.only(right: 4.w),
                      //     child: Image.asset(
                      //         "assets/oimg/icon_like_on.png"),
                      //   ),
                      Expanded(
                        child: Text(
                          item["subtitle"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.w,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              var browseId = item["browseId"];
              var isLike = LikeUtil.instance.allArtistMap.containsKey(browseId);

              return InkWell(
                onTap: () {
                  if (isLike) {
                    LikeUtil.instance.unlikeArtist(browseId);
                  } else {
                    LikeUtil.instance.likeArtist(browseId, item);
                  }
                },
                child: Image.asset(
                  isLike
                      ? "assets/oimg/icon_like_on.png"
                      : "assets/oimg/icon_like_off_g.png",
                  width: 24.w,
                  height: 24.w,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class UserMoreArtistController extends GetxController with StateMixin {
  var dArtistList = [];

  var list = [].obs;
  @override
  void onInit() {
    super.onInit();
    bindData();
  }

  bindData() async {
    dArtistList = decodeList(locArtist);
    //请求粉丝数量

    //请求排行榜上的歌手

    BaseModel result = await ApiMain.instance.getData("FEmusic_charts");
    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    //解析

    List oldList =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][2]["musicCarouselShelfRenderer"]["contents"] ??
        [];

    var newList = [];
    for (var item in oldList) {
      var browseId =
          item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];

      var bidList = dArtistList.map((e) => e["browseId"].toString()).toList();
      if (bidList.contains(browseId)) {
        //是默认的6个歌手，跳过
        var index = bidList.indexOf(browseId);

        //更新歌手粉丝信息
        var newAItem = Map.of(dArtistList[index]);
        var newSubtitle =
            item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
        newAItem["subtitle"] = newSubtitle;
        dArtistList[index] = newAItem;
        AppLog.e("第$index个,更新为$newAItem");

        continue;
      }

      var title =
          item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var subTitle =
          item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var cover =
          item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][1]["url"];

      var itemData = {
        "title": title,
        "subtitle": subTitle,
        "cover": cover,
        "type": "MUSIC_PAGE_TYPE_ARTIST",
        "browseId": browseId,
      };
      newList.add(itemData);
    }

    for (int i = 0; i < dArtistList.length; i++) {
      if (dArtistList[i]["subtitle"]?.toString().isEmpty ?? true) {
        //更新默认歌手的粉丝数量
        var itemResult = await ApiMain.instance.getData(
          dArtistList[i]["browseId"],
        );
        if (itemResult.code == HttpCode.success) {
          var newAItem = Map.of(dArtistList[i]);
          newAItem["subtitle"] =
              itemResult
                  .data["header"]["musicImmersiveHeaderRenderer"]["subscriptionButton"]["subscribeButtonRenderer"]["longSubscriberCountText"]["runs"][0]["text"];
          dArtistList[i] = newAItem;
        }
      }
    }

    //添加默认
    list.clear();
    list.addAll(dArtistList);
    list.addAll(newList);

    change("", status: RxStatus.success());
  }
}
