import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muse_wave/view/base_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../static/db_key.dart';
import '../../../tool/log.dart';
import '../../../tool/toast.dart';
import '../home.dart';
import 'list_info.dart';

class AddList extends GetView<AddListController> {
  final Map? addMap;

  const AddList({super.key, this.addMap});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AddListController());
    controller.addMap = addMap;
    if (addMap != null) {
      controller.checkIndex.value = 1;
    }

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
                    padding: EdgeInsets.symmetric(
                      vertical: 12.w,
                      horizontal: 12.w,
                    ),
                    children: [
                      //标题
                      Text("Playlist name", style: TextStyle(fontSize: 16.w)),

                      SizedBox(height: 10.w),
                      Container(
                        height: 54.w,
                        child: CupertinoTextField(
                          controller: controller.titleC,
                          placeholder: "title",
                          maxLength: 100,
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

                      //封面
                      Text("Cover", style: TextStyle(fontSize: 16.w)),

                      // SizedBox(
                      //   height: 10.w,
                      // ),
                      Row(
                        children: [
                          Container(
                            // color: Colors.black,
                            width: 110.w,
                            height: 110.w,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 10.w,
                                  child: InkWell(
                                    onTap: () {
                                      controller.chooseImg();
                                    },
                                    child: Obx(() {
                                      if (controller.coverData.value == null) {
                                        return Container(
                                          width: 100.w,
                                          height: 100.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xffDDF8FF,
                                            ).withOpacity(0.35),
                                            borderRadius: BorderRadius.circular(
                                              8.w,
                                            ),
                                          ),
                                          child: Icon(Icons.add, size: 40.w),
                                        );
                                      } else {
                                        //有图片
                                        return Container(
                                          width: 100.w,
                                          height: 100.w,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8.w,
                                            ),
                                          ),
                                          child: Image.memory(
                                            controller.coverData.value!,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    }),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Obx(() {
                                    if (controller.coverData.value != null) {
                                      return InkWell(
                                        onTap: () {
                                          controller.coverData.value = null;
                                        },
                                        child: Container(
                                          height: 25.w,
                                          width: 25.w,
                                          alignment: Alignment.center,
                                          // color: Colors.red,
                                          child: Image.asset(
                                            "assets/img/icon_remove_cover.png",
                                            width: 14.w,
                                            height: 14.w,
                                          ),
                                        ),
                                      );
                                    }
                                    return Container();
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                        ],
                      ),

                      SizedBox(height: 32.w),

                      Text("Type", style: TextStyle(fontSize: 16.w)),
                      SizedBox(height: 10.w),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 19.w,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: 166 / 86,
                        children:
                            (addMap == null ? [0, 1] : [1]).map((e) {
                              var iconList = ["1", "2"];
                              var titleList = ["Lyrics", "Tracks"];

                              return InkWell(
                                onTap: () {
                                  if (!controller.canChangeType) {
                                    ToastUtil.showToast(
                                      msg:
                                          "There are songs or lyrics under this playlist, the type cannot be changed",
                                    );
                                    return;
                                  }

                                  controller.checkIndex.value = e;
                                },
                                child: Obx(() {
                                  var isCheck =
                                      e == controller.checkIndex.value;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color:
                                          isCheck
                                              ? Color(0xffFFFAF7)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(8.w),
                                      border: Border.all(
                                        width: 2.w,
                                        color:
                                            isCheck
                                                ? Color(0xffFF9156)
                                                : Colors.white,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/img/icon_s_${iconList[e]}.png",
                                          width: 32.w,
                                          height: 32.w,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          titleList[e],
                                          style: TextStyle(
                                            fontSize: 12.w,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            }).toList(),
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
}

class AddListController extends GetxController {
  Map? addMap;

  var titleC = TextEditingController();

  var coverData = Rxn<Uint8List>();

  var checkIndex = 0.obs;

  String lid = "";

  //判断时候可以更改类型
  var canChangeType = true;

  @override
  void onInit() {
    super.onInit();

    lid = Get.arguments ?? "";
    if (lid.isEmpty) {
      return;
    }

    bindData();
  }

  Map infoData = {};
  bindData() async {
    var box = await Hive.openBox(DBKey.listData);
    infoData = box.get(lid);
    titleC.text = infoData["title"];
    coverData.value = infoData["cover"];
    checkIndex.value = infoData["type"];

    List list = infoData["list"] ?? [];
    canChangeType = list.isEmpty;
  }

  void btnOk() async {
    if (coverData.value == null) {
      ToastUtil.showToast(msg: "Select cover");
      return;
    }
    if (titleC.text.trim().isEmpty) {
      ToastUtil.showToast(msg: "Enter title");
      return;
    }
    //保存歌单

    var typeIndex = checkIndex.value;

    String id;

    if (lid.isNotEmpty) {
      id = lid;
    } else {
      id = Uuid().v8();
    }
    var data = {
      "id": id,
      "title": titleC.text,
      "saveTime": DateTime.now(),
      "type": typeIndex,
      "cover": coverData.value,
    };
    if (lid.isNotEmpty) {
      //添加歌单列表
      data["list"] = infoData["list"];
    }

    if (addMap != null) {
      //添加播放的音乐到歌单
      data["list"] = [addMap];
    }

    var box = await Hive.openBox(DBKey.listData);
    await box.put(id, data);
    //刷新首页数据
    Get.find<HomePageController>().bindData();
    //刷新详情数据
    if (Get.isRegistered<ListInfoController>()) {
      Get.find<ListInfoController>().bindData();
    }

    //返回
    Get.back();
  }

  chooseImg() async {
    if (GetPlatform.isIOS) {
      var lastStatus = await Permission.photos.status;
      AppLog.e(lastStatus);
      if (lastStatus.isPermanentlyDenied) {
        //永久拒绝后
        AppSettings.openAppSettings();
        return;
      }
      var thisStatus = await Permission.photos.request();
      if (thisStatus.isDenied) {
        return;
      }
    }

    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
    );

    if (file == null) {
      return;
    }
    coverData.value = await file.readAsBytes();

    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   withData: true,
    //   allowCompression: false,
    // );
    // if (result == null) {
    //   return;
    // }
    //
    // coverData.value = result.files.first.bytes;
    // coverData.value = await File(result.files.first.path!).readAsBytes();
  }
}
