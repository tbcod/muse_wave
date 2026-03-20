import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muse_wave/tool/log.dart';

class MuseLogger extends StatelessWidget {
  MuseLogger({super.key});

  final MuseLoggerController controller = Get.put(MuseLoggerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        return Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    controller.onClickClear();
                    Get.back();
                  },
                  child: const Text("CLEAN", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    controller.onClickEvent();
                  },
                  child: const Text("EVENT", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    controller.onClickAd();
                  },
                  child: const Text("ADS", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (BuildContext context, int index) {
                  return Text(controller.dataList[index], maxLines: 999,style: TextStyle(fontSize: 12));
                },
                itemCount: controller.dataList.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 5);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class MuseLoggerController extends GetxController {
  var dataList = [].obs;

  @override
  void onInit() {
    dataList.addAll(AppLog.logs);
    super.onInit();
  }

  onClickClear() {
    AppLog.clearLogs();
    dataList.clear();
  }

  onClickEvent() {
    List list = AppLog.logs.where((element) => element.contains("事件")).toList();
    dataList.value = list;
  }

  onClickAd() {
    List list = AppLog.logs.where((element) => element.contains("广告")).toList();
    dataList.value = list;
  }
}
