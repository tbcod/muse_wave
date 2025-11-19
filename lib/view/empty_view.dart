import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmotyView extends StatelessWidget {
  const EmotyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              SizedBox(
                height: 8.w,
              ),
              Text(
                "No content found".tr,
                style: TextStyle(fontSize: 16.w, color: Colors.black),
              )
            ],
          )),
    );
  }

}
