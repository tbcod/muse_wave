
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/view/base_view.dart';


class PlayerBottomBarView extends StatelessWidget {
  const PlayerBottomBarView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserPlayInfoController>()) {
      Get.lazyPut(() => UserPlayInfoController());
    }
    UserPlayInfoController controller = Get.find();
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: true,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Get.bottomSheet(const UserPlayInfo(), isScrollControlled: true);
                      },
                      child: Obx(() {
                        if(controller.nowData.isEmpty) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          height: 54.w,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                              color: const Color(0xffF1F1FF),
                              boxShadow: [BoxShadow(color: const Color(0xff474747).withOpacity(0.06), blurRadius: 5.w, spreadRadius: 2.w)],
                              borderRadius: BorderRadius.circular(27.w)),
                          child: Row(
                            children: [
                              //封面
                              Container(
                                  height: 36.w,
                                  width: 36.w,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.w)),
                                  child: Obx(() =>
                                      NetImageView(
                                        imgUrl: controller.nowData["cover"] ?? "",
                                        fit: BoxFit.cover,
                                      ))),

                              SizedBox(
                                width: 12.w,
                              ),
                              //标题
                              Expanded(
                                  child: Obx(() =>
                                      Text(
                                        controller.nowData["title"] ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14.w),
                                      ))),

                              //按钮
                              Obx(() =>
                              controller.isLoaded.value
                                  ? Obx(() =>
                                  InkWell(
                                    child: SizedBox(
                                      width: 32.w,
                                      height: 32.w,
                                      child: Image.asset(
                                          controller.isPlaying.value ? "assets/oimg/icon_bar_pause.png" : "assets/oimg/icon_bar_play.png"),
                                    ),
                                    onTap: () async {
                                      //判断视频是否加载
                                      if (!(controller.player?.value.isInitialized ?? false) && (!controller.isPlaying.value)) {
                                        //先加载
                                        controller.realPlay(controller.nowIndex);
                                        return;
                                      }

                                      //判断是否首次
                                      var isInitBar = controller.player?.value.position.inMilliseconds.isLowerThan(500) ?? false;

                                      if (isInitBar) {
                                        EventUtils.instance.addEvent("play_click", data: {
                                          "song_id": controller.playList[controller.nowIndex]["videoId"],
                                          "song_name": controller.playList[controller.nowIndex]["title"],
                                          "artist_name": controller.playList[controller.nowIndex]["subtitle"],
                                          "playlist_id": controller.playlistId,
                                          "station": "tab"
                                        });
                                      }

                                      if (controller.isPlaying.value) {
                                        await controller.player?.pause();
                                        AdUtils.instance.showAd("behavior", adScene: AdScene.play);
                                      } else {
                                        await controller.player?.play();
                                        //暂停其他页面的播放
                                        EventUtils.instance.addEvent("play_num", data: {
                                          "song_id": controller.nowData["videoId"] ?? "",
                                          "song_name": controller.nowData["title"] ?? "",
                                          "artist_name": controller.nowData["subtitle"] ?? "",
                                        });
                                        EventUtils.instance.addEvent("play_succ", data: {"song_id": controller.nowData["videoId"] ?? ""});
                                        EventUtils.instance.addEvent("play_click", data: {
                                          "song_id": controller.nowData["videoId"] ?? "",
                                          "song_name": controller.nowData["title"] ?? "",
                                          "artist_name": controller.nowData["subtitle"] ?? "",
                                          "station":"tab"
                                        });
                                        AdUtils.instance.showAd("behavior", adScene: AdScene.play);
                                      }
                                      controller.isPlaying.toggle();
                                    },
                                  ))
                                  : Container(width: 32.w, height: 32.w, padding: EdgeInsets.all(5.w), child: const CircularProgressIndicator())),

                              SizedBox(
                                width: 6.w,
                              ),
                              Obx(() {
                                return InkWell(
                                  child: SizedBox(
                                    width: 32.w,
                                    height: 32.w,
                                    child: Image.asset(
                                      "assets/oimg/icon_bar_next.png",
                                      color: controller.canNext.value ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    if (!controller.canNext.value) {
                                      return;
                                    }

                                    // EventUtils.instance.addEvent("play_click",
                                    //     data: {
                                    //       "song_id": playList[nowIndex + 1],
                                    //       "station": "tab"
                                    //     });
                                    controller.playNext(isBar: true);
                                    // playItemWithIndex(nowIndex + 1);
                                  },
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),

                    //进度条

                    Positioned(
                        left: 32.w,
                        bottom: 3.w,
                        right: 32.w,
                        child: Obx(() =>
                            LinearProgressIndicator(
                              minHeight: 2.w,
                              borderRadius: BorderRadius.circular(1.w),
                              backgroundColor: const Color(0xff141414).withOpacity(0.2),
                              color: const Color(0xff141414).withOpacity(0.75),
                              value: controller.sliderValue.value,
                            )))
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
