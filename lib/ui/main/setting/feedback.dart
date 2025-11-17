import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muse_wave/view/base_view.dart';

import '../../../tool/log.dart';
import '../../../tool/toast.dart';

class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => FeedbackController());
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(
              title: Text("Feedback".tr),
              actions: [
                IconButton(
                  onPressed: () {
                    if (controller.contentC.text.isEmpty ||
                        controller.emailC.text.isEmpty) {
                      ToastUtil.showToast(
                        msg: "Please enter your feedback or email".tr,
                      );
                      return;
                    }
                    AppLog.e(controller.emailC.text);
                    if (!GetUtils.isEmail(controller.emailC.text)) {
                      ToastUtil.showToast(msg: "Email is Error".tr);
                      return;
                    }

                    ToastUtil.showToast(msg: "Feedback successful".tr);
                    Get.back();
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
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    SizedBox(height: 20.w),

                    Text(
                      "Feedback content".tr,
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    //输入框
                    TextField(
                      maxLines: 4,
                      autofocus: true,
                      controller: controller.contentC,
                      style: TextStyle(fontSize: 14.w),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Color(0xffADB0B8)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16.w),
                        ),
                        contentPadding: EdgeInsets.all(16.w),
                        hintText: "Please enter content".tr,
                      ),
                    ),

                    SizedBox(height: 30.w),
                    Text(
                      "Email".tr,
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    //输入框
                    TextField(
                      maxLines: 4,
                      autofocus: true,
                      controller: controller.emailC,
                      style: TextStyle(fontSize: 14.w),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Color(0xffADB0B8)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(16.w),
                        ),
                        contentPadding: EdgeInsets.all(16.w),
                        hintText: "Please enter email".tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackController extends GetxController {
  var contentC = TextEditingController();
  var emailC = TextEditingController();
}
