import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/search/u_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_main.dart';
import '../../generated/assets.dart';
import '../../lang/my_tr.dart';
import '../../main.dart';
import '../../static/db_key.dart';
import '../../tool/ad/ad_util.dart';
import '../../tool/dialog_util.dart';
import '../../tool/download/download_util.dart';
import '../../tool/format_data.dart';
import '../../tool/history_util.dart';
import '../../tool/like/like_util.dart';
import '../../tool/log.dart';
import '../../tool/tba/event_util.dart';
import '../../view/base_view.dart';
import '../../view/more_sheet_util.dart';
import 'home/u_artist.dart';
import 'home/u_more_artist.dart';
import 'home/u_play.dart';
import 'home/u_play_list.dart';
import 'home/u_yt_channel.dart';
import 'libray/u_download_song.dart';
import 'libray/u_like_song.dart';
import 'libray/u_loc_playlist.dart';

class UserHome extends GetView<UserHomeController> {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserHomeController());

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/oimg/all_page_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 12.w,
          title: GestureDetector(
            onTap: () {
              EventUtils.instance.addEvent("home_search");
              EventUtils.instance.addEvent(
                "search_click",
                data: {"from": "home"},
              );
              Get.to(UserSearch());
            },
            child: Container(
              height: 44.w,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xffA995FF), width: 1.5.w),
                borderRadius: BorderRadius.circular(22.w),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Text(
                    "Search for music/artist/playlist".tr,
                    style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff141414).withOpacity(0.56),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 28.w,
                    width: 42.w,
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: Color(0xffA995FF),
                      borderRadius: BorderRadius.circular(14.w),
                    ),
                    child: Image.asset(
                      "assets/oimg/icon_search.png",
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: controller.obxView(
          (state) => EasyRefresh.builder(
            onRefresh: () async {
              Get.find<Application>().visitorData = "";
              await controller.bindYoutubeMusicData();
              await controller.reloadHistory();
            },
            triggerAxis: Axis.vertical,
            childBuilder: (c, p) {
              return Obx(
                () => ListView.separated(
                  physics: p,
                  padding: EdgeInsets.only(bottom: 100.w, top: 24.w),
                  itemBuilder: (_, i) {
                    Map item = controller.netList[i];

                    List childList = item["list"] ?? [];

                    if (item.isEmpty || childList.isEmpty) {
                      return Container();
                    }

                    var type = item["type"] ?? "";

                    // var moreId = item["moreId"] ?? "";
                    // AppLog.e("moreid====>$moreId");

                    return getBigItem(
                      type: type,
                      data: childList,
                      title: item["title"] ?? "",
                      onMoreClick:
                          item["title"] == "Artist".tr &&
                                  Get.find<Application>().typeSo == "ytm"
                              ? () {
                                //跳转到全部歌手
                                Get.to(UserMoreArtist());
                              }
                              : null,
                    );
                  },
                  separatorBuilder: (_, i) {
                    // if (i == 2) {
                    //   return Container(
                    //     margin: EdgeInsets.symmetric(
                    //       vertical: 8.w,
                    //       horizontal: 16.w,
                    //     ),
                    //     child: MyNativeAdView(
                    //       adKey: "pagebanner",
                    //       positionKey: "HomeNative",
                    //     ),
                    //   );
                    // }

                    return SizedBox(height: 16.w);
                  },
                  itemCount: controller.netList.length,
                ),
              );
            },
          ),
          onError: (e) {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/oimg/icon_wifi.png",
                    width: 180.w,
                    height: 180.w,
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    "No network".tr,
                    style: TextStyle(fontSize: 16.w, color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.bindYoutubeMusicData();
                    },
                    child: Text("Reload".tr),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  getBigItem({
    required String type,
    required List data,
    required String title,
    VoidCallback? onMoreClick,
  }) {
    if (type.isEmpty) {
      type = data.first?["type"];
    }

    if (data.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.w,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              // Spacer(),
              onMoreClick != null
                  ? InkWell(
                    onTap: () {
                      onMoreClick();
                      EventUtils.instance.addEvent(
                        "home_artist",
                        data: {"click_type": "more"},
                      );
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
                  )
                  : Container(),
            ],
          ),
        ),
        SizedBox(height: 10.w),

        // Container(
        //     height: 100.w,
        //     child: ListView.separated(
        //         scrollDirection: Axis.horizontal,
        //         itemBuilder: (_, i) {
        //           return Container(
        //               width: 100.w, height: 100.w, color: Colors.red);
        //         },
        //         separatorBuilder: (_, i) {
        //           return Container(
        //             width: 10.w,
        //           );
        //         },
        //         itemCount: 10))
        Builder(
          builder: (c) {
            if (type == "MUSIC_VIDEO_TYPE_OMV") {
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
                          EventUtils.instance.addEvent(
                            "home_model",
                            data: {"click_type": "play", "title": title},
                          );

                          Get.find<UserPlayInfoController>().setDataAndPlayItem(
                            [childItem],
                            childItem,
                            clickType: "home",
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
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(width: 12.w);
                  },
                  itemCount: data.length,
                ),
              );
            } else if (type == "MUSIC_VIDEO_TYPE_ATV" ||
                type == "MUSIC_VIDEO_TYPE_UGC") {
              //小的歌曲列表

              var isRec = title == "Listen now";

              return Container(
                height: 226.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    //获取三个
                    List subList = data.sublist(i * 3, i * 3 + 3);

                    return Container(
                      width: 310.w,
                      height: 218.w,
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffE9E9FF), Color(0xffffffff)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.w),
                          bottomLeft: Radius.circular(12.w),
                          bottomRight: Radius.circular(12.w),
                          topRight: Radius.circular(24.w),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            subList.map((subItem) {
                              return InkWell(
                                onTap: () {
                                  if (isRec) {
                                    EventUtils.instance.addEvent(
                                      "home_song",
                                      data: {"click_type": "play"},
                                    );
                                  } else {
                                    EventUtils.instance.addEvent(
                                      "home_model",
                                      data: {
                                        "click_type": "play",
                                        "title": title,
                                      },
                                    );
                                  }

                                  AppLog.e(subItem);
                                  var plist = List.of(data);
                                  var pItem = Map.of(subItem);

                                  Get.find<UserPlayInfoController>()
                                      .setDataAndPlayItem(
                                        [pItem],
                                        pItem,
                                        clickType: "home",
                                        loadNextData: true,
                                      );

                                  // Get.to(UserPlayInfo());
                                },
                                child: Obx(() {
                                  var isCheck =
                                      subItem["videoId"] ==
                                      Get.find<UserPlayInfoController>()
                                          .nowData["videoId"];
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
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
                                            borderRadius: BorderRadius.circular(
                                              6.w,
                                            ),
                                          ),
                                          child: NetImageView(
                                            imgUrl: subItem["cover"],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                subItem["title"],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color:
                                                      isCheck
                                                          ? Color(0xff8569FF)
                                                          : Colors.black,
                                                  fontSize: 14.w,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 10.w),
                                              Row(
                                                children: [
                                                  Obx(() {
                                                    var isLike = LikeUtil
                                                        .instance
                                                        .allVideoMap
                                                        .containsKey(
                                                          subItem["videoId"],
                                                        );
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
                                                  Expanded(
                                                    child: Text(
                                                      subItem["subtitle"] ?? "",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12.w,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            isCheck
                                                                ? Color(
                                                                  0xff8569FF,
                                                                )
                                                                : Colors.black
                                                                    .withOpacity(
                                                                      0.75,
                                                                    ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        if (FirebaseRemoteConfig.instance
                                                .getString(
                                                  "musicmuse_off_switch",
                                                ) ==
                                            "on")
                                          Obx(() {
                                            //获取下载状态
                                            var videoId = subItem["videoId"];

                                            if (DownloadUtils
                                                .instance
                                                .allDownLoadingData
                                                .containsKey(videoId)) {
                                              //有添加过下载
                                              var state =
                                                  DownloadUtils
                                                      .instance
                                                      .allDownLoadingData[videoId]["state"];
                                              double progress =
                                                  DownloadUtils
                                                      .instance
                                                      .allDownLoadingData[videoId]["progress"];

                                              // AppLog.e(
                                              //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

                                              if (state == 1 || state == 3) {
                                                //下载中\下载暂停
                                                return InkWell(
                                                  onTap: () {
                                                    DownloadUtils.instance
                                                        .remove(videoId);
                                                  },
                                                  child: Container(
                                                    height: 50.w,
                                                    width: 32.w,
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.all(
                                                      6.w,
                                                    ),
                                                    child: Container(
                                                      width: 20.w,
                                                      height: 20.w,
                                                      // padding: EdgeInsets.all(5.w),
                                                      child:
                                                          CircularProgressIndicator(
                                                            value: progress,
                                                            strokeWidth: 1.5,
                                                            backgroundColor:
                                                                Color(
                                                                  0xffA995FF,
                                                                ).withOpacity(
                                                                  0.35,
                                                                ),
                                                            color: Color(
                                                              0xffA995FF,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              } else if (state == 2) {
                                                return InkWell(
                                                  onTap: () {
                                                    DownloadUtils.instance
                                                        .remove(videoId);
                                                  },
                                                  child: Container(
                                                    height: 50.w,
                                                    padding: EdgeInsets.all(
                                                      6.w,
                                                    ),
                                                    child: Image.asset(
                                                      "assets/oimg/icon_download_ok.png",
                                                      width: 20.w,
                                                      height: 20.w,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            return InkWell(
                                              onTap: () {
                                                if (isRec) {
                                                  EventUtils.instance.addEvent(
                                                    "home_song",
                                                    data: {
                                                      "click_type": "offline",
                                                    },
                                                  );
                                                } else {
                                                  EventUtils.instance.addEvent(
                                                    "home_model",
                                                    data: {
                                                      "click_type": "offline",
                                                      "title": title,
                                                    },
                                                  );
                                                }

                                                DownloadUtils.instance.download(
                                                  videoId,
                                                  subItem,
                                                  clickType: "home",
                                                );
                                              },
                                              child: Container(
                                                height: 50.w,
                                                padding: EdgeInsets.all(6.w),
                                                child: Image.asset(
                                                  "assets/oimg/icon_download_gray.png",
                                                  width: 20.w,
                                                  height: 20.w,
                                                ),
                                              ),
                                            );
                                          }),
                                        // SizedBox(
                                        //   width: 12.w,
                                        // ),
                                        InkWell(
                                          onTap: () {
                                            MoreSheetUtil.instance
                                                .showVideoMoreSheet(
                                                  subItem,
                                                  clickType: "home",
                                                );
                                          },
                                          child: Container(
                                            height: 50.w,
                                            padding: EdgeInsets.all(6.w),
                                            child: Container(
                                              width: 20.w,
                                              height: 20.w,
                                              child: Image.asset(
                                                "assets/oimg/icon_more.png",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            }).toList(),
                      ),
                    );
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(width: 16.w);
                  },
                  itemCount: data.length ~/ 3,
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
                        EventUtils.instance.addEvent(
                          "home_model",
                          data: {"click_type": "play", "title": title},
                        );
                        AppLog.e(childItem);

                        EventUtils.instance.addEvent(
                          "det_playlist_show",
                          data: {"from": "home"},
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
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                              ),
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
                        EventUtils.instance.addEvent(
                          "home_model",
                          data: {"click_type": "play", "title": title},
                        );
                        AppLog.e(childItem);
                        EventUtils.instance.addEvent(
                          "det_playlist_show",
                          data: {"from": "home"},
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
                              "${childItem["title"]}",
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                              ),
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
                        EventUtils.instance.addEvent(
                          "home_artist",
                          data: {"click_type": "details"},
                        );

                        AppLog.e(childItem);

                        EventUtils.instance.addEvent(
                          "det_artist_show",
                          data: {"form": "home_artist"},
                        );

                        if (Get.find<Application>().typeSo == "yt") {
                          //跳转youtube频道
                          var map = Map.of(childItem);

                          map["browseId"] = map["youtubeId"];

                          AppLog.e(map);
                          Get.to(UserYoutubeChannel(), arguments: map);
                          return;
                        }

                        Get.to(UserArtistInfo(), arguments: childItem);
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
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w500,
                                ),
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
            } else if (type == "MUSIC_PAGE_TYPE_TOP_CHART") {
              //自定义排行榜
              return Container(
                height: 185.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
                    return GestureDetector(
                      onTap: () {
                        EventUtils.instance.addEvent(
                          "home_model",
                          data: {"click_type": "play", "title": title},
                        );
                        AppLog.e(childItem);
                        EventUtils.instance.addEvent(
                          "det_playlist_show",
                          data: {"from": "home"},
                        );

                        var itemMap = Map.of(childItem);

                        if (Get.find<Application>().typeSo == "yt") {
                          itemMap.remove("browseId");
                        }

                        Get.to(UserPlayListInfo(), arguments: itemMap);
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
                              style: TextStyle(
                                height: 1.2,
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                              ),
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
            } else if (type == "MUSIC_PAGE_TYPE_MYHISTORY") {
              //自定义歌曲
            } else if (type == "My_Playlist") {
              //自定义歌单

              return Container(
                height: 130.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
                    var childType = childItem["type"];

                    return InkWell(
                      onTap: () {
                        if (childType == -1) {
                          //我喜欢的
                          EventUtils.instance.addEvent(
                            "home_recom",
                            data: {"click_type": "collection"},
                          );

                          Get.to(UserLikeSong(isFormHome: true));
                        } else if (childType == -2) {
                          //我下载的
                          EventUtils.instance.addEvent(
                            "home_recom",
                            data: {"click_type": "offline"},
                          );
                          Get.to(UserDownloadSong(isFormHome: true));
                        } else {
                          //本地和网络歌单
                          EventUtils.instance.addEvent(
                            "home_recom",
                            data: {"click_type": "details"},
                          );
                          EventUtils.instance.addEvent(
                            "det_playlist_show",
                            data: {"from": "home"},
                          );
                          if (childType == 1) {
                            AppLog.e(childItem);
                            Get.to(UserPlayListInfo(), arguments: childItem);
                            // Get.to(UserPlayListInfo(),
                            //     arguments: {"browseId": childItem["id"]});
                          } else {
                            Get.to(UserLocPlayListInfo(), arguments: childItem);
                          }
                        }
                      },
                      child: Container(
                        width: 88.w,
                        // color: Colors.red,
                        height: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              width: 88.w,
                              height: 88.w,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: Builder(
                                builder: (childC) {
                                  if (childType == -1 || childType == -2) {
                                    return Image.asset(
                                      childItem["icon"],
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return NetImageView(
                                      imgUrl: childItem["cover"],
                                      fit: BoxFit.cover,
                                      errorAsset: Assets.oimgIconDItem,
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 5.w),
                            Container(
                              width: 88.w,
                              child: Text(
                                childItem["title"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.w,
                                  fontWeight: FontWeight.w500,
                                ),
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
            } else if (type == "LOCKUP_CONTENT_TYPE_ALBUM" ||
                type == "LOCKUP_CONTENT_TYPE_PLAYLIST") {
              //youtube的歌单
              return Container(
                height: 185.w,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    var childItem = data[i];
                    return GestureDetector(
                      onTap: () {
                        // EventUtils.instance.addEvent("home_model",
                        //     data: {"click_type": "play", "title": title});
                        // AppLog.e(childItem);
                        //
                        // EventUtils.instance.addEvent("det_playlist_show",
                        //     data: {"from": "home"});
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
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                              ),
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
            } else if (type == "Video") {
              //youtube的视频列表
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
                          EventUtils.instance.addEvent(
                            "home_model",
                            data: {"click_type": "play", "title": title},
                          );

                          Get.find<UserPlayInfoController>().setDataAndPlayItem(
                            [childItem],
                            childItem,
                            clickType: "home",
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
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(width: 12.w);
                  },
                  itemCount: data.length,
                ),
              );
            }

            AppLog.e(type);
            AppLog.e(data);

            return Container(height: 100.w, color: Colors.red);
            // return Container(
            //   height: 200.w,
            //   child: ListView.separated(
            //       scrollDirection: Axis.horizontal,
            //       itemBuilder: (_, i) {
            //         var childItem = data[i];
            //
            //         return Column(
            //           children: [
            //             Container(
            //               width: 100.w,
            //               height: 100.w,
            //               child: NetImageView(
            //                 imgUrl: childItem["cover"] ?? "",
            //               ),
            //             ),
            //             // Text(childItem["title"]),
            //             Text(childItem["subtitle"]),
            //           ],
            //         );
            //       },
            //       separatorBuilder: (_, i) {
            //         return SizedBox(
            //           width: 10.w,
            //         );
            //       },
            //       itemCount: data.length),
            // );
          },
        ),
      ],
    );
  }
}

class UserHomeController extends GetxController with StateMixin {
  var allData = {};
  var netList = [].obs;
  var easyC = EasyRefreshController();

  var scrollC = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    // await DownloadUtils.instance.initData();

    bindLocalData();
    // bindYoutubeMusicData();
  }

  @override
  void onReady() async {
    super.onReady();

    MyDialogUtils.instance.showOtherAppDialog();
  }

  var nextData = {};

  //第一次接口
  Future bindYoutubeMusicData() async {
    //TODO 测试youtube数据
    // await bindYoutubeData();
    // return;

    if (netList.length < 5) {
      change("", status: RxStatus.loading());
    }

    AppLog.e("开始请求");
    BaseModel result = await ApiMain.instance.getData("FEmusic_home");

    if (result.code != HttpCode.success) {
      if (netList.length < 5) {
        change("", status: RxStatus.error());
        // TbaUtils.instance.postUserData({"mm_type_so": "no"});
      }

      return;
    }

    //下一页数据
    //{
    //   "continuation": "xx",
    //   "clickTrackingParams": "xxx"
    //}

    Get.find<Application>().visitorData =
        result.data["responseContext"]?["visitorData"] ?? "";
    nextData =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]?["content"]["sectionListRenderer"]["continuations"]?[0]?["nextContinuationData"] ??
        {};

    List bigList =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]?["content"]["sectionListRenderer"]["contents"];

    // AppLog.e(bigList);

    List realList = [];

    var moreId = "";
    for (Map item in bigList) {
      //大标题
      var bigTitle =
          item["musicCarouselShelfRenderer"]?["header"]?["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0]["text"] ??
          "";

      List childList = item["musicCarouselShelfRenderer"]?["contents"] ?? [];

      //more id
      moreId =
          item["musicCarouselShelfRenderer"]?["header"]?["musicCarouselShelfBasicHeaderRenderer"]?["moreContentButton"]?["buttonRenderer"]?["navigationEndpoint"]?["watchPlaylistEndpoint"]?["playlistId"] ??
          "";

      List realChildList = [];

      //判断类型
      var type = "";

      for (Map childItem in childList) {
        // AppLog.e("当前类型：${childItem.keys}");

        if (childItem.containsKey("musicResponsiveListItemRenderer")) {
          //音乐
          List flexColumns =
              childItem["musicResponsiveListItemRenderer"]?["flexColumns"] ??
              [];
          var musicType =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];

          type = musicType;

          //标题
          var childItemTitle =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"] ??
              "";
          var childItemSubTitle =
              flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"] ??
              "";
          //id
          var videoId =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]?["videoId"] ??
              "";
          var playlistId =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]?["playlistId"] ??
              "";

          //封面
          var childItemCover =
              childItem["musicResponsiveListItemRenderer"]?["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]?[0]?["url"] ??
              "";

          if (type.isNotEmpty) {
            realChildList.add({
              "title": childItemTitle,
              "subtitle": childItemSubTitle,
              "cover": childItemCover,
              "type": type,
              "videoId": videoId,
            });
          }

          continue;
        } else if (childItem.containsKey("musicTwoRowItemRenderer")) {
          //歌单
          //歌单、专辑、歌手
          var childItemType =
              childItem["musicTwoRowItemRenderer"]["title"]["runs"][0]["navigationEndpoint"]?["browseEndpoint"]["browseEndpointContextSupportedConfigs"]?["browseEndpointContextMusicConfig"]?["pageType"] ??
              "";
          type = childItemType;

          //标题
          var childItemTitle =
              childItem["musicTwoRowItemRenderer"]?["title"]["runs"][0]["text"] ??
              "";
          List childItemSubTitleList =
              childItem["musicTwoRowItemRenderer"]?["subtitle"]["runs"] ?? [];
          String childItemSubTitle = childItemSubTitleList
              .map((e) => e["text"] ?? "")
              .toList()
              .join("");
          //id
          var browseId =
              childItem["musicTwoRowItemRenderer"]?["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"] ??
              "";

          //封面
          var childItemCover =
              childItem["musicTwoRowItemRenderer"]?["thumbnailRenderer"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][1]["url"];

          if (type.isNotEmpty) {
            realChildList.add({
              "title": childItemTitle,
              "subtitle": childItemSubTitle,
              "cover": childItemCover,
              "type": type,
              "browseId": browseId,
            });
          }
        } else {
          //歌单
          AppLog.e("不支持的类型");
          AppLog.e(childItem.keys);
        }
      }

      if (realChildList.isNotEmpty) {
        realList.add({
          "title": bigTitle,
          "list": realChildList,
          "moreId": moreId,
          "type": type,
        });
      }
    }

    // netList.value = realList;

    if (realList.isEmpty) {
      // var errorText = result.data["contents"]
      //                     ["singleColumnBrowseResultsRenderer"]["tabs"][0]
      //                 ["tabRenderer"]?["content"]["sectionListRenderer"]
      //             ["contents"]?[0]?["itemSectionRenderer"]["contents"][0]
      //         ["messageRenderer"]["text"]["runs"][0]["text"] ??
      //     "";

      // var errorText = "App isn't available in your country";
      // ToastUtil.showToast(msg: errorText);

      //不支持music的地区，使用youtube
      await bindYoutubeData();

      // if (netList.length < 5) {
      //   change("", status: RxStatus.error());
      //   // TbaUtils.instance.postUserData({"mm_type_so": "no"});
      // }
      return;
    }

    if (netList.length > 5) {
      //先删除本地的
      netList.value = List.of(netList.sublist(0, 4));
    }
    netList.addAll(realList);

    // ToastUtil.showToast(msg: "请求完成");
    // AppLog.e(netList);
    // AppLog.e(nextData);
    await reloadHistory();

    change("", status: RxStatus.success());

    //设置为ytm资源
    Get.find<Application>().changeTypeSo("ytm");

    bindYoutubeMusicNextData();

    // Get.find<UserPlayInfoController>().showLastPlayBar();
  }

  //请求下一页
  bindYoutubeMusicNextData() async {
    if (nextData.isEmpty) {
      //没有下一页了
      //存储数据
      await reloadHistory();
      saveLocList();
      return;
    }

    BaseModel result = await ApiMain.instance.getData(
      "FEmusic_home",
      nextData: nextData,
    );

    try {
      nextData =
          result
              .data["continuationContents"]["sectionListContinuation"]["continuations"][0]["nextContinuationData"];
    } catch (e) {
      AppLog.e("没有更多数据");
      AppLog.e(e);
      nextData = {};
    }

    List bigList =
        result
            .data["continuationContents"]?["sectionListContinuation"]?["contents"] ??
        [];

    List realList = [];

    var moreId = "";
    for (Map item in bigList) {
      //大标题
      var bigTitle =
          item["musicCarouselShelfRenderer"]?["header"]?["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0]["text"] ??
          "";

      // moreId = item["musicCarouselShelfRenderer"]?["header"]
      //                     ?["musicCarouselShelfBasicHeaderRenderer"]
      //                 ?["moreContentButton"]?["buttonRenderer"]
      //             ?["navigationEndpoint"]?["watchPlaylistEndpoint"]
      //         ?["playlistId"] ??
      //     "";

      List childList = item["musicCarouselShelfRenderer"]?["contents"] ?? [];

      List realChildList = [];

      //判断类型
      var type = "";

      AppLog.e("$bigTitle:共有${childList.length}条小item");

      for (Map childItem in childList) {
        // AppLog.e("当前类型：${childItem.keys}");

        if (childItem.containsKey("musicResponsiveListItemRenderer")) {
          //音乐
          List flexColumns =
              childItem["musicResponsiveListItemRenderer"]?["flexColumns"] ??
              [];
          var musicType =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];

          type = musicType;

          //标题
          var childItemTitle =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"] ??
              "";
          var childItemSubTitle =
              flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"] ??
              "";
          //id
          var videoId =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]?["videoId"] ??
              "";
          var playlistId =
              flexColumns[0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]?["playlistId"] ??
              "";

          //封面
          var childItemCover =
              childItem["musicResponsiveListItemRenderer"]?["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]?[0]?["url"] ??
              "";

          if (type.isNotEmpty) {
            realChildList.add({
              "title": childItemTitle,
              "subtitle": childItemSubTitle,
              "cover": childItemCover,
              "type": type,
              "videoId": videoId,
            });
          }

          continue;
        } else if (childItem.containsKey("musicTwoRowItemRenderer")) {
          //歌单
          //歌单、专辑、歌手

          // if (type == "MUSIC_PAGE_TYPE_ALBUM") {
          //   //专辑特殊处理
          //   AppLog.e("专辑列表");
          //   AppLog.e(childItem);
          // }

          //标题
          try {
            var childItemType =
                childItem["musicTwoRowItemRenderer"]["title"]["runs"][0]["navigationEndpoint"]?["browseEndpoint"]["browseEndpointContextSupportedConfigs"]?["browseEndpointContextMusicConfig"]?["pageType"] ??
                "";

            type = childItemType;

            var childItemTitle =
                childItem["musicTwoRowItemRenderer"]?["title"]["runs"][0]["text"] ??
                "";
            List childItemSubTitleList =
                childItem["musicTwoRowItemRenderer"]?["subtitle"]["runs"] ?? [];
            String childItemSubTitle = childItemSubTitleList
                .map((e) => e["text"] ?? "")
                .toList()
                .join("");

            //id
            var browseId =
                childItem["musicTwoRowItemRenderer"]?["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"] ??
                "";

            //封面
            var childItemCover =
                childItem["musicTwoRowItemRenderer"]?["thumbnailRenderer"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][1]["url"];

            if (type.isNotEmpty) {
              realChildList.add({
                "title": childItemTitle,
                "subtitle": childItemSubTitle,
                "cover": childItemCover,
                "type": type,
                "browseId": browseId,
              });
            }
          } catch (e) {
            // AppLog.e(e);
            // AppLog.e("出错的item");
            // AppLog.e(childItem);

            var childItemType =
                childItem["musicTwoRowItemRenderer"]["navigationEndpoint"]?["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]?["watchEndpointMusicConfig"]?["musicVideoType"] ??
                "";

            type = childItemType;

            var childItemTitle =
                childItem["musicTwoRowItemRenderer"]?["title"]["runs"][0]["text"] ??
                "";
            // List childItemSubTitleList =
            //     childItem["musicTwoRowItemRenderer"]?["subtitle"]["runs"] ?? [];
            // String childItemSubTitle = childItemSubTitleList
            //     .map((e) => e["text"] ?? "")
            //     .toList()
            //     .join("");
            String childItemSubTitle =
                childItem["musicTwoRowItemRenderer"]?["subtitle"]["runs"][0]["text"];

            //id
            var videoId =
                childItem["musicTwoRowItemRenderer"]["navigationEndpoint"]["watchEndpoint"]["videoId"] ??
                "";

            //封面
            var childItemCover =
                childItem["musicTwoRowItemRenderer"]?["thumbnailRenderer"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"][0]["url"];

            if (type.isNotEmpty) {
              realChildList.add({
                "title": childItemTitle,
                "subtitle": childItemSubTitle,
                "cover": childItemCover,
                "type": type,
                "videoId": videoId,
              });
            }
          }
        } else {
          //歌单
          AppLog.e("不支持的类型");
          AppLog.e(childItem.keys);
        }
      }

      if (realChildList.isNotEmpty) {
        realList.add({
          "title": bigTitle,
          "list": realChildList,
          "moreId": moreId,
          "type": type,
        });
      }
    }

    netList.addAll(realList);
    // ToastUtil.showToast(msg: "下一页请求成功");

    bindYoutubeMusicNextData();
  }

  Future reloadHistory() async {
    if (netList.isEmpty) {
      return;
    }

    var historySongList = List.of(HistoryUtil.instance.songHistoryList);

    var historySongData = {
      "title": "Listen now".tr,
      "list": historySongList,
      "moreId": "",
      "type": "MUSIC_VIDEO_TYPE_ATV",
    };
    netList[0] = historySongData;

    var myPlaylist = [];

    //获取收藏数量
    var hasLikeList = LikeUtil.instance.allVideoMap.isNotEmpty;

    if (hasLikeList) {
      myPlaylist.add({
        "title": "Liked songs".tr,
        "icon": "assets/oimg/icon_like_list.png",
        "type": -1,
      });
    }

    //获取所有下载完成歌曲
    var allDList = DownloadUtils.instance.allDownLoadingData.values;
    var downloadedList =
        allDList.where((e) {
          return e["state"] == 2;
        }).toList();
    var hasDownloadList = downloadedList.isNotEmpty;
    if (hasDownloadList &&
        FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") ==
            "on") {
      myPlaylist.add({
        "title": "Local songs".tr,
        "icon": "assets/oimg/icon_local.png",
        "type": -2,
      });
    }

    //添加自建或者收藏歌单
    var box = await Hive.openBox(DBKey.myPlayListData);

    // await box.clear();

    var oldList = box.values.toList();
    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });

    List homePlaylist = List.of(oldList)..removeWhere((e) {
      List childList = e["list"] ?? [];
      return childList.isEmpty && e["type"] != 1;
    });

    //添加历史歌单
    myPlaylist.addAll(homePlaylist);

    var myPlaylistData = {
      "title": "My Playlist".tr,
      "list": myPlaylist,
      "moreId": "",
      "type": "My_Playlist",
    };

    netList[1] = myPlaylistData;

    //默认6个歌手
    List artistList = decodeList(locArtist);

    // AppLog.e("artistList--");
    // AppLog.e(artistList);

    var artistData = {
      "title": "Artist".tr,
      "list": artistList,
      "moreId": "",
      "type": "MUSIC_PAGE_TYPE_ARTIST",
    };

    netList[2] = artistData;

    //默认排行
    // 美国当地
    // PL4fGSI1pDJn6O1LS0XSdF3RyO0Rq_LDeI  在前面加VL
    // VLPL4fGSI1pDJn6O1LS0XSdF3RyO0Rq_LDeI
    // 周榜
    // VLPLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx
    // 日榜
    // VLPL4fGSI1pDJn5kI81J1fYWK5eZRl1zJ5kM

    //获取语言，根据语言显示地区榜单
    List oldTopList = decodeList(locTop);
    var otherLangList = oldTopList.sublist(0, 3);
    List topList = oldTopList.sublist(3);
    if (MyTranslations.locale.languageCode == "es") {
      //墨西哥-西班牙语-mx
      topList.insert(0, otherLangList[1]);
    } else if (MyTranslations.locale.languageCode == "pt") {
      //巴西-葡萄牙语-br
      topList.insert(0, otherLangList[2]);
    } else {
      topList.insert(0, otherLangList[0]);
    }

    //youtube music不显示榜单
    if (Get.find<Application>().typeSo == "ytm") {
      topList = [];
      // topList = [
      //   {
      //     "title": "Top 100 Songs United States",
      //     "cover":
      //         "https://yt3.ggpht.com/EJcndQYhm1NaCEutBx6XxY9np_pbYsG7OoWsdMObNL0FgeEaKrj1o_s5zCXv_gSLH1I94ohj-7o=s1200",
      //     "browseId": "VLPL4fGSI1pDJn6O1LS0XSdF3RyO0Rq_LDeI"
      //   },
      //   {
      //     "title": "Top 50 Global",
      //     "cover":
      //         "https://yt3.ggpht.com/e6EMQmlAwRvJG_a5dg5OHb2InhYcdyFrDEJUuI0yn1bleYzc-HKEq8-hr9I0X-OjADluNF95ZBQ=s1200",
      //     "browseId": "VLPL4fGSI1pDJn77aK7sAW2AT0oOzo5inWY8"
      //   },
      //   {
      //     "title": "Top 100 Music Videos Global",
      //     "cover":
      //         "https://yt3.ggpht.com/wV9dgN_3SN89DkNHRQRZkJHCKXqNeOXRpoy-YQhA2ICMFsIAzT5snzfXad5VNG2HBvEaRxa41Q=s1200",
      //     "browseId": "VLPL4fGSI1pDJn5kI81J1fYWK5eZRl1zJ5kM"
      //   },
      // ];
    }

    var topData = {
      "title": "Top Chart".tr,
      "list": topList,
      "moreId": "",
      "type": "MUSIC_PAGE_TYPE_TOP_CHART",
    };
    netList[3] = topData;

    netList.refresh();
    saveLocList();
  }

  saveLocList() async {
    // var sp = await SharedPreferences.getInstance();
    // await sp.setString("LastHomeDataStr", jsonEncode(netList));

    var box = await Hive.openBox(DBKey.myLastHomeDataStr);
    box.clear();
    box.put(0, List.of(netList));
  }

  bindLocalData() async {
    var box = await Hive.openBox(DBKey.myLastHomeDataStr);
    List oldList = box.get(0) ?? [];

    if (oldList.length > 5) {
      //有缓存
      netList.value = oldList;
      // reloadHistory();
      change("", status: RxStatus.success());

      // TbaUtils.instance.postUserData({"mm_type_so": "ytm"});
      bindYoutubeMusicData();
      Get.find<UserPlayInfoController>().showLastPlayBar();
      return;
    }

    netList.add({});
    netList.add({});
    netList.add({});
    netList.add({});

    bindYoutubeMusicData();
    Get.find<UserPlayInfoController>().showLastPlayBar();
  }

  Future bindYoutubeData() async {
    if (netList.length < 5) {
      change("", status: RxStatus.loading());
    }

    AppLog.e("开始请求");
    BaseModel result = await ApiMain.instance.getYoutubeData(
      "UC-9-kyTW8ZkZNDHQJ6FgpwQ",
    );

    Get.find<Application>().visitorData =
        result.data["responseContext"]?["visitorData"] ?? "";

    List oldList =
        result
            .data["contents"]?["twoColumnBrowseResultsRenderer"]?["tabs"]?[0]["tabRenderer"]["content"]?["sectionListRenderer"]?["contents"] ??
        [];
    if (oldList.isEmpty) {
      oldList =
          result
              .data["contents"]?["twoColumnBrowseResultsRenderer"]?["tabs"]?[0]["tabRenderer"]["content"]?["richGridRenderer"]?["contents"] ??
          [];
    }

    var realList = FormatMyData.instance.getYoutubeHomeList(oldList);
    AppLog.e("首页youtube数据");
    AppLog.e(oldList);
    AppLog.e(realList);

    if (netList.length > 5) {
      //先删除本地的
      netList.value = List.of(netList.sublist(0, 4));
    }
    netList.addAll(realList);

    // ToastUtil.showToast(msg: "请求完成");
    // AppLog.e(netList);
    // AppLog.e(nextData);
    change("", status: RxStatus.success());
    //保存到历史记录
    await reloadHistory();

    saveLocList();

    Get.find<Application>().changeTypeSo("yt");
    // Get.find<UserPlayInfoController>().showLastPlayBar();
  }
}

final locArtist =
    "XX0id3VCbWN5aXBwVU5XZm5Pc1FzejNNZkNVIjoiZEllYnV0dW95IiwiUW9LM2ZhdDVBaDNLY3pGS3NnT3ZkZUNVIjoiZEllc3dvcmIiLCJUU0lUUkFfRVBZVF9FR0FQX0NJU1VNIjoiZXB5dCIsImpyLTA5bC0wMjFoLTAyMXc9X3V1eEhqSTVHNnZJd2V5NlcwQnMzUXhHNnVhMm1nN2RPVFJLakxJQ1NHVUNFemkxb1dqVS1WTEEvLWEvbW9jLnRuZXRub2NyZXN1ZWxnb29nLjNobC8vOnNwdHRoIjoicmV2b2MiLCIiOiJlbHRpdGJ1cyIsIm1lbmltRSI6ImVsdGl0InssfSJRa2ItOU9FVkJEUDd5MElqTXdqRndJQ1UiOiJkSWVidXR1b3kiLCJnOTFZR3JJQ0V6bDZRNVZVZms4anZHQ1UiOiJkSWVzd29yYiIsIlRTSVRSQV9FUFlUX0VHQVBfQ0lTVU0iOiJlcHl0IiwianItMDlsLXAtMDIxaC0wMjF3PWdSTzFnQXdlZF9UUmFfalMyWmN0SW1YSnhtRXA3TFZ6cW9mZjdRWWh6cTZyZU5HSTc5dEEzSlk4QmkwTHFXNDZ0Ul9yb2pjT3FNcHR0VmkvbW9jLnRuZXRub2NyZXN1ZWxnb29nLjNobC8vOnNwdHRoIjoicmV2b2MiLCIiOiJlbHRpdGJ1cyIsInJlYmVpQiBuaXRzdUoiOiJlbHRpdCJ7LH0iUW1zYUJkQUxhUVBGdjVvX0xfWWwweENVIjoiZEllYnV0dW95IiwiQXoyVFYyTzdGR0w3M2lYQ2xqWGVtZkNVIjoiZEllc3dvcmIiLCJUU0lUUkFfRVBZVF9FR0FQX0NJU1VNIjoiZXB5dCIsImpyLTA5bC1wLTAyMWgtMDIxdz1tN1NlLTlyczNoX3lJMklDUjNJaDVhcGVYU2xtYzZyTmhZZFFCS1Z1aWVXLV9jcTRiejdiYmtmRzA3c0RLd0lKSGo2b3VvRXJwd25RYkV4Yi9tb2MudG5ldG5vY3Jlc3VlbGdvb2cuM2hsLy86c3B0dGgiOiJyZXZvYyIsIiI6ImVsdGl0YnVzIiwiaXZhWCI6ImVsdGl0InssfSJ3ZXdPTHNwY3hJd05sRmtQcXFQV0ZaQ1UiOiJkSWVidXR1b3kiLCJBbnlCOWFJM0pfdDJaVUc1dDJRY2FWQ1UiOiJkSWVzd29yYiIsIlRTSVRSQV9FUFlUX0VHQVBfQ0lTVU0iOiJlcHl0IiwianItMDlsLXAtMDIxaC0wMjF3PVlQN0NTUnBubnd0TnZXMjlteFljNl9BNmE4dVpLVHZJMzFndi1kTk5XTFQ4TU9UTzFOaU1IcHZWeDJ6SmZRaGlFOHZhYXY2VlZ0OGNiQnovbW9jLnRuZXRub2NyZXN1ZWxnb29nLjNobC8vOnNwdHRoIjoicmV2b2MiLCIiOiJlbHRpdGJ1cyIsInNlbHl0UyB5cnJhSCI6ImVsdGl0InssfSJRMFEzMVdma09mTzFnR3g4dXdfQUJtQ1UiOiJkSWVidXR1b3kiLCJRdlNrMm5WS05TbEI2REdBSDh6M1lpQ1UiOiJkSWVzd29yYiIsIlRTSVRSQV9FUFlUX0VHQVBfQ0lTVU0iOiJlcHl0IiwianItMDlsLXAtMDIxaC0wMjF3PUFtZkMxZ3I2Z1NSbDFmR09fd1g0WDVPRUUwaGlBbzU3Q09hZUNkamtWbGZnOXEybTM1ZjRKRFlrbnJWMDhYeThrMUgxWFZubTJwYzJFWC9tb2MudG5ldG5vY3Jlc3VlbGdvb2cuM2hsLy86c3B0dGgiOiJyZXZvYyIsIiI6ImVsdGl0YnVzIiwieW5udUIgZGFCIjoiZWx0aXQieyx9Imc2SFd6RVBiQ1k3bm5nYUc4SmFDRXFDVSI6ImRJZWJ1dHVveSIsIkFwVDUwYXdOTXVLLXgzNTJkMUwwQ1BDVSI6ImRJZXN3b3JiIiwiVFNJVFJBX0VQWVRfRUdBUF9DSVNVTSI6ImVweXQiLCJqci0wOWwtcC0wMjFoLTAyMXc9ZzRsbXlaeEFCQ1NyV0hCaEtaUEc4Y2NkMVZjS09wcUpPSFlxN0NKdkI1bHNMam10T05FUXhiT2VkQkk2Nm9LU1FzWElad0xHYnlCU2p5L21vYy50bmV0bm9jcmVzdWVsZ29vZy4zaGwvLzpzcHR0aCI6InJldm9jIiwiIjoiZWx0aXRidXMiLCJ0Zml3UyByb2x5YVQiOiJlbHRpdCJ7Ww==";
final locSong =
    "XX0iUTN5Ny02dWh0NW8iOiJkSW9lZGl2IiwiVlRBX0VQWVRfT0VESVZfQ0lTVU0iOiJlcHl0IiwianItMDlsLTA2aC0wNnc9ZzI3d09DOHFhcmNZNzhQd3lKNFZVMHE5Qm9uWnNrbzltQ0NCRTlmZWF3bHU1SjhaZ3NfODFtZmNpRkJNdVMxRXZMMktlN21ObkJpM3QxZUdYUC9tb2MudG5ldG5vY3Jlc3VlbGdvb2cuM2hsLy86c3B0dGgiOiJyZXZvYyIsIm5vTCBpbnVNIjoiZWx0aXRidXMiLCJlTSByb0YgZWRhTSI6ImVsdGl0InssfSJBYVBwd3dTUl9hTyI6ImRJb2VkaXYiLCJWVEFfRVBZVF9PRURJVl9DSVNVTSI6ImVweXQiLCJBMXo4aHlQSnVWYlZKYnJBbUlONXF2R2V3N2prM0xKek1BPXNyJmdXSUpBNmdnSEdFUUpFcWhnQ3FRQUlCRU9FREFKQ1dFd215YW8tPXBxcz9ncGoudGx1YWZlZGRzL0FhUHB3d1NSX2FPL2l2L21vYy5nbWl0eS5pLy86c3B0dGgiOiJyZXZvYyIsImVub29CIG5vc25lQiI6ImVsdGl0YnVzIiwic2duaWhUIGx1Zml0dWFlQiI6ImVsdGl0InssfSJZMFJrd0RuUmJUayI6ImRJb2VkaXYiLCJWVEFfRVBZVF9PRURJVl9DSVNVTSI6ImVweXQiLCJqci0wOWwtMDZoLTA2dz1RVnhxVkx3LTZqaWFKLWJ4VjJ1OU9xR2lPS3pCRnRnbzVfNm1QaDRmUVQybXB0YUFHTWVJdkRGbHBpNkJqNTctT3FSUUtoQ0JOcy1nT0xhUzRPL21vYy50bmV0bm9jcmVzdWVsZ29vZy4zaGwvLzpzcHR0aCI6InJldm9jIiwibmVsbGFXIG5hZ3JvTSI6ImVsdGl0YnVzIiwidW9ZIG5vIGRldHNhVyI6ImVsdGl0InssfSI4SGNDMW1WUDB3cCI6ImRJb2VkaXYiLCJWVEFfRVBZVF9PRURJVl9DSVNVTSI6ImVweXQiLCJqci0wOWwtMDZoLTA2dz13a3FaMm1RQXJlMkJPZV95SHhxblNXdnNxTDlENjRHMlRFTmNodW1kUEpUNlBULVFXNlJYWENMNWFGUnN1aGpHSGFGOHp5NUplV0hIbU95L21vYy50bmV0bm9jcmVzdWVsZ29vZy4zaGwvLzpzcHR0aCI6InJldm9jIiwic29pcmFyZW1lVCBzb0wiOiJlbHRpdGJ1cyIsIm9tQSBlVCBldVEgw6lTIjoiZWx0aXQieyx9IlVZZVAySjdGM0RPIjoiZElvZWRpdiIsIlZUQV9FUFlUX09FRElWX0NJU1VNIjoiZXB5dCIsImc4SFFwd2s1NFg4NzRIam43c1BhNWZZM3BJLW0zTEp6TUE9c3ImZ1dJSmdqZ29GR0RBSkVRaGdDcVFBSUJRTEVDQU1DV0V3bXlhby09cHFzP2dwai50bHVhZmVkcWgvVVllUDJKN0YzRE8vaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwixIdpbm9WIHZhbHNpTSI6ImVsdGl0YnVzIiwidGhnaXJsQSBlQiBhbm5vRyBzJ2duaWh0eXJldkUgLSB5ZWxyYU0gYm9CIjoiZWx0aXQieyx9Im9EWXVrYWdXODNwIjoiZElvZWRpdiIsIlZUQV9FUFlUX09FRElWX0NJU1VNIjoiZXB5dCIsIndvTEdkMnJnX1k2RHZjc1ZzelFGM1VpYVktVmszTEp6TUE9c3ImZ1dJSkE2Z2dIR0VRSkVxaGdDcVFBSUJFT0VEQUpDV0V3bXlhby09cHFzP2dwai50bHVhZmVkZHMvb0RZdWthZ1c4M3AvaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwieW5udUIgZGFCIjoiZWx0aXRidXMiLCJlbHVNIHdvY3NvTSI6ImVsdGl0InssfSJvd1I3ODgzd182bCI6ImRJb2VkaXYiLCJWVEFfRVBZVF9PRURJVl9DSVNVTSI6ImVweXQiLCJqci0wOWwtMDZoLTA2dz13S0Rlb1EwS1pmNmhieVpwR2RiZGVsS2p0cjZQQUxBWUJIZDBCNWZmMldCMXlGZDZJcTBkbEp4UWR1MFRnd0xqLW0xWkR6S3QyMGNBT2ZCa0VuL21vYy50bmV0bm9jcmVzdWVsZ29vZy4zaGwvLzpzcHR0aCI6InJldm9jIiwibm90ZWxwYXRTIHNpcmhDIjoiZWx0aXRidXMiLCJ5ZWtzaWhXIGVlc3Nlbm5lVCI6ImVsdGl0InssfSIweVZXY01sM2dfQSI6ImRJb2VkaXYiLCJWVEFfRVBZVF9PRURJVl9DSVNVTSI6ImVweXQiLCJnUTU1VmtpVmxXMDc5WGpldjZ0Z0ZlQV8wcHptM0xKek1BPXNyJmdXSUpBNmdnSEdFUUpFcWhnQ3FRQUlCRU9FREFKQ1dFd215YW8tPXBxcz9ncGoudGx1YWZlZGRzLzB5VldjTWwzZ19BL2l2L21vYy5nbWl0eS5pLy86c3B0dGgiOiJyZXZvYyIsIm9kZXZldVEiOiJlbHRpdGJ1cyIsIjI1IC5sb1YgLHNub2lzc2VTIGNpc3VNIHByekIgOm9kZXZldVEiOiJlbHRpdCJ7LH0iQVNjdW9COFMwbEkiOiJkSW9lZGl2IiwiVlRBX0VQWVRfT0VESVZfQ0lTVU0iOiJlcHl0IiwiQUVzSUw2OHJXOWJ6MjZ4U3M3TWZKbG9kTzBkbTNMSnpNQT1zciZnV0lKQTZnZ0hHRVFKRXFoZ0NxUUFJQkVPRURBSkNXRXdteWFvLT1wcXM/Z3BqLnRsdWFmZWRkcy9BU2N1b0I4UzBsSS9pdi9tb2MuZ21pdHkuaS8vOnNwdHRoIjoicmV2b2MiLCJuYXJlZWhTIGRFIjoiZWx0aXRidXMiLCJzcmV2aWhTIjoiZWx0aXQieyx9IjhIYXBBaE1ZR2FzIjoiZElvZWRpdiIsIlZUQV9FUFlUX09FRElWX0NJU1VNIjoiZXB5dCIsIndTRmNaa1N4VDdkdEpnU3BvcFd6RDVKU1l4VG4zTEp6TUE9c3ImZ1dJSkE2Z2dIR0VRSkVxaGdDcVFBSUJFT0VEQUpDV0V3bXlhby09cHFzP2dwai50bHVhZmVkZHMvOEhhcEFoTVlHYXMvaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwieW5udUIgZGFCIjoiZWx0aXRidXMiLCIpZW5vZWxyb0Mgb2hjbmVoQyAudGFlZiggb3Rpbm9iIG90cm9wIGVNIjoiZWx0aXQieyx9IlE2eTR1a2szdjVIIjoiZElvZWRpdiIsIlZUQV9FUFlUX09FRElWX0NJU1VNIjoiZXB5dCIsIlFPYmhHTTJTME9jTWYwN2UxNk9WVHlkTnB1OW0zTEp6TUE9c3ImZ1dJSkE2Z2dIR0VRSkVxaGdDcVFBSUJFT0VEQUpDV0V3bXlhby09cHFzP2dwai50bHVhZmVkZHMvUTZ5NHVrazN2NUgvaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwic2VseXRTIHlycmFIIjoiZWx0aXRidXMiLCJzYVcgdEkgc0EiOiJlbHRpdCJ7LH0id1VkSjZZc0lOdVYiOiJkSW9lZGl2IiwiVlRBX0VQWVRfT0VESVZfQ0lTVU0iOiJlcHl0IiwiZ183Ti1wVlo0QkpHWWF1enpuQm9tZzF5YTJJbjNMSnpNQT1zciZnV0lKQTZnZ0hHRVFKRXFoZ0NxUUFJQkVPRURBSkNXRXdteWFvLT1wcXM/Z3BqLnRsdWFmZWRkcy93VWRKNllzSU51Vi9pdi9tb2MuZ21pdHkuaS8vOnNwdHRoIjoicmV2b2MiLCJ0Zml3UyByb2x5YVQiOiJlbHRpdGJ1cyIsImVNIGh0aVcgZ25vbGVCIHVvWSI6ImVsdGl0Intb";

///下标0us-1mx-2br
final locTop =
    "XX0iNXhBOUlwZmRRdjRvbmhCMnJnSWVwUXZ4SWlqdDJXbzNMUCI6ImRJdHNpbHlhbHAiLCI1eEE5SXBmZFF2NG9uaEIycmdJZXBRdnhJaWp0MldvM0xQTFYiOiJkSWVzd29yYiIsIlE1WHR1UXU1b1J0N1NSUjVEaXBnSU53dUZGVEJMQzRuT0E9c3ImPUVBR0NoSUFBVVJBSWt3QXBxNHF5ckZTQndMRUNBTkNYRXdteWFvLT1wcXM/Z3BqLnRsdWFmZWRxaC8wNDB4ZUluMnJrZS9pdi9tb2MuZ21pdHkuaS8vOnNwdHRoIjoicmV2b2MiLCJ5bGlhZCBsYWJvbGcgc2dub3MgcG9UIjoiZWx0aXQieyx9InhuU1VULWM3UlhEdmpCNGV6Njg1a0V6WG04azB0VHpnTFAiOiJkSXRzaWx5YWxwIiwieG5TVVQtYzdSWER2akI0ZXo2ODVrRXpYbThrMHRUemdMUExWIjoiZEllc3dvcmIiLCJRWERJempjU1NPdF9FSG1kREo3ejV6RkZxU1JCTEM0bk9BPXNyJkJBVUE0WUFHQ0FCR0lvUUFpSFFBWUhBR0NoSUFBVVJBSWt4QXBxNHF5ckZTQndMRUNBTkNuRXdteWFvLT1wcXM/Z3BqLnRsdWFmZWRxaC8wNDB4ZUluMnJrZS9pdi9tb2MuZ21pdHkuaS8vOnNwdHRoIjoicmV2b2MiLCJ5bGtlZXcgbGFib2xnIHNnbm9zIHBvVCI6ImVsdGl0InssfSItVkpWb1BxUmUyeDFLU0NHYklEdDI5SDEza19nSWtKU0xQIjoiZEl0c2lseWFscCIsIi1WSlZvUHFSZTJ4MUtTQ0diSUR0MjlIMTNrX2dJa0pTTFBMViI6ImRJZXN3b3JiIiwiUVgwTVVicDh3SFRXVWpNSHRYbUNwN3ZTUnJzRExDNG5PQT1zciZCQVVBNFlBR0NBQkdJb1FBaUhRQVlIQUdDaElBQVVSQUlreEFwcTRxeXJGU0J3TEVDQU5DbkV3bXlhby09cHFzP2dwai50bHVhZmVkcWgva1hFeTZfMF9Oc1ovaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwibmFpbGl6YXJCIHNnbm9TIHBvVCI6ImVsdGl0InssfSJOODVHRHVTb2U0ZHBBVHBUQ3Y4TlJTWDRzSGs4b1N3T0xQIjoiZEl0c2lseWFscCIsIk44NUdEdVNvZTRkcEFUcFRDdjhOUlNYNHNIazhvU3dPTFBMViI6ImRJZXN3b3JiIiwiQW1tNHhsLXNyaG5JN3RGamw3ckFYTkNyeXpBRExDNG5PQT1zciZCQVVBNFlBR0NBQkdJb1FBaUhRQVlIQUdDaElBQVVSQUlreEFwcTRxeXJGU0J3TEVDQU5DbkV3bXlhby09cHFzP2dwai50bHVhZmVkcWgvY1lHXzBuY2lteV8vaXYvbW9jLmdtaXR5LmkvLzpzcHR0aCI6InJldm9jIiwib2NpeGVNIHNnbm9TIHBvVCI6ImVsdGl0InssfSJHdU1fWEhia013NVRCeEpWRHBZNG9ONl8wRDFPVi03T0xQIjoiZEl0c2lseWFscCIsIkd1TV9YSGJrTXc1VEJ4SlZEcFk0b042XzBEMU9WLTdPTFBMViI6ImRJZXN3b3JiIiwiUTlnSllFUlVyaXJvNExtQTdmeTlEY20zb1luQkxDNG5PQT1zciY9RUFHQ2hJQUFVUkFJa3dBcHE0cXlyRlNCd0xFQ0FOQ1hFd215YW8tPXBxcz9ncGoudGx1YWZlZHFoL2MtTHdLc2I3YVBrL2l2L21vYy5nbWl0eS5pLy86c3B0dGgiOiJyZXZvYyIsInNldGF0UyBkZXRpblUgc2dub1MgcG9UIjoiZWx0aXQie1s=";

String encodeList(List data) {
  //反转后再base64
  String str = jsonEncode(data).split("").reversed.join("");
  var base64Str = base64.encode(utf8.encode(str));

  return base64Str;
}

List decodeList(String data) {
  //base64后再反转
  var str = utf8.decode(base64.decode(data));
  var jsonData = jsonDecode(str.split("").reversed.join(""));
  return jsonData;
}
