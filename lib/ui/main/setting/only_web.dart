import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muse_wave/view/base_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlyWeb extends GetView<OnlyWebController> {
  const OnlyWeb({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => OnlyWebController());

    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppBar(title: Text(controller.title)),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                    : WebViewWidget(controller: controller.webC),
              ),
            ),
            SizedBox(height: Get.mediaQuery.padding.bottom),
          ],
        ),
      ),
    );
  }
}

class OnlyWebController extends GetxController {
  late final WebViewController webC;
  final isLoading = true.obs;
  String title = '';

  @override
  void onInit() {
    super.onInit();

    //1用户协议2隐私政策
    var type = Get.arguments;
    var url = "https://";
    //TODO 隐私和协议
    if (type == 1) {
      url = GetPlatform.isIOS ? "" : "https://muse-wave.com/terms/";
      title = "Terms of Service".tr;
    } else if (type == 2) {
      url = GetPlatform.isIOS ? "" : "https://muse-wave.com/privacy/";
      title = "Privacy Policy".tr;
    } else if (type == 3) {
      url = GetPlatform.isIOS ? "" : "https://tinyurl.com/23kn5asf";
      title = "";
    }

    webC = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  void onClose() {
    webC.loadRequest(Uri.parse('about:blank'));
    super.onClose();
  }
}
