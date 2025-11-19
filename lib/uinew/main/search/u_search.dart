import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/tool/download/download_util.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/u_main.dart';
import 'package:muse_wave/view/empty_view.dart';
import 'package:muse_wave/view/more_sheet_util.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../static/db_key.dart';
import '../../../tool/ad/ad_util.dart';
import '../../../tool/dialog_util.dart';
import '../../../tool/format_data.dart';
import '../../../tool/keep_view.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../tool/toast.dart';
import '../../../view/base_view.dart';
import '../home/u_artist.dart';
import '../home/u_play.dart';
import '../home/u_play_list.dart';
//
import 'u_search_controller.dart';

class UserSearch extends GetView<UserSearchController> {
  const UserSearch({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserSearchController());
    return Container(
      decoration: const BoxDecoration(color: Colors.white, image: DecorationImage(image: AssetImage("assets/oimg/all_page_bg.png"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              Expanded(
                  child: SizedBox(
                    height: 44.w,
                    child: CupertinoTextField(
                      controller: controller.inputC,
                      focusNode: controller.inputFocusNode,
                      onChanged: (str) {
                        controller.showClearBtn.value = str.isNotEmpty;

                        if (str.isEmpty) {
                          return;
                        }
                        controller.getSearchList(str);
                      },
                      onSubmitted: (str) {
                        controller.toSearch(str);
                      },
                      autofocus: true,
                      style: TextStyle(fontSize: 12.w),
                      placeholder: "Search for music/artist/playlist".tr,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      textInputAction: TextInputAction.search,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xffA995FF), width: 1.5.w), borderRadius: BorderRadius.circular(22.w)),
                      suffix: Obx(() => controller.showClearBtn.value
                          ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.clear),
                          // child: Image.asset(
                          //   Assets.oimgIconDialogClose,
                          //   width: 20,
                          //   height: 20,
                          // ),
                        ),
                        onTap: () {
                          controller.inputC.text = "";
                          controller.showClearBtn.value = false;
                          controller.showSuggestions.value = false;
                          controller.inputFocusNode.requestFocus();

                          // controller.bindSearchWordsData();

                          //有结果上报
                          // if (controller.resultList.isNotEmpty) {
                          //   EventUtil.ins.searchResultClick(kid: "2");
                          // }

                          // controller.sourceType = "4";
                          // controller.inputC.text = "";
                          // controller.showClearBtn.value = false;
                          // controller.bindData("");
                          //
                          // //搜索页返回到中间页
                          // EventUtils.instance.addEvent("search_sh",
                          //     data: {"statuses": 1, "page_source": 4});
                        },
                      )
                          : Container(
                        height: 28.w,
                        width: 42.w,
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(color: const Color(0xffA995FF), borderRadius: BorderRadius.circular(14.w)),
                        child: Image.asset(
                          "assets/oimg/icon_search.png",
                          width: 20.w,
                          height: 20.w,
                        ),
                      )),
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text("Cancel".tr))
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }
          return PlayerBottomBarView(
            child: Stack(
              children: [
                //下方历史记录
                Positioned.fill(
                    child: Listener(
                      onPointerDown: (e) {
                        if (Get.focusScope?.hasFocus ?? false) {
                          Get.focusScope?.unfocus();
                        }
                      },
                      child: controller.obxView(
                            (state) =>
                        //搜索结果
                        Get.find<Application>().typeSo == "yt"
                            ? Obx(() => EasyRefresh(
                            onLoad: () async {
                              await controller.moreYoutubeSearch();
                              return controller.youtubeMoreToken.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
                            },
                            child: ListView.separated(
                                itemBuilder: (_, i) {
                                  return getYTItem(i);
                                },
                                separatorBuilder: (_, i) {
                                  return SizedBox(
                                    height: 10.w,
                                  );
                                },
                                itemCount: controller.ytList.length)))
                            : DefaultTabController(
                          length: controller.tabList.length,
                          child: Column(
                            key: controller.tabKey,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: TabBar(
                                  tabs: controller.tabList
                                      .map((e) => Tab(
                                    text: e,
                                  ))
                                      .toList(),
                                  onTap: (int index) {
                                    if (index == 0) {
                                      EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "all"});
                                    } else {
                                      EventUtils.instance.addEvent("search_result_click", data: {
                                        "detail_click": controller.tabEnList.length == controller.tabList.length ? controller.tabEnList[index] : controller.tabList[index],
                                      });
                                    }
                                  },
                                  isScrollable: true,
                                  labelPadding: const EdgeInsets.only(left: 12, right: 12),
                                  indicatorPadding: const EdgeInsets.only(right: 6, left: 6),
                                  indicatorWeight: 4,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  tabAlignment: TabAlignment.start,
                                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  unselectedLabelColor: Colors.black.withOpacity(0.5),
                                  labelColor: const Color(0xff8468FF),
                                  indicatorColor: const Color(0xff8468FF),
                                  labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  dividerHeight: 1,
                                  dividerColor: const Color(0xff141414).withOpacity(0.08),
                                ),
                              ),
                              Expanded(child: TabBarView(children: controller.tabList.map((e) => KeepStateView(child: getPage(e))).toList()))
                            ],
                          ),
                        ),
                        onLoading:
                        //历史记录
                        Obx(() => controller.historyList.isEmpty
                            ? Container()
                            : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 16.w,
                            ),
                            //标题
                            Row(
                              children: [
                                SizedBox(
                                  width: 12.w,
                                ),
                                Text(
                                  "History record".tr,
                                  style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Get.dialog(BaseDialog(
                                        title: "Delete".tr,
                                        content: "deleteStr".tr,
                                        lBtnText: "Cancel".tr,
                                        rBtnText: "Confirm".tr,
                                        rBtnOnTap: () async {
                                          var box = await Hive.openBox(DBKey.mySearchHistoryData);
                                          //删除全部
                                          await box.clear();
                                          controller.historyList.clear();
                                          // Get.back();
                                        },
                                        lBtnOnTap: () {
                                          // Get.back();
                                        },
                                      ));
                                    },
                                    child: Image.asset(
                                      "assets/oimg/icon_s_del.png",
                                      width: 24.w,
                                      height: 24.w,
                                    )),
                                SizedBox(
                                  width: 12.w,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            // 数据
                            Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Obx(
                                      () => ExtendedWrap(
                                    spacing: 12.w,
                                    runSpacing: 16.w,
                                    maxLines: 3,
                                    children: controller.historyList.map((e) => getHistoryItem(e)).toList(),

                                  ),
                                ))

                          ],
                        )),
                      ),
                    )),

                //上方关键词联想列表
                Positioned.fill(
                    child: Obx(() => controller.showSuggestions.value
                        ? Obx(() => Listener(
                      onPointerDown: (e) {
                        if (Get.focusScope?.hasFocus ?? false) {
                          Get.focusScope?.unfocus();
                        }
                      },
                      child: Container(
                        color: Colors.white,
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: controller.list[index]["view"],
                              onTap: () {
                                var str = controller.list[index]["text"] ?? "";
                                controller.inputC.text = str;

                                controller.showClearBtn.value = true;
                                controller.toSearch(str);
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 1.w,
                            );
                          },
                          itemCount: controller.list.length,
                        ),
                      ),
                    ))
                        : Container()))
              ],
            ),
          );
        }),
      ),
    );
  }

  getPage(String title) {
    final param = controller.getTabParams(title);
    if (title == "All".tr) {
      return ListView.builder(
        padding: EdgeInsets.only(top: 24, bottom: 60 + Get.mediaQuery.padding.bottom),
        itemBuilder: (_, i) {
          return getBigItem(i);
        },
        itemCount: controller.resultList.length,
      );
    }

    //其他显示一个listview
    if (title == "Songs".tr) {
      //歌曲列表
      return Obx(
            () {
          if (controller.songList.isEmpty) {
            return const EmotyView();
          }
          return EasyRefresh(
              onRefresh: () async {
                await controller.searchSong("", param: param);
              },
              onLoad: () async {
                await controller.moreSong(param: param);
                return controller.songNextData.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
              },
              child: ListView.separated(
                  padding: EdgeInsets.only(top: 12, bottom: 60 + Get.mediaQuery.padding.bottom),
                  itemBuilder: (_, i) {
                    return getMusicItem(controller.songList[i]);
                  },
                  separatorBuilder: (_, i) {
                    return const SizedBox();
                  },
                  itemCount: controller.songList.length));
        },
      );
    } else if (title == "Videos".tr) {
      //视频列表
      return Obx(
            () {
          if (controller.videoList.isEmpty) {
            return const EmotyView();
          }
          return EasyRefresh(
              onRefresh: () async {
                await controller.searchVideo("", param: param);
              },
              onLoad: () async {
                await controller.moreVideo(param: param);
                return controller.videoNextData.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
              },
              child: ListView.separated(
                  padding: EdgeInsets.only(top: 12, bottom: 60 + Get.mediaQuery.padding.bottom),
                  itemBuilder: (_, i) {
                    return getVideoItem(controller.videoList[i]);
                  },
                  separatorBuilder: (_, i) {
                    return const SizedBox();
                  },
                  itemCount: controller.videoList.length));
        },
      );
    } else if (title == "Artists".tr) {
      //歌手列表
      return Obx(
            () {
          if (controller.artistList.isEmpty) {
            return const EmotyView();
          }
          return EasyRefresh(
              onRefresh: () async {
                await controller.searchArtist("", param: param);
              },
              onLoad: () async {
                await controller.moreArtist(param: param);
                return controller.artistNextData.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
              },
              child: ListView.separated(
                  padding: EdgeInsets.only(top: 12, bottom: 60 + Get.mediaQuery.padding.bottom),
                  itemBuilder: (_, i) {
                    return getArtistItem(controller.artistList[i]);
                  },
                  separatorBuilder: (_, i) {
                    return const SizedBox();
                  },
                  itemCount: controller.artistList.length));
        },
      );
    } else if (title == "Albums".tr) {
      //专辑
      //   "Songs": "Canciones",
      // "Videos": "Vídeos",
      // "Albums": "Álbumes",
      // "Artists": "Artistas",
      // "playlists": "Listas de la comunidad"
      return Obx(() {
        if (controller.albumList.isEmpty) {
          return const EmotyView();
        }
        return EasyRefresh(
            onLoad: () async {
              await controller.moreAlbum(param: param);
              return controller.albumNextData.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
            },
            onRefresh: () async {
              await controller.searchAlbum("", param: param);
            },
            child: ListView.separated(
                padding: EdgeInsets.only(top: 12, bottom: 60 + Get.mediaQuery.padding.bottom),
                itemBuilder: (_, i) {
                  return getPlayListItem(controller.albumList[i]);
                },
                separatorBuilder: (_, i) {
                  return const SizedBox();
                },
                itemCount: controller.albumList.length));
      });
    } else if (title == "playlists".tr) {
      //歌单
      return Obx(
            () {
          if (controller.playlistList.isEmpty) {
            return const EmotyView();
          }
          return EasyRefresh(
              onRefresh: () async {
                await controller.searchPlaylist("", param: param);
              },
              onLoad: () async {
                await controller.morePlaylist(param: param);
                return controller.playlistNextData.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
              },
              child: ListView.separated(
                  padding: EdgeInsets.only(top: 12, bottom: 60 + Get.mediaQuery.padding.bottom),
                  itemBuilder: (_, i) {
                    return getPlayListItem(controller.playlistList[i]);
                  },
                  separatorBuilder: (_, i) {
                    return const SizedBox();
                  },
                  itemCount: controller.playlistList.length));
        },
      );
    }

    return Center(
      child: Text(title),
    );
  }

  getBigItem(int i) {
    var item = controller.resultList[i];
    // List childList = item["list"] ?? [];
    var type = item["type"];

    if (type != "MUSIC_VIDEO_TYPE_OMV" &&
        type != "MUSIC_VIDEO_TYPE_UGC" &&
        type != "MUSIC_VIDEO_TYPE_ATV" &&
        type != "MUSIC_PAGE_TYPE_PLAYLIST" &&
        type != "MUSIC_PAGE_TYPE_ALBUM" &&
        type != "MUSIC_PAGE_TYPE_ARTIST" &&
        type != "best") {
      //不支持的类型
      // AppLog.i("不支持的类型type:$type");
      return Container();
    }

    if (type == "best") {
      Map<String, dynamic> header = item["header"];
      List content = item["content"];
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xffe1e1f1).withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(bottom: 12),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
        child: Column(
          children: [
            _bestHeader(header, content),
            ...content.map((item) {
              if (item['type'] == 'more') return Container();
              return GestureDetector(
                onTap: () {
                  Debounce(500).run(() {
                    EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"]});
                    Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
                  });
                },
                child: Obx(() {
                  var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];
                  return Container(
                    height: 70,
                    decoration: BoxDecoration(color: isCheck ? const Color(0xfff7f7f7) : Colors.transparent),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                          child: NetImageView(imgUrl: item["cover"] ?? ""),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  item["title"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isCheck ? const Color(0xff8569FF) : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Obx(() {
                                      var isLike = LikeUtil.instance.allVideoMap.containsKey(item["videoId"]);
                                      if (isLike) {
                                        return Container(
                                          width: 16,
                                          height: 16,
                                          margin: const EdgeInsets.only(right: 4),
                                          child: Image.asset("assets/oimg/icon_like_on.png"),
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
                                            fontSize: 12,
                                            color: isCheck ? const Color(0xff8569FF) : Colors.black.withOpacity(0.75),
                                          ),
                                        ))
                                  ],
                                ),
                              ],
                            )),
                        const SizedBox(
                          width: 12,
                        ),
                        getDownloadAndMoreBtn(item, "search")
                      ],
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      );
    }

    return getItem(item, type);

    // return Column(
    //   children: [
    //     Container(
    //       padding: EdgeInsets.symmetric(horizontal: 12.w),
    //       child: Row(
    //         children: [
    //           Text(
    //             item["title"] ?? "",
    //             style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    //           ),
    //           const Spacer(),
    //           if (item["title"] != "Top result")
    //             InkWell(
    //               onTap: () {
    //                 if (type == "MUSIC_VIDEO_TYPE_ATV") {
    //                   controller.toIndex(1);
    //                 } else if (type == "MUSIC_VIDEO_TYPE_OMV" || type == "MUSIC_VIDEO_TYPE_UGC") {
    //                   controller.toIndex(2);
    //                 } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
    //                   controller.toIndex(4);
    //                 } else if (type == "MUSIC_PAGE_TYPE_ARTIST") {
    //                   controller.toIndex(3);
    //                 } else {
    //                   controller.toIndex(5);
    //                 }
    //               },
    //               child: Row(
    //                 children: [
    //                   Text(
    //                     "More".tr,
    //                     style: TextStyle(fontSize: 12.w, color: const Color(0xffa6a6a6)),
    //                   ),
    //                   SizedBox(
    //                     width: 4.w,
    //                   ),
    //                   Image.asset(
    //                     "assets/oimg/icon_more_right.png",
    //                     width: 12.w,
    //                     height: 12.w,
    //                   )
    //                 ],
    //               ),
    //             )
    //         ],
    //       ),
    //     ),
    //     SizedBox(
    //       height: 6.w,
    //     ),
    //     ListView.separated(
    //         padding: EdgeInsets.only(bottom: 20.w),
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         itemBuilder: (_, i) {
    //           return getItem(childList[i], type);
    //         },
    //         separatorBuilder: (_, i) {
    //           return SizedBox(
    //             height: 10.w,
    //           );
    //         },
    //         itemCount: childList.length)
    //   ],
    // );
  }

  // "title": title,
  // "subtitle": subTitle,
  // "cover": cover,
  // "videoId": vid,
  // "type": type,

  _bestHeader(Map item, List content) {
    String type = item["type"];
    bool isVideo = (type == 'MUSIC_VIDEO_TYPE_UGC' || type == 'MUSIC_VIDEO_TYPE_OMV');
    bool isArtist = type == 'MUSIC_PAGE_TYPE_ARTIST';
    bool isPlaylist = type == 'MUSIC_PAGE_TYPE_ALBUM' || type == 'MUSIC_PAGE_TYPE_PLAYLIST';
    return Obx(() {
      var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];
      return Container(
        color: isCheck ? const Color(0xfff7f7f7) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (isArtist) {
                  EventUtils.instance.addEvent("det_artist_show", data: {"form": "search"});
                  EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "artist", "artist_id": item["browseId"]});
                  Get.to(() => UserArtistInfo(), arguments: item);
                } else if (isPlaylist) {
                  EventUtils.instance.addEvent("det_playlist_show", data: {"from": "search"});
                  EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "playlist", "playlist_id": item["browseId"]});
                  Get.to(() => UserPlayListInfo(isFormSearch: true), arguments: item);
                } else {
                  EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"]});
                  Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
                }
              },
              behavior: HitTestBehavior.opaque,

              // return Container(
              //   height: 70,
              //   decoration: BoxDecoration(color: isCheck ? const Color(0xfff7f7f7) : Colors.transparent),
              child: Row(
                children: [
                  isArtist
                      ? NetImageView(
                    radius: 27,
                    imgUrl: item["cover"] ?? "",
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54,
                  )
                      : isVideo
                      ? NetImageView(
                    radius: 4,
                    imgUrl: item["cover"] ?? "",
                    fit: BoxFit.cover,
                    width: 88,
                    height: 50,
                  )
                      : NetImageView(
                    radius: 8,
                    imgUrl: item["cover"] ?? "",
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] ?? "",
                          style: TextStyle(fontSize: 14, color: isCheck ? const Color(0xff7453ff) : const Color(0xff141414), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["subtitle"] ?? "",
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: isCheck ? const Color(0xff7453ff) : const Color(0xff141414).withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                  isArtist || isPlaylist
                      ? Container(
                    padding: const EdgeInsets.all(6),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset("assets/oimg/ic_more.png"),
                    ),
                  )
                      : InkWell(
                    onTap: () {
                      if (type == "net_playlist" || type == "loc_playlist") {
                        EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "more"});
                      }
                      if (type == "artist_more_song" || type == "artist") {
                        EventUtils.instance.addEvent("det_artist_click", data: {"detail_click": "more"});
                      }

                      MoreSheetUtil.instance.showVideoMoreSheet(item, clickType: type);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset("assets/oimg/icon_more.png"),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            _getHeaderActionBtn(item, content),
          ],
        ),
      );
    });
  }

  _getHeaderActionBtn(Map item, List content) {
    String type = item["type"];
    // bool isVideo = (type == 'MUSIC_VIDEO_TYPE_UGC' || type == 'MUSIC_VIDEO_TYPE_OMV');
    bool isArtist = type == 'MUSIC_PAGE_TYPE_ARTIST';
    bool isPlaylist = type == 'MUSIC_PAGE_TYPE_ALBUM' || type == 'MUSIC_PAGE_TYPE_PLAYLIST';

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Debounce(500).run(() {
                if (isArtist || isPlaylist) {
                  if (content.isNotEmpty) {
                    final item = content.first;
                    EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"] ?? ""});
                    Get.find<UserPlayInfoController>().setDataAndPlayItem(content, item, clickType: "search", loadNextData: true);
                  } else {
                    List list = controller.resultList;
                    if (list.isNotEmpty) {
                      list.removeAt(0);
                      final item = list.first;
                      EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"] ?? ""});
                      Get.find<UserPlayInfoController>().setDataAndPlayItem(list, item, clickType: "search", loadNextData: true);
                    }
                  }
                } else {
                  EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"] ?? ""});
                  Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
                }
              });
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: const Color(0xff7453FF)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/oimg/icon_play.png",
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Play".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: (isArtist || isPlaylist)
              ? InkWell(
            onTap: () {
              Debounce(500).run(() {
                if (isPlaylist) {
                  final browseId = item["browseId"];
                  var isLike = LikeUtil.instance.allPlaylistMap.containsKey(browseId);
                  if (isLike) {
                    LikeUtil.instance.unlikeList(browseId);
                  } else {
                    LikeUtil.instance.likeList(browseId, item, "");
                  }
                  EventUtils.instance.addEvent("det_playlist_click", data: {"detail_click": "collection"});
                } else if (isArtist) {
                  final browseId = item["browseId"];
                  var isLike = LikeUtil.instance.allArtistMap.containsKey(browseId);
                  if (isLike) {
                    LikeUtil.instance.unlikeArtist(browseId);
                  } else {
                    LikeUtil.instance.likeArtist(browseId, item);
                  }
                }
              });
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xff7453FF), width: 2), color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    final browseId = item["browseId"];
                    var isLike = false;
                    if (isArtist) {
                      isLike = LikeUtil.instance.allArtistMap.containsKey(browseId);
                    } else {
                      isLike = LikeUtil.instance.allPlaylistMap.containsKey(browseId);
                    }
                    return Image.asset(isLike ? "assets/oimg/ic_like_x.png" : "assets/oimg/ic_like.png", width: 24, height: 24, color: const Color(0xff7453FF));
                  }),
                  const SizedBox(width: 8),
                  Text(
                    "like".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff7453FF)),
                  )
                ],
              ),
            ),
          )
              : InkWell(
            onTap: () {
              Debounce(500).run(() {
                var videoId = item["videoId"];
                var state = DownloadUtils.instance.allDownLoadingData[videoId]?["state"];
                if (state == 1 || state == 3) {
                  DownloadUtils.instance.remove(videoId, state: state);
                } else if (state == 2) {
                  DownloadUtils.instance.remove(videoId, state: state);
                } else {
                  DownloadUtils.instance.download(videoId, item, clickType: "search");
                }
              });
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xff7453FF), width: 2), color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    //获取下载状态
                    var videoId = item["videoId"];

                    if (DownloadUtils.instance.allDownLoadingData.containsKey(videoId)) {
                      //有添加过下载
                      var state = DownloadUtils.instance.allDownLoadingData[videoId]["state"];
                      double progress = DownloadUtils.instance.allDownLoadingData[videoId]["progress"];

                      // AppLog.e(
                      //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

                      if (state == 1 || state == 3) {
                        //下载中\下载暂停
                        return Container(
                          height: 24,
                          width: 24,
                          padding: const EdgeInsets.all(2.5),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2.5,
                            backgroundColor: const Color(0xff7453ff).withOpacity(0.35),
                            color: const Color(0xff7453ff),
                          ),
                        );
                      } else if (state == 2) {
                        return InkWell(
                          onTap: () {
                            DownloadUtils.instance.remove(videoId, state: state);
                          },
                          child: Image.asset(
                            "assets/oimg/ic_download_x.png",
                            width: 24,
                            height: 24,
                          ),
                        );
                      }
                    }

                    return Image.asset(
                      "assets/oimg/ic_download.png",
                      width: 24,
                      height: 24,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    "Offline".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff7453FF)),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  getItem(Map item, String type) {
    // if (type == "MUSIC_VIDEO_TYPE_OMV" || type == "MUSIC_VIDEO_TYPE_UGC") {
    //   //视频音乐
    //   return getVideoItem(item);
    // } else
    if (type == "MUSIC_VIDEO_TYPE_OMV" || type == "MUSIC_VIDEO_TYPE_UGC" || type == "MUSIC_VIDEO_TYPE_ATV") {
      //音乐
      return getMusicItem(item);
    } else if (type == "MUSIC_PAGE_TYPE_PLAYLIST") {
      //歌单
      return getPlayListItem(item);
    } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
      //专辑
      return getPlayListItem(item);
    } else if (type == "MUSIC_PAGE_TYPE_ARTIST") {
      //歌手
      return getArtistItem(item);
    } else {
      AppLog.e("不支持的类型:$type");
      return Container();
    }
  }

  getVideoItem(Map item) {
    // var isOK = true.obs;

    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"]});

        //添加单曲并播放
        // var pList = List.of(Get.find<UserPlayInfoController>().playList)
        //   ..add(item);
        EventUtils.instance.addEvent("play_click", data: {"song_id": item["videoId"], "song_name": item["title"], "artist_name": item["subtitle"], "playlist_id": "", "station": "search"});

        Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
        // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);
      },
      child: Obx(() {
        var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];
        return Container(
          height: 96,
          color: isCheck ? const Color(0xfff7f7f7) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 128,
                height: 72,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: NetImageView(
                          imgUrl: item["cover"] ?? "",
                          fit: BoxFit.cover,
                        )),
                    //蒙版
                    Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.black.withOpacity(0), const Color(0xff060606).withOpacity(0.75)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                        )),

                    Positioned(
                        left: 6,
                        top: 6,
                        child: isCheck
                            ? Image.asset(
                          "assets/oimg/icon_s_v_play.png",
                          width: 20,
                          height: 14,
                        )
                            : Container()),
                    Positioned(
                      bottom: 3,
                      right: 6,
                      child: Text(
                        item["timeStr"] ?? "",
                        style: const TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item["title"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isCheck ? const Color(0xffA491F7) : Colors.black),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                item["subtitle"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: isCheck ? const Color(0xffA491F7).withOpacity(0.5) : Colors.black.withOpacity(0.5)),
                              )),
                          const SizedBox(
                            width: 12,
                          ),
                          getDownloadAndMoreBtn(item, "search", iconHeight: 30)
                        ],
                      )
                    ],
                  ))
            ],
          ),
        );
      }),
    );
  }

  getMusicItem(Map item) {
    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"]});

        EventUtils.instance.addEvent("play_click", data: {"song_id": item["videoId"], "song_name": item["title"], "artist_name": item["subtitle"], "playlist_id": "", "station": "search"});

        Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
        // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);

        // var pList = List.of(Get.find<UserPlayInfoController>().playList)
        //   ..add(item);
        //
        // Get.find<UserPlayInfoController>()
        //     .setDataAndPlayItem(pList, item, clickType: "search");
        // Get.find<UserPlayInfoController>()
        //     .setDataAndPlayItem([item], item, clickType: "search");
        // Get.to(UserPlayInfo());
      },
      child: Obx(() {
        var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];

        return Container(
          height: 70,
          decoration: BoxDecoration(color: isCheck ? const Color(0xfff7f7f7) : Colors.transparent),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                child: NetImageView(
                  imgUrl: item["cover"],
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isCheck ? const Color(0xff8569FF) : Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Obx(() {
                            var isLike = LikeUtil.instance.allVideoMap.containsKey(item["videoId"]);
                            if (isLike) {
                              return Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 4),
                                child: Image.asset("assets/oimg/icon_like_on.png"),
                              );
                            }

                            return Container();
                          }),
                          // if (isLike)
                          //   Container(
                          //     width: 16,
                          //     height: 16,
                          //     margin:
                          //     EdgeInsets.only(right: 4),
                          //     child: Image.asset(
                          //         "assets/oimg/icon_like_on.png"),
                          //   ),
                          Expanded(
                              child: Text(
                                item["subtitle"] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCheck ? const Color(0xff8569FF) : Colors.black.withOpacity(0.75),
                                ),
                              ))
                        ],
                      ),
                    ],
                  )),
              const SizedBox(width: 12),
              getDownloadAndMoreBtn(item, "search")

              // Obx(() {
              //   //获取下载状态
              //   var videoId = item["videoId"];
              //
              //   if (DownloadUtils
              //       .instance.allDownLoadingData
              //       .containsKey(videoId)) {
              //     //有添加过下载
              //     var state = DownloadUtils.instance
              //         .allDownLoadingData[videoId]
              //     ["state"];
              //     double progress = DownloadUtils
              //         .instance
              //         .allDownLoadingData[videoId]
              //     ["progress"];
              //
              //     // AppLog.e(
              //     //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");
              //
              //     if (state == 1 || state == 3) {
              //       //下载中\下载暂停
              //       return InkWell(
              //         onTap: () {
              //           DownloadUtils.instance
              //               .remove(videoId);
              //         },
              //         child: Container(
              //           height: 50,
              //           padding: EdgeInsets.all(6),
              //           child: Container(
              //               width: 20,
              //               height: 20,
              //               // padding: EdgeInsets.all(5),
              //               child:
              //               CircularProgressIndicator(
              //                 value: progress,
              //                 strokeWidth: 1.5,
              //                 backgroundColor: Color(
              //                     0xffA995FF)
              //                     ithOpacity(0.35),
              //                 color:
              //                 Color(0xffA995FF),
              //               )),
              //         ),
              //       );
              //     } else if (state == 2) {
              //       return InkWell(
              //         onTap: () {
              //           DownloadUtils.instance
              //               .remove(videoId);
              //         },
              //         child: Container(
              //           height: 50.w,
              //           padding: EdgeInsets.all(6.w),
              //           child: Image.asset(
              //             "assets/oimg/icon_download_ok.png",
              //             width: 20.w,
              //             height: 20.w,
              //           ),
              //         ),
              //       );
              //     }
              //   }
              //
              //   return InkWell(
              //     onTap: () {
              //       DownloadUtils.instance.download(
              //           videoId, item,
              //           clickType: "search");
              //     },
              //     child: Container(
              //       height: 50.w,
              //       padding: EdgeInsets.all(6.w),
              //       child: Image.asset(
              //         "assets/oimg/icon_download_gray.png",
              //         width: 20.w,
              //         height: 20.w,
              //       ),
              //     ),
              //   );
              // }),
              // // SizedBox(
              // //   width: 12.w,
              // // ),
              // InkWell(
              //   onTap: () {
              //     MoreSheetUtil.instance
              //         .showVideoMoreSheet(item,
              //         clickType: "search");
              //   },
              //   child: Container(
              //     height: 50.w,
              //     padding: EdgeInsets.all(6.w),
              //     child: Container(
              //       width: 20.w,
              //       height: 20.w,
              //       child: Image.asset(
              //           "assets/oimg/icon_more.png"),
              //     ),
              //   ),
              // )
            ],
          ),
        );
      }),
    );
  }

  getPlayListItem(Map item) {
    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent("det_playlist_show", data: {"from": "search"});
        EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "playlist", "playlist_id": item["browseId"]});

        Get.to(
            UserPlayListInfo(
              isFormSearch: true,
            ),
            arguments: item);
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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.w)),
              child: NetImageView(
                imgUrl: item["cover"],
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
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
                      style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
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
                              style: TextStyle(fontSize: 12.w, color: Colors.black.withOpacity(0.75)),
                            ))
                      ],
                    ),
                  ],
                )),
            Container(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/img/icon_right.png"),
              ),
            )
          ],
        ),
      ),
    );
  }

  getArtistItem(Map item) {
    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent("det_artist_show", data: {"form": "search"});
        EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "artist", "artist_id": item["browseId"]});
        Get.to(() => UserArtistInfo(), arguments: item);
      },
      child: Container(
        height: 70.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.w)),
              child: NetAvatarView(
                imgUrl: item["cover"],
                size: 52.w,
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
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
                      style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
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
                              style: TextStyle(fontSize: 12.w, color: Colors.black.withOpacity(0.75)),
                            ))
                      ],
                    ),
                  ],
                )),
            Container(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/img/icon_right.png"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getHistoryItem(Map item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.w), color: const Color(0xffEFEFFF).withOpacity(0.5)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        child: Text(
          item["str"] ?? "",
          style: TextStyle(fontSize: 14.w),
        ),
      ),
      onTap: () {
        controller.inputC.text = item["str"];
        controller.showClearBtn.value = true;
        controller.toSearch(item["str"]);
      },
    );
  }

  Widget getYTItem(int i) {
    var item = controller.ytList[i];
    return InkWell(
      onTap: () {
        EventUtils.instance.addEvent("search_result_click", data: {"detail_click": "song", "song_id": item["videoId"]});

        //添加单曲并播放
        // var pList = List.of(Get.find<UserPlayInfoController>().playList)
        //   ..add(item);
        EventUtils.instance.addEvent("play_click", data: {"song_id": item["videoId"], "song_name": item["title"], "artist_name": item["subtitle"], "playlist_id": "", "station": "search"});

        Get.find<UserPlayInfoController>().setDataAndPlayItem([item], item, clickType: "search", loadNextData: true);
        // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);
      },
      child: Obx(() {
        var isCheck = item["videoId"] == Get.find<UserPlayInfoController>().nowData["videoId"];
        return Container(
          height: 96.w,
          color: isCheck ? const Color(0xfff7f7f7) : null,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 128.w,
                height: 72.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.w)),
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: NetImageView(
                          imgUrl: item["cover"] ?? "",
                          fit: BoxFit.cover,
                        )),
                    //蒙版
                    Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.black.withOpacity(0), const Color(0xff060606).withOpacity(0.75)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                        )),

                    Positioned(
                        left: 6.w,
                        top: 6.w,
                        child: isCheck
                            ? Image.asset(
                          "assets/oimg/icon_s_v_play.png",
                          width: 20.w,
                          height: 14.w,
                        )
                            : Container()),
                    Positioned(
                      bottom: 3.w,
                      right: 6.w,
                      child: Text(
                        item["timeStr"] ?? "",
                        style: TextStyle(fontSize: 9.w, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item["title"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500, color: isCheck ? const Color(0xffA491F7) : Colors.black),
                      ),
                      SizedBox(
                        height: 6.w,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                item["subtitle"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14.w, color: isCheck ? const Color(0xffA491F7).withOpacity(0.5) : Colors.black.withOpacity(0.5)),
                              )),
                          SizedBox(
                            width: 12.w,
                          ),
                          getDownloadAndMoreBtn(item, "search", iconHeight: 30.w)
                        ],
                      )
                    ],
                  ))
            ],
          ),
        );
      }),
    );
  }
}


