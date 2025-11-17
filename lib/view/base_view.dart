import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../generated/assets.dart';
import '../tool/ad/topon_util.dart';
import '../tool/download/download_util.dart';
import '../tool/tba/event_util.dart';
import 'more_sheet_util.dart';

class BasePage extends GetView {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(Assets.imgBgAll),
        ),
      ),
      child: child,
    );
  }
}

class BaseDialog extends GetView {
  final String? title;
  final String? content;
  final String? lBtnText;
  final String? rBtnText;
  final VoidCallback? lBtnOnTap;
  final VoidCallback? rBtnOnTap;
  final bool single;
  final bool canDismiss;
  final bool callbackBeforeClose;
  final Color mainColor;
  final Widget? contentView;

  const BaseDialog({
    Key? key,
    this.title,
    this.content,
    this.lBtnText,
    this.rBtnText,
    this.lBtnOnTap,
    this.rBtnOnTap,
    this.single = false,
    this.callbackBeforeClose = false,
    this.contentView,
    this.canDismiss = true,
    this.mainColor = const Color(0xff7453FF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!canDismiss) {
          return;
        }
        Get.back();
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
        backgroundColor: Colors.transparent,
        // shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.w),
              decoration: BoxDecoration(
                color: Color(0xff202020),
                gradient: LinearGradient(
                  colors: [Color(0xffEAEAFF), Color(0xffFAFAFA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "",
                    style: TextStyle(fontSize: 20.w, color: Colors.black),
                  ),
                  SizedBox(height: 24.w),
                  Text(
                    content ?? "",
                    style: TextStyle(fontSize: 14.w, color: Colors.black),
                  ),
                  SizedBox(height: 32.w),
                  Container(
                    height: 40.w,
                    width: double.infinity,
                    child: Row(
                      children:
                          single
                              ? [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (rBtnOnTap != null) {
                                        rBtnOnTap!();
                                      }
                                      Get.back();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.w,
                                        ),
                                        color: mainColor,
                                      ),
                                      child: Text(
                                        rBtnText ?? "",
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                              : [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (lBtnOnTap != null) {
                                        lBtnOnTap!();
                                      }
                                      Get.back();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.w,
                                        ),

                                        // color: Colors.white.withOpacity(0.15)
                                        border: Border.all(
                                          color: mainColor,
                                          width: 2.w,
                                        ),
                                      ),
                                      child: Text(
                                        lBtnText ?? "",
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: mainColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 23.w),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (rBtnOnTap != null) {
                                        rBtnOnTap!();
                                      }
                                      Get.back();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.w,
                                        ),
                                        color: mainColor,
                                      ),
                                      child: Text(
                                        rBtnText ?? "",
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NetImageView extends GetView {
  final double? width;
  final double? height;
  final String imgUrl;
  final String? errorAsset;
  final BoxFit fit;
  final Color? bgColor;
  const NetImageView({
    Key? key,
    required this.imgUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorAsset,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (c, url) {
        return errorAsset == null
            ? Container(
              color: bgColor ?? Colors.black.withOpacity(0.08),
              // child: const Center(
              //   child: Icon(Icons.error),
              // ),
            )
            : Image.asset(errorAsset!, fit: BoxFit.cover);

        // return Container(
        //   color: bgColor ?? Colors.black.withOpacity(0.08),
        //   // child: const Center(
        //   //   child: CircularProgressIndicator(),
        //   // ),
        // );
      },
      errorWidget: (c, url, error) {
        // return Container(
        //   color: bgColor ?? Colors.black.withOpacity(0.08),
        // );

        return errorAsset == null
            ? Container(
              color: bgColor ?? Colors.black.withOpacity(0.08),
              // child: const Center(
              //   child: Icon(Icons.error),
              // ),
            )
            : Image.asset(errorAsset!, fit: BoxFit.cover);
      },
    );
  }
}

class NetAvatarView extends GetView {
  final double size;
  final String imgUrl;
  final String errorAsset;
  final double borderWidth;
  final Color borderColor;
  final Color bgColor;
  const NetAvatarView({
    Key? key,
    required this.imgUrl,
    this.size = 40,
    this.borderWidth = 0,
    this.borderColor = Colors.grey,
    this.bgColor = Colors.grey,
    this.errorAsset = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: size / 2 - borderWidth / 2,
        backgroundImage: errorAsset.isEmpty ? null : AssetImage(errorAsset),
        backgroundColor: bgColor,
        foregroundImage: CachedNetworkImageProvider(imgUrl),
        onForegroundImageError: (o, e) {},
      ),
    );
  }
}

class MyTabIndicator extends Decoration {
  final double width = 16;
  final double lineWidth = 5;
  final StrokeCap strokeCap = StrokeCap.round;
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xff6898FC), Color(0xff6898FC)],
  );

  final BorderRadius? borderRadius = BorderRadius.all(Radius.circular(2));

  final EdgeInsetsGeometry insets = EdgeInsets.zero;

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);

    double wantWidth = width;
    double cw = (indicator.left + indicator.right) / 2;
    return Rect.fromLTWH(
      cw - wantWidth / 2,
      indicator.bottom - lineWidth,
      wantWidth,
      lineWidth,
    );
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _LinePainter(this, borderRadius, onChanged);

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    if (borderRadius != null) {
      return Path()..addRRect(
        borderRadius!.toRRect(_indicatorRectFor(rect, textDirection)),
      );
    }
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _LinePainter extends BoxPainter {
  _LinePainter(this.decoration, this.borderRadius, super.onChanged);

  final MyTabIndicator decoration;
  final BorderRadius? borderRadius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;

    final Paint paint;

    if (decoration.borderRadius != null) {
      paint = Paint()..shader = decoration.gradient.createShader(rect);

      final Rect indicator = decoration
          ._indicatorRectFor(rect, textDirection)
          .inflate(decoration.lineWidth / 4.0);

      final RRect rrect = RRect.fromRectAndCorners(
        indicator,
        topLeft: borderRadius!.topLeft,
        topRight: borderRadius!.topRight,
        bottomRight: borderRadius!.bottomRight,
        bottomLeft: borderRadius!.bottomLeft,
      );

      canvas.drawRRect(rrect, paint);
    } else {
      paint = Paint()..shader = decoration.gradient.createShader(rect);

      final Rect indicator = decoration
          ._indicatorRectFor(rect, textDirection)
          .deflate(decoration.lineWidth / 2.0);

      canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
    }
  }
}

getDownloadAndMoreBtn(
  Map item,
  String type, {
  bool isSearch = false,
  bool locIsHome = false,
  double iconHeight = 50,
}) {
  // type分类
  //loc_playlist
  //net_playlist
  //search
  //liked
  //download
  //artist_more_song
  //artist
  //

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      //获取是否显示下载按钮
      if (FirebaseRemoteConfig.instance.getString("musicmuse_off_switch") ==
          "on")
        Obx(() {
          //获取下载状态
          var videoId = item["videoId"];

          if (DownloadUtils.instance.allDownLoadingData.containsKey(videoId)) {
            //有添加过下载
            var state =
                DownloadUtils.instance.allDownLoadingData[videoId]["state"];
            double progress =
                DownloadUtils.instance.allDownLoadingData[videoId]["progress"];

            // AppLog.e(
            //     "videoId==$videoId,url==${controller.nowPlayUrl}\n\n,--state==$state,progress==$progress");

            if (state == 1 || state == 3) {
              //下载中\下载暂停
              return InkWell(
                onTap: () {
                  DownloadUtils.instance.remove(videoId);
                },
                child: Container(
                  height: iconHeight,
                  // color: Colors.red,
                  width: 32.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6.w),
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    // padding: EdgeInsets.all(5.w),
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 1.5,
                      backgroundColor: Color(0xffA995FF).withOpacity(0.35),
                      color: Color(0xffA995FF),
                    ),
                  ),
                ),
              );
            } else if (state == 2) {
              return InkWell(
                onTap: () {
                  DownloadUtils.instance.remove(videoId);
                },
                child: Container(
                  height: iconHeight,
                  // color: Colors.red,
                  padding: EdgeInsets.all(6.w),
                  child: Image.asset(
                    "assets/oimg/icon_download_ok.png",
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              );
            }
          }

          return InkWell(
            onTap: () {
              if (type == "net_playlist" || type == "loc_playlist") {
                EventUtils.instance.addEvent(
                  "det_playlist_click",
                  data: {"detail_click": "dl"},
                );
              }
              if (type == "artist_more_song" || type == "artist") {
                EventUtils.instance.addEvent(
                  "det_artist_click",
                  data: {"detail_click": "dl"},
                );
              }

              if (type == "net_playlist" ||
                  type == "artist_more_song" ||
                  type == "artist") {
                DownloadUtils.instance.download(
                  videoId,
                  item,
                  clickType: isSearch ? "s_detail" : "h_detail",
                );
                return;
              } else if (type == "loc_playlist" ||
                  type == "liked" ||
                  type == "download") {
                DownloadUtils.instance.download(
                  videoId,
                  item,
                  clickType: locIsHome ? "h_detail" : "library",
                );
                return;
              }

              DownloadUtils.instance.download(videoId, item, clickType: type);
            },
            child: Container(
              height: iconHeight,
              // color: Colors.red,
              padding: EdgeInsets.all(6.w),
              child: Image.asset(
                "assets/oimg/icon_download_gray.png",
                width: 20.w,
                height: 20.w,
              ),
            ),
          );
        }),
      // SizedBox(
      //   width: 2.w,
      // ),
      InkWell(
        onTap: () {
          if (type == "net_playlist" || type == "loc_playlist") {
            EventUtils.instance.addEvent(
              "det_playlist_click",
              data: {"detail_click": "more"},
            );
          }
          if (type == "artist_more_song" || type == "artist") {
            EventUtils.instance.addEvent(
              "det_artist_click",
              data: {"detail_click": "more"},
            );
          }

          MoreSheetUtil.instance.showVideoMoreSheet(item, clickType: type);
        },
        child: Container(
          height: iconHeight,
          padding: EdgeInsets.all(6.w),
          child: Container(
            width: 20.w,
            height: 20.w,
            child: Image.asset("assets/oimg/icon_more.png"),
          ),
        ),
      ),
    ],
  );
}

Widget getAdCloseView(Widget adView, {String toponAdId = ""}) {
  var isShow = true.obs;
  return Container(
    child: Obx(
      () =>
          isShow.value
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.w),
                child: Stack(
                  children: [
                    adView,
                    //关闭按钮
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        onTap: () {
                          isShow.value = false;

                          if (toponAdId.isNotEmpty) {
                            //topon 删除
                            TopOnUtils.instance.allCom.remove(toponAdId);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.w),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          width: 20.w,
                          height: 20.w,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 15.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Container(),
    ),
  );
}
