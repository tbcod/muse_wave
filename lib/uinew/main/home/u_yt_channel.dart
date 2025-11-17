import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_channel_more.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/uinew/main/home/u_play_list.dart';

import '../../../api/api_main.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';
import '../../../view/sliver_delegate.dart';

class UserYoutubeChannel extends GetView<UserYoutubeChannelController> {
  const UserYoutubeChannel({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserYoutubeChannelController());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/oimg/all_page_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: controller.obxPage(
            (state) => NestedScrollView(
              controller: controller.scrollC,
              headerSliverBuilder: (c, innerBoxIsScrolled) {
                AppLog.e(innerBoxIsScrolled);
                return [
                  SliverAppBar(
                    // systemOverlayStyle: SystemUiOverlayStyle(
                    //     statusBarIconBrightness: Brightness.light),
                    backgroundColor: Color(0xfffafafa),
                    // backgroundColor: Colors.red,
                    pinned: true,
                    centerTitle: true,
                    title: Obx(
                      () =>
                          controller.isHeaderExpanded.value
                              ? Container()
                              : Text(controller.info["title"]),
                    ),
                    expandedHeight: 200.w + Get.mediaQuery.padding.top,
                    leading: Obx(
                      () => IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Image.asset(
                          "assets/oimg/icon_back.png",
                          width: 24.w,
                          height: 24.w,
                          color:
                              controller.isHeaderExpanded.value
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                    actions: [
                      Obx(() {
                        var isLike = LikeUtil.instance.allArtistMap.containsKey(
                          controller.browseId,
                        );

                        return IconButton(
                          onPressed: () {
                            if (isLike) {
                              LikeUtil.instance.unlikeArtist(
                                controller.browseId,
                              );
                            } else {
                              LikeUtil.instance.likeArtist(
                                controller.browseId,
                                controller.info,
                              );
                            }
                          },
                          icon: Image.asset(
                            isLike
                                ? "assets/oimg/icon_like_on.png"
                                : "assets/oimg/icon_like_off.png",
                            width: 24.w,
                            height: 24.w,
                            color:
                                isLike
                                    ? null
                                    : controller.isHeaderExpanded.value
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 0),
                      background: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: NetImageView(
                                imgUrl: controller.info["cover"] ?? "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            //渐变
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xff0D0D0D).withOpacity(0.69),
                                      Color(0xff474747).withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 12.w,
                              right: 12.w,
                              bottom: 8.w,
                              child: Text(
                                controller.info["title"] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 24.w,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  controller.hasSong.value
                      ? SliverPersistentHeader(
                        pinned: true,
                        delegate: MySliverDelegate(
                          80.w,
                          80.w,
                          Container(
                            color: Color(0xfffafafa),
                            // color: Colors.green,
                            // clipBehavior: Clip.hardEdge,
                            // decoration: BoxDecoration(
                            //   color: Color(0xfffafafa),
                            // ),
                            height: 80.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      //播放
                                      if (controller.moreList.isEmpty) {
                                        AppLog.e(controller.moreList.length);
                                        return;
                                      }
                                      EventUtils.instance.addEvent(
                                        "det_artist_click",
                                        data: {"detail_click": "play"},
                                      );

                                      Get.find<UserPlayInfoController>()
                                          .setDataAndPlayItem(
                                            controller.moreList,
                                            controller.moreList.first,
                                            pid:
                                                "browseId-${controller.browseId}",
                                            clickType:
                                                false
                                                    ? "s_detail_playlist"
                                                    : "h_detail_playlist",
                                          );
                                      // Get.to(UserPlayInfo());
                                    },
                                    child: Container(
                                      height: 42.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          21.w,
                                        ),
                                        color: Color(0xff7453FF),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/oimg/icon_play.png",
                                            width: 24.w,
                                            height: 24.w,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "Play",
                                            style: TextStyle(
                                              fontSize: 16.w,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (controller.moreList.isEmpty) {
                                        AppLog.e(controller.moreList.length);
                                        return;
                                      }
                                      EventUtils.instance.addEvent(
                                        "det_artist_click",
                                        data: {"detail_click": "shuffle"},
                                      );

                                      List playList = List.of(
                                        controller.moreList,
                                      )..shuffle();

                                      Get.find<UserPlayInfoController>()
                                          .setDataAndPlayItem(
                                            playList,
                                            playList.first,
                                            pid:
                                                "browseId-${controller.browseId}",
                                            clickType:
                                                false
                                                    ? "s_detail_playlist"
                                                    : "h_detail_playlist",
                                          );
                                      // Get.to(UserPlayInfo());
                                    },
                                    child: Container(
                                      height: 42.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          21.w,
                                        ),
                                        border: Border.all(
                                          color: Color(0xff7453FF),
                                          width: 2.w,
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/oimg/icon_shuffle1.png",
                                            width: 24.w,
                                            height: 24.w,
                                            color: Color(0xff7453FF),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "Shuffle",
                                            style: TextStyle(
                                              fontSize: 16.w,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff7453FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : SliverToBoxAdapter(),
                ];
              },
              body: Container(
                color: Color(0xfffafafa),
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    top: 10.w,
                    bottom: Get.mediaQuery.padding.bottom + 100.w,
                  ),
                  itemBuilder: (_, i) {
                    return getBigItem(i);
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(height: 16.w);
                  },
                  itemCount: controller.list.length,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBigItem(int i) {
    var bigItem = controller.list[i];
    List data = bigItem["list"] ?? [];
    var type = bigItem["type"];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Text(
                bigItem["title"] ?? "",
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Spacer(),
              (bigItem["moreBrowseId"] ?? "") == ""
                  ? Container()
                  : InkWell(
                    onTap: () async {
                      //点击更多
                      AppLog.e(bigItem);
                      Get.to(UserChannelMore(), arguments: bigItem);
                    },
                    child: Row(
                      children: [
                        Text(
                          "More".tr,
                          style: TextStyle(
                            fontSize: 12.w,
                            color: Color(0xffa6a6a6),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Image.asset(
                          "assets/oimg/icon_more_right.png",
                          width: 12.w,
                          height: 12.w,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        SizedBox(height: 10.w),
        Builder(
          builder: (c) {
            if (type == "video") {
              //大的视频音乐
              return Container(
                height: 185.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
                    return Obx(() {
                      var isCheck =
                          childItem["videoId"] ==
                          Get.find<UserPlayInfoController>().nowData["videoId"];
                      return InkWell(
                        onTap: () {
                          AppLog.e(childItem);
                          Get.find<UserPlayInfoController>().setDataAndPlayItem(
                            [childItem],
                            childItem,
                            pid: "browseId-${controller.browseId}",
                            clickType:
                                false
                                    ? "s_detail_playlist"
                                    : "h_detail_playlist",
                            loadNextData: true,
                          );
                          // Get.to(UserPlayInfo());
                        },
                        child: Container(
                          width: 248.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 248.w,
                                height: 140.w,
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
                              SizedBox(height: 4.w),
                              Text(
                                childItem["title"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      isCheck
                                          ? Color(0xffA491F7)
                                          : Colors.black,
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
                    // return GestureDetector(
                    //   onTap: () {
                    //     AppLog.e(childItem);
                    //     Get.find<UserPlayInfoController>().setDataAndPlayItem(
                    //         data, childItem,
                    //         clickType: isFormSearch ? "s_detail" : "h_detail");
                    //     // Get.to(UserPlayInfo());
                    //   },
                    //   child: Container(
                    //     width: 248.w,
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Container(
                    //             width: 248.w,
                    //             height: 140.w,
                    //             clipBehavior: Clip.hardEdge,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(6.w)),
                    //             child: Stack(
                    //               children: [
                    //                 Positioned.fill(
                    //                   child: NetImageView(
                    //                     imgUrl: childItem["cover"] ?? "",
                    //                     fit: BoxFit.cover,
                    //                   ),
                    //                 ),
                    //                 Center(
                    //                   child: Image.asset(
                    //                     "assets/oimg/icon_c_play.png",
                    //                     width: 51.w,
                    //                     height: 51.w,
                    //                   ),
                    //                 )
                    //               ],
                    //             )),
                    //         SizedBox(
                    //           height: 4.w,
                    //         ),
                    //         Text(
                    //           childItem["title"],
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style: TextStyle(fontSize: 14.w),
                    //         ),
                    //         Text(
                    //           childItem["subtitle"],
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style: TextStyle(
                    //               fontSize: 12.w, color: Color(0xff595959)),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // );
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(width: 12.w);
                  },
                  itemCount: data.length,
                ),
              );
            } else if (type == "playlist" || type == "album") {
              return Container(
                height: 185.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
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
                        width: 140.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140.w,
                              height: 140.w,
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
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(width: 12.w);
                  },
                  itemCount: data.length,
                ),
              );
            }

            return Container(height: 200.w, color: Colors.red);
          },
        ),
      ],
    );
  }
}

class UserYoutubeChannelController extends GetxController with StateMixin {
  var browseId = "";

  var info = {};
  var list = [];

  var moreList = [];

  var scrollC = ScrollController();

  var isHeaderExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    browseId = Get.arguments?["browseId"];
    bindData();

    scrollC.addListener(() {
      isHeaderExpanded.value =
          scrollC.offset < 200.w - Get.mediaQuery.padding.top - kToolbarHeight;
      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //     statusBarIconBrightness:
      //         isHeaderExpanded.value ? Brightness.light : Brightness.dark));
    });
  }

  //EghyZWxlYXNlc_IGBQoDsgEA  发布作品
  //EglwbGF5bGlzdHPyBgQKAkIA  播放列表
  //EgZ2aWRlb3PyBgQKAjoA   视频
  bindData() async {
    info = {
      "cover": Get.arguments?["cover"],
      "title": Get.arguments?["title"],
      // "description": description,
      // "subtitle": fansNumStr,
      "browseId": browseId,
    };

    var result = await ApiMain.instance.getYoutubeData(
      browseId,
      params: "EgZ2aWRlb3PyBgQKAjoA",
    );
    var result2 = await ApiMain.instance.getYoutubeData(
      browseId,
      params: "EghyZWxlYXNlc_IGBQoDsgEA",
    );
    var result3 = await ApiMain.instance.getYoutubeData(
      browseId,
      params: "EglwbGF5bGlzdHPyBgQKAkIA",
    );

    //解析视频
    if (result.code == HttpCode.success) {
      //设置封面图
      try {
        info["cover"] =
            result
                .data["header"]["pageHeaderRenderer"]["content"]["pageHeaderViewModel"]["image"]["decoratedAvatarViewModel"]["avatar"]["avatarViewModel"]["image"]["sources"]
                .last["url"];
        // info["cover"] = result
        //     .data["header"]["pageHeaderRenderer"]["content"]
        //         ["pageHeaderViewModel"]["banner"]["imageBannerViewModel"]["image"]
        //         ["sources"]
        //     .last["url"];

        List tabs =
            result.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
            [];
        for (Map tab in tabs) {
          if (tab["tabRenderer"]["selected"] == true) {
            // AppLog.e(tab["tabRenderer"]["content"]);
            // Map oldData=tab["tabRenderer"]["content"];

            //获取数据
            List oldList =
                tab["tabRenderer"]["content"]["richGridRenderer"]["contents"] ??
                [];

            //

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

            var bigTitle = tab["tabRenderer"]["title"] ?? "";

            var moreBrowseId =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["browseId"] ??
                "";
            var moreParams =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["params"] ??
                "";

            list.add({
              "title": bigTitle,
              "list": newList,
              "moreBrowseId": moreBrowseId,
              "moreParams": moreParams,
              "type": "video",
            });

            break;
          }
        }
      } catch (e) {
        print(e);
      }
    }

    //解析发布作品
    if (result2.code == HttpCode.success) {
      List tabs =
          result2.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
          [];
      for (Map tab in tabs) {
        try {
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

            var bigTitle = tab["tabRenderer"]["title"] ?? "";

            var moreBrowseId =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["browseId"] ??
                "";
            var moreParams =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["params"] ??
                "";

            list.add({
              "title": bigTitle,
              "list": newList,
              "moreBrowseId": moreBrowseId,
              "moreParams": moreParams,
              "type": "album",
            });

            // AppLog.e(list);

            break;
          }
        } catch (e) {
          print(e);
        }
      }
    }

    //解析播放列表
    if (result3.code == HttpCode.success) {
      List tabs =
          result3.data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"] ??
          [];
      for (Map tab in tabs) {
        try {
          if (tab["tabRenderer"]["selected"] == true) {
            //获取数据
            List oldList =
                tab["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"][0]["gridRenderer"]["items"] ??
                [];

            //

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

            var bigTitle = tab["tabRenderer"]["title"] ?? "";

            var moreBrowseId =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["browseId"] ??
                "";
            var moreParams =
                tab["tabRenderer"]?["endpoint"]?["browseEndpoint"]?["params"] ??
                "";

            list.add({
              "title": bigTitle,
              "list": newList,
              "moreBrowseId": moreBrowseId,
              "moreParams": moreParams,
              "type": "playlist",
            });

            break;
          }
        } catch (e) {
          print(e);
        }
      }
    }

    if (list.isEmpty) {
      change("", status: RxStatus.empty());
    } else {
      change("", status: RxStatus.success());
    }
  }

  var hasSong = false.obs;
}
