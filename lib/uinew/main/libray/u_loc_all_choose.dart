import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/uinew/main/libray/u_loc_add_song.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../static/db_key.dart';
import '../../../tool/download/download_util.dart';
import '../../../tool/like/like_util.dart';
import '../../../view/base_view.dart';

class UserLoaAllChoose extends GetView<UserLoaAllChooseController> {
  const UserLoaAllChoose({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLoaAllChooseController());
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
          title: Text("Choose playlist".tr),
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
        ),
        body: PlayerBottomBarView(
          child: Obx(
            () => ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return getItem(controller.allList[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10.w);
              },
              itemCount: controller.allList.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget getItem(Map item) {
    var type = item["type"];
    return InkWell(
      onTap: () {
        Get.off(
          UserLocAddSong(),
          arguments: {"info": controller.info, "list": item["list"] ?? []},
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 8.w, right: 0.w),
        height: 70.w,
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Builder(
                builder: (c) {
                  if (type == 1) {
                    return Image.asset("assets/oimg/icon_like_list.png");
                  } else if (type == 2) {
                    return Image.asset("assets/oimg/icon_local.png");
                  } else {
                    return item["cover"] == null
                        ?
                        //默认封面
                        Image.asset("assets/oimg/icon_d_item.png")
                        : NetImageView(
                          imgUrl: item["cover"],
                          fit: BoxFit.cover,
                        );
                  }
                },
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
                    style: TextStyle(fontSize: 14.w),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.w),
                  Text(
                    "${item["songNum"]} songs",
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserLoaAllChooseController extends GetxController {
  var allList = [].obs;

  var info = {};
  @override
  void onInit() {
    super.onInit();
    info = Get.arguments;
    bindData();
  }

  bindData() async {
    //添加不为0的歌单

    //获取like

    var likeList = LikeUtil.instance.allVideoMap.values.toList();
    if (likeList.isNotEmpty) {
      //有数据
      allList.add({
        "type": 1,
        "title": "Liked songs".tr,
        "songNum": likeList.length,
        "list": likeList,
        "cover": "",
      });
    }

    var oldDList = DownloadUtils.instance.allDownLoadingData.values;
    var downloadList =
        oldDList.where((e) {
          return e["state"] == 2 && e["infoData"]["videoId"] == e["videoId"];
        }).toList();
    if (downloadList.isNotEmpty) {
      //有数据
      allList.add({
        "type": 2,
        "title": "Local songs".tr,
        "songNum": downloadList.length,
        "list": downloadList.map((e) => e["infoData"]).toList(),
        "cover": "",
      });
    }

    //获取其他本地歌单
    var box = await Hive.openBox(DBKey.myPlayListData);

    var oldList = box.values.toList();
    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });
    oldList.removeWhere((e) => e["type"] == 1);

    for (var item in oldList) {
      if (item["id"] == info["id"]) {
        continue;
      }

      List childList = item["list"] ?? [];
      if (childList.isNotEmpty) {
        allList.add({
          "type": 0,
          "title": item["title"],
          "songNum": childList.length,
          "list": childList,
          "cover": item["cover"],
        });
      }
    }
  }
}
