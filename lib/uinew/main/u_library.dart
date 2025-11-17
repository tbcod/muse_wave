import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/u_home.dart';
import 'package:uuid/uuid.dart';

import '../../generated/assets.dart';
import '../../static/app_color.dart';
import '../../static/db_key.dart';
import '../../tool/ad/ad_util.dart';
import '../../tool/download/download_util.dart';
import '../../tool/like/like_util.dart';
import '../../tool/log.dart';
import '../../tool/tba/event_util.dart';
import '../../tool/toast.dart';
import '../../view/base_view.dart';
import '../../view/more_sheet_util.dart';
import 'home/u_play.dart';
import 'home/u_play_list.dart';
import 'libray/u_download_song.dart';
import 'libray/u_like_artist.dart';
import 'libray/u_like_song.dart';
import 'libray/u_loc_playlist.dart';

class UserLibrary extends GetView<UserLibraryController> {
  const UserLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLibraryController());
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/oimg/all_page_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: false,
          title: Text("Library".tr, style: TextStyle(fontSize: 20.w)),
          titleSpacing: 12.w,
        ),
        body: Container(
          child: ListView(
            // padding: EdgeInsets.symmetric(horizontal: 12.w),
            children: [
              Container(
                height: 160.w,
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => InkWell(
                        onTap: () {
                          LikeUtil.instance.removeNewState(1);

                          EventUtils.instance.addEvent("library_liked");
                          Get.to(UserLikeSong());
                        },
                        child: Stack(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 27.w,
                                      horizontal: 16.w,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.w),
                                      color: Color(0xffF5F3FF).withOpacity(0.5),
                                    ),
                                    width: 108.w,
                                    height: 130.w,
                                    child:
                                        controller.likeCover.isNotEmpty
                                            ? Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.w),
                                              ),
                                              child: NetImageView(
                                                imgUrl:
                                                    controller.likeCover.value,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.w),
                                              ),
                                              child: Image.asset(
                                                Assets.oimgIconLibLike,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  ),
                                  SizedBox(height: 6.w),
                                  Text(
                                    "Liked songs".tr,
                                    style: TextStyle(
                                      fontSize: 14.w,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 8.w,
                              top: 8.w,
                              child:
                                  controller.hasNewLikeVideo.value
                                      ? Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4.w,
                                          ),
                                        ),
                                      )
                                      : Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (FirebaseRemoteConfig.instance.getString(
                          "musicmuse_off_switch",
                        ) !=
                        "off")
                      Obx(
                        () => InkWell(
                          onTap: () {
                            DownloadUtils.instance.removeNewState();
                            EventUtils.instance.addEvent("library_offline");
                            Get.to(UserDownloadSong());
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 14.w),
                            child: Stack(
                              children: [
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 108.w,
                                        height: 130.w,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 27.w,
                                          horizontal: 16.w,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10.w,
                                          ),
                                          color: Color(
                                            0xffB4F6FF,
                                          ).withOpacity(0.09),
                                        ),
                                        child:
                                            controller.downloadCover.isNotEmpty
                                                ? Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.w,
                                                        ),
                                                  ),
                                                  child: NetImageView(
                                                    imgUrl:
                                                        controller
                                                            .downloadCover
                                                            .value,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                : Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.w,
                                                        ),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/oimg/icon_lib_download.png",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                      ),
                                      SizedBox(height: 6.w),
                                      Text(
                                        "Local songs".tr,
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 8.w,
                                  top: 8.w,
                                  child:
                                      controller.hasNewDownload.value
                                          ? Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4.w),
                                            ),
                                          )
                                          : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Obx(
                      () => InkWell(
                        onTap: () {
                          LikeUtil.instance.removeNewState(2);
                          EventUtils.instance.addEvent("library_artist");
                          Get.to(UserLikeArtist());
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 14.w),
                          child: Stack(
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 27.w,
                                        horizontal: 16.w,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.w,
                                        ),
                                        color: Color(
                                          0xffFFEAEC,
                                        ).withOpacity(0.15),
                                      ),
                                      width: 108.w,
                                      height: 130.w,
                                      child:
                                          controller.artistCover.isNotEmpty
                                              ? Container(
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.w,
                                                      ),
                                                ),
                                                child: NetImageView(
                                                  imgUrl:
                                                      controller
                                                          .artistCover
                                                          .value,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : Container(
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.w,
                                                      ),
                                                ),
                                                child: Image.asset(
                                                  "assets/oimg/icon_lib_artist.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                    ),
                                    SizedBox(height: 6.w),
                                    Text(
                                      "Artist".tr,
                                      style: TextStyle(
                                        fontSize: 14.w,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 8.w,
                                top: 8.w,
                                child:
                                    controller.hasNewLikeArtist.value
                                        ? Container(
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              4.w,
                                            ),
                                          ),
                                        )
                                        : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.w),
              //playlist标题栏
              Container(
                height: 28.w,
                padding: EdgeInsets.only(left: 12.w, right: 20.w),
                child: Row(
                  children: [
                    Text(
                      "Playlist".tr,
                      style: TextStyle(
                        fontSize: 18.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        controller.showAddView();
                      },
                      child: Container(
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Color(0xff876CFF),
                          borderRadius: BorderRadius.circular(14.w),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 9.w),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 12.w, color: Colors.white),
                            Text(
                              "New playlist".tr,
                              style: TextStyle(
                                fontSize: 10.w,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.center,
                child: MyNativeAdView(
                  adKey: "pagebanner",
                  positionKey: "library",
                ),
              ),

              //自建歌单列表
              controller.obxView(
                (s) => Obx(
                  () => ListView.separated(
                    padding: EdgeInsets.only(
                      top: 12.w,
                      bottom: 100.w,
                      left: 8.w,
                      right: 8.w,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      return getItem(i);
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(height: 8.w);
                    },
                    itemCount: controller.list.length,
                  ),
                ),
                onEmpty: Container(
                  height: 300.w,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/img/icon_empty.png",
                          width: 180.w,
                          height: 180.w,
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          "No content found".tr,
                          style: TextStyle(fontSize: 16.w, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                onLoading: Container(
                  height: 300.w,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColor.mainColor),
                  ),
                ),
              ),

              SizedBox(height: 100.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget getItem(int i) {
    var item = controller.list[i];

    List childList = item["list"] ?? [];

    var isNetPlaylist = item["type"] == 1;

    return InkWell(
      onTap: () {
        if (isNetPlaylist) {
          //网络歌单
          EventUtils.instance.addEvent(
            "det_playlist_show",
            data: {"from": "library"},
          );
          // Get.to(UserPlayListInfo(), arguments: {"browseId": item["id"]});
          Get.to(UserPlayListInfo(), arguments: item);
          return;
        }

        EventUtils.instance.addEvent(
          "det_playlist_show",
          data: {"from": "library"},
        );

        // EventUtils.instance.addEvent("library_artist");
        Get.to(UserLocPlayListInfo(), arguments: item);
      },
      child: Container(
        padding: EdgeInsets.only(left: 8.w, right: 0.w),
        height: 70.w,
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 54.w,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                        color: Color(0xffE0E0EF),
                      ),
                    ),
                  ),

                  //默认封面
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 54.w,
                      height: 54.w,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child:
                          item["cover"] == null
                              ?
                              //默认封面
                              Image.asset("assets/oimg/icon_d_item.png")
                              : NetImageView(
                                imgUrl: item["cover"],
                                fit: BoxFit.cover,
                                errorAsset: Assets.oimgIconDItem,
                              ),
                    ),
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
                    style: TextStyle(fontSize: 14.w),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.w),
                  Text(
                    isNetPlaylist
                        ? "${item["subtitle"] ?? ""}"
                        : "${childList.length} songs",
                    style: TextStyle(
                      fontSize: 12.w,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (!isNetPlaylist)
              InkWell(
                onTap: () {
                  MoreSheetUtil.instance.showPlaylistMoreSheet(item);
                },
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  child: Image.asset("assets/oimg/icon_more.png"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UserLibraryController extends GetxController with StateMixin {
  var list = [].obs;

  void showAddView() async {
    var inputC = TextEditingController();

    var canClick = false.obs;
    //不显示播放控件
    Get.find<UserPlayInfoController>().hideFloatingWidget();
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffEAE8F9), Color(0xfffafafa)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Create playlist".tr,
                style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CupertinoTextField(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                controller: inputC,
                autofocus: true,
                placeholder: "${"Enter name".tr}\n\n\n\n",
                maxLines: 5,
                maxLength: 100,
                style: TextStyle(fontSize: 14.w),
                onChanged: (s) {
                  canClick.value = s.trim().isNotEmpty;
                },
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 32.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.w),
                          border: Border.all(
                            color: Color(0xff824EFF).withOpacity(0.75),
                            width: 2.w,
                          ),
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Color(0xff824EFF).withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 23.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (inputC.text.trim().isEmpty) {
                          ToastUtil.showToast(msg: "Enter name".tr);
                          return;
                        }
                        //保存信息
                        await savePlayList(inputC.text);

                        Get.back();
                      },
                      child: Obx(
                        () => Container(
                          height: 48.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                canClick.value
                                    ? Color(0xff824EFF)
                                    : Color(0xff824EFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24.w),
                          ),
                          child: Text(
                            "Confirm".tr,
                            style: TextStyle(
                              fontSize: 14.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.w),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      // barrierColor: Colors.black.withOpacity(0.43),
      backgroundColor: Color(0xfffafafa),
    );
    Get.find<UserPlayInfoController>().showFloatingWidget();
  }

  @override
  void onInit() {
    super.onInit();
    bindMyPlayListData();

    bindNewData();
  }

  var hasNewLikeVideo = false.obs;
  var hasNewDownload = false.obs;
  var hasNewLikeArtist = false.obs;

  var likeCover = "".obs;
  var downloadCover = "".obs;
  var artistCover = "".obs;

  bindNewData() async {
    likeCover.value =
        LikeUtil.instance.allVideoMap.values.lastOrNull?["cover"] ?? "";
    artistCover.value =
        LikeUtil.instance.allArtistMap.values.lastOrNull?["cover"] ?? "";
    List allDData = DownloadUtils.instance.allDownLoadingData.values.toList();
    var dList = List.of(allDData).reversed.toList();
    var newItem = dList.firstWhereOrNull((e) => e["state"] == 2);
    downloadCover.value = newItem?["infoData"]?["cover"] ?? "";

    // downloadCover.value = DownloadUtils.instance.allDownLoadingData.values
    //         .lastOrNull?["infoData"]?["cover"] ??
    //     "";

    hasNewLikeVideo = LikeUtil.instance.hasNewLikeVideo;
    hasNewLikeArtist = LikeUtil.instance.hasNewLikeArtist;
    hasNewDownload = DownloadUtils.instance.hasNewDownload;
  }

  bindMyPlayListData() async {
    var box = await Hive.openBox(DBKey.myPlayListData);

    // await box.clear();

    var oldList = box.values.toList();
    //时间降序
    oldList.sort((a, b) {
      DateTime aDate = a["date"];
      DateTime bDate = b["date"];
      return bDate.compareTo(aDate);
    });
    // oldList.removeWhere((e)=>e["type"]==1);

    list.value = oldList;

    change("", status: list.isEmpty ? RxStatus.empty() : RxStatus.success());

    //刷新首页数据
    Get.find<UserHomeController>().reloadHistory();
  }

  // Future savePlayList(String title) async {
  //   var box = await Hive.openBox(DBKey.myPlayListData);
  //   var id = Uuid().v8();
  //   await box.put(id, {"title": title, "date": DateTime.now(), "id": id});
  //   bindMyPlayListData();
  // }

  Future savePlayList(String title) async {
    var box = await Hive.openBox(DBKey.myPlayListData);
    var id = Uuid().v8();

    //获取是否使用名字
    var nameList = box.values.map((e) => e["title"]).toList();

    var realName = getRealName(nameList, title);
    AppLog.e(realName);

    await box.put(id, {"title": realName, "date": DateTime.now(), "id": id});
    bindMyPlayListData();
  }

  String getRealName(List nameList, String name, {int nameNum = 0}) {
    if (nameNum == 0) {
      if (nameList.contains(name)) {
        return getRealName(nameList, name, nameNum: nameNum + 1);
      }
      return name;
    } else {
      if (nameList.contains("$name($nameNum)")) {
        return getRealName(nameList, name, nameNum: nameNum + 1);
      }
      return "$name($nameNum)";
    }
  }
}
