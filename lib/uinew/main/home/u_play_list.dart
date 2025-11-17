import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';

import '../../../api/api_main.dart';
import '../../../generated/assets.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../tool/toast.dart';
import '../../../view/base_view.dart';
import '../../../view/sliver_delegate.dart';

class UserPlayListInfo extends GetView<UserPlayListInfoController> {
  final bool isFormSearch;

  UserPlayListInfo({super.key, this.isFormSearch = false});
  @override
  String? get tag {
    if (browseId.isEmpty) {
      return playlistId;
    } else {
      return browseId;
    }
  }

  final String browseId = Get.arguments?["browseId"] ?? "";
  final String playlistId = Get.arguments?["playlistId"] ?? "";

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserPlayListInfoController(), tag: tag);
    return Scaffold(
      body: controller.obxPage(
        (state) => NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            AppLog.e(notification.metrics.pixels);

            var offset = notification.metrics.pixels;
            controller.showTitle.value = offset > 100.w;

            return true;
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color(0xfffafafa),
                centerTitle: true,
                pinned: true,
                title: Obx(
                  () =>
                      controller.showTitle.value
                          ? Text(
                            controller.info["title"],
                            style: TextStyle(fontSize: 16.w),
                          )
                          : Container(),
                ),
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
                actions: [
                  Obx(() {
                    var isLike = LikeUtil.instance.allPlaylistMap.containsKey(
                      controller.browseId,
                    );

                    return IconButton(
                      onPressed: () {
                        if (isLike) {
                          LikeUtil.instance.unlikeList(controller.browseId);
                        } else {
                          LikeUtil.instance.likeList(
                            controller.browseId,
                            controller.info,
                            controller.info["songNumStr"] ?? "",
                          );
                        }
                        EventUtils.instance.addEvent(
                          "det_playlist_click",
                          data: {"detail_click": "collection"},
                        );
                      },
                      icon: Image.asset(
                        isLike
                            ? "assets/oimg/icon_like_on.png"
                            : "assets/oimg/icon_like_off.png",
                        width: 24.w,
                        height: 24.w,
                      ),
                    );
                  }),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 142.w,
                  width: double.infinity,
                  color: Color(0xfffafafa),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      //封面
                      Container(
                        height: 142.w,
                        width: 172.w,
                        child: Stack(
                          children: [
                            //底部
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 128.w,
                                height: 128.w,
                                margin: EdgeInsets.only(right: 20.w),
                                decoration: BoxDecoration(
                                  color: Color(0xffE0E0EF),
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                              ),
                            ),

                            //封面
                            Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: NetImageView(
                                imgUrl: controller.info["cover"],
                                width: 142.w,
                                height: 142.w,
                                fit: BoxFit.cover,
                                errorAsset: Assets.oimgIconDItem,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.info["title"],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.w,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12.w),
                            Text(
                              controller.info["songNumStr"],
                              style: TextStyle(
                                fontSize: 12.w,
                                color: Color(0xff121212),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: MySliverDelegate(
                  80.w,
                  80.w,
                  Container(
                    height: 80.w,
                    color: Color(0xfffafafa),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              EventUtils.instance.addEvent(
                                "det_playlist_click",
                                data: {"detail_click": "play_all"},
                              );

                              var clickTypeStr = "";
                              if (controller.isAlbum) {
                                clickTypeStr =
                                    isFormSearch
                                        ? "s_detail_album"
                                        : "h_detail_album";
                              } else {
                                clickTypeStr =
                                    isFormSearch
                                        ? "s_detail_playlist"
                                        : "h_detail_playlist";
                              }
                              Get.find<UserPlayInfoController>()
                                  .setDataAndPlayItem(
                                    controller.list,
                                    controller.list.first,
                                    pid: controller.browseId,
                                    clickType: clickTypeStr,
                                  );
                              // Get.to(UserPlayInfo());
                            },
                            child: Container(
                              height: 42.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21.w),
                                color: Color(0xff7453FF),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/oimg/icon_play.png",
                                    width: 24.w,
                                    height: 24.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Play".tr,
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
                              //TODO 随机打乱

                              EventUtils.instance.addEvent(
                                "det_playlist_click",
                                data: {"detail_click": "shuffle"},
                              );

                              List playList = List.of(controller.list)
                                ..shuffle();

                              var clickTypeStr = "";
                              if (controller.isAlbum) {
                                clickTypeStr =
                                    isFormSearch
                                        ? "s_detail_album"
                                        : "h_detail_album";
                              } else {
                                clickTypeStr =
                                    isFormSearch
                                        ? "s_detail_playlist"
                                        : "h_detail_playlist";
                              }
                              Get.find<UserPlayInfoController>()
                                  .setDataAndPlayItem(
                                    playList,
                                    playList.first,
                                    pid: controller.browseId,
                                    clickType: clickTypeStr,
                                  );

                              // Get.find<UserPlayInfoController>()
                              //     .setDataAndPlayItem(controller.list,
                              //         controller.list.first,
                              //         clickType: "h_detail");
                              // Get.to(UserPlayInfo());
                            },
                            child: Container(
                              height: 42.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21.w),
                                border: Border.all(
                                  color: Color(0xff7453FF),
                                  width: 2.w,
                                ),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/oimg/icon_shuffle1.png",
                                    width: 24.w,
                                    height: 24.w,
                                    color: Color(0xff7453FF),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Shuffle".tr,
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
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: Get.mediaQuery.padding.bottom + 60.w,
                ),
                sliver: SliverList.separated(
                  itemCount: controller.list.length,
                  itemBuilder: (_, i) {
                    return getItem(i);
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(height: 8.w);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // appBar: AppBar(
      //   title: const Text("标题"),
      // ),
      // body: Container(
      //   child: controller.obxPage((state) => NestedScrollView(
      //       headerSliverBuilder: (c, innerBoxIsScrolled) {
      //         return [
      //           SliverAppBar(
      //             backgroundColor: Color(0xfffafafa),
      //             centerTitle: true,
      //             pinned: true,
      //             title: Text(
      //               controller.info["title"],
      //               style: TextStyle(fontSize: 16.w),
      //             ),
      //             leading: IconButton(
      //                 onPressed: () {
      //                   Get.back();
      //                 },
      //                 icon: Image.asset(
      //                   "assets/oimg/icon_back.png",
      //                   width: 24.w,
      //                   height: 24.w,
      //                 )),
      //             actions: [
      //               Obx(() {
      //                 var isLike = LikeUtil.instance.allPlaylistMap
      //                     .containsKey(controller.browseId);
      //
      //                 return IconButton(
      //                     onPressed: () {
      //                       if (isLike) {
      //                         LikeUtil.instance.unlikeList(controller.browseId);
      //                       } else {
      //                         LikeUtil.instance.likeList(controller.browseId,
      //                             controller.info, List.of(controller.list));
      //                       }
      //                       EventUtils.instance.addEvent("det_playlist_click",
      //                           data: {"detail_click": "collection"});
      //                     },
      //                     icon: Image.asset(
      //                       isLike
      //                           ? "assets/oimg/icon_like_on.png"
      //                           : "assets/oimg/icon_like_off.png",
      //                       width: 24.w,
      //                       height: 24.w,
      //                     ));
      //               })
      //             ],
      //           ),
      //           SliverToBoxAdapter(
      //             child: Container(
      //               height: 142.w,
      //               width: double.infinity,
      //               color: Color(0xfffafafa),
      //               padding: EdgeInsets.symmetric(horizontal: 12.w),
      //               child: Row(
      //                 children: [
      //                   //封面
      //                   Container(
      //                     height: 142.w,
      //                     width: 172.w,
      //                     child: Stack(
      //                       children: [
      //                         //底部
      //                         Align(
      //                           alignment: Alignment.centerRight,
      //                           child: Container(
      //                             width: 128.w,
      //                             height: 128.w,
      //                             margin: EdgeInsets.only(right: 20.w),
      //                             decoration: BoxDecoration(
      //                                 color: Color(0xffE0E0EF),
      //                                 borderRadius: BorderRadius.circular(8.w)),
      //                           ),
      //                         ),
      //
      //                         //封面
      //
      //                         Container(
      //                           clipBehavior: Clip.hardEdge,
      //                           decoration: BoxDecoration(
      //                               borderRadius: BorderRadius.circular(8.w)),
      //                           child: NetImageView(
      //                             imgUrl: controller.info["cover"],
      //                             width: 142.w,
      //                             height: 142.w,
      //                             fit: BoxFit.cover,
      //                           ),
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     width: 10.w,
      //                   ),
      //                   Expanded(
      //                       child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //                       Text(
      //                         controller.info["title"],
      //                         maxLines: 3,
      //                         overflow: TextOverflow.ellipsis,
      //                         style: TextStyle(
      //                             fontSize: 18.w, fontWeight: FontWeight.w500),
      //                       ),
      //                       SizedBox(
      //                         height: 12.w,
      //                       ),
      //                       Text(
      //                         controller.info["songNumStr"],
      //                         style: TextStyle(
      //                             fontSize: 12.w, color: Color(0xff121212)),
      //                       )
      //                     ],
      //                   )),
      //                 ],
      //               ),
      //             ),
      //           ),
      //           SliverPersistentHeader(
      //               pinned: true,
      //               delegate: MySliverDelegate(
      //                   80.w,
      //                   80.w,
      //                   Container(
      //                     height: 80.w,
      //                     color: Color(0xfffafafa),
      //                     padding: EdgeInsets.symmetric(horizontal: 16.w),
      //                     child: Row(
      //                       children: [
      //                         Expanded(
      //                             child: InkWell(
      //                           onTap: () {
      //                             EventUtils.instance.addEvent(
      //                                 "det_playlist_click",
      //                                 data: {"detail_click": "play_all"});
      //
      //                             Get.find<UserPlayInfoController>()
      //                                 .setDataAndPlayItem(controller.list,
      //                                     controller.list.first,
      //                                     clickType: isFormSearch
      //                                         ? "s_detail"
      //                                         : "h_detail");
      //                             // Get.to(UserPlayInfo());
      //                           },
      //                           child: Container(
      //                             height: 42.w,
      //                             decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.circular(21.w),
      //                                 color: Color(0xff7453FF)),
      //                             child: Row(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               children: [
      //                                 Image.asset(
      //                                   "assets/oimg/icon_play.png",
      //                                   width: 24.w,
      //                                   height: 24.w,
      //                                   color: Colors.white,
      //                                 ),
      //                                 SizedBox(
      //                                   width: 8.w,
      //                                 ),
      //                                 Text(
      //                                   "Play",
      //                                   style: TextStyle(
      //                                       fontSize: 16.w,
      //                                       fontWeight: FontWeight.w500,
      //                                       color: Colors.white),
      //                                 )
      //                               ],
      //                             ),
      //                           ),
      //                         )),
      //                         SizedBox(
      //                           width: 15.w,
      //                         ),
      //                         Expanded(
      //                             child: InkWell(
      //                           onTap: () {
      //                             //TODO 随机打乱
      //
      //                             EventUtils.instance.addEvent(
      //                                 "det_playlist_click",
      //                                 data: {"detail_click": "shuffle"});
      //
      //                             List playList = List.of(controller.list)
      //                               ..shuffle();
      //
      //                             Get.find<UserPlayInfoController>()
      //                                 .setDataAndPlayItem(
      //                                     playList, playList.first,
      //                                     clickType: isFormSearch
      //                                         ? "s_detail"
      //                                         : "h_detail");
      //
      //                             // Get.find<UserPlayInfoController>()
      //                             //     .setDataAndPlayItem(controller.list,
      //                             //         controller.list.first,
      //                             //         clickType: "h_detail");
      //                             // Get.to(UserPlayInfo());
      //                           },
      //                           child: Container(
      //                             height: 42.w,
      //                             decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.circular(21.w),
      //                                 border: Border.all(
      //                                     color: Color(0xff7453FF), width: 2.w),
      //                                 color: Colors.white),
      //                             child: Row(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               children: [
      //                                 Image.asset(
      //                                     "assets/oimg/icon_shuffle1.png",
      //                                     width: 24.w,
      //                                     height: 24.w,
      //                                     color: Color(0xff7453FF)),
      //                                 SizedBox(
      //                                   width: 8.w,
      //                                 ),
      //                                 Text(
      //                                   "Shuffle",
      //                                   style: TextStyle(
      //                                       fontSize: 16.w,
      //                                       fontWeight: FontWeight.w500,
      //                                       color: Color(0xff7453FF)),
      //                                 )
      //                               ],
      //                             ),
      //                           ),
      //                         ))
      //                       ],
      //                     ),
      //                   )))
      //         ];
      //       },
      //       body: Container(
      //         color: Color(0xfffafafa),
      //         child: ListView.separated(
      //             padding: EdgeInsets.only(
      //                 bottom: Get.mediaQuery.padding.bottom + 100.w),
      //             itemBuilder: (_, i) {
      //               return getItem(i);
      //             },
      //             separatorBuilder: (_, i) {
      //               return SizedBox(
      //                 height: 8.w,
      //               );
      //             },
      //             itemCount: controller.list.length),
      //       ))),
      // ),
    );
  }

  getItem(int index) {
    var item = controller.list[index];
    return InkWell(
      onTap: () {
        if (item["videoId"].toString().isEmpty) {
          ToastUtil.showToast(msg: "videoId error".tr);
          return;
        }

        //保存歌单到历史记录
        // HistoryUtil.instance.addHistoryPlaylist(Map.of(controller.info));

        EventUtils.instance.addEvent(
          "det_playlist_click",
          data: {"detail_click": "play"},
        );

        var clickTypeStr = "";
        if (controller.isAlbum) {
          clickTypeStr = isFormSearch ? "s_detail_album" : "h_detail_album";
        } else {
          clickTypeStr =
              isFormSearch ? "s_detail_playlist" : "h_detail_playlist";
        }

        Get.find<UserPlayInfoController>().setDataAndPlayItem(
          controller.list,
          item,
          pid: controller.browseId,
          clickType: clickTypeStr,
        );
        // Get.to(UserPlayInfo());
      },
      child: Obx(() {
        var isCheck =
            item["videoId"] ==
            Get.find<UserPlayInfoController>().nowData["videoId"];

        return Container(
          height: 70.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isCheck ? Color(0xfff7f7f7) : Colors.transparent,
          ),
          child: Row(
            children: [
              controller.isAlbum
                  ? Container(
                    width: 20.w,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.bold,
                        color: isCheck ? Color(0xff8569FF) : Colors.black,
                      ),
                    ),
                  )
                  : Container(
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
                        color: isCheck ? Color(0xff8569FF) : Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    Row(
                      children: [
                        Obx(() {
                          var isLike = LikeUtil.instance.allVideoMap
                              .containsKey(item["videoId"]);
                          if (isLike) {
                            return Container(
                              width: 16.w,
                              height: 16.w,
                              margin: EdgeInsets.only(right: 4.w),
                              child: Image.asset(
                                "assets/oimg/icon_like_on.png",
                              ),
                            );
                          }

                          return Container();
                        }),
                        Expanded(
                          child: Text(
                            item["subtitle"] ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.w,
                              color:
                                  isCheck
                                      ? Color(0xff8569FF)
                                      : Colors.black.withOpacity(0.75),
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
                "net_playlist",
                isSearch: isFormSearch,
              ),

              // Obx(() {
              //   //获取下载状态
              //   var videoId = item["videoId"];
              //
              //   if (DownloadUtils.instance.allDownLoadingData
              //       .containsKey(videoId)) {
              //     //有添加过下载
              //     var state = DownloadUtils.instance.allDownLoadingData[videoId]
              //         ["state"];
              //     double progress = DownloadUtils
              //         .instance.allDownLoadingData[videoId]["progress"];
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
              //               backgroundColor:
              //                   Color(0xffA995FF).withOpacity(0.35),
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
              //       EventUtils.instance.addEvent("det_playlist_click",
              //           data: {"detail_click": "dl"});
              //       DownloadUtils.instance
              //           .download(videoId, item, clickType: "h_detail");
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
              //     EventUtils.instance.addEvent("det_playlist_click",
              //         data: {"detail_click": "more"});
              //     MoreSheetUtil.instance
              //         .showVideoMoreSheet(item, clickType: "playlist");
              //   },
              //   child: Container(
              //     width: 20.w,
              //     height: 20.w,
              //     child: Image.asset("assets/oimg/icon_more.png"),
              //   ),
              // )
            ],
          ),
        );
      }),
    );
  }
}

class UserPlayListInfoController extends GetxController with StateMixin {
  var browseId = "";
  var playlistId = "";

  var info = {};
  var list = [];

  var isAlbum = false;

  var nextData = {};

  var showTitle = false.obs;

  @override
  void onInit() {
    super.onInit();
    browseId = Get.arguments?["browseId"] ?? "";
    playlistId = Get.arguments?["playlistId"] ?? "";

    if (browseId.isEmpty) {
      browseId = playlistId;
      bindYoutubeData();
      return;
    }
    bindData();
  }

  bindData() async {
    var result = await ApiMain.instance.getData(browseId);

    if (result.code == HttpCode.success) {
      //列表
      List oldList = [];
      var newList = [];
      var artistStr = "";
      var cover = "";
      try {
        var infoData =
            result
                .data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["musicResponsiveHeaderRenderer"];

        cover =
            infoData["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
                .last["url"];
        var title = infoData["title"]["runs"][0]["text"];
        List subtitleList = infoData["subtitle"]["runs"];
        var subtitle = subtitleList
            .map((e) => e["text"].toString())
            .toList()
            .join("");
        //年份
        var yearStr = subtitleList[2]["text"];

        //专辑的歌手
        artistStr = infoData["straplineTextOne"]?["runs"]?[0]?["text"] ?? "";

        var description =
            infoData["description"]?["musicDescriptionShelfRenderer"]['description']["runs"][0]["text"] ??
            "";
        // "runs": [
        //     {
        //         "text": "25 songs"
        //     },
        //     {
        //         "text": " • "
        //     },
        //     {
        //         "text": "1 hour, 48 minutes"
        //     }
        // ]
        List otherTextList = infoData["secondSubtitle"]["runs"];
        var songNumStr = otherTextList[0]["text"];

        info = {
          "cover": cover,
          "title": title,
          "subtitle": subtitle,
          "description": description,
          "songNumStr": songNumStr,
          "yearStr": yearStr,
          "browseId": browseId,
        };

        AppLog.e(info);

        oldList =
            result
                .data["contents"]["twoColumnBrowseResultsRenderer"]["secondaryContents"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]["contents"];

        nextData =
            result
                .data["contents"]["twoColumnBrowseResultsRenderer"]["secondaryContents"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]["continuations"]?[0]?["nextContinuationData"] ??
            {};

        for (Map item in oldList) {
          var cover =
              item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][0]["url"];
          var title =
              item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
          var subtitle =
              item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
          var timeStr =
              item["musicResponsiveListItemRenderer"]["fixedColumns"][0]["musicResponsiveListItemFixedColumnRenderer"]["text"]["runs"][0]["text"];

          String videoId =
              item["musicResponsiveListItemRenderer"]["playlistItemData"]?["videoId"] ??
              '';

          if (videoId.isEmpty) {
            AppLog.e(title);
            AppLog.e(item);
          }
          newList.add({
            "cover": cover,
            "title": title,
            "subtitle": subtitle,
            "timeStr": timeStr,
            "videoId": videoId,
          });
        }
      } catch (e) {
        print(e);

        //这里是专辑，数据结构不一样
        isAlbum = true;

        oldList =
            result
                .data["contents"]["twoColumnBrowseResultsRenderer"]["secondaryContents"]["sectionListRenderer"]["contents"][0]["musicShelfRenderer"]?["contents"] ??
            [];
        for (Map item in oldList) {
          // var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]
          //             ?["musicThumbnailRenderer"]?["thumbnail"]?["thumbnails"]
          //         ?[0]?["url"] ??
          //     "-";
          var title =
              item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
          // var subtitle = item["musicResponsiveListItemRenderer"]["flexColumns"]
          //         [2]["musicResponsiveListItemFlexColumnRenderer"]["text"]
          //     ["runs"][0]["text"];
          var subtitle = artistStr;

          var timeStr =
              item["musicResponsiveListItemRenderer"]["fixedColumns"][0]["musicResponsiveListItemFixedColumnRenderer"]["text"]["runs"][0]["text"];

          var videoId =
              item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

          newList.add({
            "cover": cover,
            "title": title,
            "subtitle": subtitle,
            "timeStr": timeStr,
            "videoId": videoId,
          });
        }
      }

      list = newList;

      await bindNextData();

      //下一页请求
      // var continuationsData = result.data["contents"]
      //         ["twoColumnBrowseResultsRenderer"]["secondaryContents"]
      //     ["sectionListRenderer"]["continuations"][0]["nextContinuationData"];
      change("", status: RxStatus.success());
    } else {
      change("", status: RxStatus.error());
    }
  }

  Future bindNextData() async {
    if (nextData.isEmpty) {
      //没有下一页了
      return;
    }

    // if (isAlbum) {
    //   //专辑没有下一页
    //   return;
    // }

    var result = await ApiMain.instance.getData(browseId, nextData: nextData);

    List oldList =
        result
            .data["continuationContents"]["musicPlaylistShelfContinuation"]["contents"] ??
        [];

    nextData =
        result
            .data["continuationContents"]["musicPlaylistShelfContinuation"]["continuations"]?[0]?["nextContinuationData"] ??
        {};

    var newList = [];
    for (Map item in oldList) {
      var cover =
          item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][0]["url"];
      var title =
          item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var subtitle =
          item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
      var timeStr =
          item["musicResponsiveListItemRenderer"]["fixedColumns"][0]["musicResponsiveListItemFixedColumnRenderer"]["text"]["runs"][0]["text"];

      var videoId =
          item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];

      newList.add({
        "cover": cover,
        "title": title,
        "subtitle": subtitle,
        "timeStr": timeStr,
        "videoId": videoId,
      });
    }

    list.addAll(newList);
    await bindNextData();
  }

  // void bindYoutubeInfoData() async {
  //   if (playlistId.isEmpty) {
  //     AppLog.e("id错误");
  //     return;
  //   }
  //
  //   AppLog.e("请求详情");
  //   AppLog.e(playlistId);
  //   var result = await ApiMain.instance.getYoutubePlaylistInfo(playlistId);
  //   // var result = await ApiMain.instance.getYoutubeData("VL$playlistId");
  //
  //   if (result.code != HttpCode.success) {
  //     change("", status: RxStatus.error());
  //     return;
  //   }
  //
  //   info = {
  //     "cover": Get.arguments["cover"],
  //     "title": Get.arguments["title"],
  //     "subtitle": Get.arguments["subtitle"],
  //     // "description": description,
  //     "songNumStr": "",
  //     // "browseId":"",
  //     "playlistId": playlistId
  //     // "yearStr": yearStr,
  //     // "browseId": browseId
  //   };
  //
  //   var oldList = [];
  //   var newList = [];
  //
  //   oldList = result.data["contents"]["twoColumnWatchNextResults"]["playlist"]
  //           ["playlist"]["contents"] ??
  //       [];
  //
  //   for (var item in oldList) {
  //     var cover = "";
  //     var title = "";
  //     var subtitle = "";
  //     var timeStr = "";
  //     var videoId = "";
  //     title = item["playlistPanelVideoRenderer"]["title"]["simpleText"];
  //     subtitle = item["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]
  //         ["text"];
  //     cover = item["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"][0]
  //             ["url"] ??
  //         [];
  //     timeStr = item["playlistPanelVideoRenderer"]["lengthText"]["simpleText"];
  //     videoId = item["playlistPanelVideoRenderer"]["videoId"];
  //
  //     newList.add({
  //       "cover": cover,
  //       "title": title,
  //       "subtitle": subtitle,
  //       "timeStr": timeStr,
  //       "videoId": videoId,
  //     });
  //   }
  //
  //   list = newList;
  //   change("", status: RxStatus.success());
  // }

  bindYoutubeData() async {
    if (playlistId.isEmpty) {
      AppLog.e("id错误");
      return;
    }

    AppLog.e("请求详情");
    AppLog.e(playlistId);
    // var result = await ApiMain.instance.getYoutubePlaylistInfo(playlistId);
    var result = await ApiMain.instance.getYoutubeData("VL$playlistId");

    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    try {
      var cover =
          result
              .data["header"]["playlistHeaderRenderer"]["playlistHeaderBanner"]["heroPlaylistThumbnailRenderer"]["thumbnail"]["thumbnails"][0]["url"];
      var title =
          result
              .data["header"]["playlistHeaderRenderer"]["title"]["simpleText"];
      List subtitleList =
          result
              .data["header"]["playlistHeaderRenderer"]["numVideosText"]["runs"];
      var subtitle = subtitleList
          .map((e) => e["text"].toString())
          .toList()
          .join("");
      info = {
        "cover": cover,
        "title": title,
        "subtitle": subtitle,
        // "description": description,
        "songNumStr": subtitle,
        // "browseId":"",
        "playlistId": playlistId,
        // "yearStr": yearStr,
        // "browseId": browseId
      };
    } catch (e) {
      // print(e);
      // info = {
      //   "cover": Get.arguments["cover"],
      //   "title": Get.arguments["title"],
      //   "subtitle": Get.arguments["subtitle"],
      //   // "description": description,
      //   "songNumStr": "",
      //   // "browseId":"",
      //   "playlistId": playlistId
      //   // "yearStr": yearStr,
      //   // "browseId": browseId
      // };

      //排行榜数据不一样
      var cover =
          result
              .data["header"]["pageHeaderRenderer"]["content"]["pageHeaderViewModel"]["heroImage"]["contentPreviewImageViewModel"]["image"]["sources"]
              .last["url"];
      var title = result.data["header"]["pageHeaderRenderer"]["pageTitle"];

      String subtitle =
          result
              .data["header"]["pageHeaderRenderer"]["content"]["pageHeaderViewModel"]["metadata"]["contentMetadataViewModel"]["metadataRows"][1]["metadataParts"][1]["text"]["content"];

      info = {
        "cover": cover,
        "title": title,
        "subtitle": subtitle,
        // "description": description,
        "songNumStr": subtitle,
        // "browseId":"",
        "playlistId": playlistId,
        // "yearStr": yearStr,
        // "browseId": browseId
      };
    }

    var oldList = [];
    var newList = [];

    oldList =
        result
            .data["contents"]["twoColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"][0]["playlistVideoListRenderer"]["contents"] ??
        [];

    for (var item in oldList) {
      try {
        var cover = "";
        var title = "";
        var subtitle = "";
        var timeStr = "";
        var videoId = "";
        title = item["playlistVideoRenderer"]["title"]["runs"][0]["text"];
        subtitle =
            item["playlistVideoRenderer"]["shortBylineText"]["runs"][0]["text"];
        cover =
            item["playlistVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ??
            [];
        timeStr = item["playlistVideoRenderer"]["lengthText"]["simpleText"];
        videoId = item["playlistVideoRenderer"]["videoId"];

        newList.add({
          "cover": cover,
          "title": title,
          "subtitle": subtitle,
          "timeStr": timeStr,
          "videoId": videoId,
        });
      } catch (e) {
        print(e);
        AppLog.e(item);
      }
    }

    //更多数据

    Map lastItem = oldList.lastOrNull ?? {};
    if (lastItem.containsKey("continuationItemRenderer")) {
      //有更多数据
      moreToken =
          lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
          "";
      bindYoutubeMore();
    } else {
      moreToken = "";
    }

    list = newList;
    change("", status: RxStatus.success());
  }

  var moreToken = "";
  bindYoutubeMore() async {
    // nextData: {"continuation": moreToken}
    if (moreToken.isEmpty) {
      return;
    }
    var result = await ApiMain.instance.getYoutubeData(
      "VL$playlistId",
      nextData: {"continuation": moreToken},
    );
    // AppLog.e(result.);

    List oldList =
        result
            .data["onResponseReceivedActions"][0]["appendContinuationItemsAction"]["continuationItems"] ??
        [];

    var newList = [];
    for (var item in oldList) {
      try {
        var cover = "";
        var title = "";
        var subtitle = "";
        var timeStr = "";
        var videoId = "";
        title = item["playlistVideoRenderer"]["title"]["runs"][0]["text"];
        subtitle =
            item["playlistVideoRenderer"]["shortBylineText"]["runs"][0]["text"];
        cover =
            item["playlistVideoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ??
            [];
        timeStr = item["playlistVideoRenderer"]["lengthText"]["simpleText"];
        videoId = item["playlistVideoRenderer"]["videoId"];

        newList.add({
          "cover": cover,
          "title": title,
          "subtitle": subtitle,
          "timeStr": timeStr,
          "videoId": videoId,
        });
      } catch (e) {
        print(e);
        AppLog.e(item);
      }
    }

    //更多数据

    Map lastItem = oldList.lastOrNull ?? {};
    if (lastItem.containsKey("continuationItemRenderer")) {
      //有更多数据
      moreToken =
          lastItem["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
          "";
      bindYoutubeMore();
    } else {
      moreToken = "";
    }

    list.addAll(newList);
    AppLog.e(list.length);
  }
}
