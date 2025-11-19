import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/uinew/main/home/u_play_list.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';

class UserChannelMore extends GetView<UserChannelMoreController> {
  const UserChannelMore({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserChannelMoreController());
    return Scaffold(
      appBar: AppBar(title: Text(Get.arguments["title"] ?? "")),
      body: PlayerBottomBarView(
        child: controller.obxView(
          (s) => Obx(
            () => EasyRefresh(
              controller: controller.easyC,
              onLoad: () async {
                await controller.bindMoreData();

                return controller.moreToken.isEmpty
                    ? IndicatorResult.noMore
                    : IndicatorResult.success;
              },
              child: GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.w,
                  crossAxisSpacing: 10.w,
                  mainAxisExtent: (Get.width - 42.w) / 2 + 50.w,
                ),
                itemBuilder: (_, i) {
                  return getItem(i);
                },
                itemCount: controller.list.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getItem(int i) {
    if (controller.info["type"] == "video") {
      var childItem = controller.list[i];
      return Obx(() {
        var isCheck =
            childItem["videoId"] ==
            Get.find<UserPlayInfoController>().nowData["videoId"];
        return InkWell(
          onTap: () {
            AppLog.e(childItem);
            Get.find<UserPlayInfoController>().setDataAndPlayItem(
              controller.list,
              childItem,
              clickType: false ? "s_detail_playlist" : "h_detail_playlist",
            );
            // Get.to(UserPlayInfo());
          },
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: NetImageView(
                            imgUrl: childItem["cover"] ?? "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        isCheck
                            ? Positioned(
                              left: 6.w,
                              top: 6.w,
                              child: Image.asset(
                                "assets/oimg/icon_s_v_play.png",
                                width: 20.w,
                                height: 14.w,
                              ),
                            )
                            : Center(
                              child: Image.asset(
                                "assets/oimg/icon_c_play.png",
                                width: 51.w,
                                height: 51.w,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.w),
                Text(
                  childItem["title"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCheck ? Color(0xffA491F7) : Colors.black,
                    fontSize: 14.w,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Text(
                //   childItem["subtitle"],
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //       fontSize: 12.w, color: Color(0xff595959)),
                // ),
              ],
            ),
          ),
        );
      });
    } else if (controller.info["type"] == "album" ||
        controller.info["type"] == "playlist") {
      var childItem = controller.list[i];
      return GestureDetector(
        onTap: () {
          AppLog.e(childItem);
          EventUtils.instance.addEvent(
            "det_playlist_show",
            data: {"from": "artist_playlist"},
          );
          Get.to(UserPlayListInfo(), arguments: childItem);
        },
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  // height: 140.w,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: NetImageView(
                          imgUrl: childItem["cover"] ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                childItem["title"],
                style: TextStyle(fontSize: 14.w),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Container(height: 10.w);
  }
}

class UserChannelMoreController extends GetxController with StateMixin {
  var list = [].obs;

  var info = {};

  var easyC = EasyRefreshController();

  @override
  void onInit() {
    super.onInit();
    info = Get.arguments;

    bindData();
  }

  bindData() async {
    var result = await ApiMain.instance.getYoutubeData(
      info["moreBrowseId"],
      params: info["moreParams"],
    );
    //解析数据
    if (result.code == HttpCode.success) {
      if (info["type"] == "video") {
        List tabs =
            result.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
            [];
        for (Map tab in tabs) {
          if (tab["tabRenderer"]["selected"] == true) {
            //获取数据
            List oldList =
                tab["tabRenderer"]["content"]["richGridRenderer"]["contents"] ??
                [];

            //解析list
            var newList = [];

            for (Map oldItem in oldList) {
              try {
                var videoId =
                    oldItem["richItemRenderer"]["content"]["videoRenderer"]["videoId"] ??
                    "";
                var title =
                    oldItem["richItemRenderer"]["content"]["videoRenderer"]["title"]["runs"][0]["text"] ??
                    "";
                var cover =
                    oldItem["richItemRenderer"]["content"]["videoRenderer"]["thumbnail"]["thumbnails"]
                        .last["url"];
                newList.add({
                  "title": title,
                  "subtitle": "",
                  "cover": cover,
                  "videoId": videoId,
                });
              } catch (e) {
                print(e);
                AppLog.e(oldItem);
                //加载更多
              }
            }

            //更多数据

            Map lastItem = oldList.lastOrNull ?? {};
            if (lastItem.containsKey("continuationItemRenderer")) {
              //有更多数据
              moreToken =
                  lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
                  "";
            } else {
              moreToken = "";
            }

            list.value = newList;

            break;
          }
        }
      } else if (info["type"] == "album") {
        List tabs =
            result.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
            [];
        for (Map tab in tabs) {
          if (tab["tabRenderer"]["selected"] == true) {
            //获取数据
            List oldList =
                tab["tabRenderer"]["content"]["richGridRenderer"]["contents"];

            //解析list
            var newList = [];

            for (Map oldItem in oldList) {
              try {
                var playlistId =
                    oldItem["richItemRenderer"]["content"]["playlistRenderer"]["playlistId"] ??
                    "";
                var title =
                    oldItem["richItemRenderer"]["content"]["playlistRenderer"]["title"]["simpleText"] ??
                    "";
                var cover =
                    oldItem["richItemRenderer"]["content"]["playlistRenderer"]["thumbnails"][0]["thumbnails"]
                        .last["url"] ??
                    "";

                newList.add({
                  "title": title,
                  "subtitle": "",
                  "cover": cover,
                  "playlistId": playlistId,
                });
              } catch (e) {
                print(e);
                AppLog.e(oldItem);
              }
            }

            //更多数据

            Map lastItem = oldList.lastOrNull ?? {};
            if (lastItem.containsKey("continuationItemRenderer")) {
              //有更多数据
              moreToken =
                  lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
                  "";
            } else {
              moreToken = "";
            }
            list.value = newList;

            break;
          }
        }
      } else if (info["type"] == "playlist") {
        List tabs =
            result.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
            [];
        for (Map tab in tabs) {
          if (tab["tabRenderer"]["selected"] == true) {
            //获取数据
            List oldList =
                tab["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"][0]["gridRenderer"]["items"] ??
                [];

            //解析list
            var newList = [];

            for (Map oldItem in oldList) {
              try {
                var playlistId = oldItem["lockupViewModel"]["contentId"] ?? "";
                var title =
                    oldItem["lockupViewModel"]["metadata"]["lockupMetadataViewModel"]["title"]["content"] ??
                    "";
                var cover =
                    oldItem["lockupViewModel"]["contentImage"]["collectionThumbnailViewModel"]["primaryThumbnail"]["thumbnailViewModel"]["image"]["sources"]
                        .last["url"];

                newList.add({
                  "title": title,
                  "subtitle": "",
                  "cover": cover,
                  "playlistId": playlistId,
                });
              } catch (e) {
                AppLog.e(oldItem);
                e.printInfo();
              }
            }

            //更多数据

            Map lastItem = oldList.lastOrNull ?? {};
            if (lastItem.containsKey("continuationItemRenderer")) {
              //有更多数据
              moreToken =
                  lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
                  "";
            } else {
              moreToken = "";
            }

            list.value = newList;
            break;
          }
        }
      }

      change("", status: RxStatus.success());
    } else {
      change("", status: RxStatus.error());
    }
  }

  var moreToken = "";

  Future bindMoreData() async {
    if (moreToken.isEmpty) {
      return;
    }
    AppLog.e(moreToken);

    var result = await ApiMain.instance.getYoutubeData(
      info["moreBrowseId"],
      params: info["moreParams"],
      nextData: {"continuation": moreToken},
    );

    if (info["type"] == "video") {
      //视频解析
      List oldList =
          result
              .data["onResponseReceivedActions"][0]["appendContinuationItemsAction"]["continuationItems"] ??
          [];
      var newList = [];

      for (Map oldItem in oldList) {
        try {
          var videoId =
              oldItem["richItemRenderer"]["content"]["videoRenderer"]["videoId"] ??
              "";
          var title =
              oldItem["richItemRenderer"]["content"]["videoRenderer"]["title"]["runs"][0]["text"] ??
              "";
          var cover =
              oldItem["richItemRenderer"]["content"]["videoRenderer"]["thumbnail"]["thumbnails"]
                  .last["url"];
          newList.add({
            "title": title,
            "subtitle": "",
            "cover": cover,
            "videoId": videoId,
          });
        } catch (e) {
          print(e);
          AppLog.e(oldItem);
          //加载更多
        }
      }

      //更多数据

      Map lastItem = oldList.lastOrNull ?? {};
      if (lastItem.containsKey("continuationItemRenderer")) {
        //有更多数据
        moreToken =
            lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
            "";
      } else {
        moreToken = "";
      }

      list.addAll(newList);
    } else if (info["type"] == "album") {
      //作品解析
      List oldList =
          result
              .data["onResponseReceivedActions"][0]["appendContinuationItemsAction"]["continuationItems"] ??
          [];
      var newList = [];

      for (Map oldItem in oldList) {
        try {
          var playlistId =
              oldItem["richItemRenderer"]["content"]["playlistRenderer"]["playlistId"] ??
              "";
          var title =
              oldItem["richItemRenderer"]["content"]["playlistRenderer"]["title"]["simpleText"] ??
              "";
          var cover =
              oldItem["richItemRenderer"]["content"]["playlistRenderer"]["thumbnails"][0]["thumbnails"]
                  .last["url"] ??
              "";

          newList.add({
            "title": title,
            "subtitle": "",
            "cover": cover,
            "playlistId": playlistId,
          });
        } catch (e) {
          print(e);
          AppLog.e(oldItem);
        }
      }

      //更多数据

      Map lastItem = oldList.lastOrNull ?? {};
      if (lastItem.containsKey("continuationItemRenderer")) {
        //有更多数据
        moreToken =
            lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
            "";
      } else {
        moreToken = "";
      }

      list.addAll(newList);
    } else if (info["type"] == "playlist") {
      //列表暂未发现分页

      //播放列表解析
      // AppLog.e(result.data);
      // List oldList = result.data["onResponseReceivedActions"][0]
      //         ["appendContinuationItemsAction"]["continuationItems"] ??
      //     [];
      // var newList = [];
      //
      // for (Map oldItem in oldList) {
      //   try {
      //     var playlistId = oldItem["lockupViewModel"]["contentId"] ?? "";
      //     var title = oldItem["lockupViewModel"]["metadata"]
      //             ["lockupMetadataViewModel"]["title"]["content"] ??
      //         "";
      //     var cover = oldItem["lockupViewModel"]["contentImage"]
      //                 ["collectionThumbnailViewModel"]["primaryThumbnail"]
      //             ["thumbnailViewModel"]["image"]["sources"]
      //         .last["url"];
      //
      //     newList.add({
      //       "title": title,
      //       "subtitle": "",
      //       "cover": cover,
      //       "playlistId": playlistId,
      //     });
      //   } catch (e) {
      //     AppLog.e(oldItem);
      //     e.printInfo();
      //   }
      // }
      //
      // //更多数据
      //
      // Map lastItem = oldList.lastOrNull ?? {};
      // if (lastItem.containsKey("continuationItemRenderer")) {
      //   //有更多数据
      //   moreToken = lastItem["continuationItemRenderer"]
      //           ?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
      //       "";
      // } else {
      //   moreToken = "";
      // }
      //
      // list.addAll(newList);
    }

    // AppLog.e(result.data);
  }
}
