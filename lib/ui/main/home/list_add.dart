import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/ui/main/home/search.dart';
import 'package:muse_wave/view/base_view.dart';

import '../../../generated/assets.dart';
import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import '../../../tool/toast.dart';
import '../home.dart';
import 'list_info.dart';

class ListAddPage extends GetView<ListAddPageController> {
  const ListAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ListAddPageController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              title: Text("Add to playlist"),
              actions: [
                IconButton(
                  onPressed: () async {
                    //保存歌单
                    //保存

                    LoadingUtil.showLoading();
                    var box = await Hive.openBox(DBKey.listData);
                    var data = Map.of(controller.infoData);
                    data["list"] = controller.checkList.value;
                    await box.put(controller.id, data);
                    LoadingUtil.hideAllLoading();
                    //刷新数据
                    Get.find<HomePageController>().bindData();
                    if (Get.isRegistered<ListInfoController>()) {
                      Get.find<ListInfoController>().bindData();
                    }
                    //刷新搜索列表
                    if (Get.isRegistered<SearchPageController>()) {
                      Get.find<SearchPageController>().reloadData();
                    }

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
            Expanded(
              child: Container(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: Obx(() {
                    return ListView.separated(
                      padding: EdgeInsets.only(
                        top: 16.w,
                        bottom: Get.mediaQuery.padding.bottom + 8.w + 50.w,
                      ),
                      itemBuilder: (_, i) {
                        if (controller.isMusic) {
                          return getItem2(i);
                        }
                        return getItem1(i);
                      },
                      separatorBuilder: (_, i) {
                        return SizedBox(
                          height: controller.isMusic ? 26.w : 20.w,
                        );
                      },
                      itemCount: controller.list.length,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //歌词
  Widget getItem1(int i) {
    var item = controller.list[i];

    return InkWell(
      onTap: () async {
        if (controller.checkList.contains(item)) {
          controller.checkList.remove(item);
        } else {
          controller.checkList.add(item);
        }

        // //保存
        // var box = await Hive.openBox(DBKey.listData);
        // var data = Map.of(controller.infoData);
        // data["list"] = controller.checkList.value;
        // await box.put(controller.infoData["id"], data);
        // //刷新数据
        // Get.find<HomePageController>().bindData();
        // if (Get.isRegistered<ListInfoController>()) {
        //   Get.find<ListInfoController>().bindData();
        // }
      },
      child: Obx(() {
        var isCheck = controller.checkList.contains(item);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isCheck ? Color(0xffF4F7FF) : Color(0xffF4F7FF),
                    border:
                        isCheck
                            ? Border.all(
                              color: Color(0xff558CFF),
                              width: 1.w,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )
                            : null,
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.w),
                      ),
                      SizedBox(height: 10.w),
                      Text(
                        item["lyrics"],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Color(0xff141414).withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Image.asset(
                isCheck
                    ? "assets/img/icon_playlist_add_ok.png"
                    : "assets/img/icon_playlist_add.png",
                width: 20.w,
                height: 20.w,
              ),
              // Obx(() {
              //   var isCheck = controller.checkList.contains(item);
              //   return Image.asset(
              //     isCheck
              //         ? "assets/img/icon_playlist_add_ok.png"
              //         : "assets/img/icon_playlist_add.png",
              //     width: 20.w,
              //     height: 20.w,
              //   );
              // }),
            ],
          ),
        );
      }),
    );
  }

  //歌曲
  Widget getItem2(int i) {
    var item = controller.list[i];

    Uint8List? cover = item["cover"];

    return InkWell(
      onTap: () async {
        var isCheck = controller.checkList
            .map((e) => e["id"])
            .contains(item["id"]);

        if (isCheck) {
          // ToastUtil.showToast(msg: "Already added");
          // return;
          controller.checkList.removeWhere((e) => e["id"] == item["id"]);
        } else {
          controller.checkList.add(item);
        }

        // //保存
        // var box = await Hive.openBox(DBKey.listData);
        // var data = Map.of(controller.infoData);
        // data["list"] = controller.checkList.value;
        // await box.put(controller.infoData["id"], data);
        // //刷新数据
        // Get.find<HomePageController>().bindData();
        // if (Get.isRegistered<ListInfoController>()) {
        //   Get.find<ListInfoController>().bindData();
        // }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
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
              ),
            ),
            Obx(() {
              // var isCheck = controller.checkList.contains(item);
              var isCheck = controller.checkList
                  .map((e) => e["id"])
                  .contains(item["id"]);
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

class ListAddPageController extends GetxController {
  var list = [].obs;
  var isMusic = false;

  var infoData = {};

  var checkList = [].obs;

  var id = "";

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments ?? "";
    // isMusic = infoData["type"] == 1;
    // checkList.value = infoData["list"] ?? [];
    bindData();
  }

  bindData() async {
    var box = await Hive.openBox(DBKey.listData);
    infoData = box.get(id);

    AppLog.e(infoData["title"]);
    AppLog.e(infoData["type"]);
    isMusic = infoData["type"] == 1;
    AppLog.e(isMusic);
    checkList.value = List.of(infoData["list"] ?? []);

    if (isMusic) {
      var box = await Hive.openBox(DBKey.tracksData);
      AppLog.e(box.values.length);
      list.value = List.of(box.values.toList());
    } else {
      var box = await Hive.openBox(DBKey.lyricsData);
      list.value = List.of(box.values.toList());
    }
  }
}
