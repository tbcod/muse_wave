import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/ui/main/home/play.dart';
import 'package:muse_wave/view/base_view.dart';

import '../../../generated/assets.dart';
import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import '../../../tool/toast.dart';
import '../home.dart';
import 'add_list.dart';
import 'create_music_lyrics.dart';
import 'list_add.dart';
import 'lyrics_info.dart';

class ListInfo extends GetView<ListInfoController> {
  const ListInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ListInfoController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    showMoreListView(controller.infoData);
                  },
                  // icon: Image.asset(
                  //   "assets/img/icon_edit.png",
                  //   width: 24.w,
                  //   height: 24.w,
                  // )
                  icon: Icon(Icons.more_vert),
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
                            child: Column(
                              children: [
                                Container(
                                  height: 136.w,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Row(
                                    children: [
                                      //封面
                                      Container(
                                        height: 136.w,
                                        width: 160.w,
                                        child: Stack(
                                          children: [
                                            //底部
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child:
                                                  controller.infoData["type"] ==
                                                          1
                                                      ? Container(
                                                        width: 130.w,
                                                        height: 130.w,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                66.w,
                                                              ),
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                      : Container(
                                                        width: 128.w,
                                                        height: 128.w,
                                                        margin: EdgeInsets.only(
                                                          right: 10.w,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xff141414,
                                                          ).withOpacity(0.15),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.w,
                                                              ),
                                                        ),
                                                      ),
                                            ),

                                            //封面
                                            Container(
                                              width: 142.w,
                                              height: 142.w,
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.w),
                                              ),
                                              child: Image.memory(
                                                controller.infoData["cover"],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20.w),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.infoData["title"],
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16.w),
                                            ),
                                            SizedBox(height: 16.w),
                                            Obx(
                                              () => Text(
                                                "${controller.list.length} songs",
                                                style: TextStyle(
                                                  fontSize: 12.w,
                                                  color: Color(
                                                    0xff141414,
                                                  ).withOpacity(0.75),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.w),

                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 18.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.w),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Obx(
                                          () =>
                                              controller.list.isEmpty
                                                  ? Container()
                                                  : Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Obx(
                                                          () => Text(
                                                            "Playlist  (${controller.list.length})  ",
                                                            style: TextStyle(
                                                              fontSize: 20.w,
                                                            ),
                                                          ),
                                                        ),
                                                        //播放全部按钮
                                                        if (controller
                                                                .infoData["type"] ==
                                                            1)
                                                          InkWell(
                                                            onTap: () {
                                                              // if (!controller.isMusic) {
                                                              //   ToastUtil.showToast(
                                                              //       msg: "仅支持音乐歌单");
                                                              //   return;
                                                              // }

                                                              Get.find<
                                                                    PlayPageController
                                                                  >()
                                                                  .setDataAndPlay({
                                                                    "item":
                                                                        controller
                                                                            .list[0],
                                                                    "list":
                                                                        controller
                                                                            .list,
                                                                  });
                                                              Get.to(
                                                                PlayPage(),
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 26.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Color(
                                                                      0xffE8F0FF,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          13.w,
                                                                        ),
                                                                  ),
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6.w,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .play_arrow_rounded,
                                                                    size: 16.w,
                                                                  ),

                                                                  SizedBox(
                                                                    width: 2.w,
                                                                  ),
                                                                  Text(
                                                                    "Play All",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          10.w,
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                        ),
                                        SizedBox(height: 14.w),
                                        Expanded(
                                          child: Obx(() {
                                            if (controller.list.isEmpty) {
                                              //空布局
                                              return Container(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 40.w),
                                                    Image.asset(
                                                      Assets.imgIconNoContent,
                                                      width: 140.w,
                                                      height: 140.w,
                                                    ),
                                                    Text(
                                                      "No content now, Add songs you like",
                                                      style: TextStyle(
                                                        fontSize: 14.w,
                                                      ),
                                                    ),
                                                    SizedBox(height: 32.w),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                          ListAddPage(),
                                                          arguments:
                                                              controller.id,
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 48.w,
                                                        width: 112.w,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.w,
                                                              ),
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Color(
                                                              0xff558CFF,
                                                            ),
                                                            width: 1.w,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "Add",
                                                          style: TextStyle(
                                                            fontSize: 14.w,
                                                            color: Color(
                                                              0xff558CFF,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }

                                            return ListView.separated(
                                              padding: EdgeInsets.only(
                                                top: 5.w,
                                                bottom:
                                                    Get
                                                        .mediaQuery
                                                        .padding
                                                        .bottom +
                                                    8.w +
                                                    50.w,
                                              ),
                                              itemBuilder: (_, i) {
                                                if (controller.isMusic) {
                                                  return getList2Item(i);
                                                }
                                                return getList1Item(i);
                                              },
                                              separatorBuilder: (_, i) {
                                                return SizedBox(height: 18.w);
                                              },
                                              itemCount: controller.list.length,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
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

  getList1Item(int i) {
    var item = controller.list[i];

    return InkWell(
      onTap: () {
        Get.to(LyricsInfo(), arguments: item);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6.w,
              spreadRadius: 2.w,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 34.w,
                  width: 88.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12.w),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xff6898FC), Color(0xffECF2FF)],
                    ),
                  ),
                  child: Text("Lyrics ${i + 1}"),
                ),
                Spacer(),
                Container(
                  width: 72.w,
                  height: 28.w,
                  margin: EdgeInsets.only(top: 4.w, right: 4.w),
                  padding: EdgeInsets.symmetric(horizontal: 13.w),
                  decoration: BoxDecoration(
                    color: Color(0xffFFE9DD),
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 18.w),
                      Text("Play", style: TextStyle(fontSize: 12.w)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.w),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                item["title"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                item["lyrics"] ?? "",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.w,
                  color: Color(0xff141414).withOpacity(0.8),
                ),
              ),
            ),

            SizedBox(height: 18.w),
          ],
        ),
      ),
    );
  }

  getList2Item(int i) {
    var item = controller.list[i];
    // var itemData = {
    //   "id": id,
    //   "saveTime": DateTime.now(),
    //   "title": musicName,
    //   "cover": albumArt,
    //   "fileData": file.bytes,
    // };
    Uint8List? fileData = item["fileData"];
    Uint8List? cover = item["cover"];

    return InkWell(
      onTap: () {
        Get.find<PlayPageController>().setDataAndPlay({
          "item": item,
          "list": controller.list,
        });
        Get.to(PlayPage());
      },
      child: Obx(() {
        var isCheck =
            Get.find<PlayPageController>().nowData["id"] == item["id"];
        return Container(
          // height: 52.w,
          padding: EdgeInsets.only(left: 16.w, right: 0, top: 5.w, bottom: 5.w),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isCheck ? Color(0xfff4f4f4) : Colors.transparent,
          ),
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
                    fontSize: 14.w,
                    color: isCheck ? Color(0xff6898FC) : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 35.w),

              InkWell(
                onTap: () {
                  showMoreView(item);
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Image.asset(
                    Assets.imgIconMore,
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  showMoreView(Map item) async {
    //底部弹出更多

    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE9F0FC), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Spacer(),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close, size: 20.w),
                ),
              ],
            ),

            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, i) {
                var titleList = ["Create Lyric", "Edit", "Delete"];
                var iconList = ["more1", "more2", "more3"];

                return InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.w,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/img/icon_${iconList[i]}.png",
                          width: 24.w,
                          height: 24.w,
                        ),
                        SizedBox(width: 16.w),
                        Text(titleList[i]),
                      ],
                    ),
                  ),
                  onTap: () async {
                    Get.back();
                    if (i == 0) {
                      //歌曲创建歌词
                      Get.to(CreateMusicLyrics(), arguments: item["id"]);
                    } else if (i == 1) {
                      //编辑
                      await Future.delayed(Duration(milliseconds: 400));
                      showRenameView(item);
                    } else if (i == 2) {
                      //删除
                      var box = await Hive.openBox(DBKey.tracksData);
                      await box.delete(item["id"]);
                      ToastUtil.showToast(msg: "Delete successfully".tr);
                      controller.bindData();
                    }
                  },
                );
              },
              separatorBuilder: (_, i) {
                return SizedBox(height: 16.w);
              },
              itemCount: 3,
            ),
            SizedBox(height: 32.w),
            // Container(
            //   height: 1.w,
            //   width: double.infinity,
            //   color: Color(0xff121212).withOpacity(0.05),
            // ),
            // InkWell(
            //   onTap: () {
            //     Get.back();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.symmetric(vertical: 16.w),
            //     width: double.infinity,
            //     alignment: Alignment.center,
            //     // color: Colors.red,
            //     child: Text(
            //       "Cancel",
            //       style: TextStyle(color: Color(0xff121212).withOpacity(0.75)),
            //     ),
            //   ),
            // ),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
    //关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }

  showMoreListView(Map item) async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE9F0FC), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Spacer(),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close, size: 20.w),
                ),
              ],
            ),

            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, i) {
                var titleList = ["Edit Playlist", "Edit", "Delete"];
                var iconList = ["more1", "more2", "more3"];

                return InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.w,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/img/icon_${iconList[i]}.png",
                          width: 24.w,
                          height: 24.w,
                        ),
                        SizedBox(width: 16.w),
                        Text(titleList[i]),
                      ],
                    ),
                  ),
                  onTap: () async {
                    Get.back();
                    if (i == 1) {
                      //编辑
                      Get.to(AddList(), arguments: item["id"]);
                    } else if (i == 2) {
                      //删除歌单
                      var box = await Hive.openBox(DBKey.listData);
                      await box.delete(item["id"]);
                      ToastUtil.showToast(msg: "Delete successfully");
                      // controller.bindData();
                      //刷新首页
                      Get.find<HomePageController>().bindData();
                      Get.back();
                    } else if (i == 0) {
                      Get.to(ListAddPage(), arguments: controller.id);
                    }
                  },
                );
              },
              separatorBuilder: (_, i) {
                return SizedBox(height: 16.w);
              },
              itemCount: 3,
            ),
            SizedBox(height: 32.w),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
    //关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }

  showRenameView(Map item) async {
    //不显示播放控件
    Get.find<PlayPageController>().hideFloatingWidget();

    var inputC = TextEditingController();
    inputC.text = item["title"] ?? "";

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffE9F0FC), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close, size: 20.w),
                ),
              ],
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text("Rename", style: TextStyle(fontSize: 20.w)),
            ),
            SizedBox(height: 16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CupertinoTextField(
                controller: inputC,
                autofocus: true,
                placeholder: "Enter name\n\n\n\n",
                maxLines: 5,
                maxLength: 100,
                style: TextStyle(fontSize: 14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 240.w,
                  height: 48.w,
                  decoration: BoxDecoration(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: InkWell(
                    onTap: () async {
                      if (inputC.text.trim().isEmpty) {
                        ToastUtil.showToast(msg: "Enter name".tr);
                        return;
                      }
                      //保存信息
                      var box = await Hive.openBox(DBKey.tracksData);

                      var id = item["id"];
                      var data = Map.of(item);
                      data["title"] = inputC.text;
                      await box.put(id, data);
                      //刷新首页数据
                      controller.bindData();
                      //刷新播放列表
                      Get.find<PlayPageController>().reloadList();

                      Get.back();
                    },
                    child: Container(
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xff3B7BFF),
                        borderRadius: BorderRadius.circular(24.w),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(fontSize: 14.w, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.w),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
      isScrollControlled: true,
    );
    //关闭后显示
    Get.find<PlayPageController>().showFloatingWidget();
  }
}

class ListInfoController extends GetxController {
  var infoData = {}.obs;
  var id = "";
  var isMusic = false;
  var list = [].obs;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments ?? "";
    bindData();
  }

  bindData() async {
    var box = await Hive.openBox(DBKey.listData);
    infoData.value = box.get(id);
    isMusic = infoData["type"] == 1;

    //list数据
    List oldList = infoData["list"] ?? [];
    var idList =
        oldList.map((e) {
          return e["id"];
        }).toList();

    Box box2;
    if (isMusic) {
      box2 = await Hive.openBox(DBKey.tracksData);
    } else {
      box2 = await Hive.openBox(DBKey.lyricsData);
    }

    list.clear();
    for (int i = 0; i < idList.length; i++) {
      list.add(box2.get(idList[i]));
    }
    // list.value = infoData["list"] ?? [];
    AppLog.e(list.length);
  }
}
