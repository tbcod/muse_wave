import 'dart:convert';

import 'package:anythink_sdk/at_index.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/ad/topon_util.dart';


class UDebugPage extends StatelessWidget {
  UDebugPage({super.key});

  final UDebugController controller = Get.put(UDebugController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Debug".tr,
          style: TextStyle(fontSize: 20.w),
        ),
        titleSpacing: 12.w,
        actions: [
          // CupertinoButton(
          //     onPressed: () {
          //       NativeUtils.instance.test();
          //     },
          //     child: const Text('A')),
          // CupertinoButton(
          //     onPressed: () {
          //       controller.exceptionTest();
          //     },
          //     child: const Text('AB')),
        ],
      ),
      body: Container(
        height: ScreenUtil().screenHeight,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                    onPressed: () {
                      MobileAds.instance.openAdInspector((value) {});
                    },
                    child: const Text('Admob')),
                const SizedBox(height: 12),
                CupertinoButton(
                    onPressed: () {
                      AppLovinMAX.showMediationDebugger();
                    },
                    child: const Text('ApplovinMax')),
                const SizedBox(height: 12),
                CupertinoButton(
                    onPressed: () {
                      ATInitManger.showDebuggerUI(debugKey: "");
                    },
                    child: const Text('Topon')),
              ],
            ),
            const SizedBox(height: 12),
            Text('${controller.getAd(AdUtils.instance.adJson)}'),
          ],
        ),
      ),
    );
  }
}

class UDebugController extends GetxController {
  getAd(Map user) {
    var encoder = const JsonEncoder.withIndent("  "); // 两个空格缩进
    String prettyJson = encoder.convert(user);
    return prettyJson;
    // String formatted = user.entries.map((e) => "${e.key}: ${e.value}").join("\n");
    // return formatted;
  }

  exceptionTest() async {
    // const invalidJson = '{"name": "Tom", "age": }'; // 错误 JSON
    // json.decode(invalidJson);
    // var result = await GetConnect().get("https://lh3.googleusercontent.com/110fyr-gVhGEM4NwkBAV8kh31uqRvxS7w_3KlAYLNq2pMbD2VhWN8hi3HHHHYLYN6F4LUkaDtmfGI0NT-k=w60-h60-l90-rj");

    // await Dio().get("https://lh3.googleusercontent.com/10fyr-gVhGEM4NwkBAV8kh31uqRvxS7w_3KlAYLNq2pMbD2VhWN8hi3HHHHYLYN6F4LUkaDtmfGI0NT-k=w60-h60-l90-rj");
  }
}
