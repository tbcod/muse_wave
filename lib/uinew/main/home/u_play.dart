import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/tool/ad/view/page_admob_native.dart';
import 'package:muse_wave/tool/tba/tba_and.dart';
import 'package:muse_wave/tool/tba/tba_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../static/db_key.dart';
import '../../../tool/ad/ad_util.dart';
import '../../../tool/dialog_util.dart';
import '../../../tool/download/download_util.dart';
import '../../../tool/history_util.dart';
import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../tool/toast.dart';
import '../../../ui/main/home/add_lyrics.dart';
import '../../../view/base_view.dart';
import '../../../view/more_sheet_util.dart';
import '../libray/u_loc_playlist.dart';
import '../u_library.dart';

class UserPlayInfo extends GetView<UserPlayInfoController> {
  const UserPlayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, image: DecorationImage(image: AssetImage("assets/oimg/all_page_bg.png"), fit: BoxFit.fill)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              // appBar: AppBar(
              //   leading: IconButton(
              //     onPressed: () {
              //       Get.back();
              //       controller.showFloatingWidget();
              //     },
              //     icon: Icon(Icons.expand_more),
              //   ),
              //   actions: [
              //     IconButton(
              //         onPressed: () {
              //           MoreSheetUtil.instance.showVideoMoreSheet(
              //               controller.nowData,
              //               isPlayPage: true,
              //               clickType: "play");
              //         },
              //         icon: Icon(Icons.more_vert))
              //   ],
              // ),
              body: Column(
                children: [
                  SizedBox(height: Get.mediaQuery.padding.top),

                  AppBar(
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                        controller.showFloatingWidget();
                      },
                      icon: Image.asset("assets/oimg/icon_play_close.png", width: 24.w, height: 24.w),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          MoreSheetUtil.instance.showVideoMoreSheet(controller.nowData, isPlayPage: true, clickType: "play");
                        },
                        icon: Image.asset("assets/oimg/icon_play_more.png", width: 24.w, height: 24.w),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //视频
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Obx(
                                    () =>
                                        controller.isLoaded.value && controller.player != null
                                            ? Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              //设置最高高度
                                              child: AspectRatio(aspectRatio: controller.videoAspectRatio, child: Container(child: VideoPlayer(controller.player!))),
                                            )
                                            : Container(width: double.infinity, height: double.infinity, child: Center(child: CircularProgressIndicator())),
                                  ),
                                ),
                                //广告
                                Positioned.fill(child: Container(alignment: Alignment.center, child: MyNativeAdView(adKey: "pagebanner", positionKey: "play"))),
                                Positioned.fill(child: Container(alignment: Alignment.center, child: PageAdmobNativeView())),
                              ],
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16.w),
                                //名字
                                Obx(
                                  () => Text(
                                    controller.nowData["title"] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 22.w, letterSpacing: -1, fontWeight: FontWeight.w500),
                                  ),
                                ),

                                SizedBox(height: 12.w),
                                //歌手
                                Obx(() => Text(controller.nowData["subtitle"] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.w))),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.w),
                        ],
                      ),
                    ),
                  ),

                  //播放选项按钮
                  Container(
                    height: 48.w,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Container(width: 32.w, height: 32.w, child: Obx(() => Image.asset(controller.singleLoop.value ? "assets/oimg/icon_loop_on.png" : "assets/oimg/icon_loop_off.png"))),
                          onTap: () {
                            EventUtils.instance.addEvent("play_page_click", data: {"click": "single"});

                            controller.singleLoop.toggle();
                          },
                        ),
                        SizedBox(width: 35.w),
                        Obx(
                          () => InkWell(
                            child: Container(width: 32.w, height: 32.w, child: Image.asset("assets/oimg/icon_last.png", color: controller.canLast.value ? Colors.black : Colors.grey)),
                            onTap: () {
                              if (!controller.canLast.value) {
                                return;
                              }
                              EventUtils.instance.addEvent("play_page_click", data: {"click": "switch"});

                              // controller
                              //     .playItemWithIndex(controller.nowIndex - 1);

                              EventUtils.instance.addEvent(
                                "play_click",
                                data: {
                                  "song_id": controller.nowData["videoId"],
                                  "song_name": controller.nowData["title"],
                                  "artist_name": controller.nowData["subtitle"],
                                  "playlist_id": controller.playlistId,
                                  "station": "play_center",
                                },
                              );

                              controller.playLast();
                            },
                          ),
                        ),
                        SizedBox(width: 35.w),
                        Obx(
                          () =>
                              controller.isLoaded.value
                                  ? Obx(
                                    () => InkWell(
                                      child: Container(width: 48.w, height: 48.w, child: Image.asset(controller.isPlaying.value ? "assets/img/icon_p_pause.png" : "assets/img/icon_p_play.png")),
                                      onTap: () async {
                                        if (controller.player == null || (!controller.player!.value.isInitialized)) {
                                          //加载视频
                                          controller.realPlay(controller.nowIndex);

                                          return;
                                        }

                                        if (controller.isPlaying.value) {
                                          controller.player?.pause();
                                        } else {
                                          AdUtils.instance.showAd("behavior", adScene: AdScene.play);

                                          controller.player?.play();

                                          EventUtils.instance.addEvent(
                                            "play_num",
                                            data: {
                                              "song_id": controller.nowData["videoId"],
                                              "song_name": controller.nowData["title"],
                                              "artist_name": controller.nowData["subtitle"],
                                              "playlist_id": controller.playlistId,
                                            },
                                          );
                                          EventUtils.instance.addEvent(
                                            "play_click",
                                            data: {
                                              "song_id": controller.nowData["videoId"],
                                              "song_name": controller.nowData["title"],
                                              "artist_name": controller.nowData["subtitle"],
                                              "playlist_id": controller.playlistId,
                                              "station": "play_center",
                                            },
                                          );

                                          EventUtils.instance.addEvent("play_succ", data: {"song_id": controller.nowData["videoId"]});
                                        }

                                        EventUtils.instance.addEvent("play_page_click", data: {"click": "pause"});

                                        controller.isPlaying.toggle();
                                      },
                                    ),
                                  )
                                  : Container(width: 48.w, height: 48.w, child: CircularProgressIndicator()),
                        ),
                        SizedBox(width: 35.w),
                        Obx(() {
                          return InkWell(
                            child: Container(width: 32.w, height: 32.w, child: Image.asset("assets/oimg/icon_next.png", color: controller.canNext.value ? Colors.black : Colors.grey)),
                            onTap: () {
                              if (!controller.canNext.value) {
                                return;
                              }
                              EventUtils.instance.addEvent("play_page_click", data: {"click": "switch"});

                              EventUtils.instance.addEvent(
                                "play_click",
                                data: {
                                  "song_id": controller.nowData["videoId"],
                                  "song_name": controller.nowData["title"],
                                  "artist_name": controller.nowData["subtitle"],
                                  "playlist_id": controller.playlistId,
                                  "station": "play_center",
                                },
                              );
                              // controller.playItemWithIndex(controller.nowIndex + 1);
                              controller.playNext();
                            },
                          );
                        }),
                        SizedBox(width: 35.w),
                        InkWell(
                          child: Container(width: 32.w, height: 32.w, child: Obx(() => Image.asset(controller.isShuffle.value ? "assets/oimg/icon_shuffle_on.png" : "assets/oimg/icon_shuffle.png"))),
                          onTap: () {
                            //TODO 乱序
                            controller.shuffle();

                            //已经重新设置播放列表
                            // ToastUtil.showToast(msg: "The playlist has been reset");

                            EventUtils.instance.addEvent("play_page_click", data: {"click": "shuffle"});
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.w),

                  //进度条
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Obx(
                          () => Container(
                            height: 20.w,
                            // color: Colors.red,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay,
                                // trackMargin: EdgeInsets.all(0),
                                allowedInteraction: SliderInteraction.tapAndSlide,
                                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5, disabledThumbRadius: 5),
                              ),
                              child: Slider(
                                value: controller.sliderValue.value,
                                onChanged: (value) {
                                  //计算时间
                                  controller.sliderValue.value = value;
                                  controller.player?.seekTo(controller.maxD * value);
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
                                activeColor: Color(0xff7453FF),
                                // secondaryTrackValue: maxBuffering / duration,
                                // secondaryActiveColor:
                                //     Color(0xff8C48FF).withOpacity(0.35),
                                inactiveColor: Color(0xff7453FF).withOpacity(0.2),
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
                                Text(controller.playTime.value, style: TextStyle(fontSize: 10.w, color: Color(0xff141414).withOpacity(0.75))),
                                Spacer(),
                                Text(controller.maxTime.value, style: TextStyle(fontSize: 10.w, color: Color(0xff141414).withOpacity(0.75))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.w),

                  //其他按钮
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    height: 32.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.showPlayList();
                            EventUtils.instance.addEvent("play_page_click", data: {"click": "plist"});
                          },
                          child: Image.asset("assets/oimg/icon_playlist.png", width: 32.w, height: 32.w),
                        ),
                        InkWell(
                          onTap: () {
                            EventUtils.instance.addEvent("play_page_click", data: {"click": "add"});

                            controller.showAddList();
                          },
                          child: Image.asset("assets/oimg/icon_add_play.png", width: 32.w, height: 32.w),
                        ),
                        if (FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") == "on")
                          Obx(() {
                            //获取下载状态
                            var videoId = controller.nowData["videoId"];

                            if (DownloadUtils.instance.allDownLoadingData.containsKey(videoId)) {
                              //有添加过下载
                              var state = DownloadUtils.instance.allDownLoadingData[videoId]["state"];
                              double progress = DownloadUtils.instance.allDownLoadingData[videoId]["progress"];

                              // AppLog.e(
                              //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

                              if (state == 0) {
                                return InkWell(
                                  onTap: () {
                                    EventUtils.instance.addEvent("play_page_click", data: {"click": "offline"});

                                    controller.downloadFile();
                                  },
                                  child: Image.asset("assets/oimg/icon_download_black.png", width: 32.w, height: 32.w),
                                );
                              } else if (state == 1 || state == 3) {
                                //下载中\下载暂停
                                return InkWell(
                                  onTap: () {
                                    controller.removeDownload(state);
                                  },
                                  child: Container(
                                    width: 32.w,
                                    height: 32.w,
                                    padding: EdgeInsets.all(3.w),
                                    child: CircularProgressIndicator(value: progress, strokeWidth: 2, backgroundColor: Color(0xffA995FF).withOpacity(0.35), color: Color(0xffA995FF)),
                                  ),
                                );
                              } else if (state == 2) {
                                return InkWell(
                                  onTap: () {
                                    controller.removeDownload(state);
                                  },
                                  child: Image.asset("assets/oimg/icon_download_ok.png", width: 32.w, height: 32.w),
                                );
                              }
                            }

                            return InkWell(
                              onTap: () {
                                EventUtils.instance.addEvent("play_page_click", data: {"click": "offline"});
                                controller.downloadFile();
                              },
                              child: Image.asset("assets/oimg/icon_download_black.png", width: 32.w, height: 32.w),
                            );
                          }),
                        Obx(() {
                          var videoId = controller.nowData["videoId"];
                          var isLike = LikeUtil.instance.allVideoMap.containsKey(videoId);

                          return InkWell(
                            onTap: () {
                              EventUtils.instance.addEvent("play_page_click", data: {"click": "collection"});

                              if (isLike) {
                                LikeUtil.instance.unlikeVideo(videoId);
                              } else {
                                LikeUtil.instance.likeVideo(videoId, controller.nowData);
                              }
                            },
                            child: Image.asset(isLike ? "assets/oimg/icon_like_on.png" : "assets/oimg/icon_like_off.png", width: 32.w, height: 32.w),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: Get.mediaQuery.padding.bottom + 30.w),
                ],
              ),
            ),
          ),
        ),

        //下载引导
        Positioned.fill(
          child: Obx(
            () =>
                controller.isShowDownloadGuide.value
                    ? GestureDetector(
                      onTap: () async {
                        var sp = await SharedPreferences.getInstance();
                        await sp.setBool("IsShowDownloadGuide", true);
                        controller.isShowDownloadGuide.value = false;
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.65),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 102.w + 10.w,
                              bottom: Get.mediaQuery.padding.bottom + 30.w - 20.w,
                              child: Column(
                                children: [
                                  //链接线
                                  Container(width: 8.w, height: 8.w, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.w), color: Color(0xff9279FE))),
                                  Container(
                                    width: 4.w,
                                    height: 60.w,
                                    // color: Colors.red,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xff9279FE), Color(0xff9279FE).withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                    ),
                                  ),
                                  //下载按钮
                                  Container(
                                    width: 72.w,
                                    height: 72.w,
                                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xff876CFF), width: 2.w), borderRadius: BorderRadius.circular(36.w)),
                                    alignment: Alignment.center,
                                    child: Obx(() {
                                      //获取下载状态
                                      var videoId = controller.nowData["videoId"];

                                      if (DownloadUtils.instance.allDownLoadingData.containsKey(videoId)) {
                                        //有添加过下载
                                        var state = DownloadUtils.instance.allDownLoadingData[videoId]["state"];
                                        double progress = DownloadUtils.instance.allDownLoadingData[videoId]["progress"];

                                        // AppLog.e(
                                        //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

                                        if (state == 0) {
                                          return InkWell(
                                            onTap: () async {
                                              var sp = await SharedPreferences.getInstance();
                                              await sp.setBool("IsShowDownloadGuide", true);
                                              controller.isShowDownloadGuide.value = false;

                                              EventUtils.instance.addEvent("play_page_click", data: {"click": "offline"});

                                              controller.downloadFile();
                                            },
                                            child: Image.asset("assets/oimg/icon_download_black.png", width: 32.w, height: 32.w),
                                          );
                                        } else if (state == 1 || state == 3) {
                                          //下载中\下载暂停
                                          return InkWell(
                                            onTap: () async {
                                              var sp = await SharedPreferences.getInstance();
                                              await sp.setBool("IsShowDownloadGuide", true);
                                              controller.isShowDownloadGuide.value = false;
                                              controller.removeDownload(state);
                                            },
                                            child: Container(
                                              width: 32.w,
                                              height: 32.w,
                                              padding: EdgeInsets.all(3.w),
                                              child: CircularProgressIndicator(value: progress, strokeWidth: 2, backgroundColor: Color(0xffA995FF).withOpacity(0.35), color: Color(0xffA995FF)),
                                            ),
                                          );
                                        } else if (state == 2) {
                                          return InkWell(
                                            onTap: () async {
                                              var sp = await SharedPreferences.getInstance();
                                              await sp.setBool("IsShowDownloadGuide", true);
                                              controller.isShowDownloadGuide.value = false;
                                              controller.removeDownload(state);
                                            },
                                            child: Image.asset("assets/oimg/icon_download_ok.png", width: 32.w, height: 32.w),
                                          );
                                        }
                                      }

                                      return InkWell(
                                        onTap: () async {
                                          var sp = await SharedPreferences.getInstance();
                                          await sp.setBool("IsShowDownloadGuide", true);
                                          controller.isShowDownloadGuide.value = false;
                                          EventUtils.instance.addEvent("play_page_click", data: {"click": "offline"});
                                          controller.downloadFile();
                                        },
                                        child: Image.asset("assets/oimg/icon_download_black.png", width: 32.w, height: 32.w),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),

                            //上方描述
                            Positioned(
                              right: 26.w,
                              bottom: Get.mediaQuery.padding.bottom + 10.w + 72.w + 72.w,
                              child: Container(
                                width: 240.w,
                                height: 72.w,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.oimgImgDownloadGuide))),
                                alignment: Alignment.center,
                                child: Text("downloadGuideStr".tr, style: TextStyle(fontSize: 14.w, height: 20 / 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Container(),
          ),
        ),
      ],
    );
  }
}

