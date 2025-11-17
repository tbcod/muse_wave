import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/ext/state_ext.dart';
import 'package:muse_wave/uinew/main/home/u_play_list.dart';

import '../../../api/api_main.dart';
import '../../../tool/format_data.dart';
import '../../../tool/log.dart';
import '../../../tool/tba/event_util.dart';
import '../../../view/base_view.dart';

class UserMoreAlbum extends GetView<UserMoreAlbumController> {
  final String barTitle;
  const UserMoreAlbum({super.key, required this.barTitle});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserMoreAlbumController());
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
        body: controller.obxView(
          (state) => Container(
            child: Obx(
              () => GridView.builder(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: Get.mediaQuery.padding.bottom + 100.w,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.75,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.w,
                  crossAxisSpacing: 16.w,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return getItem(index);
                },
                itemCount: controller.list.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  getItem(int index) {
    var childItem = controller.list[index];

    return GestureDetector(
      onTap: () {
        AppLog.e(childItem);
        EventUtils.instance.addEvent(
          "det_playlist_show",
          data: {"from": "artist_album"},
        );
        Get.to(UserPlayListInfo(), arguments: childItem);
      },
      child: Container(
        // width: 140.w,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: (Get.width - 16.w - 48.w) / 2,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetImageView(
                      imgUrl: childItem["cover"] ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.w),
            Text(
              childItem["title"],
              style: TextStyle(fontSize: 14.w),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class UserMoreAlbumController extends GetxController with StateMixin {
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
            .data["contents"]["singleColumnBrowseResultsRenderer"]["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]["contents"][0]["gridRenderer"]["items"] ??
        [];

    // nextData = result.data["contents"]["singleColumnBrowseResultsRenderer"]
    //                 ["tabs"][0]["tabRenderer"]["content"]["sectionListRenderer"]
    //             ["contents"][0]["musicPlaylistShelfRenderer"]?["continuations"]
    //         ?[0]?["nextContinuationData"] ??
    //     {};

    var newListData = FormatMyData.instance.getOtherList(oldList);
    list.value = newListData;
    change("", status: RxStatus.success());
  }
}
