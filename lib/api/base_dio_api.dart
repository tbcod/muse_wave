import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../tool/log.dart';
import '../tool/toast.dart';


class BaseApi {
  Dio? dio;

  BaseApi(String baseHost) {
    dio ??= Dio(BaseOptions(
      validateStatus: (status) {
        return status != null && status < 500; // 接受 4xx，抛出 5xx
      },
    ));
    dio?.options.connectTimeout = const Duration(seconds: 9);
    dio?.options.receiveTimeout = const Duration(seconds: 12);
    dio?.options.baseUrl = baseHost;

    //模拟器测试时候添加
    // dio?.httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.findProxy = (uri) {
    //       // 将请求代理至 localhost:8888。
    //       // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
    //       return 'PROXY localhost:1087';
    //     };
    //     return client;
    //   },
    // );
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
        Map<String, dynamic>? headers,
      }) async {
    CancelFunc? cancelFunc;

    // AppLog.i(
    //     "请求前url: ${(dio?.options.baseUrl ?? "") + url} , method: $method , header: $headers , param：$body");

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
      Response? response;
      if (method == HttpMethod.get) {
        Map<String, String> strMap = body.map((key, value) => MapEntry(key, value?.toString() ?? ""));
        response = await dio?.get<String>(url, queryParameters: strMap, options: Options(headers: headers, contentType: contentType));
      } else {
        response = await dio?.post<String>(url, data: body, options: Options(headers: headers, contentType: contentType));
      }
      if (cancelFunc != null) {
        cancelFunc();
      }

      // return response;
      // AppLog.d(
      //     "url: ${response?.requestOptions.uri} ,\n method: $method ,\n header: ${response?.requestOptions.headers} ,\n param：${jsonEncode(body)}");
      // AppLog.w(response?.statusMessage);
      // AppLog.w(response?.statusCode);

      //200 and 299
      if (response?.statusCode != null && response!.statusCode! >= 200 && response.statusCode! < 300) {
        // AppLog.d("${response?.requestOptions.uri} \n请求成功：\n${response?.data}");
        // AppLog.i("${response.requestOptions.uri} \n请求成功");
        // AppLog.d(
        //     "${response.request?.url} \n请求成功：\n${response.body},\ncode:${response.statusCode}");
        // AppLog.d("${response.request?.headers}");

        BaseModel data;
        // data = BaseModel.fromJson(jsonDecode(response.bodyString ?? "{}"));

        var bodyString = response.data.toString();

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

        if (toastError && data.code != HttpCode.success) {
          ToastUtil.showToast(msg: data.message ?? "httpError".tr);
        }
        return data;
      } else {
        AppLog.e("${response?.requestOptions.uri} \n请求失败：\n${response?.data},\ncode:${response?.statusCode}");
        if (toastError) {
          ToastUtil.showToast(msg: "httpError".tr);
        }
        return BaseModel(code: response?.statusCode ?? -1, message: "httpError".tr);
      }
    } on DioException catch (e) {
      AppLog.e('DioException：code: ${e.response?.statusCode}, msg:${e.message}');
      return BaseModel(code: -1, message: "httpError".tr);
    } catch (e, s) {
      AppLog.e("e:$e,$s");

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
  BaseModel({
    this.data,
    this.message,
    required this.code,
  });

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


//
// class BaseApi {
//   Dio? dio;
//
//   BaseApi(String baseHost) {
//     dio ??= Dio();
//     dio?.options.connectTimeout = Duration(seconds: 20);
//     dio?.options.receiveTimeout = Duration(seconds: 20);
//     dio?.options.baseUrl = baseHost;
//
//     //模拟器测试时候添加
//     dio?.httpClientAdapter = IOHttpClientAdapter(
//       createHttpClient: () {
//         final client = HttpClient();
//         client.findProxy = (uri) {
//           // 将请求代理至 localhost:8888。
//           // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
//           return 'PROXY localhost:1087';
//         };
//         return client;
//       },
//     );
//   }
//
//   Future<BaseModel> httpRequest(
//     String url, {
//     bool needToken = false,
//     bool toastError = false,
//     bool showLoading = false,
//     String method = HttpMethod.get,
//     String contentType = "application/x-www-form-urlencoded",
//     Map<String, dynamic> body = const {},
//     // String? contentType,
//     Map<String, String>? headers,
//   }) async {
//     CancelFunc? cancelFunc;
//
//     AppLog.v(
//       "请求前url: ${(dio?.options.baseUrl ?? "") + url} , method: $method , header: $headers , param：$body",
//     );
//
//     // var connectivityResult = await Connectivity().checkConnectivity();
//     // if (connectivityResult != ConnectivityResult.wifi &&
//     //     connectivityResult != ConnectivityResult.mobile) {
//     //   //没有网络
//     //   AppLog.e("没有网络:$connectivityResult");
//     //   return BaseModel(code: -1, message: "No internet connection");
//     // }
//
//     if (showLoading) {
//       cancelFunc = LoadingUtil.showLoading();
//     }
//     headers ??= {};
//     try {
//       if (needToken) {
//         // Application c = Get.find();
//         //
//         // if (c.token.isNotEmpty) {
//         //   headers["Authorization"] = "Bearer ${c.token}";
//         // } else {
//         //   AppLog.e("没有token");
//         // }
//       }
//
//       Response? response;
//       if (method == HttpMethod.get) {
//         Map<String, String> strMap = body.map(
//           (key, value) => MapEntry(key, value?.toString() ?? ""),
//         );
//         response = await dio?.get<String>(
//           url,
//           queryParameters: strMap,
//           options: Options(headers: headers, contentType: contentType),
//         );
//       } else {
//         response = await dio?.post<String>(
//           url,
//           data: body,
//           options: Options(headers: headers, contentType: contentType),
//         );
//       }
//       if (cancelFunc != null) {
//         cancelFunc();
//       }
//
//       // return response;
//       // AppLog.d(
//       //     "url: ${response?.requestOptions.uri} ,\n method: $method ,\n header: ${response?.requestOptions.headers} ,\n param：${jsonEncode(body)}");
//       // AppLog.w(response?.statusMessage);
//       // AppLog.w(response?.statusCode);
//
//       //200 and 299
//       if (response?.statusCode == 200) {
//         // AppLog.d("${response?.requestOptions.uri} \n请求成功：\n${response?.data}");
//         AppLog.d("${response?.requestOptions.uri} \n请求成功");
//         // AppLog.d(
//         //     "${response.request?.url} \n请求成功：\n${response.body},\ncode:${response.statusCode}");
//         // AppLog.d("${response.request?.headers}");
//
//         BaseModel data;
//         // data = BaseModel.fromJson(jsonDecode(response.bodyString ?? "{}"));
//
//         var bodyString = response?.data.toString() ?? "{}";
//
//         //可以解析成json就解析，否则返回string
//         if (bodyString.startsWith("{") || bodyString.startsWith("[")) {
//           var json = jsonDecode(bodyString);
//           if (json is Map && json["code"] != null) {
//             //有错误
//             data = BaseModel(code: json["code"], message: json["msg"]);
//           } else {
//             data = BaseModel(code: HttpCode.success, data: json);
//           }
//         } else {
//           data = BaseModel(code: HttpCode.success, data: bodyString);
//         }
//
//         //登录过期
//         // if (data.code == HttpCode.tokenExpired ||
//         //     data.code == HttpCode.tokenExpiredOther) {
//         //   MainService.instance.AppLoginOut();
//         //   // ToastUtil.showToast(msg: "登录已过期，请重新登录");
//         //   return BaseModel(code: -1, message: "登录已过期，请重新登录");
//         // }
//
//         if (toastError && data.code != HttpCode.success) {
//           ToastUtil.showToast(msg: data.message ?? "httpError".tr);
//         }
//         return data;
//       } else {
//         AppLog.d(
//           "${response?.requestOptions.uri} \n请求失败：\n${response?.data},\ncode:${response?.statusCode}",
//         );
//         if (toastError) {
//           ToastUtil.showToast(msg: "httpError".tr);
//         }
//         return BaseModel(
//           code: response?.statusCode ?? -1,
//           message: "httpError".tr,
//         );
//       }
//     } catch (e) {
//       AppLog.e(e);
//
//       if (toastError) {
//         ToastUtil.showToast(msg: "httpError".tr);
//       }
//       if (cancelFunc != null) {
//         cancelFunc();
//       }
//       return BaseModel(code: -1, message: "httpError".tr);
//     }
//   }
// }
//
// class HttpMethod {
//   static const String get = "get";
//   static const String post = "post";
// }
//
// ///自定义网络请求编码
// class HttpCode {
//   ///失败
//   static const fail = -1;
//
//   ///成功
//   static const success = 20000;
// }
//
// class BaseModel<T> {
//   BaseModel({this.data, this.message, required this.code});
//
//   BaseModel.fromJson(dynamic json) {
//     message = json["msg"];
//     code = json["code"];
//     data = json["data"];
//   }
//   T? data;
//   String? message;
//   num? code;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['data'] = data;
//     map['msg'] = message;
//     map['code'] = code;
//     return map;
//   }
// }
