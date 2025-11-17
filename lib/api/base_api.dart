import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../tool/log.dart';
import '../tool/toast.dart';

class BaseApi extends GetConnect {
  BaseApi(String baseHost) {
    httpClient.baseUrl = baseHost;
    allowAutoSignedCert = true;
    withCredentials = true;
    httpClient.timeout = const Duration(seconds: 30);
  }

  Future<BaseModel> httpRequest(
    String url, {
    bool needToken = false,
    bool toastError = false,
    bool showLoading = false,
    String method = HttpMethod.get,
    String contentType = "application/x-www-form-urlencoded",
    Map<String, dynamic> body = const {},
    // String? contentType,
    Map<String, String>? headers,
    Progress? uploadProgress,
  }) async {
    CancelFunc? cancelFunc;

    AppLog.v(
      "请求前url: ${(httpClient.baseUrl ?? "") + url} , method: $method , header: $headers , param：$body",
    );

    // var connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult != ConnectivityResult.wifi &&
    //     connectivityResult != ConnectivityResult.mobile) {
    //   //没有网络
    //   AppLog.e("没有网络:$connectivityResult");
    //   return BaseModel(code: -1, message: "No internet connection");
    // }

    if (showLoading) {
      cancelFunc = LoadingUtil.showLoading();
    }
    headers ??= {};
    try {
      if (needToken) {
        // Application c = Get.find();
        //
        // if (c.token.isNotEmpty) {
        //   headers["Authorization"] = "Bearer ${c.token}";
        // } else {
        //   AppLog.e("没有token");
        // }
      }

      Response response;
      if (method == HttpMethod.get) {
        Map<String, String> strMap = body.map(
          (key, value) => MapEntry(key, value?.toString() ?? ""),
        );
        response = await get(
          url,
          headers: headers,
          query: strMap,
          contentType: contentType,
        );
      } else {
        response = await post(
          url,
          body,
          headers: headers,
          uploadProgress: uploadProgress,
          contentType: contentType,
        );
      }
      if (cancelFunc != null) {
        cancelFunc();
      }

      // return response;
      // debugPrint(jsonEncode(body));
      AppLog.d(
        "url: ${response.request?.url} ,\n method: $method ,\n header: ${response.request?.headers} ,\n param：${jsonEncode(body)}",
      );
      AppLog.w(response.statusText);
      AppLog.w(response.statusCode);
      if (response.isOk) {
        AppLog.d("${response.request?.url} \n请求成功");
        // AppLog.d(response.body);
        // AppLog.d(
        //     "${response.request?.url} \n请求成功：\n${response.body},\ncode:${response.statusCode}");
        // AppLog.d("${response.request?.headers}");

        BaseModel data;
        // data = BaseModel.fromJson(jsonDecode(response.bodyString ?? "{}"));

        var bodyString = response.bodyString ?? "{}";

        //可以解析成json就解析，否则返回string
        if (bodyString.startsWith("{") || bodyString.startsWith("[")) {
          var json = jsonDecode(bodyString);
          if (json is Map && json["code"] != null) {
            //有错误
            data = BaseModel(code: json["code"], message: json["msg"]);
          } else {
            data = BaseModel(code: HttpCode.success, data: json);
          }
        } else {
          data = BaseModel(code: HttpCode.success, data: bodyString);
        }

        //登录过期
        // if (data.code == HttpCode.tokenExpired ||
        //     data.code == HttpCode.tokenExpiredOther) {
        //   MainService.instance.AppLoginOut();
        //   // ToastUtil.showToast(msg: "登录已过期，请重新登录");
        //   return BaseModel(code: -1, message: "登录已过期，请重新登录");
        // }

        if (toastError && data.code != HttpCode.success) {
          ToastUtil.showToast(msg: data.message ?? "httpError".tr);
        }
        return data;
      } else {
        AppLog.d(
          "${response.request?.url} \n请求失败：\n${response.body},\ncode:${response.statusCode}",
        );
        if (toastError) {
          ToastUtil.showToast(msg: "httpError".tr);
        }
        return BaseModel(
          code: response.statusCode ?? -1,
          message: "httpError".tr,
        );
      }
    } catch (e) {
      AppLog.e(e);

      if (toastError) {
        ToastUtil.showToast(msg: "httpError".tr);
      }
      if (cancelFunc != null) {
        cancelFunc();
      }
      return BaseModel(code: -1, message: "httpError".tr);
    }
  }
}

class HttpMethod {
  static const String get = "get";
  static const String post = "post";
}

///自定义网络请求编码
class HttpCode {
  ///失败
  static const fail = -1;

  ///成功
  static const success = 20000;
}

class BaseModel<T> {
  BaseModel({this.data, this.message, required this.code});

  BaseModel.fromJson(dynamic json) {
    message = json["msg"];
    code = json["code"];
    data = json["data"];
  }
  T? data;
  String? message;
  num? code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data;
    map['msg'] = message;
    map['code'] = code;
    return map;
  }
}