// class UserSearch extends GetView<UserSearchController> {
//   const UserSearch({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Get.lazyPut(() => UserSearchController());
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         image: DecorationImage(
//           image: AssetImage("assets/oimg/all_page_bg.png"),
//           fit: BoxFit.fill,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Row(
//             children: [
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Container(
//                   height: 44.w,
//                   child: CupertinoTextField(
//                     controller: controller.inputC,
//                     focusNode: controller.inputFocusNode,
//                     onChanged: (str) {
//                       controller.showClearBtn.value = str.isNotEmpty;
//
//                       if (str.isEmpty) {
//                         return;
//                       }
//                       controller.getSearchList(str);
//                     },
//                     onSubmitted: (str) {
//                       controller.toSearch(str);
//                     },
//                     autofocus: true,
//                     style: TextStyle(fontSize: 12.w),
//                     placeholder: "Search for music/artist/playlist".tr,
//                     padding: EdgeInsets.symmetric(horizontal: 16.w),
//                     textInputAction: TextInputAction.search,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(
//                         color: Color(0xffA995FF),
//                         width: 1.5.w,
//                       ),
//                       borderRadius: BorderRadius.circular(22.w),
//                     ),
//                     suffix: Obx(
//                       () =>
//                           controller.showClearBtn.value
//                               ? GestureDetector(
//                                 behavior: HitTestBehavior.opaque,
//                                 child: Container(
//                                   margin: EdgeInsets.symmetric(horizontal: 16),
//                                   child: Icon(Icons.clear),
//                                   // child: Image.asset(
//                                   //   Assets.oimgIconDialogClose,
//                                   //   width: 20,
//                                   //   height: 20,
//                                   // ),
//                                 ),
//                                 onTap: () {
//                                   controller.inputC.text = "";
//                                   controller.showClearBtn.value = false;
//                                   controller.showSuggestions.value = false;
//
//                                   controller.inputFocusNode.requestFocus();
//
//                                   // controller.bindSearchWordsData();
//
//                                   //有结果上报
//                                   // if (controller.resultList.isNotEmpty) {
//                                   //   EventUtil.ins.searchResultClick(kid: "2");
//                                   // }
//
//                                   // controller.sourceType = "4";
//                                   // controller.inputC.text = "";
//                                   // controller.showClearBtn.value = false;
//                                   // controller.bindData("");
//                                   //
//                                   // //搜索页返回到中间页
//                                   // EventUtils.instance.addEvent("search_sh",
//                                   //     data: {"statuses": 1, "page_source": 4});
//                                 },
//                               )
//                               : Container(
//                                 height: 28.w,
//                                 width: 42.w,
//                                 padding: EdgeInsets.symmetric(vertical: 4.w),
//                                 margin: EdgeInsets.only(right: 8.w),
//                                 decoration: BoxDecoration(
//                                   color: Color(0xffA995FF),
//                                   borderRadius: BorderRadius.circular(14.w),
//                                 ),
//                                 child: Image.asset(
//                                   "assets/oimg/icon_search.png",
//                                   width: 20.w,
//                                   height: 20.w,
//                                 ),
//                               ),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Get.back();
//                 },
//                 child: Text("Cancel".tr),
//               ),
//             ],
//           ),
//         ),
//         body: Container(
//           child: Stack(
//             children: [
//               //下方历史记录
//               Positioned.fill(
//                 child: Listener(
//                   onPointerDown: (e) {
//                     if (Get.focusScope?.hasFocus ?? false) {
//                       Get.focusScope?.unfocus();
//                     }
//                   },
//                   child: controller.obxView(
//                     (state) =>
//                         //搜索结果
//                         Get.find<Application>().typeSo == "yt"
//                             ? Container(
//                               child: Obx(
//                                 () => EasyRefresh(
//                                   onLoad: () async {
//                                     await controller.moreYoutubeSearch();
//                                     return controller.youtubeMoreToken.isEmpty
//                                         ? IndicatorResult.noMore
//                                         : IndicatorResult.success;
//                                   },
//                                   child: ListView.separated(
//                                     itemBuilder: (_, i) {
//                                       return getYTItem(i);
//                                     },
//                                     separatorBuilder: (_, i) {
//                                       return SizedBox(height: 10.w);
//                                     },
//                                     itemCount: controller.ytList.length,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             : DefaultTabController(
//                               length: controller.tabList.length,
//                               child: Column(
//                                 key: controller.tabKey,
//                                 children: [
//                                   Container(
//                                     width: double.infinity,
//                                     height: 30.w,
//                                     margin: EdgeInsets.only(top: 15.w),
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 4.w,
//                                     ),
//                                     child: TabBar(
//                                       tabs:
//                                           controller.tabList
//                                               .map((e) => Tab(text: e))
//                                               .toList(),
//                                       onTap: (int index) {
//                                         if (index == 0) {
//                                           EventUtils.instance.addEvent(
//                                             "search_result_click",
//                                             data: {"detail_click": "all"},
//                                           );
//                                         }
//                                       },
//                                       isScrollable: true,
//                                       labelPadding: EdgeInsets.only(
//                                         left: 12.w,
//                                         right: 12.w,
//                                       ),
//                                       indicatorPadding: EdgeInsets.all(0),
//                                       tabAlignment: TabAlignment.start,
//                                       unselectedLabelStyle: TextStyle(
//                                         fontSize: 14.w,
//                                       ),
//                                       unselectedLabelColor: Colors.black
//                                           .withOpacity(0.5),
//                                       labelColor: Color(0xff8468FF),
//                                       indicatorColor: Color(0xff8468FF),
//                                       labelStyle: TextStyle(fontSize: 18.w),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: TabBarView(
//                                       children:
//                                           controller.tabList
//                                               .map(
//                                                 (e) => KeepStateView(
//                                                   child: getPage(e),
//                                                 ),
//                                               )
//                                               .toList(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                     onLoading:
//                     //历史记录
//                     SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           Obx(
//                             () =>
//                                 controller.historyList.isEmpty
//                                     ? Container()
//                                     : Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         SizedBox(height: 16.w),
//                                         //标题
//                                         Row(
//                                           children: [
//                                             SizedBox(width: 12.w),
//                                             Text(
//                                               "History record".tr,
//                                               style: TextStyle(
//                                                 fontSize: 20.w,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Spacer(),
//                                             GestureDetector(
//                                               behavior: HitTestBehavior.opaque,
//                                               onTap: () {
//                                                 Get.dialog(
//                                                   BaseDialog(
//                                                     title: "Delete".tr,
//                                                     content: "deleteStr".tr,
//                                                     lBtnText: "Cancel".tr,
//                                                     rBtnText: "Confirm".tr,
//                                                     rBtnOnTap: () async {
//                                                       var box = await Hive.openBox(
//                                                         DBKey
//                                                             .mySearchHistoryData,
//                                                       );
//                                                       //删除全部
//                                                       await box.clear();
//                                                       controller.historyList
//                                                           .clear();
//                                                       // Get.back();
//                                                     },
//                                                     lBtnOnTap: () {
//                                                       // Get.back();
//                                                     },
//                                                   ),
//                                                 );
//                                               },
//                                               child: Container(
//                                                 padding: EdgeInsets.all(2.w),
//                                                 child: Image.asset(
//                                                   "assets/oimg/icon_s_del.png",
//                                                   width: 20.w,
//                                                   height: 20.w,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 12.w),
//                                           ],
//                                         ),
//                                         SizedBox(height: 16.w),
//                                         // 数据
//                                         Container(
//                                           width: double.infinity,
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 12.w,
//                                           ),
//                                           child: Obx(
//                                             () => ExtendedWrap(
//                                               spacing: 12.w,
//                                               runSpacing: 16.w,
//                                               children:
//                                                   controller.historyList
//                                                       .map(
//                                                         (e) =>
//                                                             getHistoryItem(e),
//                                                       )
//                                                       .toList(),
//                                               maxLines: 3,
//
//                                               // maxLines: controller.historyExpanded.value
//                                               //     ? 100
//                                               //     : 2,
//                                               // minLines: 2,
//                                               // // overflowWidget: TextButton(
//                                               // //     onPressed: () {
//                                               // //       controller
//                                               // //           .historyExpanded
//                                               // //           .toggle();
//                                               // //     },
//                                               // //     child: Text(controller
//                                               // //             .historyExpanded
//                                               // //             .value
//                                               // //         ? "Less"
//                                               // //         : "More")),
//                                               //
//                                               // overflowWidget: GestureDetector(
//                                               //     behavior: HitTestBehavior.opaque,
//                                               //     onTap: () {
//                                               //       controller.historyExpanded.toggle();
//                                               //     },
//                                               //     child: Container(
//                                               //       height: 40.w,
//                                               //       width: 20.w,
//                                               //       alignment: Alignment.center,
//                                               //       child: Image.asset(
//                                               //         controller.historyExpanded.value
//                                               //             ? "assets/img/uimg/h_less.png"
//                                               //             : "assets/img/uimg/h_more.png",
//                                               //         width: 20.w,
//                                               //         height: 20.w,
//                                               //       ),
//                                               //     )),
//                                             ),
//                                           ),
//                                         ),
//
//                                         //数据
//                                         // Container(
//                                         //     width: double.infinity,
//                                         //     padding:
//                                         //         EdgeInsets.symmetric(horizontal: 12.w),
//                                         //     child: Obx(
//                                         //       () => ExtendedWrap(
//                                         //         spacing: 12.w,
//                                         //         runSpacing: 16.w,
//                                         //         children: controller.historyList
//                                         //             .map((e) => getHistoryItem(e))
//                                         //             .toList(),
//                                         //         maxLines: controller.historyExpanded.value
//                                         //             ? 100
//                                         //             : 2,
//                                         //         minLines: 2,
//                                         //         // overflowWidget: TextButton(
//                                         //         //     onPressed: () {
//                                         //         //       controller
//                                         //         //           .historyExpanded
//                                         //         //           .toggle();
//                                         //         //     },
//                                         //         //     child: Text(controller
//                                         //         //             .historyExpanded
//                                         //         //             .value
//                                         //         //         ? "Less"
//                                         //         //         : "More")),
//                                         //
//                                         //         overflowWidget: GestureDetector(
//                                         //             behavior: HitTestBehavior.opaque,
//                                         //             onTap: () {
//                                         //               controller.historyExpanded.toggle();
//                                         //             },
//                                         //             child: Container(
//                                         //               height: 40.w,
//                                         //               width: 20.w,
//                                         //               alignment: Alignment.center,
//                                         //               child: Image.asset(
//                                         //                 controller.historyExpanded.value
//                                         //                     ? "assets/img/uimg/h_less.png"
//                                         //                     : "assets/img/uimg/h_more.png",
//                                         //                 width: 20.w,
//                                         //                 height: 20.w,
//                                         //               ),
//                                         //             )),
//                                         //       ),
//                                         //     ))
//                                       ],
//                                     ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(vertical: 20.w),
//                             alignment: Alignment.center,
//                             child: MyNativeAdView(
//                               adKey: "pagebanner",
//                               positionKey: "search",
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               //上方关键词联想列表
//               Positioned.fill(
//                 child: Obx(
//                   () =>
//                       controller.showSuggestions.value
//                           ? Obx(
//                             () => Listener(
//                               onPointerDown: (e) {
//                                 if (Get.focusScope?.hasFocus ?? false) {
//                                   Get.focusScope?.unfocus();
//                                 }
//                               },
//                               child: Container(
//                                 color: Colors.white,
//                                 child: ListView.separated(
//                                   itemBuilder: (
//                                     BuildContext context,
//                                     int index,
//                                   ) {
//                                     return ListTile(
//                                       title: controller.list[index]["view"],
//                                       onTap: () {
//                                         var str =
//                                             controller.list[index]["text"] ??
//                                             "";
//                                         controller.inputC.text = str;
//
//                                         controller.showClearBtn.value = true;
//                                         controller.toSearch(str);
//                                       },
//                                     );
//                                   },
//                                   separatorBuilder: (
//                                     BuildContext context,
//                                     int index,
//                                   ) {
//                                     return SizedBox(height: 1.w);
//                                   },
//                                   itemCount: controller.list.length,
//                                 ),
//                               ),
//                             ),
//                           )
//                           : Container(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   getPage(String title) {
//     if (title == "All".tr) {
//       return Container(
//         child: ListView.separated(
//           padding: EdgeInsets.only(
//             top: 16.w,
//             bottom: 60.w + Get.mediaQuery.padding.bottom,
//           ),
//           itemBuilder: (_, i) {
//             return getBigItem(i);
//           },
//           separatorBuilder: (_, i) {
//             return SizedBox(height: 0);
//           },
//           itemCount: controller.resultList.length,
//         ),
//       );
//     }
//
//     //其他显示一个listview
//     if (title == "Tracks".tr) {
//       //歌曲列表
//       return Container(
//         child: Obx(
//           () => EasyRefresh(
//             onRefresh: () async {
//               await controller.searchSong("");
//             },
//             onLoad: () async {
//               await controller.moreSong();
//               return controller.songNextData.isEmpty
//                   ? IndicatorResult.noMore
//                   : IndicatorResult.success;
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.only(
//                 top: 10.w,
//                 bottom: 60.w + Get.mediaQuery.padding.bottom,
//               ),
//               itemBuilder: (_, i) {
//                 return getMusicItem(controller.songList[i]);
//               },
//               separatorBuilder: (_, i) {
//                 return SizedBox();
//               },
//               itemCount: controller.songList.length,
//             ),
//           ),
//         ),
//       );
//     } else if (title == "Video".tr) {
//       //视频列表
//       return Container(
//         child: Obx(
//           () => EasyRefresh(
//             onRefresh: () async {
//               await controller.searchVideo("");
//             },
//             onLoad: () async {
//               await controller.moreVideo();
//               return controller.videoNextData.isEmpty
//                   ? IndicatorResult.noMore
//                   : IndicatorResult.success;
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.only(
//                 top: 10.w,
//                 bottom: 60.w + Get.mediaQuery.padding.bottom,
//               ),
//               itemBuilder: (_, i) {
//                 return getVideoItem(controller.videoList[i]);
//               },
//               separatorBuilder: (_, i) {
//                 return SizedBox();
//               },
//               itemCount: controller.videoList.length,
//             ),
//           ),
//         ),
//       );
//     } else if (title == "Artist".tr) {
//       //歌手列表
//       return Container(
//         child: Obx(
//           () => EasyRefresh(
//             onRefresh: () async {
//               await controller.searchArtist("");
//             },
//             onLoad: () async {
//               await controller.moreArtist();
//               return controller.artistNextData.isEmpty
//                   ? IndicatorResult.noMore
//                   : IndicatorResult.success;
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.only(
//                 top: 10.w,
//                 bottom: 60.w + Get.mediaQuery.padding.bottom,
//               ),
//               itemBuilder: (_, i) {
//                 return getArtistItem(controller.artistList[i]);
//               },
//               separatorBuilder: (_, i) {
//                 return SizedBox();
//               },
//               itemCount: controller.artistList.length,
//             ),
//           ),
//         ),
//       );
//     } else if (title == "Album".tr) {
//       //专辑
//       return Container(
//         child: Obx(
//           () => EasyRefresh(
//             onLoad: () async {
//               await controller.moreAlbum();
//               return controller.albumNextData.isEmpty
//                   ? IndicatorResult.noMore
//                   : IndicatorResult.success;
//             },
//             onRefresh: () async {
//               await controller.searchAlbum("");
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.only(
//                 top: 10.w,
//                 bottom: 60.w + Get.mediaQuery.padding.bottom,
//               ),
//               itemBuilder: (_, i) {
//                 return getPlayListItem(controller.albumList[i]);
//               },
//               separatorBuilder: (_, i) {
//                 return SizedBox();
//               },
//               itemCount: controller.albumList.length,
//             ),
//           ),
//         ),
//       );
//     } else if (title == "Playlist".tr) {
//       //歌单
//       return Container(
//         child: Obx(
//           () => EasyRefresh(
//             onRefresh: () async {
//               await controller.searchPlaylist("");
//             },
//             onLoad: () async {
//               await controller.morePlaylist();
//               return controller.playlistNextData.isEmpty
//                   ? IndicatorResult.noMore
//                   : IndicatorResult.success;
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.only(
//                 top: 10.w,
//                 bottom: 60.w + Get.mediaQuery.padding.bottom,
//               ),
//               itemBuilder: (_, i) {
//                 return getPlayListItem(controller.playlistList[i]);
//               },
//               separatorBuilder: (_, i) {
//                 return SizedBox();
//               },
//               itemCount: controller.playlistList.length,
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Container(child: Center(child: Text(title)));
//   }
//
//   getBigItem(int i) {
//     var item = controller.resultList[i];
//     List childList = item["list"] ?? [];
//     var type = item["type"];
//
//     if (type != "MUSIC_VIDEO_TYPE_OMV" &&
//         type != "MUSIC_VIDEO_TYPE_UGC" &&
//         type != "MUSIC_VIDEO_TYPE_ATV" &&
//         type != "MUSIC_PAGE_TYPE_PLAYLIST" &&
//         type != "MUSIC_PAGE_TYPE_ALBUM" &&
//         type != "MUSIC_PAGE_TYPE_ARTIST") {
//       //不支持的类型
//       AppLog.e(type);
//       return Container();
//     }
//
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           child: Row(
//             children: [
//               Text(
//                 item["title"] ?? "",
//                 style: TextStyle(
//                   fontSize: 20.w,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//               Spacer(),
//               if (item["title"] != "Top result")
//                 InkWell(
//                   onTap: () {
//                     if (type == "MUSIC_VIDEO_TYPE_ATV") {
//                       controller.toIndex(1);
//                     } else if (type == "MUSIC_VIDEO_TYPE_OMV" ||
//                         type == "MUSIC_VIDEO_TYPE_UGC") {
//                       controller.toIndex(2);
//                     } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
//                       controller.toIndex(4);
//                     } else if (type == "MUSIC_PAGE_TYPE_ARTIST") {
//                       controller.toIndex(3);
//                     } else {
//                       controller.toIndex(5);
//                     }
//                   },
//                   child: Row(
//                     children: [
//                       Text(
//                         "More".tr,
//                         style: TextStyle(
//                           fontSize: 12.w,
//                           color: Color(0xffa6a6a6),
//                         ),
//                       ),
//                       SizedBox(width: 4.w),
//                       Image.asset(
//                         "assets/oimg/icon_more_right.png",
//                         width: 12.w,
//                         height: 12.w,
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         SizedBox(height: 6.w),
//         ListView.separated(
//           padding: EdgeInsets.only(bottom: 20.w),
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemBuilder: (_, i) {
//             return getItem(childList[i], type);
//           },
//           separatorBuilder: (_, i) {
//             return SizedBox(height: 10.w);
//           },
//           itemCount: childList.length,
//         ),
//       ],
//     );
//   }
//
//   getItem(Map item, String type) {
//     if (type == "MUSIC_VIDEO_TYPE_OMV" || type == "MUSIC_VIDEO_TYPE_UGC") {
//       //视频音乐
//       return getVideoItem(item);
//     } else if (type == "MUSIC_VIDEO_TYPE_ATV") {
//       //音乐
//       return getMusicItem(item);
//     } else if (type == "MUSIC_PAGE_TYPE_PLAYLIST") {
//       //歌单
//       return getPlayListItem(item);
//     } else if (type == "MUSIC_PAGE_TYPE_ALBUM") {
//       //专辑
//       return getPlayListItem(item);
//     } else if (type == "MUSIC_PAGE_TYPE_ARTIST") {
//       //歌手
//       return getArtistItem(item);
//     } else {
//       AppLog.e("不支持的类型");
//       AppLog.e(type);
//     }
//   }
//
//   getVideoItem(Map item) {
//     // var isOK = true.obs;
//
//     return InkWell(
//       onTap: () {
//         EventUtils.instance.addEvent(
//           "search_result_click",
//           data: {"detail_click": "song", "song_id": item["videoId"]},
//         );
//
//         //添加单曲并播放
//         // var pList = List.of(Get.find<UserPlayInfoController>().playList)
//         //   ..add(item);
//
//         EventUtils.instance.addEvent(
//           "play_click",
//           data: {
//             "song_id": item["videoId"],
//             "song_name": item["title"],
//             "artist_name": item["subtitle"],
//             "playlist_id": "",
//             "station": "search",
//           },
//         );
//
//         Get.find<UserPlayInfoController>().setDataAndPlayItem(
//           [item],
//           item,
//           clickType: "search",
//           loadNextData: true,
//         );
//
//         // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);
//       },
//       child: Obx(() {
//         var isCheck =
//             item["videoId"] ==
//             Get.find<UserPlayInfoController>().nowData["videoId"];
//         return Container(
//           height: 96.w,
//           color: isCheck ? Color(0xfff7f7f7) : null,
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Row(
//             children: [
//               Container(
//                 width: 128.w,
//                 height: 72.w,
//                 clipBehavior: Clip.hardEdge,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.w),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: NetImageView(
//                         imgUrl: item["cover"] ?? "",
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     //蒙版
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.black.withOpacity(0),
//                               Color(0xff060606).withOpacity(0.75),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     Positioned(
//                       left: 6.w,
//                       top: 6.w,
//                       child:
//                           isCheck
//                               ? Image.asset(
//                                 "assets/oimg/icon_s_v_play.png",
//                                 width: 20.w,
//                                 height: 14.w,
//                               )
//                               : Container(),
//                     ),
//                     Positioned(
//                       bottom: 3.w,
//                       right: 6.w,
//                       child: Text(
//                         item["timeStr"] ?? "",
//                         style: TextStyle(fontSize: 9.w, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       item["title"] ?? "",
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14.w,
//                         fontWeight: FontWeight.w500,
//                         color: isCheck ? Color(0xffA491F7) : Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 6.w),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item["subtitle"],
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 14.w,
//                               color:
//                                   isCheck
//                                       ? Color(0xffA491F7).withOpacity(0.5)
//                                       : Colors.black.withOpacity(0.5),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         getDownloadAndMoreBtn(item, "search", iconHeight: 30.w),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   getMusicItem(Map item) {
//     return InkWell(
//       onTap: () {
//         EventUtils.instance.addEvent(
//           "search_result_click",
//           data: {"detail_click": "song", "song_id": item["videoId"]},
//         );
//
//         EventUtils.instance.addEvent(
//           "play_click",
//           data: {
//             "song_id": item["videoId"],
//             "song_name": item["title"],
//             "artist_name": item["subtitle"],
//             "playlist_id": "",
//             "station": "search",
//           },
//         );
//
//         Get.find<UserPlayInfoController>().setDataAndPlayItem(
//           [item],
//           item,
//           clickType: "search",
//           loadNextData: true,
//         );
//         // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);
//
//         // var pList = List.of(Get.find<UserPlayInfoController>().playList)
//         //   ..add(item);
//         //
//         // Get.find<UserPlayInfoController>()
//         //     .setDataAndPlayItem(pList, item, clickType: "search");
//         // Get.find<UserPlayInfoController>()
//         //     .setDataAndPlayItem([item], item, clickType: "search");
//         // Get.to(UserPlayInfo());
//       },
//       child: Obx(() {
//         var isCheck =
//             item["videoId"] ==
//             Get.find<UserPlayInfoController>().nowData["videoId"];
//
//         return Container(
//           height: 70.w,
//           decoration: BoxDecoration(
//             color: isCheck ? Color(0xfff7f7f7) : Colors.transparent,
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Row(
//             children: [
//               Container(
//                 width: 54.w,
//                 height: 54.w,
//                 clipBehavior: Clip.hardEdge,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.w),
//                 ),
//                 child: NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Text(
//                       item["title"],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14.w,
//                         fontWeight: FontWeight.w500,
//                         color: isCheck ? Color(0xff8569FF) : Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 10.w),
//                     Row(
//                       children: [
//                         Obx(() {
//                           var isLike = LikeUtil.instance.allVideoMap
//                               .containsKey(item["videoId"]);
//                           if (isLike) {
//                             return Container(
//                               width: 16.w,
//                               height: 16.w,
//                               margin: EdgeInsets.only(right: 4.w),
//                               child: Image.asset(
//                                 "assets/oimg/icon_like_on.png",
//                               ),
//                             );
//                           }
//
//                           return Container();
//                         }),
//                         // if (isLike)
//                         //   Container(
//                         //     width: 16.w,
//                         //     height: 16.w,
//                         //     margin:
//                         //     EdgeInsets.only(right: 4.w),
//                         //     child: Image.asset(
//                         //         "assets/oimg/icon_like_on.png"),
//                         //   ),
//                         Expanded(
//                           child: Text(
//                             item["subtitle"] ?? "",
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 12.w,
//                               color:
//                                   isCheck
//                                       ? Color(0xff8569FF)
//                                       : Colors.black.withOpacity(0.75),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               getDownloadAndMoreBtn(item, "search"),
//
//               // Obx(() {
//               //   //获取下载状态
//               //   var videoId = item["videoId"];
//               //
//               //   if (DownloadUtils
//               //       .instance.allDownLoadingData
//               //       .containsKey(videoId)) {
//               //     //有添加过下载
//               //     var state = DownloadUtils.instance
//               //         .allDownLoadingData[videoId]
//               //     ["state"];
//               //     double progress = DownloadUtils
//               //         .instance
//               //         .allDownLoadingData[videoId]
//               //     ["progress"];
//               //
//               //     // AppLog.e(
//               //     //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");
//               //
//               //     if (state == 1 || state == 3) {
//               //       //下载中\下载暂停
//               //       return InkWell(
//               //         onTap: () {
//               //           DownloadUtils.instance
//               //               .remove(videoId);
//               //         },
//               //         child: Container(
//               //           height: 50.w,
//               //           padding: EdgeInsets.all(6.w),
//               //           child: Container(
//               //               width: 20.w,
//               //               height: 20.w,
//               //               // padding: EdgeInsets.all(5.w),
//               //               child:
//               //               CircularProgressIndicator(
//               //                 value: progress,
//               //                 strokeWidth: 1.5,
//               //                 backgroundColor: Color(
//               //                     0xffA995FF)
//               //                     .withOpacity(0.35),
//               //                 color:
//               //                 Color(0xffA995FF),
//               //               )),
//               //         ),
//               //       );
//               //     } else if (state == 2) {
//               //       return InkWell(
//               //         onTap: () {
//               //           DownloadUtils.instance
//               //               .remove(videoId);
//               //         },
//               //         child: Container(
//               //           height: 50.w,
//               //           padding: EdgeInsets.all(6.w),
//               //           child: Image.asset(
//               //             "assets/oimg/icon_download_ok.png",
//               //             width: 20.w,
//               //             height: 20.w,
//               //           ),
//               //         ),
//               //       );
//               //     }
//               //   }
//               //
//               //   return InkWell(
//               //     onTap: () {
//               //       DownloadUtils.instance.download(
//               //           videoId, item,
//               //           clickType: "search");
//               //     },
//               //     child: Container(
//               //       height: 50.w,
//               //       padding: EdgeInsets.all(6.w),
//               //       child: Image.asset(
//               //         "assets/oimg/icon_download_gray.png",
//               //         width: 20.w,
//               //         height: 20.w,
//               //       ),
//               //     ),
//               //   );
//               // }),
//               // // SizedBox(
//               // //   width: 12.w,
//               // // ),
//               // InkWell(
//               //   onTap: () {
//               //     MoreSheetUtil.instance
//               //         .showVideoMoreSheet(item,
//               //         clickType: "search");
//               //   },
//               //   child: Container(
//               //     height: 50.w,
//               //     padding: EdgeInsets.all(6.w),
//               //     child: Container(
//               //       width: 20.w,
//               //       height: 20.w,
//               //       child: Image.asset(
//               //           "assets/oimg/icon_more.png"),
//               //     ),
//               //   ),
//               // )
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   getPlayListItem(Map item) {
//     return InkWell(
//       onTap: () {
//         EventUtils.instance.addEvent(
//           "det_playlist_show",
//           data: {"from": "search"},
//         );
//         EventUtils.instance.addEvent(
//           "search_result_click",
//           data: {"detail_click": "playlist", "playlist_id": item["browseId"]},
//         );
//
//         Get.to(UserPlayListInfo(isFormSearch: true), arguments: item);
//       },
//       child: Container(
//         height: 70.w,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: Row(
//           children: [
//             Container(
//               width: 54.w,
//               height: 54.w,
//               clipBehavior: Clip.hardEdge,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6.w),
//               ),
//               child: NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Text(
//                     item["title"],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 14.w,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 10.w),
//                   Row(
//                     children: [
//                       // if (isLike)
//                       //   Container(
//                       //     width: 16.w,
//                       //     height: 16.w,
//                       //     margin:
//                       //     EdgeInsets.only(right: 4.w),
//                       //     child: Image.asset(
//                       //         "assets/oimg/icon_like_on.png"),
//                       //   ),
//                       Expanded(
//                         child: Text(
//                           item["subtitle"] ?? "",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12.w,
//                             color: Colors.black.withOpacity(0.75),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   getArtistItem(Map item) {
//     return InkWell(
//       onTap: () {
//         EventUtils.instance.addEvent(
//           "det_artist_show",
//           data: {"form": "search"},
//         );
//         EventUtils.instance.addEvent(
//           "search_result_click",
//           data: {"detail_click": "artist", "artist_id": item["browseId"]},
//         );
//         Get.to(UserArtistInfo(), arguments: item);
//       },
//       child: Container(
//         height: 70.w,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: Row(
//           children: [
//             Container(
//               width: 54.w,
//               height: 54.w,
//               clipBehavior: Clip.hardEdge,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6.w),
//               ),
//               child: NetAvatarView(imgUrl: item["cover"], size: 52.w),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Text(
//                     item["title"],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 14.w,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 10.w),
//                   Row(
//                     children: [
//                       // if (isLike)
//                       //   Container(
//                       //     width: 16.w,
//                       //     height: 16.w,
//                       //     margin:
//                       //     EdgeInsets.only(right: 4.w),
//                       //     child: Image.asset(
//                       //         "assets/oimg/icon_like_on.png"),
//                       //   ),
//                       Expanded(
//                         child: Text(
//                           item["subtitle"] ?? "",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12.w,
//                             color: Colors.black.withOpacity(0.75),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget getHistoryItem(Map item) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.w),
//           color: Color(0xffEFEFFF).withOpacity(0.5),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
//         child: Text(item["str"] ?? "", style: TextStyle(fontSize: 14.w)),
//       ),
//       onTap: () {
//         controller.inputC.text = item["str"];
//         controller.showClearBtn.value = true;
//         controller.toSearch(item["str"]);
//       },
//     );
//   }
//
//   Widget getYTItem(int i) {
//     var item = controller.ytList[i];
//     return InkWell(
//       onTap: () {
//         EventUtils.instance.addEvent(
//           "search_result_click",
//           data: {"detail_click": "song", "song_id": item["videoId"]},
//         );
//
//         //添加单曲并播放
//         // var pList = List.of(Get.find<UserPlayInfoController>().playList)
//         //   ..add(item);
//         EventUtils.instance.addEvent(
//           "play_click",
//           data: {
//             "song_id": item["videoId"],
//             "song_name": item["title"],
//             "artist_name": item["subtitle"],
//             "playlist_id": "",
//             "station": "search",
//           },
//         );
//
//         Get.find<UserPlayInfoController>().setDataAndPlayItem(
//           [item],
//           item,
//           clickType: "search",
//           loadNextData: true,
//         );
//         // Get.find<UserPlayInfoController>().addToNext(item, isPlayItem: true);
//       },
//       child: Obx(() {
//         var isCheck =
//             item["videoId"] ==
//             Get.find<UserPlayInfoController>().nowData["videoId"];
//         return Container(
//           height: 96.w,
//           color: isCheck ? Color(0xfff7f7f7) : null,
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Row(
//             children: [
//               Container(
//                 width: 128.w,
//                 height: 72.w,
//                 clipBehavior: Clip.hardEdge,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.w),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: NetImageView(
//                         imgUrl: item["cover"] ?? "",
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     //蒙版
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.black.withOpacity(0),
//                               Color(0xff060606).withOpacity(0.75),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     Positioned(
//                       left: 6.w,
//                       top: 6.w,
//                       child:
//                           isCheck
//                               ? Image.asset(
//                                 "assets/oimg/icon_s_v_play.png",
//                                 width: 20.w,
//                                 height: 14.w,
//                               )
//                               : Container(),
//                     ),
//                     Positioned(
//                       bottom: 3.w,
//                       right: 6.w,
//                       child: Text(
//                         item["timeStr"] ?? "",
//                         style: TextStyle(fontSize: 9.w, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       item["title"] ?? "",
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14.w,
//                         fontWeight: FontWeight.w500,
//                         color: isCheck ? Color(0xffA491F7) : Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 6.w),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item["subtitle"],
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 14.w,
//                               color:
//                                   isCheck
//                                       ? Color(0xffA491F7).withOpacity(0.5)
//                                       : Colors.black.withOpacity(0.5),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         getDownloadAndMoreBtn(item, "search", iconHeight: 30.w),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }
//
// class UserSearchController extends GetxController with StateMixin {
//   var list = [].obs;
//   var historyList = [].obs;
//   //搜索结果
//   var resultList = [];
//   var tabList = [].obs;
//
//   var showSuggestions = false.obs;
//
//   var tabKey = GlobalKey();
//
//   var inputC = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//     bindHistoryData();
//
//     //好评引导
//     MyDialogUtils.instance.showRateDialog();
//
//     EventUtils.instance.addEvent("search_home");
//   }
//
//   void getSearchList(String str) async {
//     BaseModel result = await ApiMain.instance.getSearchList(str);
//     if (result.code == HttpCode.success) {
//       //解析搜索联想词
//
//       //第一条为联想词，第二条为有图片的联想
//       List oldList =
//           result
//               .data["contents"]
//               .first["searchSuggestionsSectionRenderer"]["contents"];
//       var newList = [];
//       for (var item in oldList) {
//         List childTextList =
//             item["searchSuggestionRenderer"]["suggestion"]["runs"];
//         var itemTextView = RichText(
//           text: TextSpan(
//             children:
//                 childTextList
//                     .map(
//                       (e) => TextSpan(
//                         text: e["text"],
//                         style: TextStyle(
//                           fontSize: 14.w,
//                           color: Colors.black,
//                           fontWeight:
//                               e["bold"] == true
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                         ),
//                       ),
//                     )
//                     .toList(),
//           ),
//         );
//         var itemText =
//             item["searchSuggestionRenderer"]["navigationEndpoint"]["searchEndpoint"]["query"];
//
//         newList.add({"view": itemTextView, "text": itemText});
//       }
//       list.value = newList;
//       showSuggestions.value = list.isNotEmpty;
//     }
//   }
//
//   saveHistory(String data) async {
//     var box = await Hive.openBox(DBKey.mySearchHistoryData);
//
//     if (data.isEmpty) {
//       return;
//     }
//
//     await box.put(data, {"str": data, "date": DateTime.now()});
//
//     bindHistoryData();
//   }
//
//   Future bindHistoryData() async {
//     var box = await Hive.openBox(DBKey.mySearchHistoryData);
//     var oldList = box.values.toList();
//
//     //时间降序
//     oldList.sort((a, b) {
//       DateTime aDate = a["date"];
//       DateTime bDate = b["date"];
//       return bDate.compareTo(aDate);
//     });
//     if (oldList.length > 10) {
//       historyList.value = oldList.sublist(0, 10);
//     } else {
//       historyList.value = oldList;
//     }
//
//     AppLog.e("共有以下条数历史记录");
//     AppLog.e(historyList.length);
//   }
//
//   String youtubeMoreToken = "";
//   void toSearch(String str) async {
//     //收起键盘
//     Get.focusScope?.unfocus();
//
//     await Future.delayed(Duration(milliseconds: 500));
//
//     EventUtils.instance.addEvent("search_content", data: {"content": str});
//
//     LoadingUtil.showLoading();
//     //保存搜索历史记录
//     saveHistory(str);
//
//     if (Get.find<Application>().typeSo == "yt") {
//       //youtube的搜索
//
//       var result = await ApiMain.instance.youtubeSearch(str);
//       showSuggestions.value = false;
//       lastWords = str;
//       LoadingUtil.hideAllLoading();
//       if (result.code != HttpCode.success) {
//         change("", status: RxStatus.error());
//         return;
//       }
//
//       //解析数据
//       var oldList =
//           result
//               .data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"] ??
//           [];
//       //更多数据token
//       try {
//         youtubeMoreToken =
//             result
//                 .data["contents"]["twoColumnSearchResultsRenderer"]["primaryContents"]["sectionListRenderer"]["contents"][1]["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
//             "";
//       } catch (e) {
//         print(e);
//         youtubeMoreToken = "";
//       }
//
//       var newList = [];
//       for (Map item in oldList) {
//         if (item.containsKey("videoRenderer")) {
//           //视频
//           AppLog.e(item);
//
//           var videoId = item["videoRenderer"]["videoId"];
//           var cover =
//               item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
//           var title = item["videoRenderer"]["title"]["runs"][0]["text"];
//           var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
//           var timeStr =
//               item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
//
//           newList.add({
//             "title": title,
//             "subtitle": subtitle,
//             "cover": cover,
//             "videoId": videoId,
//             "timeStr": timeStr,
//             "type": "Video",
//           });
//         } else {
//           //reelShelfRenderer
//           //lockupViewModel
//           //shelfRenderer
//           //channelRenderer
//
//           AppLog.e(item.keys);
//         }
//       }
//
//       ytList.value = newList;
//       change("", status: RxStatus.success());
//
//       EventUtils.instance.addEvent("search_result");
//
//       return;
//     }
//
//     //设置上方tab
//     tabList.value = ["All".tr];
//     tabList.addAll([
//       "Tracks".tr,
//       "Video".tr,
//       "Artist".tr,
//       "Album".tr,
//       "Playlist".tr,
//     ]);
//
//     //清空搜索记录
//     resultList.clear();
//     //搜索结果
//     var result = await ApiMain.instance.getSearchResult(str);
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       var oldList =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"];
//
//       for (Map item in oldList) {
//         if (item.containsKey("musicCardShelfRenderer")) {
//           //精准搜索
//           String bigTitle =
//               item["musicCardShelfRenderer"]["header"]["musicCardShelfHeaderBasicRenderer"]["title"]["runs"][0]["text"];
//           // List childList = item["musicShelfRenderer"]["contents"];
//
//           var childTitle =
//               item["musicCardShelfRenderer"]["title"]["runs"][0]["text"];
//
//           List childSubtitleList =
//               item["musicCardShelfRenderer"]["subtitle"]["runs"];
//           var childSubtitle = childSubtitleList
//               .map((e) => e["text"])
//               .toList()
//               .join("");
//
//           var cover =
//               item["musicCardShelfRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                   .last["url"];
//
//           try {
//             var type =
//                 item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["watchEndpointMusicSupportedConfigs"]["watchEndpointMusicConfig"]["musicVideoType"];
//             var videoId =
//                 item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["watchEndpoint"]["videoId"];
//             resultList.add({
//               "title": bigTitle,
//               "list": [
//                 {
//                   "title": childTitle,
//                   "subtitle": childSubtitle,
//                   "cover": cover,
//                   "videoId": videoId,
//                   "type": type,
//                 },
//               ],
//               "type": type,
//             });
//           } catch (e) {
//             print(e);
//
//             var type =
//                 item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseEndpointContextSupportedConfigs"]["browseEndpointContextMusicConfig"]["pageType"];
//             var browseId =
//                 item["musicCardShelfRenderer"]["title"]["runs"][0]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//             resultList.add({
//               "title": bigTitle,
//               "list": [
//                 {
//                   "title": childTitle,
//                   "subtitle": childSubtitle,
//                   "cover": cover,
//                   "browseId": browseId,
//                   "type": type,
//                 },
//               ],
//               "type": type,
//             });
//           }
//
//           continue;
//         }
//
//         if (item.containsKey("itemSectionRenderer")) {
//           //didYouMean，没有内容
//           continue;
//         }
//
//         //列表
//         String bigTitle =
//             item["musicShelfRenderer"]["title"]["runs"][0]["text"];
//         List childList = item["musicShelfRenderer"]["contents"];
//
//         //解析childList
//         var newChildList = FormatMyData.instance.getAllSearchList(childList);
//         resultList.add({
//           "title": bigTitle,
//           "list": newChildList,
//           "type": newChildList.first["type"],
//         });
//       }
//
//       // AppLog.e(resultList);
//
//       showSuggestions.value = false;
//       change("", status: RxStatus.success());
//
//       EventUtils.instance.addEvent("search_result");
//     } else {
//       showSuggestions.value = false;
//       change("", status: RxStatus.error());
//     }
//
//     lastWords = str;
//     LoadingUtil.hideAllLoading();
//
//     await searchOtherList(str);
//   }
//
//   Future moreYoutubeSearch() async {
//     AppLog.e(youtubeMoreToken);
//
//     if (youtubeMoreToken.isEmpty) {
//       AppLog.e("没有更多了");
//       return;
//     }
//
//     var str = lastWords;
//
//     var result = await ApiMain.instance.youtubeSearch(
//       str,
//       continuation: youtubeMoreToken,
//     );
//     showSuggestions.value = false;
//     lastWords = str;
//     LoadingUtil.hideAllLoading();
//     if (result.code != HttpCode.success) {
//       change("", status: RxStatus.error());
//       return;
//     }
//
//     //解析数据
//
//     var oldList =
//         result
//             .data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][0]["itemSectionRenderer"]["contents"] ??
//         [];
//     //更多数据token
//     try {
//       youtubeMoreToken =
//           result
//               .data["onResponseReceivedCommands"][0]["appendContinuationItemsAction"]["continuationItems"][1]["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ??
//           "";
//     } catch (e) {
//       print(e);
//       youtubeMoreToken = "";
//     }
//
//     var newList = [];
//     for (Map item in oldList) {
//       if (item.containsKey("videoRenderer")) {
//         //视频
//         var videoId = item["videoRenderer"]["videoId"];
//         var cover =
//             item["videoRenderer"]["thumbnail"]["thumbnails"][0]["url"] ?? "";
//         var title = item["videoRenderer"]["title"]["runs"][0]["text"];
//         var subtitle = item["videoRenderer"]["ownerText"]["runs"][0]["text"];
//         var timeStr = item["videoRenderer"]["lengthText"]?["simpleText"] ?? "";
//         newList.add({
//           "title": title,
//           "subtitle": subtitle,
//           "cover": cover,
//           "videoId": videoId,
//           "timeStr": timeStr,
//           "type": "Video",
//         });
//       } else {
//         AppLog.e(item.keys);
//       }
//     }
//
//     ytList.addAll(newList);
//   }
//
//   Future searchOtherList(String str) async {
//     await Future.wait([
//       searchSong(str),
//       searchVideo(str),
//       searchArtist(str),
//       searchAlbum(str),
//       searchPlaylist(str),
//     ]);
//   }
//
//   var songList = [].obs;
//   var songNextData = {};
//   var videoList = [].obs;
//   var videoNextData = {};
//   var artistList = [].obs;
//   var artistNextData = {};
//   var albumList = [].obs;
//   var albumNextData = {};
//   var playlistList = [].obs;
//   var playlistNextData = {};
//
//   var lastWords = "";
//
//   var ytList = [].obs;
//
//   var inputFocusNode = FocusNode();
//   var showClearBtn = false.obs;
//   Future searchSong(String str) async {
//     //搜索结果
//     songList.clear();
//     songNextData = {};
//     BaseModel result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIIAWoMEAMQBBAOEAoQCRAF",
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList = [];
//
//       List contents =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ??
//           [];
//       for (Map item in contents) {
//         if (item.containsKey("musicShelfRenderer")) {
//           oldList = item["musicShelfRenderer"]?["contents"] ?? [];
//           songNextData =
//               item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ??
//               {};
//         }
//       }
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         // var childSubtitle =
//         //     childSubtitleList.map((e) => e["text"]).toList().join("");
//         var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         var videoId =
//             item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "videoId": videoId,
//           "type": "",
//         });
//       }
//       songList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future moreSong() async {
//     if (songNextData.isEmpty) {
//       return;
//     }
//
//     var result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIIAWoMEAMQBBAOEAoQCRAF",
//       nextData: songNextData,
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["contents"] ??
//           [];
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       songNextData =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ??
//           {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         var videoId =
//             item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "videoId": videoId,
//           "type": "",
//         });
//       }
//       songList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future searchVideo(String str) async {
//     videoList.clear();
//     videoNextData = {};
//     BaseModel result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIQAWoMEAMQBBAOEAoQCRAF",
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList = [];
//
//       List contents =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ??
//           [];
//       for (Map item in contents) {
//         if (item.containsKey("musicShelfRenderer")) {
//           oldList = item["musicShelfRenderer"]?["contents"] ?? [];
//           videoNextData =
//               item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ??
//               {};
//         }
//       }
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         // var childSubtitle =
//         //     childSubtitleList.map((e) => e["text"]).toList().join("");
//         var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
//         var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         var videoId =
//             item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "timeStr": timeStr,
//           "videoId": videoId,
//           "type": "",
//         });
//       }
//       videoList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future moreVideo() async {
//     if (videoNextData.isEmpty) {
//       return;
//     }
//
//     var result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIQAWoMEAMQBBAOEAoQCRAF",
//       nextData: videoNextData,
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["contents"] ??
//           [];
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       videoNextData =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ??
//           {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         // var childSubtitle =
//         //     childSubtitleList.map((e) => e["text"]).toList().join("");
//         var childSubtitle = childSubtitleList.firstOrNull?["text"] ?? "";
//         var timeStr = childSubtitleList.lastOrNull?["text"] ?? "";
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         var videoId =
//             item["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "videoId": videoId,
//           "timeStr": timeStr,
//           "type": "",
//         });
//       }
//       videoList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future searchArtist(String str) async {
//     artistList.clear();
//     artistNextData = {};
//     BaseModel result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIgAWoMEAMQBBAOEAoQCRAF",
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList = [];
//
//       List contents =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ??
//           [];
//       for (Map item in contents) {
//         if (item.containsKey("musicShelfRenderer")) {
//           oldList = item["musicShelfRenderer"]?["contents"] ?? [];
//           artistNextData =
//               item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ??
//               {};
//         }
//       }
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         //     ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       artistList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future moreArtist() async {
//     if (artistNextData.isEmpty) {
//       return;
//     }
//
//     var result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIgAWoMEAMQBBAOEAoQCRAF",
//       nextData: artistNextData,
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["contents"] ??
//           [];
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       artistNextData =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ??
//           {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         // ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       artistList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future searchAlbum(String str) async {
//     albumList.clear();
//     albumNextData = {};
//     BaseModel result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIYAWoMEAMQBBAOEAoQCRAF",
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList = [];
//
//       List contents =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ??
//           [];
//       for (Map item in contents) {
//         if (item.containsKey("musicShelfRenderer")) {
//           oldList = item["musicShelfRenderer"]?["contents"] ?? [];
//           albumNextData =
//               item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ??
//               {};
//         }
//       }
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       // albumNextData = result.data["contents"]["tabbedSearchResultsRenderer"]
//       //                 ["tabs"][0]["tabRenderer"]["content"]
//       //             ["sectionListRenderer"]["contents"][0]["musicShelfRenderer"]
//       //         ["continuations"]?[0]["nextContinuationData"] ??
//       //     {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         //     ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       albumList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future moreAlbum() async {
//     if (albumNextData.isEmpty) {
//       return;
//     }
//
//     var result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgWKAQIYAWoMEAMQBBAOEAoQCRAF",
//       nextData: albumNextData,
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["contents"] ??
//           [];
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       albumNextData =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ??
//           {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         // ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       albumList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future searchPlaylist(String str) async {
//     playlistList.clear();
//     playlistNextData = {};
//     BaseModel result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=",
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList = [];
//
//       List contents =
//           result
//               .data["contents"]["tabbedSearchResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"] ??
//           [];
//       for (Map item in contents) {
//         if (item.containsKey("musicShelfRenderer")) {
//           oldList = item["musicShelfRenderer"]?["contents"] ?? [];
//           playlistNextData =
//               item["musicShelfRenderer"]["continuations"]?[0]["nextContinuationData"] ??
//               {};
//         }
//       }
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         //     ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       playlistList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   Future morePlaylist() async {
//     if (playlistNextData.isEmpty) {
//       return;
//     }
//
//     var result = await ApiMain.instance.getSearchResult(
//       lastWords,
//       params: "EgeKAQQoAEABagwQAxAEEA4QChAJEAU=",
//       nextData: playlistNextData,
//     );
//
//     if (result.code == HttpCode.success) {
//       //解析搜索结果
//       List oldList =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["contents"] ??
//           [];
//
//       if (oldList.isEmpty) {
//         return;
//       }
//
//       playlistNextData =
//           result
//               .data["continuationContents"]["musicShelfContinuation"]["continuations"]?[0]["nextContinuationData"] ??
//           {};
//
//       var childList = [];
//       for (Map item in oldList) {
//         var childTitle =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][0]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"][0]["text"];
//
//         List childSubtitleList =
//             item["musicResponsiveListItemRenderer"]["flexColumns"][1]["musicResponsiveListItemFlexColumnRenderer"]["text"]["runs"];
//         var childSubtitle = childSubtitleList
//             .map((e) => e["text"])
//             .toList()
//             .join("");
//
//         var cover =
//             item["musicResponsiveListItemRenderer"]["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
//                 .last["url"];
//         // var videoId = item["musicResponsiveListItemRenderer"]
//         // ["playlistItemData"]["videoId"];
//
//         var browseId =
//             item["musicResponsiveListItemRenderer"]["navigationEndpoint"]["browseEndpoint"]["browseId"];
//         childList.add({
//           "title": childTitle,
//           "subtitle": childSubtitle,
//           "cover": cover,
//           "browseId": browseId,
//           "type": "",
//         });
//       }
//       playlistList.addAll(childList);
//     } else {
//       AppLog.e("请求失败");
//     }
//   }
//
//   toIndex(int index) {
//     DefaultTabController.of(tabKey.currentContext!).animateTo(index);
//   }
// }