class UserPlayInfoController extends GetxController {
  var tabIndex = 0.obs;
  var sliderValue = 0.0.obs;

  // FlutterSoundPlayer playerModule = FlutterSoundPlayer();

  VideoPlayerController? player;

  //歌单
  var playList = [].obs;

  //当前播放下标
  var nowIndex = 0;

  //当前播放的音乐信息
  var nowData = {}.obs;

  var playlistId = "";

  //播放时长
  var playTime = "".obs;

  //最大时长
  var maxTime = "".obs;
  var maxD = Duration.zero;

  //播放监听

  //播放状态
  var isPlaying = false.obs;

  var canNext = false.obs;
  var canLast = false.obs;

  MyVideoHandler? myHandler;

  OverlayEntry? overlayEntry;

  var isLoaded = false.obs;

  var videoAspectRatio = 0.0;

  var nowPlayUrl = "";

  var singleLoop = false.obs;
  Timer? timer;

  bool _isTimerPaused = false;

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  void onInit() async {
    super.onInit();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    await session.setActive(true);

    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            AppLog.e("外部音乐开始duck");

            // Another app started playing audio and we should duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            AppLog.e("外部音乐开始播放");

            // Another app started playing audio and we should pause.

            // await player?.pause();
            // isPlaying.value = player?.value.isPlaying ?? false;
            // if (Get.find<Application>().isAppBack) {
            //   isPlaying.value = player?.value.isPlaying ?? false;
            // }

            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck.
            AppLog.e("外部音乐结束duck");
            break;
          case AudioInterruptionType.pause:
            AppLog.e("外部音乐结束pause");
            // The interruption ended and we should resume.
            await player?.play();
            isPlaying.value = player?.value.isPlaying ?? false;
            break;

          case AudioInterruptionType.unknown:
            AppLog.e("外部音乐结束unknown");
            // The interruption ended but we should not resume.
            // await player?.pause();
            // isPlaying.value = player?.value.isPlaying ?? false;

            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      player?.pause();
      // The user unplugged the headphones, so we should pause or lower the volume.
    });

    session.devicesChangedEventStream.listen((event) {
      AppLog.e('Devices added:   ${event.devicesAdded}');
      AppLog.e('Devices removed: ${event.devicesRemoved}');
      if (event.devicesRemoved.isNotEmpty) {
        //设备移除暂停
        player?.pause();
      }
    });

    myHandler = await AudioService.init(builder: () => MyVideoHandler(), config: AudioServiceConfig(androidNotificationIcon: "drawable/ic_launcher_foreground"));

    checkShowDownloadGuide();

    TbaUtils.instance.checkUnFinishedEvent();
  }

  _startTimer() {
    if (timer != null) {
      return;
    }
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 31580), (Timer t) {
      if (player?.value.isPlaying == true) {
        ApiMain.instance.postYoutubePlaybackInfo(isWatchOnly: true);
      }
    });
  }

  var isShowDownloadGuide = false.obs;

  checkShowDownloadGuide() async {
    if (FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") == "off") {
      //下载功能已关闭
      AppLog.e("下载功能已关闭");
      return;
    }
    // isShowDownloadGuide.value = true;
    // return;

    var sp = await SharedPreferences.getInstance();
    bool isShowed = sp.getBool("IsShowDownloadGuide") ?? false;
    if (isShowed) {
      return;
    }
    isShowDownloadGuide.value = true;
  }

  showFloatingWidget() async {
    // if (nowData.isEmpty) {
    //   // hideFloatingWidget();
    //   return;
    // }
    // hideFloatingWidget();
    // // await Future.delayed(Duration(milliseconds: 500));
    //
    // overlayEntry = OverlayEntry(
    //   builder: (c) {
    //     return Obx(() {
    //       var bHeight = 0.0;
    //       if (Get.isRegistered<MyNativeAdViewController>(tag: "homeBottom") && Get.find<MyNativeAdViewController>(tag: "homeBottom").loadType.value != 0) {
    //         //已加载广告
    //         bHeight = 50.w;
    //       }
    //
    //       return Positioned(
    //         bottom: (Get.find<Application>().isMainPage.value ? kBottomNavigationBarHeight + bHeight : 0) + Get.mediaQuery.padding.bottom + Get.mediaQuery.padding.bottom,
    //         left: 0,
    //         right: 0,
    //         child: Material(
    //           color: Colors.transparent,
    //           child: Stack(
    //             children: [
    //               InkWell(
    //                 onTap: () async {
    //                   // Get.to(UserPlayInfo());
    //                   hideFloatingWidget();
    //                   // checkShowDownloadGuide();
    //                   await Get.bottomSheet(
    //                     Container(
    //                       child: UserPlayInfo(),
    //                       // padding: EdgeInsets.only(
    //                       //     top: Get.mediaQuery.padding.top),
    //                     ),
    //                     isScrollControlled: true,
    //                   );
    //                   showFloatingWidget();
    //                 },
    //                 child: Container(
    //                   width: double.infinity,
    //                   height: 54.w,
    //                   padding: EdgeInsets.symmetric(horizontal: 24.w),
    //                   margin: EdgeInsets.symmetric(horizontal: 8.w),
    //                   decoration: BoxDecoration(
    //                     color: Color(0xffF1F1FF),
    //                     boxShadow: [BoxShadow(color: Color(0xff474747).withOpacity(0.06), blurRadius: 5.w, spreadRadius: 2.w)],
    //                     borderRadius: BorderRadius.circular(27.w),
    //                   ),
    //                   child: Row(
    //                     children: [
    //                       //封面
    //                       Container(
    //                         height: 36.w,
    //                         width: 36.w,
    //                         clipBehavior: Clip.hardEdge,
    //                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w)),
    //                         child: Obx(() => NetImageView(imgUrl: nowData["cover"] ?? "", fit: BoxFit.cover)),
    //                       ),
    //
    //                       SizedBox(width: 12.w),
    //                       //标题
    //                       Expanded(child: Obx(() => Text(nowData["title"], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.w)))),
    //
    //                       //按钮
    //                       Obx(
    //                         () =>
    //                             isLoaded.value
    //                                 ? Obx(
    //                                   () => InkWell(
    //                                     child: Container(width: 32.w, height: 32.w, child: Image.asset(isPlaying.value ? "assets/oimg/icon_bar_pause.png" : "assets/oimg/icon_bar_play.png")),
    //                                     onTap: () async {
    //                                       //判断视频是否加载
    //                                       if (!(player?.value.isInitialized ?? false) && (!isPlaying.value)) {
    //                                         //先加载
    //                                         realPlay(nowIndex);
    //                                         return;
    //                                       }
    //
    //                                       //判断是否首次
    //                                       var isInitBar = player?.value.position.inMilliseconds.isLowerThan(500) ?? false;
    //
    //                                       if (isInitBar) {
    //                                         EventUtils.instance.addEvent(
    //                                           "play_click",
    //                                           data: {
    //                                             "song_id": playList[nowIndex]["videoId"],
    //                                             "song_name": playList[nowIndex]["title"],
    //                                             "artist_name": playList[nowIndex]["subtitle"],
    //                                             "playlist_id": playlistId,
    //                                             "station": "tab",
    //                                           },
    //                                         );
    //                                       }
    //
    //                                       if (isPlaying.value) {
    //                                         await player?.pause();
    //                                       } else {
    //                                         await player?.play();
    //                                         //暂停其他页面的播放
    //                                       }
    //                                       isPlaying.toggle();
    //                                     },
    //                                   ),
    //                                 )
    //                                 : Container(width: 32.w, height: 32.w, padding: EdgeInsets.all(5.w), child: CircularProgressIndicator()),
    //                       ),
    //
    //                       SizedBox(width: 6.w),
    //                       Obx(() {
    //                         return InkWell(
    //                           child: Container(width: 32.w, height: 32.w, child: Image.asset("assets/oimg/icon_bar_next.png", color: canNext.value ? Colors.black : Colors.grey)),
    //                           onTap: () {
    //                             if (!canNext.value) {
    //                               return;
    //                             }
    //
    //                             // EventUtils.instance.addEvent("play_click",
    //                             //     data: {
    //                             //       "song_id": playList[nowIndex + 1],
    //                             //       "station": "tab"
    //                             //     });
    //                             playNext(isBar: true);
    //                             // playItemWithIndex(nowIndex + 1);
    //                           },
    //                         );
    //                       }),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //
    //               //进度条
    //               Positioned(
    //                 left: 32.w,
    //                 bottom: 3.w,
    //                 right: 32.w,
    //                 child: Obx(
    //                   () => LinearProgressIndicator(
    //                     minHeight: 2.w,
    //                     borderRadius: BorderRadius.circular(1.w),
    //                     backgroundColor: Color(0xff141414).withOpacity(0.2),
    //                     color: Color(0xff141414).withOpacity(0.75),
    //                     value: sliderValue.value,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     });
    //   },
    // );
    // Overlay.of(Get.overlayContext!).insertAll([overlayEntry!]);
  }

  hideFloatingWidget() {
    // try {
    //   if (overlayEntry != null) {
    //     overlayEntry?.remove();
    //     overlayEntry?.dispose();
    //     overlayEntry = null;
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  ///  loadNextData. 范围：搜索结果、首页单曲推荐（包括MV）、音乐人 video 模块、（音乐人主页热门歌曲，为热门歌曲【更多内容】为歌单）
  setDataAndPlayItem(List list, Map item, {required String clickType, bool loadNextData = false, String pid = ""}) async {
    if (player != null) {
      player?.dispose();
      player = null;
    }

    isLoaded.value = false;
    //设置歌单id
    playlistId = pid;

    if (list.isNotEmpty) {
      playList.value = list;
      nowIndex = list.map((e) => e["videoId"]).toList().indexOf(item["videoId"]);
      nowData.value = playList[nowIndex];
    }
    if (playList.isEmpty) {
      return;
    }

    if (clickType == "appOpen") {
      playItemWithIndex(nowIndex, isOpenShowBar: true);
      return;
    }

    EventUtils.instance.addEvent("play_page", data: {"song_id": item["videoId"]});

    EventUtils.instance.addEvent("play_click", data: {"song_id": item["videoId"], "song_name": item["title"], "artist_name": item["subtitle"], "playlist_id": playlistId, "station": clickType});

    playItemWithIndex(nowIndex);

    //加载相关歌曲
    if (loadNextData) {
      moreContinuation = "";
      loadNextList();
    }

    hideFloatingWidget();
    // checkShowDownloadGuide();
    await Get.bottomSheet(
      Container(
        child: UserPlayInfo(),
        // padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
      ),
      isScrollControlled: true,
    );
    showFloatingWidget();
  }

  var moreContinuation = "";

  loadNextList() async {
    if (Get.find<Application>().typeSo == "yt") {
      //youtube相关歌曲
      var result = await ApiMain.instance.getYoutubeNext(nowData["videoId"]);
      if (result.code == HttpCode.success) {
        //解析数据

        List oldList = [];

        try {
          oldList = result.data["contents"]["twoColumnWatchNextResults"]["secondaryResults"]["secondaryResults"]["results"] ?? [];
          moreContinuation = result.data["contents"]["twoColumnWatchNextResults"]["secondaryResults"]["secondaryResults"]["continuations"][0]["nextContinuationData"]["continuation"] ?? "";
        } catch (e, s) {
          moreContinuation = "";

          Map r1 = result.data["contents"]["twoColumnWatchNextResults"]["secondaryResults"]["secondaryResults"]["results"].last;

          moreContinuation = r1["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ?? "";

          // AppLog.e("$e,$s");
        }

        for (Map itemMap in oldList) {
          if (itemMap.containsKey("compactVideoRenderer")) {
            //歌曲
            String cover = itemMap["compactVideoRenderer"]["thumbnail"]["thumbnails"].last["url"] ?? "";
            String title = itemMap["compactVideoRenderer"]["title"]["simpleText"] ?? "";
            String subtitle = itemMap["compactVideoRenderer"]["longBylineText"]["runs"][0]["text"];
            String videoId = itemMap["compactVideoRenderer"]["videoId"] ?? "";

            playList.add({"title": title, "subtitle": subtitle, "cover": cover, "type": "likevideos", "videoId": videoId});
          } else if (itemMap.containsKey("lockupViewModel")) {
            //歌曲
            String? videoId = itemMap["lockupViewModel"]["contentId"];
            if (videoId == null) continue;
            String? cover = itemMap["lockupViewModel"]["contentImage"]?["thumbnailViewModel"]?["image"]?["sources"].last["url"];
            cover ??= itemMap["lockupViewModel"]["contentImage"]?["collectionThumbnailViewModel"]?["primaryThumbnail"]?["thumbnailViewModel"]?["image"]?["sources"].last["url"];
            String? title = itemMap["lockupViewModel"]["metadata"]["lockupMetadataViewModel"]?["title"]?["content"];
            String? subtitle = itemMap["lockupViewModel"]["metadata"]["lockupMetadataViewModel"]["metadata"]["contentMetadataViewModel"]["metadataRows"][0]["metadataParts"][0]["text"]["content"];

            playList.add({"title": title, "subtitle": subtitle, "cover": cover, "type": "likevideos", "videoId": videoId});
          }
        }

        canNext.value = canPlayNext();
        canLast.value = canPlayLast();
      } else {
        //请求失败，拿取最近播放
      }

      return;
    }

    var result = await ApiMain.instance.getVideoNext(nowData["videoId"], isMoreVideo: true);
    if (result.code == HttpCode.success) {
      List oldList =
          result
              .data["contents"]["singleColumnMusicWatchNextResultsRenderer"]["tabbedRenderer"]["watchNextTabbedResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["musicQueueRenderer"]["content"]["playlistPanelRenderer"]["contents"] ??
          [];

      // try {
      //   moreContinuation =
      //       result.data["contents"]["singleColumnMusicWatchNextResultsRenderer"]
      //                                   ["tabbedRenderer"]
      //                               ["watchNextTabbedResultsRenderer"]
      //                           ["tabs"][0]["tabRenderer"]["content"]
      //                       ["musicQueueRenderer"]["content"]
      //                   ["playlistPanelRenderer"]["continuations"][0]
      //               ["nextRadioContinuationData"]["continuation"] ??
      //           "";
      // } catch (e) {
      //   print(e);
      //   moreContinuation = "";
      // }

      for (Map itemMap in oldList) {
        if (itemMap.containsKey("playlistPanelVideoRenderer")) {
          //歌曲
          String cover = itemMap["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"].last["url"] ?? "";
          String title = itemMap["playlistPanelVideoRenderer"]["title"]["runs"][0]["text"] ?? "";
          String subtitle = itemMap["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["text"];
          String videoId = itemMap["playlistPanelVideoRenderer"]["videoId"] ?? "";

          playList.add({"title": title, "subtitle": subtitle, "cover": cover, "type": "likemusic", "videoId": videoId});
        }
      }
      canNext.value = canPlayNext();
      canLast.value = canPlayLast();
    } else {
      //请求失败，拿取最近播放
    }
  }

  //music相似歌曲更多
  Future nextMoreList() async {
    if (moreContinuation.isEmpty) {
      return;
    }
    if (Get.find<Application>().typeSo == "yt") {
      await youtubeNextMoreList();
      return;
    }

    var result = await ApiMain.instance.getVideoNext(nowData["videoId"], isMoreVideo: true, continuation: moreContinuation);
    if (result.code == HttpCode.success) {
      List oldList = result.data["continuationContents"]["playlistPanelContinuation"]["contents"] ?? [];

      try {
        moreContinuation = result.data["continuationContents"]["playlistPanelContinuation"]["continuations"][0]["nextRadioContinuationData"]["continuation"] ?? "";
      } catch (e) {
        print(e);
        moreContinuation = "";
      }

      for (Map itemMap in oldList) {
        if (itemMap.containsKey("playlistPanelVideoRenderer")) {
          //歌曲
          String cover = itemMap["playlistPanelVideoRenderer"]["thumbnail"]["thumbnails"].last["url"] ?? "";
          String title = itemMap["playlistPanelVideoRenderer"]["title"]["runs"][0]["text"] ?? "";
          String subtitle = itemMap["playlistPanelVideoRenderer"]["longBylineText"]["runs"][0]["text"];
          String videoId = itemMap["playlistPanelVideoRenderer"]["videoId"] ?? "";

          playList.add({"title": title, "subtitle": subtitle, "cover": cover, "type": "likemusic", "videoId": videoId});
        }
      }
      canNext.value = canPlayNext();
      canLast.value = canPlayLast();
    } else {
      //请求失败，拿取最近播放
    }
  }

  //youtube相似歌曲更多
  Future youtubeNextMoreList() async {
    if (moreContinuation.isEmpty) {
      return;
    }

    AppLog.e("youtube更多相似:$moreContinuation");

    var result = await ApiMain.instance.getYoutubeNext(nowData["videoId"], continuation: moreContinuation);
    if (result.code == HttpCode.success) {
      //解析数据

      List oldList = result.data["onResponseReceivedEndpoints"][0]["appendContinuationItemsAction"]["continuationItems"] ?? [];

      try {
        moreContinuation = oldList.last["continuationItemRenderer"]?["continuationEndpoint"]?["continuationCommand"]?["token"] ?? "";
      } catch (e) {
        moreContinuation = "";
        print(e);
      }

      for (Map itemMap in oldList) {
        if (itemMap.containsKey("compactVideoRenderer")) {
          //歌曲
          String cover = itemMap["compactVideoRenderer"]["thumbnail"]["thumbnails"].last["url"] ?? "";
          String title = itemMap["compactVideoRenderer"]["title"]["simpleText"] ?? "";
          String subtitle = itemMap["compactVideoRenderer"]["longBylineText"]["runs"][0]["text"];
          String videoId = itemMap["compactVideoRenderer"]["videoId"] ?? "";

          playList.add({"title": title, "subtitle": subtitle, "cover": cover, "type": "likevideos", "videoId": videoId});
        }
      }

      canNext.value = canPlayNext();
      canLast.value = canPlayLast();
    } else {
      //请求失败，拿取最近播放
    }
  }

  playItemWithIndex(int index, {bool isAutoNext = false, bool isOpenShowBar = false, bool clickNext = false}) async {
    ApiMain.instance.postYoutubePlaybackInfo(isWatchOnly: true);

    if (isPlaying.value) {
      await player?.pause();
    }
    realPlay(index, isAutoNext: isAutoNext, isOpenShowBar: isOpenShowBar, clickNext: clickNext);
  }

  int _playNextCount = 0;

  realPlay(int index, {bool isAutoNext = false, bool isOpenShowBar = false, bool clickNext = false}) async {
    //上报上个视频的时长
    if (player != null && player?.value.duration != null && isOpenShowBar == false) {
      var lastp = player?.value.position ?? Duration.zero;
      var lastd = player?.value.duration ?? Duration(milliseconds: 1);
      var playP = lastp.inMilliseconds / lastd.inMilliseconds;
      var timeNum = 0;
      if (playP < 0.01) {
        timeNum = 0;
      } else if (playP < 0.05) {
        timeNum = 1;
      } else if (playP < 0.1) {
        timeNum = 2;
      } else if (playP < 0.3) {
        timeNum = 3;
      } else if (playP < 0.5) {
        timeNum = 4;
      } else if (playP < 1) {
        timeNum = 5;
      } else {
        timeNum = 6;
      }
      EventUtils.instance.addEvent("play_time", data: {"song_time": timeNum});
    }

    if (!isAutoNext && !isOpenShowBar) {
      AdUtils.instance.showAd("behavior", adScene: AdScene.play);
      Future.delayed(Duration(milliseconds: 500)).then((_) {
        //延迟后显示好评引导
        MyDialogUtils.instance.showRateDialog();
      });
    }

    timer?.cancel();
    timer = null;

    isLoaded.value = false;

    nowIndex = index;
    nowData.value = playList[nowIndex];

    canLast.value = canPlayLast();
    canNext.value = canPlayNext();
    if (isOpenShowBar) {
      showFloatingWidget();
      isLoaded.value = true;
      return;
    }

    //黑名单歌曲
    var blackVideoIds = FirebaseRemoteConfig.instance.getString("musicmuse_song_block");

    if (blackVideoIds.split(";").contains(nowData["videoId"])) {
      //在黑名单内，不允许播放
      ToastUtil.showToast(msg: "playCopyrightStr".tr);

      //如果是自动播放直接切换到一首
      playNext(isAutoNext: true);

      return;
    }

    //获取是否有本地数据
    Map? downloadData = DownloadUtils.instance.allDownLoadingData[nowData["videoId"]];
    var downloadDic = await getApplicationDocumentsDirectory();

    var downloadPath = "${downloadDic.path}/" + (downloadData?["path"] ?? "");

    if (downloadPath.isEmpty || !(await File(downloadPath).exists())) {
      //判断是否有缓存
      //获取缓存
      var cacheDic = await getTemporaryDirectory();
      Map? cacheData = DownloadUtils.instance.allCacheData[nowData["videoId"]];
      if (cacheData?["path"] != null && (await File("${cacheDic.path}/${cacheData!["path"]}").exists())) {
        AppLog.e("播放缓存歌曲$downloadPath");

        //有缓存
        //播放本地文件
        // var url = cacheData!["url"];
        // final physicalFilePath =
        //     await ALDownloaderFileManager.getPhysicalFilePathForUrl(url);

        String cachePath = "${cacheDic.path}/${cacheData["path"]}";

        //加载和播放
        if (player != null) {
          player?.removeListener(playListener);
          player?.dispose();
        }
        player = VideoPlayerController.file(File(cachePath), videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
      } else {
        //请求播放数据
        AppLog.i("请求播放数据");

        var lasthttpvideoId = nowData["videoId"];
        var result = await ApiMain.instance.getVideoInfo(nowData["videoId"]);
        // AppLog.e(result.data);

        if (result.code != HttpCode.success) {
          // ToastUtil.showToast(msg: result.message ?? "error");
          AppLog.e("请求失败。${result.message}");
          //如果不是当前
          if (lasthttpvideoId == nowData["videoId"]) {
            // ToastUtil.showToast(msg: "network error");
            //播放下一个

            //判断是否无网络
            final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

            // AppLog.e("播放网络：$connectivityResult");
            // if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
            //   //没有网络
            //   AppLog.e("没有网络，不切换下一曲");
            //   return;
            // }
            //
            // //如果是首页初始化，不播放下一首
            // if (!isOpenShowBar) {
            //   playNext(isAutoNext: true);
            // }

            AppLog.e("播放网络：$connectivityResult");
            bool hasNetwork = connectivityResult.contains(ConnectivityResult.wifi) || connectivityResult.contains(ConnectivityResult.mobile);

            //没有网络
            AppLog.e("没有网络，不切换下一曲");
            if (!hasNetwork) {
              EventUtils.instance.addEvent("play_num", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"]});
              EventUtils.instance.addEvent("play_fail", data: {"song_id": nowData["videoId"], "reason": "no network"});
            }

            //如果是首页初始化，不播放下一首
            if (!isOpenShowBar && hasNetwork) {
              if (_playNextCount < 5) {
                _playNextCount++;
                playNext(isAutoNext: true);
              }
            }
          }

          return;
        }
        //获取url
        nowPlayUrl = result.data["streamingData"]?["formats"]?.first?["url"] ?? "";
        // int width = result.data["streamingData"]["formats"].first["width"];
        // int height = result.data["streamingData"]["formats"].first["height"];
        //
        // //视频比例
        // videoAspectRatio = width / height;

        //加载和播放
        if (player != null) {
          player?.removeListener(playListener);
          player?.dispose();
        }

        if (nowPlayUrl.isEmpty) {
          EventUtils.instance.addEvent("play_num", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"]});
          EventUtils.instance.addEvent("play_fail", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"], "reason": "Get url error"});
          if (!isAutoNext) {
            ToastUtil.showToast(msg: "Get url error".tr);
          } else {
            // AppLog.e(result.data);
          }
          //播放下一个
          if (!isOpenShowBar) {
            if (_playNextCount < 5) {
              _playNextCount++;
              playNext(isAutoNext: true);
            }
          }
          // playNext(isAutoNext: true);

          return;
        }

        //获取是否下载过了

        player = VideoPlayerController.networkUrl(Uri.parse(nowPlayUrl), videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
      }
    } else {
      AppLog.e("播放下载歌曲$downloadPath");

      //播放本地文件
      // var url = downloadData["url"];
      // final physicalFilePath =
      //     await ALDownloaderFileManager.getPhysicalFilePathForUrl(url);

      //加载和播放
      if (player != null) {
        player?.removeListener(playListener);
        player?.dispose();
      }
      player = VideoPlayerController.file(File(downloadPath), videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true));
    }

    // await player?.initialize();
    _playNextCount = 0;
    await player?.initialize().catchError((e) {
      final errorCode = player?.value.errorDescription ?? 'initialize error';
      if (!isOpenShowBar) {
        EventUtils.instance.addEvent("play_num", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"]});
        EventUtils.instance.addEvent(
          "play_fail",
          data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"], "reason": "initialize error", "detail": errorCode},
        );
      }
      AppLog.e("initialize error:${e.toString()}");
    });

    videoAspectRatio = player?.value.aspectRatio ?? 1;

    player?.addListener(playListener);
    isLoaded.value = true;

    if (isOpenShowBar) {
      //更新播放
      var item = MediaItem(id: nowData["videoId"], title: nowData["title"], duration: maxD, artUri: Uri.parse(nowData["cover"] ?? ""));
      myHandler?.showItem(item);
      myHandler?._updateState();
      return;
    }

    player?.play();
    //保存播放列表和当前播放数据，下次打开app显示
    saveBarData();

    //更新播放
    var item = MediaItem(id: nowData["videoId"], title: nowData["title"], duration: maxD, artUri: Uri.parse(nowData["cover"] ?? ""));
    myHandler?.showItem(item);

    isPlaying.value = true;

    EventUtils.instance.addEvent("play_num", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"]});
    EventUtils.instance.addEvent("play_succ", data: {"song_id": nowData["videoId"], "song_name": nowData["title"], "artist_name": nowData["subtitle"]});
    //保存历史记录
    if (!isAutoNext && !clickNext) {
      HistoryUtil.instance.addHistorySong(Map.of(nowData));
    }

    //缓存歌曲
    DownloadUtils.instance.cacheSong(nowData["videoId"], Map.of(nowData));
    //缓存下一首
    if (canNext.value) {
      try {
        DownloadUtils.instance.cacheSong(playList[nowIndex + 1]["videoId"], Map.of(playList[nowIndex + 1]));
      } catch (e) {
        print(e);
      }
    }

    ApiMain.instance.postYoutubePlaybackInfo(isWatchOnly: false);
    _startTimer();
  }

  //播放监听
  void playListener() {
    // maxD = d;
    // maxTime.value = formatDuration(maxD);

    //获取时长
    maxD = player?.value.duration ?? Duration.zero;
    maxTime.value = formatDuration(maxD);

    //当前时长
    var nowD = player?.value.position ?? Duration.zero;
    sliderValue.value = nowD.inMilliseconds / (maxD.inMilliseconds == 0 ? 1 : maxD.inMilliseconds);
    playTime.value = formatDuration(nowD);

    if (player?.value.isBuffering ?? false) {
      isLoaded.value = false;
    } else {
      isLoaded.value = true;
    }

    //更新通知栏进度
    var item = MediaItem(id: nowData["videoId"], title: nowData["title"], duration: maxD, artUri: Uri.parse(nowData["cover"] ?? ""));
    myHandler?.showItem(item);

    myHandler?._updateState();

    //播放完成自动播放下一个
    if (player?.value.isCompleted ?? false) {
      player?.removeListener(playListener);
      player?.dispose();
      player = null;

      EventUtils.instance.addEvent("play_time", data: {"song_time": 6});
      AppLog.e("播放下一个");
      if (singleLoop.value) {
        //单曲循环
        playItemWithIndex(nowIndex, isAutoNext: true);
      } else {
        //不是单曲循环
        if (canNext.value) {
          playNext(isAutoNext: true);
        } else {
          //从列表第一个从新开始
          playItemWithIndex(0, isAutoNext: true);
        }
      }
    }
  }

  int getRIndex() {
    var rIndex = Random().nextInt(playList.length);
    if (playList.length > 1 && rIndex == nowIndex) {
      //重新随机
      return getRIndex();
    }
    return rIndex;
  }

  playLast({bool isNotif = false}) {
    if (isShuffle.value) {
      //随机播放一首
      var rIndex = getRIndex();
      if (isNotif) {
        EventUtils.instance.addEvent(
          "play_click",
          data: {"song_id": playList[rIndex]["videoId"], "song_name": playList[rIndex]["title"], "artist_name": playList[rIndex]["subtitle"], "playlist_id": playlistId, "station": "background"},
        );
      }
      playItemWithIndex(rIndex, clickNext: true);
      return;
    }

    if (canLast.value) {
      if (isNotif) {
        EventUtils.instance.addEvent(
          "play_click",
          data: {
            "song_id": playList[nowIndex - 1]["videoId"],
            "song_name": playList[nowIndex - 1]["title"],
            "artist_name": playList[nowIndex - 1]["subtitle"],
            "playlist_id": playlistId,
            "station": "background",
          },
        );
      }

      playItemWithIndex(nowIndex - 1, clickNext: true);
    }
  }

  playNext({bool isAutoNext = false, bool isBar = false, bool isNotif = false}) {
    if (isShuffle.value) {
      //随机播放一首
      var rIndex = getRIndex();
      if (isBar) {
        EventUtils.instance.addEvent(
          "play_click",
          data: {"song_id": playList[rIndex]["videoId"], "song_name": playList[rIndex]["title"], "artist_name": playList[rIndex]["subtitle"], "playlist_id": playlistId, "station": "tab"},
        );
      } else {
        if (isNotif) {
          EventUtils.instance.addEvent(
            "play_click",
            data: {"song_id": playList[rIndex]["videoId"], "song_name": playList[rIndex]["title"], "artist_name": playList[rIndex]["subtitle"], "playlist_id": playlistId, "station": "background"},
          );
        }
      }
      playItemWithIndex(rIndex, isAutoNext: isAutoNext, clickNext: true);
      return;
    }

    if (canNext.value) {
      if (isBar) {
        EventUtils.instance.addEvent(
          "play_click",
          data: {
            "song_id": playList[nowIndex + 1]["videoId"],
            "song_name": playList[nowIndex + 1]["title"],
            "artist_name": playList[nowIndex + 1]["subtitle"],
            "playlist_id": playlistId,
            "station": "tab",
          },
        );
      } else {
        if (isNotif) {
          EventUtils.instance.addEvent(
            "play_click",
            data: {
              "song_id": playList[nowIndex + 1]["videoId"],
              "song_name": playList[nowIndex + 1]["title"],
              "artist_name": playList[nowIndex + 1]["subtitle"],
              "playlist_id": playlistId,
              "station": "background",
            },
          );
        }
      }

      playItemWithIndex(nowIndex + 1, isAutoNext: isAutoNext, clickNext: true);
    }
  }

  bool canPlayNext() {
    if (isShuffle.value) {
      return true;
    }

    if (playList.length > nowIndex + 1) {
      return true;
    } else {
      return false;
    }
  }

  bool canPlayLast() {
    if (isShuffle.value) {
      return true;
    }

    if (nowIndex > 0) {
      return true;
    } else {
      return false;
    }
  }

  showAddList() async {
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
                    return getMyPlayList(list[i], Map.of(nowData));
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
                          ToastUtil.showToast(msg: "Please enter a playlist name".tr);
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

  showPlayList() {
    final listIndexC = AutoScrollController();

    //当前播放列表
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
                  Obx(() => Text("${"Playlist".tr}（${playList.length}）", style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.w500))),
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
              child: Obx(
                () => EasyRefresh(
                  onLoad: () async {
                    await nextMoreList();
                    return moreContinuation.isEmpty ? IndicatorResult.noMore : IndicatorResult.success;
                  },
                  child: ListView.separated(
                    controller: listIndexC,
                    // padding: EdgeInsets.symmetric(horizontal: 16.w),
                    // shrinkWrap: true,
                    //
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      return getPlayListItem(i, listIndexC);
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(height: 10.w);
                    },
                    itemCount: playList.length,
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom + 20.w),
          ],
        ),
      ),
      backgroundColor: Color(0xfffafafa),
      barrierColor: Colors.black.withOpacity(0.43),
    );

    Future.delayed(Duration(seconds: 1)).then((_) {
      listIndexC.scrollToIndex(nowIndex, preferPosition: AutoScrollPosition.begin);
    });
  }

  Future savePlayList(String title) async {
    var box = await Hive.openBox(DBKey.myPlayListData);
    var id = Uuid().v8();

    //获取是否使用名字
    var nameList = box.values.map((e) => e["title"]).toList();

    var realName = getRealName(nameList, title);

    await box.put(id, {"title": realName, "date": DateTime.now(), "id": id});
  }

  String getRealName(List nameList, String name, {int nameNum = 0}) {
    if (nameList.contains("$name($nameNum)")) {
      return getRealName(nameList, name, nameNum: nameNum + 1);
    }
    if (nameNum == 0) {
      return name;
    }
    return "$name($nameNum)";
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
                  Text(item["title"], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w500)),
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

  getPlayListItem(int i, AutoScrollController scrollC) {
    var item = playList[i];

    return AutoScrollTag(
      key: ValueKey(i),
      controller: scrollC,
      index: i,
      child: Obx(() {
        var isCheck = item["videoId"] == nowData["videoId"];

        return InkWell(
          onTap: () {
            if (isCheck) {
              return;
            }
            EventUtils.instance.addEvent(
              "play_click",
              data: {"song_id": item["videoId"], "song_name": item["title"], "artist_name": item["subtitle"], "playlist_id": playlistId, "station": "play_center"},
            );

            //切换播放
            playItemWithIndex(i);
          },
          child: Container(
            height: 62.w,
            width: double.infinity,
            color: isCheck ? Color(0xfff4f4f4) : Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.w),
            child: Row(
              children: [
                //封面
                Container(
                  height: 52.w,
                  width: 52.w,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.w)),
                  child: NetImageView(imgUrl: item["cover"], fit: BoxFit.cover),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item["title"], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isCheck ? Color(0xff8569FF) : Colors.black)),
                      SizedBox(height: 10.w),
                      Text(item["subtitle"], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.w, color: isCheck ? Color(0xff8569FF) : Colors.black.withOpacity(0.75))),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),

                InkWell(
                  onTap: () {
                    // showMoreView(item);
                    MoreSheetUtil.instance.showVideoMoreSheet(item, clickType: "play_playlist", isPlayPage: true);
                  },
                  child: Image.asset("assets/img/icon_music_more.png", width: 24.w, height: 24.w),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  downloadFile() async {
    DownloadUtils.instance.download(nowData["videoId"], nowData, clickType: "play");
  }

  removeDownload(int state) async {
    DownloadUtils.instance.remove(nowData["videoId"], state: state);
  }

  //添加到下一个播放
  bool addToNext(Map item, {bool isPlayItem = false}) {
    if (playList.isEmpty) {
      setDataAndPlayItem([item], item, clickType: "play_center");
      return true;
    }

    var idList = playList.map((e) => e["videoId"]).toList();
    if (idList.contains(item["videoId"])) {
      // return false;

      //已经在列表中了,先删除再添加
      playList.removeWhere((e) => e["videoId"] == item["videoId"]);
    }

    var pIndex = playList.indexWhere((e) => e["videoId"] == nowData["videoId"]);

    if (pIndex == -1) {
      nowIndex -= 1;
    } else {
      nowIndex = pIndex;
    }

    playList.insert(nowIndex + 1, item);

    //刷新上一首下一首状态
    canLast.value = canPlayLast();
    canNext.value = canPlayNext();

    if (isPlayItem) {
      playNext();
      //显示播放页面
      hideFloatingWidget();
      // checkShowDownloadGuide();
      Get.bottomSheet(
        Container(
          child: UserPlayInfo(),
          // padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
        ),
        isScrollControlled: true,
      ).then((_) {
        showFloatingWidget();
      });
    }

    return true;
  }

  //添加到最后播放
  bool addToQueue(Map item) {
    if (playList.isEmpty) {
      setDataAndPlayItem([item], item, clickType: "play_center");
      return true;
    }

    var idList = playList.map((e) => e["videoId"]).toList();
    if (idList.contains(item["videoId"])) {
      // return false;
      //已经在列表中了,先删除再添加
      playList.removeWhere((e) => e["videoId"] == item["videoId"]);
    }
    playList.add(item);

    canLast.value = canPlayLast();
    canNext.value = canPlayNext();
    return true;
  }

  var isShuffle = false.obs;

  void shuffle() {
    isShuffle.toggle();

    canNext.value = canPlayNext();
    canLast.value = canPlayLast();

    //乱序
    // playList.shuffle();
    //
    // nowIndex =
    //     playList.map((e) => e["videoId"]).toList().indexOf(nowData["videoId"]);
    //
    // canLast.value = canPlayLast();
    // canNext.value = canPlayNext();
  }

  void saveBarData() async {
    var box = await Hive.openBox(DBKey.myLastPlayDataAndIndex);
    await box.clear();
    await box.put("myLastPlayDataAndIndex", {"index": nowIndex, "list": List.of(playList)});
  }

  var homeIsShowBar = false;

  showLastPlayBar() async {
    if (homeIsShowBar) {
      return;
    }

    var box = await Hive.openBox(DBKey.myLastPlayDataAndIndex);
    Map data = box.get("myLastPlayDataAndIndex") ?? {};
    List lastList = data["list"] ?? [];

    if (lastList.isEmpty) {
      //没有上次的数据使用默认第一首歌
      await HistoryUtil.instance.initData();
      List dList = List.of(HistoryUtil.instance.songHistoryList);
      AppLog.e("使用默认播放");
      AppLog.e(dList);
      setDataAndPlayItem(dList, dList[0], clickType: "appOpen");
      return;
    }
    var lastIndex = data["index"];

    setDataAndPlayItem(lastList, lastList[lastIndex], clickType: "appOpen");

    homeIsShowBar = true;
  }

  reLoadAndPlay() {
    if (playList.isEmpty) {
      return;
    }
    if (isLoaded.value) {
      return;
    }

    EventUtils.instance.addEvent(
      "play_click",
      data: {"song_id": playList[nowIndex]["videoId"], "song_name": playList[nowIndex]["title"], "artist_name": playList[nowIndex]["subtitle"], "playlist_id": playlistId, "station": "background"},
    );

    realPlay(nowIndex);
  }
}

class MyVideoHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  VideoPlayerController? _player;

  showItem(MediaItem item) {
    // AppLog.e("showItem==$item");
    mediaItem.add(item);

    _player = Get.find<UserPlayInfoController>().player;
    // playMediaItem(item);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    if (Platform.isAndroid) exit(0);
  }

  @override
  Future<void> play() async {
    if (!(_player?.value.isInitialized ?? false) && (!Get.find<UserPlayInfoController>().isPlaying.value)) {
      //先加载
      Get.find<UserPlayInfoController>().reLoadAndPlay();
      return;
    }

    await _player?.play();
    final controller = Get.find<UserPlayInfoController>();
    controller.isPlaying.value = true;
    EventUtils.instance.addEvent(
      "play_num",
      data: {"song_id": controller.nowData["videoId"] ?? "", "song_name": controller.nowData["title"] ?? "", "artist_name": controller.nowData["subtitle"] ?? ""},
    );
    EventUtils.instance.addEvent("play_succ", data: {"song_id": controller.nowData["videoId"] ?? ""});
    EventUtils.instance.addEvent(
      "play_click",
      data: {"song_id": controller.nowData["videoId"] ?? "", "song_name": controller.nowData["title"] ?? "", "artist_name": controller.nowData["subtitle"] ?? "", "station": "tab"},
    );
  }

  @override
  Future<void> pause() async {
    final controller = Get.find<UserPlayInfoController>();
    controller.isPlaying.value = false;
    await _player?.pause();
  }

  @override
  Future<void> stop() async {
    await _player?.dispose();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player?.seekTo(position);
  }

  @override
  Future<void> skipToNext() {
    return Get.find<UserPlayInfoController>().playNext(isNotif: true);
  }

  @override
  Future<void> skipToPrevious() {
    return Get.find<UserPlayInfoController>().playLast(isNotif: true);
  }

  _updateState() async {
    playbackState.add(
      PlaybackState(
        controls: [
          if (Get.find<UserPlayInfoController>().canLast.value) MediaControl.skipToPrevious,
          (_player?.value.isPlaying ?? false) ? MediaControl.pause : MediaControl.play,
          if (Get.find<UserPlayInfoController>().canNext.value) MediaControl.skipToNext,
        ],
        // Which other actions should be enabled in the notification
        systemActions: {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
        // Which controls to show in Android's compact view.
        // androidCompactActionIndices: const [0, 1, 3],
        // Whether audio is ready, buffering, ...
        processingState: AudioProcessingState.ready,
        // Whether audio is playing
        playing: _player?.value.isPlaying ?? false,
        // The current position as of this update. You should not broadcast
        // position changes continuously because listeners will be able to
        // project the current position after any elapsed time based on the
        // current speed and whether audio is playing and ready. Instead, only
        // broadcast position updates when they are different from expected (e.g.
        // buffering, or seeking).
        updatePosition: (_player?.value.position) ?? Duration.zero,
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
