import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/libray/u_loc_all_choose.dart';

import '../../../generated/assets.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';
import '../../../view/sliver_delegate.dart';
import '../home/u_play.dart';

class UserLocPlayListInfo extends GetView<UserLocPlayListInfoController> {
  final bool isFormHome;

  const UserLocPlayListInfo({super.key, this.isFormHome = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLocPlayListInfoController());
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      body: Obx(
        () => NotificationListener<ScrollNotification>(
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
                              child:
                                  controller.info["cover"] != null
                                      ? NetImageView(
                                        imgUrl: controller.info["cover"],
                                        width: 142.w,
                                        height: 142.w,
                                        fit: BoxFit.cover,
                                        errorAsset: Assets.oimgIconDItem,
                                      )
                                      : Image.asset(
                                        "assets/oimg/icon_d_item.png",
                                      ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 24.w),
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
                              "${controller.list.length} songs",
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
              controller.list.isEmpty
                  ? SliverToBoxAdapter(
                    child: Container(height: 10.w, color: Color(0xfffafafa)),
                  )
                  : SliverPersistentHeader(
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

                                  Get.find<UserPlayInfoController>()
                                      .setDataAndPlayItem(
                                        controller.list,
                                        controller.list.first,
                                        clickType:
                                            isFormHome ? "h_detail" : "library",
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

                                  Get.find<UserPlayInfoController>()
                                      .setDataAndPlayItem(
                                        playList,
                                        playList.first,
                                        clickType:
                                            isFormHome ? "h_detail" : "library",
                                      );
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
              SliverToBoxAdapter(
                child: controller.obxView(
                  (state) => ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: Get.mediaQuery.padding.bottom + 60.w,
                    ),
                    itemBuilder: (_, i) {
                      return getItem(i);
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(height: 8.w);
                    },
                    itemCount: controller.list.length,
                  ),
                  onEmpty: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/img/icon_empty.png",
                          width: 180.w,
                          height: 180.w,
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          "No content now, Add songs you like".tr,
                          style: TextStyle(fontSize: 14.w, color: Colors.black),
                        ),
                        SizedBox(height: 32.w),
                        InkWell(
                          onTap: () {
                            //添加歌曲
                            Get.to(
                              UserLoaAllChoose(),
                              arguments: controller.info,
                            );
                          },
                          child: Container(
                            width: 88.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            child: Center(child: Text("Add".tr)),
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

      // body: Container(
      //   child: Obx(() => NestedScrollView(
      //       headerSliverBuilder: (c, innerBoxIsScrolled) {
      //         return [
      //           SliverAppBar(
      //             backgroundColor: Colors.white,
      //             centerTitle: true,
      //             pinned: true,
      //             title: Text(controller.info["title"],
      //                 style: TextStyle(fontSize: 16.w)),
      //             leading: IconButton(
      //                 onPressed: () {
      //                   Get.back();
      //                 },
      //                 icon: Image.asset(
      //                   "assets/oimg/icon_back.png",
      //                   width: 24.w,
      //                   height: 24.w,
      //                 )),
      //           ),
      //           SliverToBoxAdapter(
      //             child: Container(
      //               height: 142.w,
      //               width: double.infinity,
      //               color: Colors.white,
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
      //                           child: controller.info["cover"] != null
      //                               ? NetImageView(
      //                                   imgUrl: controller.info["cover"],
      //                                   width: 142.w,
      //                                   height: 142.w,
      //                                   fit: BoxFit.cover,
      //                                 )
      //                               : Image.asset(
      //                                   "assets/oimg/icon_d_item.png"),
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     width: 24.w,
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
      //                         "${controller.list.length} songs",
      //                         style: TextStyle(
      //                             fontSize: 12.w, color: Color(0xff121212)),
      //                       )
      //                     ],
      //                   )),
      //                 ],
      //               ),
      //             ),
      //           ),
      //           controller.list.isEmpty
      //               ? SliverToBoxAdapter(
      //                   child: Container(
      //                     height: 10.w,
      //                     color: Colors.white,
      //                   ),
      //                 )
      //               : SliverPersistentHeader(
      //                   pinned: true,
      //                   delegate: MySliverDelegate(
      //                       100.w,
      //                       100.w,
      //                       Container(
      //                         height: 100.w,
      //                         color: Colors.white,
      //                         padding: EdgeInsets.symmetric(horizontal: 16.w),
      //                         child: Row(
      //                           children: [
      //                             Expanded(
      //                                 child: InkWell(
      //                               onTap: () {
      //                                 EventUtils.instance.addEvent(
      //                                     "det_playlist_click",
      //                                     data: {"detail_click": "play_all"});
      //
      //                                 Get.find<UserPlayInfoController>()
      //                                     .setDataAndPlayItem(controller.list,
      //                                         controller.list.first,
      //                                         clickType: isFormHome
      //                                             ? "h_detail"
      //                                             : "library");
      //                                 // Get.to(UserPlayInfo());
      //                               },
      //                               child: Container(
      //                                 height: 42.w,
      //                                 decoration: BoxDecoration(
      //                                     borderRadius:
      //                                         BorderRadius.circular(21.w),
      //                                     color: Color(0xff7453FF)),
      //                                 child: Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.center,
      //                                   children: [
      //                                     Image.asset(
      //                                       "assets/oimg/icon_play.png",
      //                                       width: 24.w,
      //                                       height: 24.w,
      //                                       color: Colors.white,
      //                                     ),
      //                                     SizedBox(
      //                                       width: 8.w,
      //                                     ),
      //                                     Text(
      //                                       "Play",
      //                                       style: TextStyle(
      //                                           fontSize: 16.w,
      //                                           fontWeight: FontWeight.w500,
      //                                           color: Colors.white),
      //                                     )
      //                                   ],
      //                                 ),
      //                               ),
      //                             )),
      //                             SizedBox(
      //                               width: 15.w,
      //                             ),
      //                             Expanded(
      //                                 child: InkWell(
      //                               onTap: () {
      //                                 //TODO 随机打乱
      //
      //                                 EventUtils.instance.addEvent(
      //                                     "det_playlist_click",
      //                                     data: {"detail_click": "shuffle"});
      //
      //                                 List playList = List.of(controller.list)
      //                                   ..shuffle();
      //
      //                                 Get.find<UserPlayInfoController>()
      //                                     .setDataAndPlayItem(
      //                                         playList, playList.first,
      //                                         clickType: isFormHome
      //                                             ? "h_detail"
      //                                             : "library");
      //                                 // Get.to(UserPlayInfo());
      //                               },
      //                               child: Container(
      //                                 height: 42.w,
      //                                 decoration: BoxDecoration(
      //                                     borderRadius:
      //                                         BorderRadius.circular(21.w),
      //                                     border: Border.all(
      //                                         color: Color(0xff7453FF),
      //                                         width: 2.w),
      //                                     color: Colors.white),
      //                                 child: Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.center,
      //                                   children: [
      //                                     Image.asset(
      //                                         "assets/oimg/icon_shuffle1.png",
      //                                         width: 24.w,
      //                                         height: 24.w,
      //                                         color: Color(0xff7453FF)),
      //                                     SizedBox(
      //                                       width: 8.w,
      //                                     ),
      //                                     Text(
      //                                       "Shuffle",
      //                                       style: TextStyle(
      //                                           fontSize: 16.w,
      //                                           fontWeight: FontWeight.w500,
      //                                           color: Color(0xff7453FF)),
      //                                     )
      //                                   ],
      //                                 ),
      //                               ),
      //                             ))
      //                           ],
      //                         ),
      //                       )))
      //         ];
      //       },
      //       body: controller.obxView(
      //           (state) => ListView.separated(
      //               padding: EdgeInsets.only(
      //                   bottom: Get.mediaQuery.padding.bottom + 60.w),
      //               itemBuilder: (_, i) {
      //                 return getItem(i);
      //               },
      //               separatorBuilder: (_, i) {
      //                 return SizedBox(
      //                   height: 8.w,
      //                 );
      //               },
      //               itemCount: controller.list.length),
      //           onEmpty: Center(
      //               child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Image.asset(
      //                 "assets/img/icon_empty.png",
      //                 width: 180.w,
      //                 height: 180.w,
      //               ),
      //               SizedBox(
      //                 height: 8.w,
      //               ),
      //               Text(
      //                 "No content now, Add songs you like",
      //                 style: TextStyle(fontSize: 14.w, color: Colors.black),
      //               ),
      //               SizedBox(
      //                 height: 32.w,
      //               ),
      //               InkWell(
      //                 onTap: () {
      //                   //添加歌曲
      //                   Get.to(UserLoaAllChoose(), arguments: controller.info);
      //                 },
      //                 child: Container(
      //                   width: 88.w,
      //                   height: 40.w,
      //                   decoration: BoxDecoration(
      //                       border: Border.all(color: Colors.black, width: 1),
      //                       borderRadius: BorderRadius.circular(20.w)),
      //                   child: Center(
      //                     child: Text("Add"),
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ))))),
      // ),
    );
  }

  getItem(int index) {
    var item = controller.list[index];
    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent(
          "det_playlist_click",
          data: {"detail_click": "play"},
        );

        Get.find<UserPlayInfoController>().setDataAndPlayItem(
          controller.list,
          item,
          clickType: isFormHome ? "h_detail" : "library",
        );
        // Get.to(UserPlayInfo());
        //保存歌单到历史记录
        // HistoryUtil.instance.addHistoryPlaylist(controller.info, isLoc: true);
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
              item["cover"] == "-"
                  ? Container(width: 20.w, child: Text("${index + 1}"))
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
                "loc_playlist",
                locIsHome: isFormHome,
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
              //           .download(videoId, item, clickType: "library");
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
              //         .showVideoMoreSheet(item, clickType: "loc_playlist");
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

class UserLocPlayListInfoController extends GetxController with StateMixin {
  var info = {};
  var list = [].obs;

  var showTitle = false.obs;

  @override
  void onInit() {
    super.onInit();
    info = Get.arguments;
    bindData();
  }

  bindData() async {
    list.value = info["list"] ?? [];
    change("", status: list.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}
