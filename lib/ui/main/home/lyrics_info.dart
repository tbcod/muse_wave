import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/generated/assets.dart';
import 'package:muse_wave/ui/main/home/play.dart';
import 'package:muse_wave/view/base_view.dart';
import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import 'add_lyrics.dart';

class LyricsInfo extends GetView<LyricsInfoController> {
  const LyricsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LyricsInfoController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(AddLyrics(), arguments: controller.infoData.value);
                  },
                  icon: Image.asset(
                    "assets/img/icon_edit.png",
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () =>
                    controller.infoData.isEmpty
                        ? Container()
                        : Container(
                          child: MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView(
                              padding: EdgeInsets.symmetric(vertical: 12.w),
                              children: [
                                SizedBox(height: 12.w),
                                //标题
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Text(
                                    controller.infoData["title"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.w,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.w),

                                //录音
                                getRecordingView(),

                                SizedBox(height: 32.w),
                                //歌词
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1.w,
                                      color: Color(
                                        0xff1f1f1f,
                                      ).withOpacity(0.08),
                                    ),
                                  ),
                                  child: Text(
                                    controller.infoData["lyrics"],
                                    style: TextStyle(fontSize: 12.w),
                                  ),
                                ),

                                SizedBox(
                                  height: Get.mediaQuery.padding.bottom + 20.w,
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getRecordingView() {
    return Obx(() {
      if (controller.state.value == 0) {
        return InkWell(
          onTap: () {},
          child: Container(
            height: 54.w,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: Color(0xffFFD8B4),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    children: [
                      SizedBox(width: 32.w),
                      //按钮
                      InkWell(
                        onTap: () {
                          controller.playRecorder();
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          child: Image.asset(Assets.imgIconRplay),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Obx(
                            () => Text(
                              controller.fileName.value,
                              style: TextStyle(fontSize: 12.w),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 24.w + 32.w),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (controller.state.value == 1) {
        return InkWell(
          onTap: () {},
          child: Container(
            height: 54.w,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: Color(0xffFFD8B4),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    children: [
                      SizedBox(width: 32.w),
                      //按钮
                      InkWell(
                        onTap: () {
                          // controller.stopPlay();
                          if (controller.isPlaying.value) {
                            controller.pausePlay();
                          } else {
                            controller.resumePlay();
                          }
                        },
                        child: Obx(
                          () => Container(
                            width: 24.w,
                            height: 24.w,
                            child: Image.asset(
                              controller.isPlaying.value
                                  ? Assets.imgIconRpause
                                  : Assets.imgIconRplay,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Obx(
                          () => Container(
                            height: 40.w,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay,
                                // trackMargin: EdgeInsets.all(0),
                                allowedInteraction:
                                    SliderInteraction.tapAndSlide,
                                tickMarkShape: RoundSliderTickMarkShape(
                                  tickMarkRadius: 4,
                                ),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                  disabledThumbRadius: 5,
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
                                activeColor: Colors.black,
                                // secondaryTrackValue: maxBuffering / duration,
                                secondaryActiveColor: Color(
                                  0xff8C48FF,
                                ).withOpacity(0.35),
                                inactiveColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Obx(() => Text(controller.playTime.value)),

                      SizedBox(width: 32.w),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container();
    });
  }
}

class LyricsInfoController extends GetxController {
  var state = 0.obs;
  var fileName = "".obs;
  var playTime = "".obs;

  var infoData = {}.obs;
  var sliderValue = 0.0.obs;
  Uint8List? musicData;

  // FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  // StreamSubscription? _playerSubscription;

  var player = AudioPlayer();
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  var isPlaying = false.obs;
  var maxD = Duration.zero;

  var lid = "";
  @override
  void onInit() {
    super.onInit();

    lid = Get.arguments["id"];
    bindData();
  }

  bindData() async {
    if (lid.isEmpty) {
      AppLog.e("id null");
      return;
    }
    var box = await Hive.openBox(DBKey.lyricsData);
    infoData.value = box.get(lid);

    //    var data = {
    //       "id": id,
    //       "audioData": musicData,
    //       "audioName": fileName.value,
    //       "title": titleC.text,
    //       "lyrics": lyricsC.text,
    //       "saveTime": DateTime.now()
    //     };
    fileName.value = infoData["audioName"];
    musicData = infoData["audioData"];
  }

  playRecorder() async {
    if (musicData == null) {
      return;
    }
    //如果正在后台播放音乐，先暂停
    if (Get.find<PlayPageController>().player.state == PlayerState.playing) {
      Get.find<PlayPageController>().player.pause();
    }

    playTime.value = "";
    sliderValue.value = 0.0;

    player.play(BytesSource(musicData!, mimeType: "audio/aac"));
    state.value = 1;

    if (_playerCompleteSubscription != null) {
      return;
    }

    _playerCompleteSubscription = player.onPlayerComplete.listen((e) {
      //播放完成
      stopPlay();
    });
    _durationSubscription = player.onDurationChanged.listen((d) {
      //多大时长监听
      maxD = d;
      // maxTime.value = formatDuration(maxD);
    });
    _positionSubscription = player.onPositionChanged.listen((p) {
      var sv = p.inMilliseconds.toDouble() / maxD.inMilliseconds.toDouble();
      if (sv < 0) {
        sv = 0;
      } else if (sv > 1) {
        sv = 1;
      }
      sliderValue.value = sv;

      playTime.value = formatDuration(p);
    });
    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      // AppLog.e(state.name);
      isPlaying.value = state == PlayerState.playing;
    });
  }

  stopPlay() async {
    state.value = 0;
    player.stop();
  }

  pausePlay() async {
    player.pause();
  }

  resumePlay() async {
    player.resume();
    if (Get.find<PlayPageController>().player.state == PlayerState.playing) {
      Get.find<PlayPageController>().player.pause();
    }
  }

  @override
  void onClose() {
    super.onClose();

    //播放相关
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.dispose();
  }
}
