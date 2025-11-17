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
import 'list_info.dart';
import 'lyrics_info.dart';

class SearchPage extends GetView<SearchPageController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SearchPageController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Row(
                children: [
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 44.w,
                      child: CupertinoTextField(
                        focusNode: controller.focusNode,
                        controller: controller.inputC,
                        autofocus: true,
                        padding: EdgeInsets.only(left: 4.w, right: 4.w),
                        placeholder: "Search your songs",
                        style: TextStyle(fontSize: 12.w),
                        onSubmitted: (str) {
                          //关闭键盘
                          Get.focusScope?.unfocus();
                          controller.searchData(str);
                        },
                        onChanged: (str) {
                          controller.showDel.value = str.isNotEmpty;

                          if (str.isEmpty) {
                            controller.allList.clear();
                            return;
                          }
                          controller.searchData(str);
                        },
                        suffix: Obx(
                          () =>
                              controller.showDel.value
                                  ? Container(
                                    margin: EdgeInsets.only(right: 12.w),
                                    child: InkWell(
                                      child: Container(
                                        // color: Colors.red,
                                        padding: EdgeInsets.all(4.w),
                                        child: Image.asset(
                                          "assets/img/icon_s_remove.png",
                                          width: 20.w,
                                          height: 20.w,
                                        ),
                                      ),
                                      onTap: () {
                                        controller.inputC.clear();
                                        controller.showDel.value = false;
                                        controller.allList.clear();
                                        controller.isEmpty.value = false;

                                        //打开键盘
                                        Get.focusScope?.requestFocus(
                                          controller.focusNode,
                                        );
                                      },
                                    ),
                                  )
                                  : Container(),
                        ),
                        prefix: Container(
                          margin: EdgeInsets.only(left: 12.w),
                          child: Image.asset(
                            "assets/img/icon_search.png",
                            width: 20.w,
                            height: 20.w,
                          ),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xff6898FC),
                            width: 2.w,
                          ),
                          borderRadius: BorderRadius.circular(16.w),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xff141414),
                      textStyle: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Obx(
                  () =>
                      controller.isEmpty.value
                          ? getEmptyView()
                          : Obx(
                            () => ListView.separated(
                              padding: EdgeInsets.only(
                                top: 24.w,
                                bottom:
                                    Get.mediaQuery.padding.bottom + 8.w + 50.w,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return getItem(index);
                              },
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return SizedBox(height: 10.w);
                              },
                              itemCount: controller.allList.length,
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

  Widget getItem(int index) {
    var type = controller.allList[index]["type"];
    if (type == 1) {
      return getList1Item(index);
    } else if (type == 2) {
      return getList2Item(index);
    } else {
      return getList3Item(index);
    }
  }

  getList1Item(int i) {
    var item = controller.allList[i]["data"];

    return InkWell(
      onTap: () {
        //关闭键盘
        Get.focusScope?.unfocus();
        Get.to(LyricsInfo(), arguments: item);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
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
    var item = controller.allList[i]["data"];
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
        //关闭键盘
        Get.focusScope?.unfocus();

        var mlist =
            controller.allList
                .where((e) {
                  return e["type"] == 2;
                })
                .map((e) {
                  return e["data"];
                })
                .toList();

        Get.find<PlayPageController>().setDataAndPlay({
          "item": item,
          "list": mlist,
        });
        Get.to(PlayPage());
      },
      child: Container(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        width: double.infinity,
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
            Expanded(child: Text(item["title"])),
            SizedBox(width: 35.w),

            // InkWell(
            //     onTap: () {
            //       showMoreView();
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

  getList3Item(int i) {
    var item = controller.allList[i]["data"];
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
      onTap: () {
        //关闭键盘
        Get.focusScope?.unfocus();
        Get.to(ListInfo(), arguments: item["id"]);
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
            //       showMoreView();
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

  getEmptyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SizedBox(
        //   height: 94.w,
        // ),
        Image.asset(Assets.imgIconNoContent, width: 140.w, height: 140.w),
        SizedBox(height: 14.w),
        Text("No content", style: TextStyle(fontSize: 14.w)),
        SizedBox(height: 32.w + Get.mediaQuery.padding.bottom),
      ],
    );
  }
}

class SearchPageController extends GetxController {
  TextEditingController inputC = TextEditingController();

  var focusNode = FocusNode();

  var showDel = false.obs;

  var allList = [].obs;

  var isEmpty = false.obs;
  void searchData(String str) async {
    allList.clear();

    //查询歌词
    var box1 = await Hive.openBox(DBKey.lyricsData);
    var list1 =
        box1.values.where((e) {
          return e["title"].toString().contains(str);
        }).toList();
    //查询歌曲
    var box2 = await Hive.openBox(DBKey.tracksData);
    var list2 =
        box2.values.where((e) {
          return e["title"].toString().contains(str);
        }).toList();

    //查询歌单
    var box3 = await Hive.openBox(DBKey.listData);
    var list3 =
        box3.values.where((e) {
          return e["title"].toString().contains(str);
        }).toList();

    //添加到list
    allList.addAll(
      list1.map((e) {
        return {"type": 1, "data": e};
      }).toList(),
    );
    allList.addAll(
      list2.map((e) {
        return {"type": 2, "data": e};
      }).toList(),
    );
    allList.addAll(
      list3.map((e) {
        return {"type": 3, "data": e};
      }).toList(),
    );

    isEmpty.value = allList.isEmpty;
  }

  void reloadData() async {
    searchData(inputC.text);
  }
}
