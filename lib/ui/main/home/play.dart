import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:uuid/uuid.dart';

import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import '../../../tool/toast.dart';
import '../home.dart';
import 'add_list.dart';
import 'add_lyrics.dart';
import 'create_music_lyrics.dart';
import 'list_info.dart';
import 'lyrics_info.dart';

class PlayPage extends GetView<PlayPageController> {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.lazyPut(() => PlayPageController());
    controller.hideFloatingWidget();

    return WillPopScope(
      onWillPop: () async {
        controller.showFloatingWidget();
        return true;
      },
      child: BasePage(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              AppBar(
                leading: IconButton(
                  onPressed: () {
                    Get.back();
                    controller.showFloatingWidget();
                  },
                  icon: Icon(Icons.expand_more),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.tabIndex.value = 0;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                            child: Obx(
                              () => Text(
                                "Song",
                                style: TextStyle(
                                  color:
                                      controller.tabIndex.value == 0
                                          ? Color(0xff141414)
                                          : Color(0xff141414).withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 2.w,
                          height: 14.w,
                          color: Color(0xff141414).withOpacity(0.15),
                        ),
                        InkWell(
                          onTap: () {
                            controller.tabIndex.value = 1;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                            child: Obx(
                              () => Text(
                                "Lyrics",
                                style: TextStyle(
                                  color:
                                      controller.tabIndex.value == 1
                                          ? Color(0xff141414)
                                          : Color(0xff141414).withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Obx(
                        () =>
                            controller.tabIndex.value == 0
                                ? Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Container(
                                      //   width: 327.w,
                                      //   height: 327.w,
                                      //   color: Colors.grey,
                                      // ),
                                      Obx(() {
                                        Uint8List? cover =
                                            controller.nowData["cover"];

                                        return Container(
                                          height: 327.w,
                                          width: 327.w,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15.w,
                                            ),
                                          ),
                                          child:
                                              cover == null
                                                  ? Image.asset(
                                                    Assets.imgIconPcover,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.memory(
                                                    cover,
                                                    fit: BoxFit.cover,
                                                  ),
                                        );
                                      }),

                                      SizedBox(height: 24.w),

                                      Container(
                                        width: 327.w,
                                        child: Obx(() {
                                          return TextScroll(
                                            (controller.nowData["title"]
                                                        ?.toString() ??
                                                    "")
                                                .replaceAll("\n", ""),
                                            // maxLines: 2,
                                            // overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 22.w),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                )
                                : Obx(() {
                                  return Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 327.w,
                                          width: 327.w,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 30.w,
                                            vertical: 10.w,
                                          ),
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15.w,
                                            ),
                                            color: Color(0xffF3F3F3),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Container(
                                              width: double.infinity,

                                              // height: 300.w,
                                              // color: Colors.green,
                                              // margin:
                                              //     EdgeInsets.symmetric(horizontal: 30.w),
                                              // constraints:
                                              //     BoxConstraints(maxHeight: 300.w),
                                              alignment: Alignment.center,
                                              child: Text(
                                                controller.nowData["lyrics"] ??
                                                    "No lyrics",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14.w,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Text(
                                          //   "No lyrics",
                                          //   style: TextStyle(
                                          //       fontSize: 14.w,
                                          //       color: Color(0xff141414)
                                          //           .withOpacity(0.5)),
                                          // ),
                                        ),
                                        SizedBox(height: 24.w),
                                        Container(
                                          width: 327.w,
                                          child: Obx(() {
                                            return TextScroll(
                                              (controller.nowData["title"]
                                                          ?.toString() ??
                                                      "")
                                                  .replaceAll("\n", ""),
                                              // maxLines: 1,
                                              // overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 22.w),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  );

                                  // if ((controller.nowData["lyrics"]
                                  //             ?.toString() ??
                                  //         "")
                                  //     .isEmpty) {
                                  //   return Container(
                                  //     child: Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Container(
                                  //             height: 327.w,
                                  //             width: 327.w,
                                  //             alignment: Alignment.center,
                                  //             clipBehavior: Clip.hardEdge,
                                  //             decoration: BoxDecoration(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(
                                  //                         15.w),
                                  //                 color: Color(0xffF3F3F3)),
                                  //             child: SingleChildScrollView(
                                  //               child: Container(
                                  //                 width: double.infinity,
                                  //
                                  //                 // height: 300.w,
                                  //                 // color: Colors.green,
                                  //                 // margin:
                                  //                 //     EdgeInsets.symmetric(horizontal: 30.w),
                                  //                 // constraints:
                                  //                 //     BoxConstraints(maxHeight: 300.w),
                                  //                 alignment: Alignment.center,
                                  //                 child: Text(
                                  //                   controller.nowData[
                                  //                           "lyrics"] ??
                                  //                       "No lyrics",
                                  //                   textAlign: TextAlign.center,
                                  //                   style: TextStyle(
                                  //                       fontSize: 14.w,
                                  //                       color: Colors.black
                                  //                           .withOpacity(0.5)),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //             // Text(
                                  //             //   "No lyrics",
                                  //             //   style: TextStyle(
                                  //             //       fontSize: 14.w,
                                  //             //       color: Color(0xff141414)
                                  //             //           .withOpacity(0.5)),
                                  //             // ),
                                  //             ),
                                  //         SizedBox(
                                  //           height: 24.w,
                                  //         ),
                                  //         Container(
                                  //           width: 327.w,
                                  //           child: Obx(() {
                                  //             return TextScroll(
                                  //               (controller.nowData["title"]
                                  //                           ?.toString() ??
                                  //                       "")
                                  //                   .replaceAll("\n", ""),
                                  //               // maxLines: 1,
                                  //               // overflow: TextOverflow.ellipsis,
                                  //               style:
                                  //                   TextStyle(fontSize: 22.w),
                                  //             );
                                  //           }),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   );
                                  // }
                                  //
                                  // return Container(
                                  //   alignment: Alignment.center,
                                  //   // margin: EdgeInsets.symmetric(vertical: 50.w),
                                  //   constraints:
                                  //       BoxConstraints(maxHeight: 300.w),
                                  //   padding: EdgeInsets.symmetric(
                                  //       horizontal: 30.w, vertical: 30.w),
                                  //   child: SingleChildScrollView(
                                  //     child: Container(
                                  //       width: double.infinity,
                                  //
                                  //       // height: 300.w,
                                  //       // color: Colors.green,
                                  //       // margin:
                                  //       //     EdgeInsets.symmetric(horizontal: 30.w),
                                  //       // constraints:
                                  //       //     BoxConstraints(maxHeight: 300.w),
                                  //       alignment: Alignment.center,
                                  //       child: Text(
                                  //         controller.nowData["lyrics"] ?? "",
                                  //         textAlign: TextAlign.center,
                                  //         style: TextStyle(fontSize: 14.w),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );
                                }),
                      ),
                    ),

                    //进度条
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Obx(
                            () => Container(
                              height: 30.w,
                              // color: Colors.red,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 6,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  // trackMargin: EdgeInsets.all(0),
                                  allowedInteraction:
                                      SliderInteraction.tapAndSlide,
                                  tickMarkShape: RoundSliderTickMarkShape(
                                    tickMarkRadius: 6,
                                  ),
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 7,
                                    disabledThumbRadius: 7,
                                  ),
                                ),
                                child: Slider(
                                  value: controller.sliderValue.value,
                                  onChanged: (value) {
                                    //计算时间
                                    controller.sliderValue.value = value;
                                    controller.player.seek(
                                      controller.maxD * value,
                                    );
                                  },

                                  // onChangeEnd: (value) async {
                                  //   controller.sliderValue.value = value;
                                  //   await controller.playerModule
                                  //       .seekToPlayer(
                                  //           controller.maxD * value);
                                  //
                                  //   controller._playerSubscription?.resume();
                                  // },
                                  // onChangeStart: (value) {
                                  //   controller._playerSubscription?.pause();
                                  // },
                                  activeColor: Color(0xffFF9020),
                                  // secondaryTrackValue: maxBuffering / duration,
                                  // secondaryActiveColor:
                                  //     Color(0xff8C48FF).withOpacity(0.35),
                                  inactiveColor: Color(
                                    0xffFF9020,
                                  ).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          //时间
                          Obx(
                            () => Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Row(
                                children: [
                                  Text(
                                    controller.playTime.value,
                                    style: TextStyle(
                                      fontSize: 10.w,
                                      color: Color(
                                        0xff141414,
                                      ).withOpacity(0.75),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    controller.maxTime.value,
                                    style: TextStyle(
                                      fontSize: 10.w,
                                      color: Color(
                                        0xff141414,
                                      ).withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50.w),
                    Container(
                      height: 48.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              child: Image.asset("assets/img/icon_p_add.png"),
                            ),
                            onTap: () {
                              controller.showAddList();
                            },
                          ),
                          SizedBox(width: 35.w),
                          Obx(
                            () => InkWell(
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                child: Image.asset(
                                  Assets.imgIconPL,
                                  color:
                                      controller.canLast.value
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                              onTap: () {
                                if (!controller.canLast.value) {
                                  return;
                                }
                                controller.playMusic(controller.nowIndex - 1);
                              },
                            ),
                          ),
                          SizedBox(width: 35.w),
                          Obx(
                            () => InkWell(
                              child: Container(
                                width: 48.w,
                                height: 48.w,
                                child: Image.asset(
                                  controller.isPlaying.value
                                      ? "assets/img/icon_p_pause.png"
                                      : "assets/img/icon_p_play.png",
                                ),
                              ),
                              onTap: () async {
                                if (controller.isPlaying.value) {
                                  controller.player.pause();
                                } else {
                                  controller.player.resume();
                                }
                                // controller.isPlaying.toggle();
                              },
                            ),
                          ),
                          SizedBox(width: 35.w),
                          Obx(() {
                            return InkWell(
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                child: Image.asset(
                                  Assets.imgIconPN,
                                  color:
                                      controller.canNext.value
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                              onTap: () {
                                if (!controller.canNext.value) {
                                  return;
                                }
                                controller.playMusic(controller.nowIndex + 1);
                              },
                            );
                          }),
                          SizedBox(width: 35.w),
                          InkWell(
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              child: Image.asset(
                                "assets/img/icon_p_playlist.png",
                              ),
                            ),
                            onTap: () {
                              controller.showPlaylist();
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Get.mediaQuery.padding.bottom + 50.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayPageController extends GetxController {
  var tabIndex = 0.obs;
  var sliderValue = 0.0.obs;
  // FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  var player = AudioPlayer(playerId: "music_muse_app_player");

  //歌单
  var playList = [];

  //当前播放下标
  var nowIndex = 0;

  //当前播放的音乐信息
  var nowData = {}.obs;

  //播放时长
  var playTime = "".obs;
  //最大时长
  var maxTime = "".obs;
  var maxD = Duration.zero;

  //播放监听
  StreamSubscription? _playerSubscription;

  //播放状态
  var isPlaying = false.obs;

  var canNext = false.obs;
  var canLast = false.obs;

  MyAudioHandler? myHandler;

  setDataAndPlay(Map data) async {
    var item = data["item"] ?? {};
    List list = data["list"] ?? [];

    if (list.isNotEmpty) {
      playList = list;
      nowIndex = list.indexOf(item);
      nowData.value = playList[nowIndex];
    }
    if (playList.isEmpty) {
      return;
    }

    playMusic(nowIndex);
  }

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  playMusic(int index) async {
    if (isPlaying.value) {
      await player.pause();
    }
    realPlay(index);

    // AdUtils.instance.showAd("behavior",
    //     onShow: ShowCallback(onShowFail: (adId, e) {
    //       AppLog.e(e);
    //       realPlay(index);
    //     }, onClose: (adId) {
    //       AppLog.e("广告关闭$adId");
    //       realPlay(index);
    //     }, onShow: (adId) {
    //       AppLog.e("广告显示$adId");
    //     }, onClick: (adId) {
    //       AppLog.e("广告点击$adId");
    //     }));
  }

  realPlay(int index) {
    nowIndex = index;
    nowData.value = playList[nowIndex];

    canLast.value = canPlayLast();
    canNext.value = canPlayNext();

    player.setReleaseMode(ReleaseMode.stop);
    player.play(
      BytesSource(
        playList[index]["fileData"],
        mimeType: playList[index]["mimeType"] ?? "audio/mp3",
      ),
    );

    isPlaying.value = true;

    if (_playerCompleteSubscription != null) {
      return;
    }

    _playerCompleteSubscription = player.onPlayerComplete.listen((e) {
      //播放完成
      if (canPlayNext()) {
        playMusic(nowIndex + 1);
      } else {
        isPlaying.value = false;
      }
    });
    _durationSubscription = player.onDurationChanged.listen((d) async {
      //多大时长监听
      maxD = d;
      maxTime.value = formatDuration(maxD);

      var coverPath = "";
      if (nowData["cover"] != null) {
        //有封面图
        var file =
            await File(
              "${(await getTemporaryDirectory()).path}/img_${Uuid().v8()}.jpg",
            ).create();
        await file.writeAsBytes(nowData["cover"]);
        coverPath = file.path;
      }
      var item = MediaItem(
        id: nowData["id"],
        title: nowData["title"],
        duration: maxD,
        artUri: coverPath.isEmpty ? null : Uri.file(coverPath),
      );
      myHandler?.showItem(item);
    });
    _positionSubscription = player.onPositionChanged.listen((p) {
      sliderValue.value =
          p.inMilliseconds.toDouble() / maxD.inMilliseconds.toDouble();

      playTime.value = formatDuration(p);

      //更新进度
      myHandler?._updateState();
    });
    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      AppLog.e(state.name);
      isPlaying.value = state == PlayerState.playing;
      //更新状态
      myHandler?._updateState();
    });
  }

  bool canPlayNext() {
    if (playList.length > nowIndex + 1) {
      return true;
    } else {
      return false;
    }
  }

  bool canPlayLast() {
    if (nowIndex > 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    // _playerSubscription?.cancel();
    // playerModule.closePlayer();

    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.dispose();
    myHandler?.playbackState.close();
  }

  OverlayEntry? _overlayEntry;
  showFloatingWidget() {
    if (nowData.isEmpty) {
      return;
    }

    _overlayEntry ??= OverlayEntry(
      builder: (c) {
        return Obx(() {
          return Positioned(
            bottom:
                (Get.find<Application>().isMainPage.value
                    ? kBottomNavigationBarHeight
                    : 0) +
                Get.mediaQuery.padding.bottom +
                8.w,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(PlayPage());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 16.w,
                        top: 9.w,
                        bottom: 9.w,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Color(0xffE8EFFD),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff474747).withOpacity(0.06),
                            blurRadius: 5.w,
                            spreadRadius: 2.w,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(27.w),
                      ),
                      child: Row(
                        children: [
                          //封面
                          Obx(() {
                            Uint8List? cover = nowData["cover"];

                            return Container(
                              height: 36.w,
                              width: 36.w,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child:
                                  cover == null
                                      ? Image.asset(
                                        Assets.imgIconDef,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.memory(cover, fit: BoxFit.cover),
                            );
                          }),

                          SizedBox(width: 12.w),
                          //标题
                          Expanded(
                            child: Obx(
                              () => Text(
                                nowData["title"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          //按钮
                          Obx(
                            () => InkWell(
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                child: Image.asset(
                                  isPlaying.value
                                      ? Assets.imgIconBarS
                                      : Assets.imgIconBarP,
                                ),
                              ),
                              onTap: () async {
                                if (isPlaying.value) {
                                  await player.pause();
                                } else {
                                  await player.resume();

                                  //暂停其他页面的播放
                                  if (Get.isRegistered<AddLyricsController>()) {
                                    if (Get.find<AddLyricsController>()
                                        .isPlaying
                                        .value) {
                                      Get.find<AddLyricsController>()
                                          .pausePlay();
                                    }
                                  }
                                  if (Get.isRegistered<
                                    LyricsInfoController
                                  >()) {
                                    if (Get.find<LyricsInfoController>()
                                        .isPlaying
                                        .value) {
                                      Get.find<LyricsInfoController>()
                                          .pausePlay();
                                    }
                                  }
                                  if (Get.isRegistered<
                                    CreateMusicLyricsController
                                  >()) {
                                    if (Get.find<CreateMusicLyricsController>()
                                        .isPlaying
                                        .value) {
                                      Get.find<CreateMusicLyricsController>()
                                          .pausePlay();
                                    }
                                  }
                                }
                                // isPlaying.toggle();
                              },
                            ),
                          ),

                          SizedBox(width: 6.w),
                          Obx(() {
                            return InkWell(
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                child: Image.asset(
                                  Assets.imgIconBarN,
                                  color:
                                      canNext.value
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                              onTap: () {
                                if (!canNext.value) {
                                  return;
                                }
                                playMusic(nowIndex + 1);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  //进度条
                  Positioned(
                    left: 32.w,
                    bottom: 1.w,
                    right: 32.w,
                    child: Obx(
                      () => LinearProgressIndicator(
                        minHeight: 2.w,
                        borderRadius: BorderRadius.circular(1.w),
                        backgroundColor: Colors.black.withOpacity(0.2),
                        color: Colors.black.withOpacity(0.75),
                        value: sliderValue.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }

  void hideFloatingWidget() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void showPlaylist() async {
    //当前播放列表
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE9F0FC), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    "Playlist（${playList.length}）",
                    style: TextStyle(fontSize: 20.w),
                  ),
                  // Spacer(),
                  // IconButton(
                  //     onPressed: () {
                  //       Get.back();
                  //     },
                  //     icon: Icon(Icons.close))
                ],
              ),
            ),
            SizedBox(height: 24.w),
            Expanded(
              child: ListView.separated(
                // padding: EdgeInsets.symmetric(horizontal: 16.w),
                // shrinkWrap: true,
                //
                // physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  return getPlayListItem(i);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(height: 10.w);
                },
                itemCount: playList.length,
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom + 20.w),
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );
  }

  void showAddList() async {
    //所有歌曲歌单
    var box = await Hive.openBox(DBKey.listData);
    var mList =
        box.values.where((e) {
          //筛选出歌曲歌单，不要歌词歌单
          return e["type"] == 1;
        }).toList();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE9F0FC), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text("Add", style: TextStyle(fontSize: 20.w)),
                  Spacer(),

                  InkWell(
                    onTap: () {
                      Get.back();
                      //创建歌单
                      Get.to(AddList(addMap: Map.of(nowData.value)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color: Color(0xffBAD1FF),
                      ),
                      height: 30.w,
                      width: 72.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 14.w),
                          SizedBox(width: 6.w),
                          Text("New", style: TextStyle(fontSize: 12.w)),
                        ],
                      ),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Get.back();
                  //     //创建歌单
                  //     Get.to(AddList(addMap: Map.of(nowData.value)));
                  //   },
                  //   icon: Image.asset(
                  //     "assets/img/icon_p_add_list.png",
                  //     width: 24.w,
                  //     height: 24.w,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 24.w),
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) {
                  return getMListItem(i, mList);
                },
                separatorBuilder: (_, i) {
                  return SizedBox(height: 10.w);
                },
                itemCount: mList.length,
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom + 20.w),
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );
  }

  Widget getPlayListItem(int i) {
    var item = playList[i];
    //播放列表的item
    Uint8List? cover = item["cover"];

    return Obx(() {
      var isCheck = item["id"] == nowData["id"];

      return InkWell(
        onTap: () {
          //切换播放
          playMusic(i);
        },
        child: Container(
          height: 62.w,
          width: double.infinity,
          color: isCheck ? Color(0xfff3f3f3) : Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.w),
          child: Row(
            children: [
              //封面
              Container(
                height: 52.w,
                width: 52.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child:
                    cover == null
                        ? Image.asset(Assets.imgIconDef)
                        : Image.memory(cover),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  item["title"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCheck ? Color(0xff6898FC) : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 35.w),

              // InkWell(
              //     onTap: () {
              //       // showMoreView(item);
              //     },
              //     child: Image.asset(
              //       "assets/img/icon_music_more.png",
              //       width: 24.w,
              //       height: 24.w,
              //     ))
            ],
          ),
        ),
      );
    });
  }

  Widget getMListItem(int i, List mList) {
    var item = mList[i];
    Uint8List? cover = item["cover"];

    var typeIndex = item["type"];

    var isMusic = typeIndex == 1;

    List childList = item["list"] ?? [];

    // var data = {
    //   "id": id,
    //   "title": titleC.text,
    //   "saveTime": DateTime.now(),
    //   "type": typeIndex,
    //   "cover": coverData.value
    // };

    return InkWell(
      onTap: () async {
        //添加当前歌曲到歌单

        //判断是否添加过当前歌曲
        if (childList.map((e) => e["id"]).toList().contains(nowData["id"])) {
          //已经添加过
          ToastUtil.showToast(
            msg: "This song has already been added to this playlist",
          );
          return;
        }

        var listid = item["id"];
        List newList = List.of(childList)..add(nowData.value);
        var box = await Hive.openBox(DBKey.listData);
        var newMap = Map.of(item);
        newMap["list"] = newList;
        await box.put(listid, newMap);
        ToastUtil.showToast(msg: "Add to ${item["title"] ?? ""}");
        Get.back();
        //刷新歌单详情
        if (Get.isRegistered<ListInfoController>()) {
          Get.find<ListInfoController>().bindData();
        }
        //刷新首页
        Get.find<HomePageController>().bindData();

        //更换歌单，播放第一首
        // if (childList.isEmpty) {
        //   //没有歌曲
        //   ToastUtil.showToast(msg: "No songs added");
        //   return;
        // }
        // setDataAndPlay({"item": childList[0], "list": childList});
        // Get.back();
        // Get.to(PlayPage());
      },
      child: Container(
        height: 56.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        width: double.infinity,
        child: Row(
          children: [
            //封面
            Container(
              width: 66.w,
              height: 56.w,
              child: Stack(
                children: [
                  //底部view
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        isMusic
                            ? Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: Color(0xff191919),
                                borderRadius: BorderRadius.circular(25.w),
                              ),
                            )
                            : Container(
                              width: 46.w,
                              height: 46.w,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(
                                color: Color(0xff141414).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4.w),
                              ),
                            ),
                  ),

                  Container(
                    height: 56.w,
                    width: 56.w,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child:
                        cover == null
                            ? Image.asset(Assets.imgIconDef)
                            : Image.memory(cover, fit: BoxFit.cover),
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
                  Text(
                    item["title"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.w),
                  ),
                  SizedBox(height: 12.w),
                  Text(
                    "${childList.length} songs",
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Color(0xff141414).withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 35.w),

            // InkWell(
            //     onTap: () {
            //       // showMoreListView(item);
            //     },
            //     child: Image.asset(
            //       "assets/img/icon_music_more.png",
            //       width: 24.w,
            //       height: 24.w,
            //     ))
          ],
        ),
      ),
    );
  }

  reloadList() async {
    if (playList.isEmpty) {
      return;
    }

    var oldList = List.from(playList);

    //重新加载
    var box = await Hive.openBox(DBKey.tracksData);

    var newList = [];
    for (Map item in oldList) {
      newList.add(box.get(item["id"]));
    }

    Map newItemData =
        newList.where((e) {
          return nowData["id"] == e["id"];
        }).first;
    playList = newList;
    nowData.value = newItemData;
  }

  playNext() {
    if (canNext.value) {
      playMusic(nowIndex + 1);
    }
  }

  playLast() {
    if (canLast.value) {
      playMusic(nowIndex - 1);
    }
  }

  AudioSession? session;
  @override
  void onInit() async {
    super.onInit();
    session = await AudioSession.instance;
    await session?.configure(AudioSessionConfiguration.music());
    session?.interruptionEventStream.listen((event) async {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause.

            await player.pause();
            // if (Get.find<Application>().isAppBack) {
            //   isPlaying.value = player?.value.isPlaying ?? false;
            // }

            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck.
            break;
          case AudioInterruptionType.pause:
            // The interruption ended and we should resume.
            await player.pause();
            break;
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume.
            await player.resume();

            break;
        }
      }
    });

    session?.becomingNoisyEventStream.listen((_) {
      player.pause();
      // The user unplugged the headphones, so we should pause or lower the volume.
    });

    session?.devicesChangedEventStream.listen((event) {
      AppLog.e('Devices added:   ${event.devicesAdded}');
      AppLog.e('Devices removed: ${event.devicesRemoved}');
      if (event.devicesRemoved.isNotEmpty) {
        //设备移除暂停
        player.pause();
      }
    });

    myHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationIcon: "drawable/ic_launcher_foreground",
      ),
    );
  }
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = Get.find<PlayPageController>().player;

  showItem(MediaItem item) {
    AppLog.e(item);
    mediaItem.add(item);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    if (Platform.isAndroid) exit(0);
  }

  @override
  Future<void> play() {
    return _player.resume();
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() {
    return Get.find<PlayPageController>().playNext();
  }

  @override
  Future<void> skipToPrevious() {
    return Get.find<PlayPageController>().playLast();
  }

  _updateState() async {
    playbackState.add(
      PlaybackState(
        controls: [
          if (Get.find<PlayPageController>().canLast.value)
            MediaControl.skipToPrevious,
          _player.state == PlayerState.playing
              ? MediaControl.pause
              : MediaControl.play,
          if (Get.find<PlayPageController>().canNext.value)
            MediaControl.skipToNext,
        ],
        // Which other actions should be enabled in the notification
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        // Which controls to show in Android's compact view.
        // androidCompactActionIndices: const [0, 1, 3],
        // Whether audio is ready, buffering, ...
        processingState: AudioProcessingState.ready,
        // Whether audio is playing
        playing: _player.state == PlayerState.playing,
        // The current position as of this update. You should not broadcast
        // position changes continuously because listeners will be able to
        // project the current position after any elapsed time based on the
        // current speed and whether audio is playing and ready. Instead, only
        // broadcast position updates when they are different from expected (e.g.
        // buffering, or seeking).
        updatePosition: (await _player.getCurrentPosition()) ?? Duration.zero,
        // // The current buffered position as of this update
        // bufferedPosition: Duration(milliseconds: 65432),
        // The current speed
        speed: 1.0,
        // The current queue position
        queueIndex: 0,
      ),
    );
  }
}
