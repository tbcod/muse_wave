import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../static/app_color.dart';

class ToastUtil {
  ///常规 toast
  static void showToast({required String msg, IconType type = IconType.none}) {
    // BotToast.showText(
    //     text: msg,
    //     contentPadding: EdgeInsets.all(12.w),
    //     borderRadius: BorderRadius.circular(8.w),
    //     contentColor: Color(0xff2D312E));
    showToastWithIcon(msg: msg, type: type);
  }

  //带图标
  static void showToastWithIcon({
    required String msg,
    IconType type = IconType.info,
  }) {
    BotToast.showCustomText(
      toastBuilder: (c) {
        return Container(
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: 240, minWidth: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xff2D312E),
          ),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          // child: type == IconType.none
          //     ? Text(
          //         msg,
          //         style: TextStyle(fontSize: 14, color: Colors.white),
          //       )
          //     : Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Builder(builder: (c) {
          //             if (type == IconType.info) {
          //               return Image.asset(
          //                 "assets/img/other/icon_warning.png",
          //                 width: 16,
          //                 height: 16,
          //               );
          //               // return Icon(
          //               //   Icons.info,
          //               //   size: 16.w,
          //               //   color: Colors.amber,
          //               // );
          //             } else if (type == IconType.error) {
          //               return Image.asset(
          //                 "assets/img/other/icon_failed.png",
          //                 width: 16,
          //                 height: 16,
          //               );
          //               // return Icon(
          //               //   Icons.dangerous,
          //               //   size: 16.w,
          //               //   color: Colors.red,
          //               // );
          //             } else if (type == IconType.success) {
          //               return Image.asset(
          //                 "assets/img/other/icon_success.png",
          //                 width: 16,
          //                 height: 16,
          //               );
          //               // return Icon(
          //               //   Icons.check_circle,
          //               //   size: 16.w,
          //               //   color: Colors.green,
          //               // );
          //             }
          //
          //             return Container();
          //           }),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //               child: Text(
          //             msg,
          //             style: TextStyle(fontSize: 14, color: Colors.white),
          //           ))
          //         ],
          //       ),
        );
      },
      align: Alignment.center,
      animationDuration: const Duration(milliseconds: 256),
    );
  }

  // static void showTipDialog({required String msg}) {
  //   Get.dialog(BaseDialog(
  //     content: msg,
  //     single: true,
  //   ));
  // }
}

enum IconType { none, error, info, success }

///   var cancel= LoadingUtil.showLoading();
///    //关闭
///    cancel();
class LoadingUtil {
  // static CancelFunc showLoading() {
  //   return BotToast.showLoading();
  // }

  static CancelFunc showLoading({String msg = "加载中", VoidCallback? onClose}) {
    return BotToast.showCustomLoading(
      onClose: onClose,
      toastBuilder: (CancelFunc cancelFunc) {
        return Container(
          width: 80.w,
          height: 80.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff3B402C),
            borderRadius: BorderRadius.all(Radius.circular(10.w)),
          ),
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                color: AppColor.mainColor,
                strokeWidth: 3.w,
                backgroundColor: AppColor.mainColor.withOpacity(0.25),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideAllLoading() {
    BotToast.closeAllLoading();
  }
}
