import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../tool/like/like_util.dart';
import '../../../view/base_view.dart';
import '../home/u_play.dart';

class UserLikeSong extends GetView<UserLikeSongController> {
  final bool isFormHome;

  const UserLikeSong({super.key, this.isFormHome = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserLikeSongController());
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
          title: Text("Liked songs".tr),
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
        body: Obx(
          () => ListView.separated(
            padding: EdgeInsets.only(
              bottom: Get.mediaQuery.padding.bottom + 60.w,
            ),
            itemBuilder: (_, i) {
              return getMusicItem(controller.list[i]);
            },
            separatorBuilder: (_, i) {
              return SizedBox(height: 10.w);
            },
            itemCount: controller.list.length,
          ),
        ),
      ),
    );
  }

  getMusicItem(Map item) {
    return InkWell(
      onTap: () {
        Get.find<UserPlayInfoController>().setDataAndPlayItem(
          controller.list,
          item,
          clickType: "liked",
        );
        // Get.to(UserPlayInfo());
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
                  SizedBox(height: 10.w),
                  Row(
                    children: [
                      Obx(() {
                        var isLike = LikeUtil.instance.allVideoMap.containsKey(
                          item["videoId"],
                        );
                        if (isLike) {
                          return Container(
                            width: 16.w,
                            height: 16.w,
                            margin: EdgeInsets.only(right: 4.w),
                            child: Image.asset("assets/oimg/icon_like_on.png"),
                          );
                        }

                        return Container();
                      }),
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
                          style: TextStyle(
                            fontSize: 12.w,
                            color: Colors.black.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            getDownloadAndMoreBtn(item, "liked", locIsHome: isFormHome),
            //
            // Obx(() {
            //   //获取下载状态
            //   var videoId = item["videoId"];
            //
            //   if (DownloadUtils.instance.allDownLoadingData
            //       .containsKey(videoId)) {
            //     //有添加过下载
            //     var state =
            //         DownloadUtils.instance.allDownLoadingData[videoId]["state"];
            //     double progress = DownloadUtils
            //         .instance.allDownLoadingData[videoId]["progress"];
            //
            //     // AppLog.e(
            //     //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");
            //
            //     if (state == 1 || state == 3) {
            //       //下载中\下载暂停
            //       return InkWell(
            //         onTap: () {
            //           DownloadUtils.instance.remove(videoId);
            //         },
            //         child: Container(
            //             width: 20.w,
            //             height: 20.w,
            //             // padding: EdgeInsets.all(5.w),
            //             child: CircularProgressIndicator(
            //               value: progress,
            //               strokeWidth: 1.5,
            //               backgroundColor: Color(0xffA995FF).withOpacity(0.35),
            //               color: Color(0xffA995FF),
            //             )),
            //       );
            //     } else if (state == 2) {
            //       return InkWell(
            //         onTap: () {
            //           DownloadUtils.instance.remove(videoId);
            //         },
            //         child: Image.asset(
            //           "assets/oimg/icon_download_ok.png",
            //           width: 20.w,
            //           height: 20.w,
            //         ),
            //       );
            //     }
            //   }
            //
            //   return InkWell(
            //     onTap: () {
            //       DownloadUtils.instance
            //           .download(videoId, item, clickType: "liked");
            //     },
            //     child: Image.asset(
            //       "assets/oimg/icon_download_gray.png",
            //       width: 20.w,
            //       height: 20.w,
            //     ),
            //   );
            // }),
            // SizedBox(
            //   width: 12.w,
            // ),
            // InkWell(
            //   onTap: () {
            //     MoreSheetUtil.instance
            //         .showVideoMoreSheet(item, clickType: "like");
            //   },
            //   child: Container(
            //     width: 20.w,
            //     height: 20.w,
            //     child: Image.asset("assets/oimg/icon_more.png"),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class UserLikeSongController extends GetxController {
  var list = [].obs;

  @override
  void onInit() {
    super.onInit();
    bindData();
  }

  bindData() {
    //获取所有收藏的歌曲
    list.value = LikeUtil.instance.allVideoMap.values.toList();
  }
}
