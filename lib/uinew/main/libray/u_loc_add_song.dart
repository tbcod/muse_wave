import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/uinew/main/libray/u_loc_playlist.dart';

import '../../../static/db_key.dart';
import '../../../view/base_view.dart';
import '../u_library.dart';

class UserLocAddSong extends GetView<UserLocAddSongController> {
  const UserLocAddSong({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLocAddSongController());
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
          title: Text("Add songs to playlist".tr),
          actions: [
            IconButton(
              onPressed: () async {
                if (controller.checkList.isEmpty) {
                  return;
                }

                controller.info["list"] = controller.checkList;
                controller.info["cover"] = controller.checkList.last["cover"];

                //保存数据
                var box = await Hive.openBox(DBKey.myPlayListData);
                await box.put(controller.info["id"], controller.info);

                //刷新上级页面
                UserLocPlayListInfoController c = Get.find();
                c.bindData();
                //刷新lib页面
                UserLibraryController libC = Get.find();
                libC.bindMyPlayListData();

                // HistoryUtil.instance
                //     .addHistoryPlaylist(controller.info, isLoc: true);

                Get.back();
              },
              icon: Image.asset(
                "assets/img/icon_ok.png",
                width: 24.w,
                height: 24.w,
              ),
            ),
          ],
        ),
        body: Container(
          child: Obx(() {
            return ListView.separated(
              itemBuilder: (_, i) {
                return getItem(i);
              },
              separatorBuilder: (_, i) {
                return SizedBox(height: 10.w);
              },
              itemCount: controller.list.length,
            );
          }),
        ),
      ),
    );
  }

  getItem(int index) {
    var item = controller.list[index];

    return InkWell(
      onTap: () {
        var listId = controller.checkList.map((e) => e["videoId"]).toList();
        if (listId.contains(item["videoId"])) {
          //已经勾选
          // ToastUtil.showToast(msg: "Already added");
          // return;
          controller.checkList.remove(item);
        } else {
          controller.checkList.add(item);
        }
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
                    ),
                  ),
                  Row(
                    children: [
                      // Obx(() {
                      //   var isLike = LikeUtil.instance.allVideoMap
                      //       .containsKey(item["videoId"]);
                      //   if (isLike) {
                      //     return Container(
                      //       width: 16.w,
                      //       height: 16.w,
                      //       margin: EdgeInsets.only(right: 4.w),
                      //       child: Image.asset("assets/oimg/icon_like_on.png"),
                      //     );
                      //   }
                      //
                      //   return Container();
                      // }),
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
            SizedBox(width: 12.w),
            Obx(() {
              // var isCheck = controller.checkList.contains(item);
              var isCheck = controller.checkList
                  .map((e) => e["videoId"])
                  .contains(item["videoId"]);
              return Image.asset(
                isCheck
                    ? "assets/img/icon_playlist_add_ok.png"
                    : "assets/img/icon_playlist_add.png",
                width: 20.w,
                height: 20.w,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class UserLocAddSongController extends GetxController {
  var list = [].obs;

  var checkList = [].obs;

  var info = {};

  @override
  void onInit() {
    super.onInit();
    info = Get.arguments["info"];
    list.value = Get.arguments["list"];
    // bindData();
  }

  // bindData() async {
  //   //TODO 获取收藏？下载？的歌曲
  //   //获取所有收藏的歌曲
  //   list.value = LikeUtil.instance.allVideoMap.values.toList();
  // }
}
