import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_more_album.dart';
import 'package:muse_wave/uinew/main/home/u_more_song.dart';
import 'package:muse_wave/uinew/main/home/u_more_video.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/uinew/main/home/u_play_list.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../tool/format_data.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';
import '../../../view/sliver_delegate.dart';

class UserArtistInfo extends GetView<UserArtistInfoController> {
  @override
  String? get tag => browseId;

  final bool isFormSearch;
  final browseId = Get.arguments?["browseId"];
  UserArtistInfo({super.key, this.isFormSearch = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserArtistInfoController(), tag: tag);

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
        body: PlayerBottomBarView(
          child: Container(
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
                                              clickType:
                                                  isFormSearch
                                                      ? "s_detail_artist"
                                                      : "h_detail_artist",
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
                                              clickType:
                                                  isFormSearch
                                                      ? "s_detail_artist"
                                                      : "h_detail_artist",
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

                      String browseId = bigItem["moreBrowseId"] ?? "";
                      String params = bigItem["moreParams"] ?? "";
                      AppLog.e(
                        "type==$type\nbrowseId==$browseId\nparams==$params",
                      );
                      var title = bigItem["title"] ?? "";
                      if (type == "music") {
                        Get.to(
                          UserMoreSong(
                            barTitle: title,
                            isFormSearch: isFormSearch,
                          ),
                          arguments: {"browseId": browseId, "params": params},
                        );
                      } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
                        Get.to(
                          UserMoreAlbum(barTitle: title),
                          arguments: {"browseId": browseId, "params": params},
                        );
                      } else if (type == "MUSIC_VIDEO_TYPE_OMV" ||
                          type == "MUSIC_VIDEO_TYPE_UGC") {
                        Get.to(
                          UserMoreVideo(
                            barTitle: title,
                            isFormSearch: isFormSearch,
                          ),
                          arguments: {"browseId": browseId, "params": params},
                        );
                      } else if (type == "MUSIC_PAGE_TYPE_PLAYLIST") {
                        Get.to(UserMoreAlbum(barTitle: title), arguments: {"browseId": browseId, "params": params});
                      }


                      // BaseModel result = await ApiMain.instance.getMoreData({
                      //   "browseId": browseId,
                      //   "params": params,
                      // });
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
            if (type == "MUSIC_VIDEO_TYPE_OMV" ||
                type == "MUSIC_VIDEO_TYPE_UGC") {
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
                            clickType:
                                isFormSearch
                                    ? "s_detail_artist"
                                    : "h_detail_artist",
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
            } else if (type == "music") {
              //小的歌曲列表
              return MediaQuery.removePadding(
                context: c,
                removeTop: true,
                child: Container(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 0),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      var item = data[i];
                      return InkWell(
                        onTap: () {
                          Get.find<UserPlayInfoController>().setDataAndPlayItem(
                            [item],
                            item,
                            clickType:
                                isFormSearch
                                    ? "s_detail_artist"
                                    : "h_detail_artist",
                            loadNextData: true,
                          );
                          // Get.to(UserPlayInfo());
                        },
                        child: Obx(() {
                          var isCheck =
                              item["videoId"] ==
                              Get.find<UserPlayInfoController>()
                                  .nowData["videoId"];
                          return Container(
                            // color: Colors.red,
                            height: 70.w,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color:
                                  isCheck
                                      ? Color(0xfff7f7f7)
                                      : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 54.w,
                                  height: 54.w,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.w),
                                  ),
                                  child: NetImageView(
                                    imgUrl: item["cover"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        item["title"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          height: 1,
                                          fontSize: 14.w,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isCheck
                                                  ? Color(0xff8569FF)
                                                  : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 12.w),
                                      Row(
                                        children: [
                                          Obx(() {
                                            var isLike = LikeUtil
                                                .instance
                                                .allVideoMap
                                                .containsKey(item["videoId"]);
                                            if (isLike) {
                                              return Container(
                                                width: 16.w,
                                                height: 16.w,
                                                margin: EdgeInsets.only(
                                                  right: 4.w,
                                                ),
                                                child: Image.asset(
                                                  "assets/oimg/icon_like_on.png",
                                                ),
                                              );
                                            }

                                            return Container();
                                          }),
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
                                                height: 1,
                                                fontSize: 12.w,
                                                color:
                                                    isCheck
                                                        ? Color(0xff8569FF)
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                getDownloadAndMoreBtn(
                                  item,
                                  "artist",
                                  isSearch: isFormSearch,
                                ),

                                // Obx(() {
                                //   //获取下载状态
                                //   var videoId = item["videoId"];
                                //
                                //   if (DownloadUtils.instance.allDownLoadingData
                                //       .containsKey(videoId)) {
                                //     //有添加过下载
                                //     var state = DownloadUtils.instance
                                //         .allDownLoadingData[videoId]["state"];
                                //     double progress = DownloadUtils.instance
                                //         .allDownLoadingData[videoId]["progress"];
                                //
                                //     // AppLog.e(
                                //     //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");
                                //
                                //     if (state == 1 || state == 3) {
                                //       //下载中\下载暂停
                                //       return InkWell(
                                //         onTap: () {
                                //           DownloadUtils.instance.remove(videoId);
                                //         },
                                //         child: Container(
                                //             width: 20.w,
                                //             height: 20.w,
                                //             // padding: EdgeInsets.all(5.w),
                                //             child: CircularProgressIndicator(
                                //               value: progress,
                                //               strokeWidth: 1.5,
                                //               backgroundColor: Color(0xffA995FF)
                                //                   .withOpacity(0.35),
                                //               color: Color(0xffA995FF),
                                //             )),
                                //       );
                                //     } else if (state == 2) {
                                //       return InkWell(
                                //         onTap: () {
                                //           DownloadUtils.instance.remove(videoId);
                                //         },
                                //         child: Image.asset(
                                //           "assets/oimg/icon_download_ok.png",
                                //           width: 20.w,
                                //           height: 20.w,
                                //         ),
                                //       );
                                //     }
                                //   }
                                //
                                //   return InkWell(
                                //     onTap: () {
                                //       EventUtils.instance.addEvent(
                                //           "det_artist_click",
                                //           data: {"detail_click": "dl"});
                                //
                                //       DownloadUtils.instance.download(
                                //           videoId, item,
                                //           clickType: "h_detail");
                                //     },
                                //     child: Image.asset(
                                //       "assets/oimg/icon_download_gray.png",
                                //       width: 20.w,
                                //       height: 20.w,
                                //     ),
                                //   );
                                // }),
                                // SizedBox(
                                //   width: 12.w,
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     MoreSheetUtil.instance.showVideoMoreSheet(
                                //         item,
                                //         clickType: "artist");
                                //   },
                                //   child: Container(
                                //     width: 20.w,
                                //     height: 20.w,
                                //     child:
                                //         Image.asset("assets/oimg/icon_more.png"),
                                //   ),
                                // )
                              ],
                            ),
                          );
                        }),
                      );
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(height: 8.w);
                    },
                    itemCount: data.length,
                  ),
                ),
              );
            } else if (type == "MUSIC_PAGE_TYPE_PLAYLIST") {
              //歌单
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
            } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
              //专辑
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
                          data: {"from": "artist_album"},
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
            } else if (type == "MUSIC_PAGE_TYPE_ARTIST") {
              //歌手
              return Container(
                height: 160.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
                    return GestureDetector(
                      onTap: () {
                        AppLog.e(childItem);
                        EventUtils.instance.addEvent(
                          "det_artist_show",
                          data: {"form": "artist_fans_like"},
                        );
                        Get.to(()=>
                          UserArtistInfo(),
                          arguments: childItem,
                          preventDuplicates: false,
                        );
                      },
                      child: Container(
                        width: 100.w,
                        height: 160.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.w),
                            Container(
                              width: 68.w,
                              height: 68.w,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34.w),
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
                            SizedBox(height: 12.w),
                            Container(
                              width: 68.w,
                              child: Text(
                                childItem["title"],
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.w),
                              ),
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

            return Container(
              height: 200.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  var childItem = data[i];

                  return Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        child: NetImageView(imgUrl: childItem["cover"] ?? ""),
                      ),
                      // Text(childItem["title"]),
                      Text(childItem["subtitle"]),
                    ],
                  );
                },
                separatorBuilder: (_, i) {
                  return SizedBox(width: 10.w);
                },
                itemCount: data.length,
              ),
            );
          },
        ),
      ],
    );
  }
}

