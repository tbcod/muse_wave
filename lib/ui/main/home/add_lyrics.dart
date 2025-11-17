import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart' hide PlayerState;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/generated/assets.dart';
import 'package:muse_wave/ui/main/home/play.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../static/app_color.dart';
import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import '../../../tool/toast.dart';
import '../home.dart';
import 'lyrics_info.dart';

class AddLyrics extends GetView<AddLyricsController> {
  const AddLyrics({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AddLyricsController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    controller.btnOk();
                  },
                  icon: Image.asset(
                    "assets/img/icon_ok.png",
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                    children: [
                      //录音
                      getRecordingView(),

                      SizedBox(height: 40.w),
                      //标题
                      Container(
                        height: 54.w,
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        child: CupertinoTextField(
                          controller: controller.titleC,
                          maxLength: 100,
                          placeholder: "title",
                          placeholderStyle: TextStyle(
                            color: Color(0xff141414).withOpacity(0.5),
                          ),
                          style: TextStyle(fontSize: 12.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xff1F1F1F).withOpacity(0.08),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.w),

                      //歌词
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        child: CupertinoTextField(
                          controller: controller.lyricsC,
                          placeholder:
                              "Write your lyrics\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
                          placeholderStyle: TextStyle(
                            color: Color(0xff141414).withOpacity(0.5),
                          ),
                          maxLines: 15,
                          style: TextStyle(fontSize: 12.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 18.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xff1F1F1F).withOpacity(0.08),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
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
    );
  }

  getRecordingView() {
    return Obx(() {
      if (controller.state.value == 0) {
        //未录音
        return Container(
          width: double.infinity,
          height: 66.w,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    controller.startRecorder();
                  },
                  child: Container(
                    height: 54.w,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Color(0xffFFD8B4),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 32.w),
                        //按钮
                        Container(
                          width: 24.w,
                          height: 24.w,
                          child: Image.asset("assets/img/icon_recoring.png"),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Click to Start Recoring",
                              style: TextStyle(fontSize: 12.w),
                            ),
                          ),
                        ),

                        SizedBox(width: 24.w + 32.w),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        // return InkWell(
        //   onTap: () {
        //     controller.startRecorder();
        //   },
        //   child: Container(
        //     height: 54.w,
        //     width: double.infinity,
        //     margin: EdgeInsets.symmetric(horizontal: 12.w),
        //     decoration: BoxDecoration(
        //         color: Color(0xffE8E2FF),
        //         borderRadius: BorderRadius.circular(12.w)),
        //     child: Row(
        //       children: [
        //         SizedBox(
        //           width: 32.w,
        //         ),
        //         //按钮
        //         Container(
        //           width: 24.w,
        //           height: 24.w,
        //           child: Image.asset("assets/img/icon_recoring.png"),
        //         ),
        //         Expanded(
        //             child: Center(
        //           child: Text(
        //             "Click to Start Recoring",
        //             style: TextStyle(fontSize: 12.w),
        //           ),
        //         )),
        //
        //         SizedBox(
        //           width: 24.w + 32.w,
        //         )
        //       ],
        //     ),
        //   ),
        // );
      } else if (controller.state.value == 1) {
        return Container(
          width: double.infinity,
          height: 66.w,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    controller.stopRecorder();
                  },
                  child: Container(
                    height: 54.w,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Stack(
                      children: [
                        //渐变
                        Container(
                          width: 0.5.sw,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffFFAD64),
                                Color(0xffF9F3EC).withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                        //录音背景
                        Positioned(
                          left: 16.w,
                          right: 16.w,
                          top: 12.w,
                          bottom: 12.w,
                          child: Image.asset(
                            "assets/img/bg_recoring.png",
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned.fill(
                          child: Row(
                            children: [
                              SizedBox(width: 32.w),
                              //按钮
                              Container(
                                width: 24.w,
                                height: 24.w,
                                child: Image.asset(
                                  "assets/img/icon_recoring.png",
                                  color: Colors.red,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Obx(
                                    () => Text(
                                      controller.recorderTime.value,
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
                ),
              ),
            ],
          ),
        );
      } else if (controller.state.value == 2) {
        //完成录音

        return Container(
          width: double.infinity,
          height: 66.w,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 54.w,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Color(0xffFFD8B4),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Stack(
                    children: [
                      Row(
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
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            // AppLog.e("111");
                            controller.state.value = 0;
                            controller.musicData = null;
                          },
                          child: Container(
                            color: Colors.transparent,
                            width: 24.w,
                            height: 24.w,
                            padding: EdgeInsets.all(4.w),
                            child: Image.asset("assets/img/icon_r_delete.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   right: 0,
              //   top: 0,
              //   child: GestureDetector(
              //     onTap: () {
              //       // AppLog.e("111");
              //       controller.state.value = 0;
              //       controller.musicData = null;
              //     },
              //     child: Container(
              //       color: Colors.transparent,
              //       width: 30.w,
              //       height: 30.w,
              //       padding: EdgeInsets.all(7.w),
              //       child: Image.asset("assets/img/icon_r_delete.png"),
              //     ),
              //   ),
              // )
            ],
          ),
        );
      } else if (controller.state.value == 3) {
        return Container(
          width: double.infinity,
          height: 66.w,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    // controller.state.value = 2;
                  },
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
                                        overlayShape:
                                            SliderComponentShape.noOverlay,
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
                                        inactiveColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Obx(
                                () => Text(
                                  controller.playTime.value,
                                  style: TextStyle(color: Color(0xff121212)),
                                ),
                              ),

                              SizedBox(width: 32.w),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        // return InkWell(
        //   onTap: () {
        //     // controller.state.value = 2;
        //   },
        //   child: Container(
        //     height: 54.w,
        //     width: double.infinity,
        //     margin: EdgeInsets.symmetric(horizontal: 12.w),
        //     clipBehavior: Clip.none,
        //     decoration: BoxDecoration(
        //         color: AppColor.mainColor,
        //         borderRadius: BorderRadius.circular(12.w)),
        //     child: Stack(
        //       children: [
        //         Positioned.fill(
        //             child: Row(
        //           children: [
        //             SizedBox(
        //               width: 32.w,
        //             ),
        //             //按钮
        //             InkWell(
        //               onTap: () {
        //                 // controller.stopPlay();
        //                 if (controller.isPlaying.value) {
        //                   controller.pausePlay();
        //                 } else {
        //                   controller.resumePlay();
        //                 }
        //               },
        //               child: Obx(() => Container(
        //                     width: 24.w,
        //                     height: 24.w,
        //                     child: Image.asset(
        //                       controller.isPlaying.value
        //                           ? "assets/img/icon_r_pause.png"
        //                           : "assets/img/icon_r_play.png",
        //                     ),
        //                   )),
        //             ),
        //             SizedBox(
        //               width: 16.w,
        //             ),
        //             Expanded(
        //                 child: Obx(() => Container(
        //                       height: 40.w,
        //                       child: SliderTheme(
        //                         data: SliderThemeData(
        //                             trackHeight: 4,
        //                             overlayShape:
        //                                 SliderComponentShape.noOverlay,
        //                             // trackMargin: EdgeInsets.all(0),
        //                             allowedInteraction:
        //                                 SliderInteraction.tapAndSlide,
        //                             tickMarkShape: RoundSliderTickMarkShape(
        //                                 tickMarkRadius: 4),
        //                             thumbShape: RoundSliderThumbShape(
        //                                 enabledThumbRadius: 5,
        //                                 disabledThumbRadius: 5)),
        //                         child: Slider(
        //                           value: controller.sliderValue.value,
        //                           onChanged: (value) {
        //                             //计算时间
        //                             controller.sliderValue.value = value;
        //                             controller.player
        //                                 .seek(controller.maxD * value);
        //                           },
        //                           activeColor: Colors.black,
        //                           // secondaryTrackValue: maxBuffering / duration,
        //                           secondaryActiveColor:
        //                               Color(0xff8C48FF).withOpacity(0.35),
        //                           inactiveColor: Colors.white,
        //                         ),
        //                       ),
        //                     ))),
        //             SizedBox(
        //               width: 16.w,
        //             ),
        //             Obx(() => Text(controller.playTime.value)),
        //
        //             SizedBox(
        //               width: 32.w,
        //             )
        //           ],
        //         ))
        //       ],
        //     ),
        //   ),
        // );
      }

      return Container();
    });
  }
}

class AddLyricsController extends GetxController {
  var titleC = TextEditingController();
  var lyricsC = TextEditingController();

  //录音状态
  //0未录音
  //1录音中
  //2录音完成
  //3录音完成播放中
  var state = 0.obs;

  var sliderValue = 0.0.obs;

  var lid = "";
  @override
  void onInit() {
    super.onInit();
    Map? infoData = Get.arguments;
    if (infoData?.isNotEmpty ?? false) {
      //设置数据

      lid = infoData!["id"];
      fileName.value = infoData["audioName"];
      musicData = infoData["audioData"];
      titleC.text = infoData["title"];
      lyricsC.text = infoData["lyrics"];
      state.value = 2;
    }
  }

  void btnOk() async {
    //判断是否录音
    if (musicData == null) {
      ToastUtil.showToast(msg: "The recording file is empty");
      return;
    }
    if (titleC.text.trim().isEmpty || lyricsC.text.trim().isEmpty) {
      ToastUtil.showToast(msg: "Enter content");
      return;
    }

    var box = await Hive.openBox(DBKey.lyricsData);
    String id;
    if (lid.isNotEmpty) {
      id = lid;
    } else {
      id = Uuid().v8();
    }

    //音频
    var data = {
      "id": id,
      "audioData": musicData,
      "audioName": fileName.value,
      "title": titleC.text,
      "lyrics": lyricsC.text,
      "saveTime": DateTime.now(),
    };
    await box.put(id, data);

    //刷新详情数据
    if (Get.isRegistered<LyricsInfoController>()) {
      Get.find<LyricsInfoController>().bindData();
    }

    //刷新首页数据
    Get.find<HomePageController>().bindData();

    ToastUtil.showToast(msg: "Lyrics created successfully");

    Get.back();
  }

  //录音相关
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  StreamController<Uint8List>? recordingDataController;
  StreamSubscription? _recordingDataSubscription;
  IOSink? sink;
  StreamSubscription? _recorderSubscription;

  //播放相关
  var player = AudioPlayer();
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  var isPlaying = false.obs;

  // StreamSubscription? _playerSubscription;

  //录音时长
  var recorderTime = "".obs;

  //播放时长
  var maxD = Duration.zero;

  var playTime = "".obs;

  var fileName = "".obs;

  void startRecorder() async {
    //麦克风权限
    var lastStatus = await Permission.microphone.status;
    if (lastStatus.isPermanentlyDenied) {
      //永久拒绝后
      AppSettings.openAppSettings();
      return;
    }

    var status = await Permission.microphone.request();

    if (!status.isGranted) {
      return;
    }

    //如果正在后台播放音乐，先暂停
    if (Get.find<PlayPageController>().player.state == PlayerState.playing) {
      Get.find<PlayPageController>().player.pause();
    }

    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );

    await recorderModule.openRecorder();
    await recorderModule.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );

    var filePath =
        (await getTemporaryDirectory()).path +
        "/${DateTime.now().millisecondsSinceEpoch}${ext[Codec.aacADTS.index]}";
    AppLog.e(filePath);

    await recorderModule.startRecorder(toFile: filePath, codec: Codec.aacADTS);

    _recorderSubscription = recorderModule.onProgress!.listen((e) {
      AppLog.e(e);
      Duration time = e.duration;
      recorderTime.value = formatDuration(time);
    });

    state.value = 1;
  }

  Uint8List? musicData;
  stopRecorder() async {
    //文件名：月.日.年_时间
    var path = await recorderModule.stopRecorder();
    await recorderModule.closeRecorder();
    _recorderSubscription?.cancel();
    AppLog.e(path);

    musicData = await File(path!).readAsBytes();

    // var rec=await recorderModule.openRecorder();

    fileName.value = DateFormat("MM.dd.yyyy_HH:mm:ss").format(DateTime.now());

    state.value = 2;
  }

  playRecorder() async {
    if (musicData == null) {
      return;
    }
    AppLog.e(musicData?.length);

    //如果正在后台播放音乐，先暂停
    if (Get.find<PlayPageController>().player.state == PlayerState.playing) {
      Get.find<PlayPageController>().player.pause();
    }

    playTime.value = "";
    sliderValue.value = 0.0;

    player.play(BytesSource(musicData!, mimeType: "audio/aac"));
    state.value = 3;

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
    state.value = 2;
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
    _recorderSubscription?.cancel();
    recorderModule.closeRecorder();

    //播放相关
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.dispose();
  }
}

String formatDuration(Duration position, {bool showHours = false}) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  final minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString =
      hours >= 10
          ? '$hours'
          : hours == 0
          ? '00'
          : '0$hours';

  final minutesString =
      minutes >= 10
          ? '$minutes'
          : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString =
      seconds >= 10
          ? '$seconds'
          : seconds == 0
          ? '00'
          : '0$seconds';

  var formattedTime =
      '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
  if (showHours) {
    formattedTime = '$hoursString:$minutesString:$secondsString';
  }
  return formattedTime;
}
