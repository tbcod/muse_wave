import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/tool/log.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../tool/format_data.dart';
import '../../../tool/like/like_util.dart';
import '../../../view/base_view.dart';

class UserMoreSong extends GetView<UserMoreSongController> {
  final String barTitle;
  final bool isFormSearch;
  const UserMoreSong({
    super.key,
    required this.barTitle,
    this.isFormSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserMoreSongController());
    return Container(
      decoration: const BoxDecoration(
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
          title: Text(barTitle),
        ),
        body: PlayerBottomBarView(
          child: controller.obxView(
            (state) => Container(
              child: Obx(() {
                return EasyRefresh(
                  onLoad: () async {
                    await controller.bindMoreData();
                    return controller.nextData.isEmpty
                        ? IndicatorResult.noMore
                        : IndicatorResult.success;
                  },
                  child: ListView.separated(
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
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  getItem(int index) {
    var item = controller.list[index];
    return InkWell(
      onTap: () {
        Get.find<UserPlayInfoController>().setDataAndPlayItem(
          controller.list,
          item,
          clickType: isFormSearch ? "s_detail_artist" : "h_detail_artist",
        );
        // Get.to(UserPlayInfo());
      },
      child: Obx(() {
        var isCheck =
            item["videoId"] ==
            Get.find<UserPlayInfoController>().nowData["videoId"];

        return Container(
          // color: Colors.red,
          height: 70.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isCheck ? Color(0xfff7f7f7) : Colors.transparent,
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
                child: NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
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
              getDownloadAndMoreBtn(item, "artist_more_song"),

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
              //     MoreSheetUtil.instance
              //         .showVideoMoreSheet(item, clickType: "artist");
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

class UserMoreSongController extends GetxController with StateMixin {
  Map moreData = {};

  var list = [].obs;
  Map nextData = {};

  @override
  void onInit() {
    super.onInit();
    moreData = Get.arguments;
    bindData();
  }

  Future bindData() async {
    AppLog.e("更多歌曲$moreData");

    BaseModel result = await ApiMain.instance.getData(
      moreData["browseId"],
      params: moreData["params"],
    );
    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    //解析
    List oldList =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]["contents"] ??
        [];

    nextData =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]?["continuations"]?[0]?["nextContinuationData"] ??
        {};

    var newMusicData = FormatMyData.instance.getMusicList(oldList);

    list.value = newMusicData;
    change("", status: RxStatus.success());

    //
    // for (var item in oldList) {
    //   //
    //   var cover = item["musicResponsiveListItemRenderer"]["thumbnail"]
    //       ["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][1]["url"];
    //
    //   var title = item["musicResponsiveListItemRenderer"]["flexColumns"][0]
    //           ["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]
    //       ["text"];
    //   var subtitle = item["musicResponsiveListItemRenderer"]["flexColumns"][1]
    //           ["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]
    //       ["text"];
    //   var videoId = item["musicResponsiveListItemRenderer"]["playlistItemData"]
    //       ["videoId"];
    //
    //   //播放数量
    //   // var playNumStr = item["musicResponsiveListItemRenderer"]["flexColumns"][2]
    //   // ["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]
    //   // ["text"];
    //   // //专辑名称
    //   // var albumName = item["musicResponsiveListItemRenderer"]["flexColumns"][3]
    //   // ["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]
    //   // ["text"];
    // }
  }

  Future bindMoreData() async {
    BaseModel result = await ApiMain.instance.getData(
      moreData["browseId"],
      params: moreData["params"],
      nextData: nextData,
    );
    if (result.code != HttpCode.success) {
      return;
    }

    //解析
    List oldList =
        result
            .data["continuationContents"]["musicPlaylistShelfContinuation"]["contents"] ??
        [];

    nextData =
        result
            .data["continuationContents"]["musicPlaylistShelfContinuation"]["continuations"]?[0]?["nextContinuationData"] ??
        {};

    var newMusicData = FormatMyData.instance.getMusicList(oldList);

    list.addAll(newMusicData);
  }
}
