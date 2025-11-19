import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_play.dart';
import 'package:muse_wave/view/player_bottom_bar.dart';

import '../../../api/api_main.dart';
import '../../../api/base_dio_api.dart';
import '../../../tool/format_data.dart';
import '../../../view/base_view.dart';

class UserMoreVideo extends GetView<UserMoreVideoController> {
  final String barTitle;
  final bool isFormSearch;
  const UserMoreVideo({
    super.key,
    required this.barTitle,
    this.isFormSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserMoreVideoController());
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
          title: Text(barTitle),
        ),
        body: PlayerBottomBarView(
          child: controller.obxView(
            (state) => Container(
              child: Obx(() {
                return EasyRefresh(
                  // onLoad: () async {
                  //   await controller.bindMoreData();
                  //   return controller.nextData.isEmpty
                  //       ? IndicatorResult.noMore
                  //       : IndicatorResult.success;
                  // },
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      bottom: Get.mediaQuery.padding.bottom + 100.w,
                    ),
                    itemBuilder: (_, i) {
                      return getItem(i);
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(height: 10.w);
                    },
                    itemCount: controller.list.length,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  getItem(int index) {
    var item = controller.list[index];

    return Obx(() {
      var isCheck =
          item["videoId"] ==
          Get.find<UserPlayInfoController>().nowData["videoId"];
      return InkWell(
        onTap: () {
          Get.find<UserPlayInfoController>().setDataAndPlayItem(
            List.of(controller.list),
            item,
            clickType: isFormSearch ? "s_detail_artist" : "h_detail_artist",
          );
          // Get.to(UserPlayInfo());
        },
        child: Container(
          height: 96.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 128.w,
                height: 72.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: NetImageView(
                        imgUrl: item["cover"] ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 6.w,
                      top: 6.w,
                      child:
                          isCheck
                              ? Image.asset(
                                "assets/oimg/icon_s_v_play.png",
                                width: 20.w,
                                height: 14.w,
                              )
                              : Container(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item["title"] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                        color: isCheck ? Color(0xffA491F7) : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item["subtitle"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isCheck
                                      ? Color(0xffA491F7).withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                              fontSize: 14.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class UserMoreVideoController extends GetxController with StateMixin {
  Map moreData = {};

  var list = [].obs;
  Map nextData = {};
  @override
  void onInit() {
    super.onInit();
    moreData = Get.arguments;
    bindData();
  }

  bindData() async {
    BaseModel result = await ApiMain.instance.getData(
      moreData["browseId"],
      params: moreData["params"],
    );
    if (result.code != HttpCode.success) {
      change("", status: RxStatus.error());
      return;
    }

    //解析
    List oldList =
        result
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["musicPlaylistShelfRenderer"]["contents"] ??
        [];

    // nextData = result.data["contents"]["singleColumnBrowseResultsRenderer"]
    //                 ["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]
    //             ["contents"][0]["musicPlaylistShelfRenderer"]?["continuations"]
    //         ?[0]?["nextContinuationData"] ??
    //     {};

    var newListData = FormatMyData.instance.getMusicList(oldList);
    list.value = newListData;
    change("", status: RxStatus.success());
  }
}
