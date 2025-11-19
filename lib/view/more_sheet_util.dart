import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/uinew/main/home/u_yt_channel.dart';

import 'package:uuid/uuid.dart';

import '../api/api_main.dart';
import '../api/base_dio_api.dart';
import '../static/db_key.dart';
import '../tool/download/download_util.dart';
import '../tool/history_util.dart';
import '../tool/like/like_util.dart';
import '../tool/log.dart';
import '../tool/tba/event_util.dart';
import '../tool/toast.dart';
import '../uinew/main/home/u_artist.dart';
import '../uinew/main/home/u_play.dart';
import '../uinew/main/libray/u_loc_playlist.dart';
import '../uinew/main/u_library.dart';
import 'base_view.dart';

class MoreSheetUtil {
  MoreSheetUtil._internal();

  static final MoreSheetUtil _instance = MoreSheetUtil._internal();

  static MoreSheetUtil get instance {
    return _instance;
  }

  showVideoMoreSheet(Map item, {bool isPlayPage = false, required String clickType}) async {
    //不显示播放控件
    Get.find<UserPlayInfoController>().hideFloatingWidget();

    //判断当前播放是否是这首歌

    var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffEAE8F9), Color(0xfffafafa)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 95.w,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 40.w,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w)),
                            child: NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(child: Text(item["title"], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  ),

                  //关闭按钮
                  Positioned(
                    right: 12.w,
                    top: 12.w,
                    child: InkWell(
                      onTap: () {
                        if (clickType == "net_playlist" || clickType == "loc_playlist") {
                          EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "return"});
                        }
                        if (clickType == "artist_more_song" || clickType == "artist") {
                          EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "return"});
                        }

                        Get.back();
                      },
                      child: Image.asset("assets/oimg/icon_sheet_close.png", width: 20.w, height: 20.w),
                    ),
                  ),
                ],
              ),
            ),

            //分割线
            Container(height: 1.w, color: Color(0xff121212).withOpacity(0.05)),

            SizedBox(height: 24.w),

            //下载
            if (FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") == "on")
              Column(
                children: [
                  Obx(() {
                    var videoId = item["videoId"];

                    var state = DownloadUtils.instance.allDownLoadingData[videoId]?["state"] ?? 0;

                    double progress = DownloadUtils.instance.allDownLoadingData[videoId]?["progress"] ?? 0;

                    if (state == 1 || state == 3) {
                      //下载中
                      return InkWell(
                        onTap: () {
                          DownloadUtils.instance.remove(item["videoId"], state: state);
                        },
                        child: Container(
                          height: 40.w,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                // padding: EdgeInsets.all(5.w),
                                child: CircularProgressIndicator(value: progress, strokeWidth: 1.5, backgroundColor: Color(0xffA995FF).withOpacity(0.35), color: Color(0xffA995FF)),
                              ),
                              SizedBox(width: 16.w),
                              Text("Downloading".tr, style: TextStyle(fontSize: 14.w)),
                            ],
                          ),
                        ),
                      );
                    } else if (state == 2) {
                      //下载完成
                      return InkWell(
                        onTap: () {
                          DownloadUtils.instance.remove(item["videoId"], state: state);
                        },
                        child: Container(
                          height: 40.w,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_download_ok.png")),
                              SizedBox(width: 16.w),
                              Text("Downloaded".tr, style: TextStyle(fontSize: 14.w)),
                            ],
                          ),
                        ),
                      );
                    } else {
                      //未下载

                      return InkWell(
                        onTap: () {
                          DownloadUtils.instance.download(item["videoId"], item, clickType: clickType);
                        },
                        child: Container(
                          height: 40.w,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_download_black.png")),
                              SizedBox(width: 16.w),
                              Text("Offline".tr, style: TextStyle(fontSize: 14.w)),
                            ],
                          ),
                        ),
                      );
                    }
                  }),
                  SizedBox(height: 16.w),
                ],
              ),

            //收藏
            Obx(() {
              var videoId = item["videoId"];
              var isLike = LikeUtil.instance.allVideoMap.containsKey(videoId);
              return InkWell(
                onTap: () {
                  if (!isLike) {
                    LikeUtil.instance.likeVideo(item["videoId"], item);
                  } else {
                    LikeUtil.instance.unlikeVideo(item["videoId"]);
                  }

                  if (clickType == "net_playlist" || clickType == "loc_playlist") {
                    EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "like_song"});
                  }
                  if (clickType == "artist_more_song" || clickType == "artist") {
                    EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "like_song"});
                  }
                },
                child: Container(
                  height: 40.w,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Container(width: 24.w, height: 24.w, child: Image.asset(isLike ? "assets/oimg/icon_like_on.png" : "assets/oimg/icon_like_off.png")),
                      SizedBox(width: 16.w),
                      Text(isLike ? "Remove from library".tr : "Add to Library".tr, style: TextStyle(fontSize: 14.w)),
                    ],
                  ),
                ),
              );
            }),

            if (!isCheck)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16.w),
                  //下一个播放
                  InkWell(
                    onTap: () {
                      //获取当前播放列表
                      var isOk = Get.find<UserPlayInfoController>().addToNext(item);
                      ToastUtil.showToast(msg: isOk ? "Add ok".tr : "Already in the list".tr);
                      if (clickType == "net_playlist" || clickType == "loc_playlist") {
                        EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "play_next"});
                      }
                      if (clickType == "artist_more_song" || clickType == "artist") {
                        EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "play_next"});
                      }
                    },
                    child: Container(
                      height: 40.w,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_m_next.png")),
                          SizedBox(width: 16.w),
                          Text("Play next".tr, style: TextStyle(fontSize: 14.w)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.w),
                  //添加到播放列表
                  InkWell(
                    onTap: () {
                      //获取当前播放列表
                      var isOk = Get.find<UserPlayInfoController>().addToQueue(item);
                      ToastUtil.showToast(msg: isOk ? "Add ok".tr : "Already in the list".tr);

                      if (clickType == "net_playlist" || clickType == "loc_playlist") {
                        EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "add_queue"});
                      }
                      if (clickType == "artist_more_song" || clickType == "artist") {
                        EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "add_queue"});
                      }
                    },
                    child: Container(
                      height: 40.w,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_playlist.png")),
                          SizedBox(width: 16.w),
                          Text("Add to queue".tr, style: TextStyle(fontSize: 14.w)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 16.w),
            //添加到歌单
            InkWell(
              onTap: () {
                //获取当前播放列表
                if (clickType == "net_playlist" || clickType == "loc_playlist") {
                  EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "add_playlist"});
                }
                if (clickType == "artist_more_song" || clickType == "artist") {
                  EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "add_playlist"});
                }

                showAddList(item);
              },
              child: Container(
                height: 40.w,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_add_play.png")),
                    SizedBox(width: 16.w),
                    Text("Add to playlist".tr, style: TextStyle(fontSize: 14.w)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.w),
            //跳转到歌手
            InkWell(
              onTap: () async {
                if (clickType == "net_playlist" || clickType == "loc_playlist") {
                  EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "go_artist"});
                }
                if (clickType == "artist_more_song" || clickType == "artist") {
                  EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "go_artist"});
                }

                if (clickType == "play_playlist" || clickType == "play") {
                  EventUtils.instance.addEvent("play_page_click", data: {"song_id": item["videoId"], "station": "view_artist"});
                }
                AppLog.e(item);

                if (Get.find<Application>().typeSo == "yt") {
                  LoadingUtil.showLoading();
                  var result1 = await ApiMain.instance.getVideoInfo(item["videoId"]);
                  LoadingUtil.hideAllLoading();

                  String channelId = result1.data["videoDetails"]?["channelId"] ?? "";
                  String author = result1.data["videoDetails"]?["author"] ?? "";
                  if (channelId.isEmpty) {
                    ToastUtil.showToast(msg: "Failed to get artist".tr);
                    return;
                  }

                  AppLog.e("youtube频道");
                  AppLog.e(channelId);
                  AppLog.e(author);

                  Get.to(UserYoutubeChannel(), arguments: {"browseId": channelId, "title": item["subtitle"]});

                  return;
                }
                //   Get.to(
                //     UserYoutubeChannel(),
                //     arguments: {"browseId": browseId},
                //   );

                //请求获取歌手信息
                LoadingUtil.showLoading();
                var result = await ApiMain.instance.getVideoNext(item["videoId"]);

                if (result.code == HttpCode.success) {
                  try {
                    var browseId =
                        result
                            .data["contents"]["singleColumnMusicWatchNextResultsRenderer"]["tabbedRenderer"]["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]["playlistPanelRenderer"]["contents"][0]["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];

                    Get.back();
                    LoadingUtil.hideAllLoading();

                    await Future.delayed(Duration(milliseconds: 200));

                    EventUtils.instance.addEvent("det_artist_show", data: {"form": "song_more_go_to_artist"});

                    if (isPlayPage) {
                      // if (!isPlayPage) {
                      //   Get.find<UserPlayInfoController>().showFloatingWidget();
                      // }

                      //显示下方播放bar菜单
                      Get.find<UserPlayInfoController>().showFloatingWidget();
                      await Get.to(() => UserArtistInfo(), arguments: {"browseId": browseId});

                      Get.find<UserPlayInfoController>().hideFloatingWidget();
                      return;
                    }

                    // if (Get.find<Application>().typeSo == "yt") {
                    //   Get.to(
                    //     UserYoutubeChannel(),
                    //     arguments: {"browseId": browseId},
                    //   );
                    // } else {
                    //
                    // }
                    Get.to(UserArtistInfo(), arguments: {"browseId": browseId});
                  } catch (e) {
                    AppLog.e(e);
                    LoadingUtil.hideAllLoading();
                    ToastUtil.showToast(msg: "Failed to get artist".tr);
                  }
                } else {
                  LoadingUtil.hideAllLoading();
                  ToastUtil.showToast(msg: "Failed to get artist".tr);
                }
              },
              child: Container(
                height: 40.w,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_add_user.png")),
                    SizedBox(width: 16.w),
                    Text("Go to artist".tr, style: TextStyle(fontSize: 14.w)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.w),

            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      // barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );

    //显示播放控件
    if (!isPlayPage) {
      Get.find<UserPlayInfoController>().showFloatingWidget();
    }
  }

  showPlaylistMoreSheet(Map item) async {
    Get.find<UserPlayInfoController>().hideFloatingWidget();
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffEAE8F9), Color(0xfffafafa)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 95.w,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 40.w,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 40.w,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(width: 36.w, height: 36.w, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w), color: Color(0xffE0E0EF))),
                                ),

                                //默认封面
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 40.w,
                                    height: 40.w,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w)),
                                    child:
                                        item["cover"] == null
                                            ?
                                            //默认封面
                                            Image.asset("assets/oimg/icon_d_item.png")
                                            : NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(child: Text(item["title"], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  ),

                  //关闭按钮
                  Positioned(
                    right: 12.w,
                    top: 12.w,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Image.asset("assets/oimg/icon_sheet_close.png", width: 20.w, height: 20.w),
                    ),
                  ),
                ],
              ),
            ),

            //分割线
            Container(height: 1.w, color: Color(0xff121212).withOpacity(0.05)),

            SizedBox(height: 24.w),

            //重命名
            InkWell(
              onTap: () async {
                Get.back();
                await Future.delayed(Duration(milliseconds: 200));

                showRenameSheet(item);
              },
              child: Container(
                height: 40.w,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_rename.png")), SizedBox(width: 16.w), Text("Rename".tr, style: TextStyle(fontSize: 14.w))],
                ),
              ),
            ),

            // SizedBox(
            //   height: 16.w,
            // ),
            // //收藏
            // InkWell(
            //   onTap: () {},
            //   child: Container(
            //     height: 40.w,
            //     width: double.infinity,
            //     padding: EdgeInsets.symmetric(horizontal: 16.w),
            //     child: Row(
            //       children: [
            //         Container(
            //           width: 24.w,
            //           height: 24.w,
            //           child: Image.asset("assets/oimg/icon_like_off.png"),
            //         ),
            //         SizedBox(
            //           width: 16.w,
            //         ),
            //         Text(
            //           "Add to Library",
            //           style: TextStyle(fontSize: 14.w),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 16.w),
            //删除
            InkWell(
              onTap: () async {
                var box = await Hive.openBox(DBKey.myPlayListData);
                await box.delete(item["id"]);
                //刷新数据
                Get.find<UserLibraryController>().bindMyPlayListData();

                Get.back();
              },
              child: Container(
                height: 40.w,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [Container(width: 24.w, height: 24.w, child: Image.asset("assets/oimg/icon_del.png")), SizedBox(width: 16.w), Text("Delete".tr, style: TextStyle(fontSize: 14.w))],
                ),
              ),
            ),

            SizedBox(height: 16.w),

            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      // barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
    Get.find<UserPlayInfoController>().showFloatingWidget();
  }

  showAddList(Map addItem) async {
    //添加到自己歌单
    var box = await Hive.openBox(DBKey.myPlayListData);

    var oldList = box.values.toList();
    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });

    oldList.removeWhere((e) => e["type"] == 1);

    var list = [].obs;
    list.value = oldList;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffEAE8F9), Color(0xfffafafa)]),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text("Add to playlist".tr, style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.w500)),
                  // Spacer(),
                  // IconButton(
                  //     onPressed: () {
                  //       Get.back();
                  //     },
                  //     icon: Icon(Icons.close))
                ],
              ),
            ),
            SizedBox(height: 5.w),

            //新增歌单
            InkWell(
              onTap: () {
                showAddView(list);
              },
              child: Container(
                height: 72.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(children: [Image.asset("assets/oimg/icon_add.png", width: 56.w, height: 56.w), SizedBox(width: 22.w), Text("New list".tr)]),
              ),
            ),

            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemBuilder: (_, i) {
                    return getMyPlayList(list[i], addItem);
                  },
                  separatorBuilder: (_, i) {
                    return SizedBox(height: 10.w);
                  },
                  itemCount: list.length,
                ),
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );
  }

  void showAddView(RxList list) {
    var inputC = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffEAE8F9), Color(0xfffafafa)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text("Create playlist".tr, style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.w500))),
            SizedBox(height: 16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CupertinoTextField(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                controller: inputC,
                autofocus: true,
                placeholder: "${"Enter name".tr}\n\n\n\n",
                maxLines: 5,
                maxLength: 100,
                style: TextStyle(fontSize: 14.w),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.w), color: Colors.white),
              ),
            ),
            SizedBox(height: 32.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.w), border: Border.all(color: Color(0xff824EFF).withOpacity(0.75), width: 2.w)),
                        child: Text("Cancel".tr, style: TextStyle(fontSize: 14.w, color: Color(0xff824EFF).withOpacity(0.75))),
                      ),
                    ),
                  ),
                  SizedBox(width: 23.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (inputC.text.trim().isEmpty) {
                          ToastUtil.showToast(msg: "Enter name".tr);
                          return;
                        }
                        //保存信息
                        await savePlayList(inputC.text);

                        var box = await Hive.openBox(DBKey.myPlayListData);

                        var oldList = box.values.toList();
                        //时间降序
                        oldList.sort((a, b) {
                          DateTime aDate = a["date"];
                          DateTime bDate = b["date"];
                          return bDate.compareTo(aDate);
                        });
                        oldList.removeWhere((e) => e["type"] == 1);
                        list.value = oldList;

                        Get.back();
                      },
                      child: Container(
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xff824EFF).withOpacity(0.5), borderRadius: BorderRadius.circular(24.w)),
                        child: Text("Confirm".tr, style: TextStyle(fontSize: 14.w, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.w),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      // barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
  }

  Future savePlayList(String title) async {
    var box = await Hive.openBox(DBKey.myPlayListData);
    var id = Uuid().v8();

    //获取是否使用名字
    var nameList = box.values.map((e) => e["title"]).toList();

    var realName = getRealName(nameList, title);
    AppLog.e(realName);

    await box.put(id, {"title": realName, "date": DateTime.now(), "id": id});
  }

  String getRealName(List nameList, String name, {int nameNum = 0}) {
    if (nameNum == 0) {
      if (nameList.contains(name)) {
        return getRealName(nameList, name, nameNum: nameNum + 1);
      }
      return name;
    } else {
      if (nameList.contains("$name($nameNum)")) {
        return getRealName(nameList, name, nameNum: nameNum + 1);
      }
      return "$name($nameNum)";
    }
  }

  getMyPlayList(Map item, Map addItem) {
    List childList = item["list"] ?? [];

    return InkWell(
      onTap: () async {
        if (childList.map((e) => e["videoId"]).contains(addItem["videoId"])) {
          ToastUtil.showToast(msg: "alreadyAdd".tr);
          return;
        }

        //添加歌曲到此歌单
        childList.add(addItem);
        //设置封面
        item["cover"] = addItem["cover"];
        //保存
        var box = await Hive.openBox(DBKey.myPlayListData);

        item["list"] = childList;
        await box.put(item["id"], item);

        //刷新lib首页
        if (Get.isRegistered<UserLibraryController>()) {
          Get.find<UserLibraryController>().bindMyPlayListData();
        }

        if (Get.isRegistered<UserLocPlayListInfoController>()) {
          Get.find<UserLocPlayListInfoController>().bindData();
        }

        ToastUtil.showToast(msg: "${"addToPlaylistOk".tr}:${item["title"]}");

        HistoryUtil.instance.addHistoryPlaylist(item, isLoc: true);

        Get.back();
      },
      child: Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        height: 70.w,
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 54.w,
              child: Stack(
                children: [
                  Align(alignment: Alignment.centerRight, child: Container(width: 48.w, height: 48.w, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w), color: Color(0xffE0E0EF)))),

                  //默认封面
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 54.w,
                      height: 54.w,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w)),
                      child:
                          item["cover"] == null
                              ?
                              //默认封面
                              Image.asset("assets/oimg/icon_d_item.png")
                              : NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item["title"], style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 12.w),
                  Text("${childList.length} songs", style: TextStyle(fontSize: 12.w, color: Colors.black.withOpacity(0.5))),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            InkWell(
              onTap: () {
                MoreSheetUtil.instance.showPlaylistMoreSheet(item);
              },
              child: Container(width: 20.w, height: 20.w, child: Image.asset("assets/oimg/icon_more.png")),
            ),
          ],
        ),
      ),
    );
  }

  void showRenameSheet(Map item) {
    String lastTitle = item["title"] ?? "";

    var inputC = TextEditingController(text: lastTitle);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffEAE8F9), Color(0xfffafafa)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text("Rename playlist".tr, style: TextStyle(fontSize: 20.w))),
            SizedBox(height: 16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CupertinoTextField(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                controller: inputC,
                autofocus: true,
                placeholder: "${"Enter name".tr}\n\n\n\n",
                maxLines: 5,
                maxLength: 100,
                style: TextStyle(fontSize: 14.w),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.w), color: Colors.white),
              ),
            ),
            SizedBox(height: 32.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.w), border: Border.all(color: Color(0xff824EFF).withOpacity(0.75), width: 2.w)),
                        child: Text("Cancel".tr, style: TextStyle(fontSize: 14.w, color: Color(0xff824EFF).withOpacity(0.75))),
                      ),
                    ),
                  ),
                  SizedBox(width: 23.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (inputC.text.trim().isEmpty) {
                          ToastUtil.showToast(msg: "Enter name".tr);
                          return;
                        }
                        //保存信息
                        // await savePlayList(inputC.text);

                        var box = await Hive.openBox(DBKey.myPlayListData);

                        item["title"] = inputC.text;
                        await box.put(item["id"], item);

                        //刷新数据
                        if (Get.isRegistered<UserLibraryController>()) {
                          Get.find<UserLibraryController>().bindMyPlayListData();
                        }

                        Get.back();
                      },
                      child: Container(
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xff824EFF).withOpacity(0.5), borderRadius: BorderRadius.circular(24.w)),
                        child: Text("Confirm".tr, style: TextStyle(fontSize: 14.w, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.w),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      // barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
  }
}
