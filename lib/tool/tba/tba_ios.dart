// import 'dart:convert';
// import 'dart:io';
//
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:music_muse/util/tba/tba_util.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../api/base_api.dart';
// import '../../app.dart';
// import '../../const/env.dart';
// import '../log.dart';
//
// class TbaIos extends BaseApi {
//   static final String host = Env.isUser
//       ? "https://levulose.littlemusicmuse.com/antenna/auric/ward"
//       : "https://test-levulose.littlemusicmuse.com/zazen/prop";
//
//   TbaIos._internal() : super(host);
//   static final TbaIos _instance = TbaIos._internal();
//   static TbaIos get instance {
//     return _instance;
//   }
//
//   Future<BaseModel> postData(TbaType type,
//       {Map<String, dynamic>? eventData, String? eventId}) async {
//     AppLog.e("事件上报：${type.name}:${eventId ?? ""}");
//     AppLog.e("事件数据：$eventData");
//
//     //通用参数
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     IosDeviceInfo iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
//
//     var languageCode = Get.deviceLocale?.languageCode ?? "zh";
//     var countryCode = Get.deviceLocale?.countryCode ?? "CN";
//
//     var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
//
//     var connectivityResult = await Connectivity().checkConnectivity();
//     var offsetHours = DateTime.now().timeZoneOffset.inHours;
//
//     var logId = Uuid().v1();
//
//     Map<String, dynamic> generalMap = {
//       "figurate": {
//         //system_language
//         "bassoon": "${languageCode}_$countryCode",
//         //app_version
//         "brent": packageInfo.version,
//         //distinct_id
//         "teapot": Get.find<Application>().userAppUuid,
//         //manufacturer
//         "nih": "apple",
//       },
//       "melvin": {
//         //gaid
//         // "cogitate": "",
//         //os_version
//         "exorcise": iosDeviceInfo.systemVersion,
//         //ab_test
//         // "watch": "",
//         //os
//         "garland": "school",
//         //network_type
//         "irk": connectivityResult.map((e) => e.name).join(","),
//         //brand
//         "mouse": "apple",
//         //idfv
//         "liken": iosDeviceInfo.identifierForVendor,
//         //device_model
//         "bunch": iosDeviceInfo.model
//       },
//       "botanist": {
//         //bundle_id
//         "environ": packageInfo.packageName,
//         //client_ts
//         "anagram": DateTime.now().millisecondsSinceEpoch,
//         //idfa
//         "labour": idfa,
//         //operator
//         "jackass": "mcc",
//         //log_id
//         "auriga": logId,
//         //zone_offset
//         "mark": offsetHours,
//         //uid
//         "fusty": Get.find<Application>().userAppUuid,
//         //ip
//         // "flu": "",
//         //battery_left
//         // "dryad": "",
//         //cpu_arch
//         // "glassy": "",
//         //android_id
//         // "brighton":"",
//       },
//     };
//
//     //全局参数
//     var isNewUser = false;
//     var sp = await SharedPreferences.getInstance();
//
//     var installTimeMs = sp.getInt("installTimeMs") ?? 0;
//     var tempD = DateTime.fromMillisecondsSinceEpoch(installTimeMs)
//         .difference(DateTime.now());
//     isNewUser = tempD.inHours < 24;
//
//     generalMap["hammock"] = {
//       "new_user": isNewUser ? "new" : "old",
//       "type_so": Get.find<Application>().typeSo
//     };
//
//     //通用参数
//     // Map<String, dynamic> generalMap = {
//     //   "figurate": {
//     //     //app_version
//     //     "brent": packageInfo.version,
//     //     //os_version
//     //     "circus": iosDeviceInfo.systemVersion,
//     //     //system_language
//     //     "bassoon": "${languageCode}_$countryCode",
//     //     //distinct_id
//     //     "teapot": Get.find<Application>().userAppUuid,
//     //     //os
//     //     "padre": "grumble",
//     //     //key 随机生成的uuid
//     //     "peat": Uuid().v8(),
//     //     //brand
//     //     "hodges": "apple",
//     //     //ip
//     //     // "hearty":"",
//     //     //log_id
//     //     "lolly": logId,
//     //     //bundle_id
//     //     "ooze": packageInfo.packageName,
//     //   },
//     //   "discrete": {
//     //     //idfa
//     //     "radial": idfa,
//     //     //device_model
//     //     "mathews": iosDeviceInfo.model,
//     //     //storage_size
//     //     // "cutover":0,
//     //     //zone_offset
//     //     "dingy": offsetHours,
//     //     //channel
//     //     "scrawl": "appStore",
//     //   },
//     //   "zillion": {
//     //     //idfv
//     //     "deem": iosDeviceInfo.identifierForVendor,
//     //   },
//     //   "pollen": {
//     //     //manufacturer
//     //     "price": "apple",
//     //     //ab_test
//     //     // "snail": "",
//     //     //network_type
//     //     "gestural": connectivityResult.last.name,
//     //     //gaid
//     //     // "college": "",
//     //     //client_ts
//     //     "brakeman": DateTime.now().millisecondsSinceEpoch,
//     //     //operator mcc和mnc
//     //     "alexis": "mcc",
//     //     //os_country
//     //     "globe": countryCode,
//     //     //android_id
//     //     // "shirley": "",
//     //   }
//     // };
//
//     if (type == TbaType.install) {
//       generalMap["pow"] = eventData;
//       //拼接Map
//       // if (eventData != null) {
//       //   generalMap.addAll(eventData);
//       // }
//     } else if (type == TbaType.session) {
//       generalMap["cabinet"] = {};
//     } else if (type == TbaType.ad) {
//       generalMap["womb"] = eventData;
//       // generalMap.addAll(eventData ?? {});
//     } else if (type == TbaType.event) {
//       //事件id
//       generalMap["add"] = eventId;
//       if (eventData?.isNotEmpty ?? false) {
//         //字段名加后缀
//         eventData!.forEach((key, value) {
//           generalMap["$key|crib"] = value;
//         });
//       }
//     }
//
//     // AppLog.e(jsonEncode(generalMap));
//
//     //先存本地，请求成功后删除
//     var box = await Hive.openBox("tbaErrorData");
//     //存下来下次提交
//     await box.put(logId, generalMap);
//
//     var result = await httpRequest("",
//         method: HttpMethod.post,
//         body: generalMap,
//         contentType: "application/json");
//
//     //请求失败的下次一起提交
//
//     if (result.code != HttpCode.success) {
//       AppLog.e("上报请求失败");
//       AppLog.e(logId);
//     } else {
//       //请求成功了，先删除本次的
//       await box.delete(logId);
//
//       //再次提交上次请求失败的数据
//       if (!isPostError) {
//         var listErrorData = box.values.toList();
//         postTbaErrorData(listErrorData);
//       }
//     }
//
//     return result;
//   }
//
//   var isPostError = false;
//   postTbaErrorData(List data) async {
//     if (data.isEmpty) {
//       return;
//     }
//     isPostError = true;
//     var box = await Hive.openBox("tbaErrorData");
//     AppLog.e("上报上次未成功的tba");
//     AppLog.e(data.length);
//
//     if (data.length > 1000) {
//       //太多了不上报
//       await box.clear();
//       isPostError = false;
//       return;
//     }
//
//     for (int i = 0; i < data.length; i++) {
//       var bodyMap = Map<String, dynamic>.from(data[i]);
//       var httpData = await httpRequest("",
//           method: HttpMethod.post,
//           body: bodyMap,
//           contentType: "application/json");
//       if (httpData.code == HttpCode.success) {
//         AppLog.e("上次失败的上报成功$i");
//         AppLog.e(bodyMap["botanist"]["auriga"] ?? "");
//
//         await box.delete(bodyMap["botanist"]["auriga"] ?? "");
//       }
//     }
//     isPostError = false;
//   }
// }
