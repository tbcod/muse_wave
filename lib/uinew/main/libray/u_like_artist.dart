import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../tool/like/like_util.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';
import '../home/u_artist.dart';
import '../home/u_play.dart';

class UserLikeArtist extends GetView<UserLikeArtistController> {
  const UserLikeArtist({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLikeArtistController());
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
          title: Text("Liked Artist".tr),
          actions: [
            // IconButton(
            //     onPressed: () async {
            //       await LikeUtil.instance.clearAll();
            //
            //       controller.bindData();
            //     },
            //     icon: Icon(Icons.delete))
          ],
        ),
        body: PlayerBottomBarView(
          child: Obx(
            () => ListView.separated(
              padding: EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom + 60.w,
              ),
              itemBuilder: (_, i) {
                return getArtistItem(controller.list[i]);
              },
              separatorBuilder: (_, i) {
                return SizedBox(height: 10.w);
              },
              itemCount: controller.list.length,
            ),
          ),
        ),
      ),
    );
  }

  getArtistItem(Map item) {
    return InkWell(
      onTap: () {
        AppLog.e(item);
        EventUtils.instance.addEvent(
          "det_artist_show",
          data: {"form": "library"},
        );
        Get.to(()=>UserArtistInfo(), arguments: item);
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: NetAvatarView(imgUrl: item["cover"], size: 52.w),
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
                    ),
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
                          style: TextStyle(fontSize: 12.w),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              var browseId = item["browseId"];
              var isLike = LikeUtil.instance.allArtistMap.containsKey(browseId);

              return InkWell(
                onTap: () {
                  if (isLike) {
                    LikeUtil.instance.unlikeArtist(browseId);
                  } else {
                    LikeUtil.instance.likeArtist(browseId, item);
                  }
                },
                child: Image.asset(
                  isLike
                      ? "assets/oimg/icon_like_on.png"
                      : "assets/oimg/icon_like_off.png",
                  width: 24.w,
                  height: 24.w,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class UserLikeArtistController extends GetxController {
  var list = [].obs;

  @override
  void onInit() {
    super.onInit();
    bindData();
  }

  bindData() {
    //获取所有收藏的歌曲
    list.value = LikeUtil.instance.allArtistMap.values.toList();
  }
}
