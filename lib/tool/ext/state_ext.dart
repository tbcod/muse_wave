//修改默认的加载布局，空布局，错误布局
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/simple/simple_builder.dart';

import '../../static/app_color.dart';


extension StateExt<T> on StateMixin<T> {
  Widget obxPage(
    NotifierBuilder<T?> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
  }) {
    return SimpleBuilder(builder: (_) {
      if (status.isLoading) {
        return onLoading ??
            Scaffold(
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
                    )),
              ),
              body: Center(
                  child: CircularProgressIndicator(
                color: AppColor.mainColor,
              )),
            );
      } else if (status.isError) {
        return onError != null
            ? onError(status.errorMessage)
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(),
                body: Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/oimg/icon_wifi.png",
                      width: 180.w,
                      height: 180.w,
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    Text("No network".tr,
                        style: TextStyle(fontSize: 16.w, color: Colors.black))
                  ],
                )),
              );
      } else if (status.isEmpty) {
        return onEmpty ??
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(),
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/img/icon_empty.png",
                    width: 180.w,
                    height: 180.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    "No content found".tr,
                    style: TextStyle(fontSize: 16.w, color: Colors.black),
                  )
                ],
              )),
            ); // Also can be widget(null); but is risky
      }
      return widget(value);
    });
  }

  Widget obxView(
    NotifierBuilder<T?> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
  }) {
    return SimpleBuilder(builder: (_) {
      if (status.isLoading) {
        return onLoading ??
            Scaffold(
              backgroundColor: Colors.transparent,
              // appBar: AppBar(),
              body: Center(
                  child: CircularProgressIndicator(
                color: AppColor.mainColor,
              )),
            );
      } else if (status.isError) {
        return onError != null
            ? onError(status.errorMessage)
            : Scaffold(
                backgroundColor: Colors.transparent,
                // appBar: AppBar(),
                body: Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/oimg/icon_wifi.png",
                      width: 180.w,
                      height: 180.w,
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    Text("No network".tr,
                        style: TextStyle(fontSize: 16.w, color: Colors.black))
                  ],
                )),
              );
      } else if (status.isEmpty) {
        return onEmpty ??
            Scaffold(
              backgroundColor: Colors.transparent,
              // appBar: AppBar(),
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/img/icon_empty.png",
                    width: 180.w,
                    height: 180.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    "No content found".tr,
                    style: TextStyle(fontSize: 16.w, color: Colors.black),
                  )
                ],
              )),
            ); // Also can be widget(null); but is risky
      }
      return widget(value);
    });
  }
}