class UserArtistInfoController extends GetxController with StateMixin {
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

  bindData() async {
    var result = await ApiMain.instance.getData(browseId);
    if (result.code == HttpCode.success) {
      //标题
      var title =
          result
              .data["header"]["musicImmersiveHeaderRenderer"]["title"]["runs"]
              .first["text"];
      var cover =
          result
              .data["header"]["musicImmersiveHeaderRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][1]["url"];
      var description =
          result
              .data["header"]["musicImmersiveHeaderRenderer"]["description"]?["runs"]
              .first["text"] ??
          "";

      var fansNumStr =
          result
              .data["header"]["musicImmersiveHeaderRenderer"]["subscriptionButton"]["subscribeButtonRenderer"]["subscriberCountText"]["runs"]
              .first["text"];

      info = {
        "cover": cover,
        "title": title,
        "description": description,
        "subtitle": fansNumStr,
        "browseId": browseId,
      };

      //所有数据列表
      List oldList =
          result
              .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"];

      var newList = [];
      for (Map item in oldList) {
        if (item.containsKey("musicShelfRenderer")) {
          //歌曲列表
          var bigTitle = item["musicShelfRenderer"]["title"]["runs"][0]["text"];
          //点击更多信息
          var moreBrowseId =
              item["musicShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]?["browseEndpoint"]?["browseId"] ??
              "";
          var moreParams =
              item["musicShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]?["browseEndpoint"]?["params"] ??
              "";
          //歌曲列表
          List musicOldList = item["musicShelfRenderer"]["contents"];

          var newMusicData = FormatMyData.instance.getMusicList(musicOldList);

          newList.add({
            "title": bigTitle,
            "list": newMusicData,
            "moreBrowseId": moreBrowseId,
            "moreParams": moreParams,
            "type": "music",
          });
        } else if (item.containsKey("musicDescriptionShelfRenderer")) {
          //关于歌手
        } else if (item.containsKey("musicCarouselShelfRenderer")) {
          //其他列表
          var bigTitle =
              item["musicCarouselShelfRenderer"]["header"]["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0]["text"];

          var moreBrowseId =
              item["musicCarouselShelfRenderer"]["header"]["musicCarouselShelfBasicHeaderRenderer"]["moreContentButton"]?["buttonRenderer"]?["navigationEndpoint"]?["browseEndpoint"]?["browseId"] ??
              "";
          var moreParams =
              item["musicCarouselShelfRenderer"]["header"]["musicCarouselShelfBasicHeaderRenderer"]["moreContentButton"]?["buttonRenderer"]?["navigationEndpoint"]?["browseEndpoint"]?["params"] ??
              "";

          List otherOldList = item["musicCarouselShelfRenderer"]["contents"];
          var newOtherData = FormatMyData.instance.getOtherList(otherOldList);
          newList.add({
            "title": bigTitle,
            "list": newOtherData,
            "moreBrowseId": moreBrowseId,
            "moreParams": moreParams,
            "type": newOtherData.first["type"],
          });
        }
      }

      list = newList;

      if (newList.isNotEmpty && newList[0]["title"] != "Songs") {
        hasSong.value = false;
      } else {
        hasSong.value = true;
        bindMoreSongList();
      }

      // AppLog.e(list);
      change("", status: RxStatus.success());
    } else {
      change("", status: RxStatus.error());
    }
  }

  var hasSong = false.obs;
  bindMoreSongList() async {
    AppLog.e("请求更多歌曲");
    //先设为5首歌
    moreList = list[0]["list"];

    BaseModel result = await ApiMain.instance.getData(
      list[0]["moreBrowseId"],
      params: list[0]["moreParams"],
    );
    if (result.code != HttpCode.success) {
      return;
    }

    //解析
    List oldList =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]["contents"] ??
        [];

    // nextData = result.data["contents"]["singleColumnBrowseResultsRenderer"]
    // ["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]
    // ["contents"][0]["musicPlaylistShelfRenderer"]?["continuations"]
    // ?[0]?["nextContinuationData"] ??
    //     {};

    var newMusicData = FormatMyData.instance.getMusicList(oldList);

    moreList = newMusicData;
  }
}
