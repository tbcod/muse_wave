import 'package:advertising_id/advertising_id.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/tba/tba_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../api/base_api.dart';
import '../../main.dart';
import '../log.dart';

class TbaAnd extends BaseApi {
  static final String host =
      MuseConfig.isUser
          ? "https://volley.muse-wave.com/movie/ere"
          : "https://test-volley.muse-wave.com/messy/wilma/setscrew";

  TbaAnd._internal() : super(host);
  static final TbaAnd _instance = TbaAnd._internal();

  String? _advertisingId;

  static TbaAnd get instance {
    return _instance;
  }



  Future<BaseModel> postData(
    TbaType type, {
    Map<String, dynamic>? eventData,
    String? eventId,
    String? positionKey,
  }) async {
    // AppLog.e("事件上报：${type.name}:\n${eventId ?? ""}\n事件数据：$eventData");
    // AppLog.e("事件数据：$eventData");
    AppLog.i("事件上报：${type.name.replaceAll("mw_", "")}, $eventId, $eventData");
    //通用参数
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AndroidDeviceInfo andDeviceInfo = await DeviceInfoPlugin().androidInfo;

    var languageCode = Get.deviceLocale?.languageCode ?? "zh";
    var countryCode = Get.deviceLocale?.countryCode ?? "CN";

    // var idfa = await AppTrackingTransparency.getAdvertisingIdentifier();

    var connectivityResult = await Connectivity().checkConnectivity();
    var offsetHours = DateTime.now().timeZoneOffset.inHours;

    // AppLog.e("当前时区$offsetHours");

    var logId = Uuid().v1();

    var androidId = await AndroidId().getId();

    // MobileAds.instance.getAdvertisingId();
    String advertisingId = "";
    try {
      _advertisingId ??= await AdvertisingId.id(true);
      advertisingId = _advertisingId ?? "";
      // AppLog.e("获取gaid成功:$advertisingId");
    } catch (e) {
      AppLog.e("获取gaid出错,$e");
      // AppLog.e(e);
    }

    //通用参数
    Map<String, dynamic> generalMap = {};

    Map<String, dynamic> otherMap = {
      "queue": {
        "canadian": DateTime.now().millisecondsSinceEpoch,
        "flatbed": Get.find<Application>().userAppUuid,
        "snook": "${languageCode}_$countryCode",
        "muriatic": logId,
        "clinch": andDeviceInfo.supportedAbis.toString(),
      },
      "chamfer": {
        "crowbar": packageInfo.version,
        "stark": advertisingId,
        "chauncey": "titanium",
      },
      "kiss": {
        "fortieth": andDeviceInfo.manufacturer,
        "blow": androidId,
        "panicked": andDeviceInfo.brand,
        "fugal": "GooglePlay",
        "nib": packageInfo.packageName,
        "occult": "mcc",
        "conceal": andDeviceInfo.model,
        "apache": offsetHours,
        "doggone": connectivityResult.map((e) => e.name).toList().toString(),
        "helmet": andDeviceInfo.version.sdkInt,
      },
    };
    generalMap.addAll(otherMap);
    if (type == TbaType.install) {
      // generalMap["renewal"] = eventData;
      generalMap.addAll(eventData ?? {});
      generalMap["sept"] = "rodent";
    } else if (type == TbaType.session) {
      generalMap["laura"] = {};
    } else if (type == TbaType.ad) {
      generalMap.addAll(eventData ?? {});
      generalMap["sept"] = "emphases";
      generalMap['joyride/ad_load_pos'] = positionKey;
    } else if (type == TbaType.event) {
      //事件id
      generalMap["sept"] = eventId;
      generalMap[eventId ?? ""] = eventData;
    } else if (type == TbaType.userInfo) {
      generalMap["sept"] = "holt";
      generalMap["holt"] = eventData;
    }

    //全局属性
    // generalMap['joyride/%key'] = 1;

    //先存本地，请求成功后删除
    // var box = await Hive.openBox("tbaErrorData");
    // //存下来下次提交
    // await box.put(logId, generalMap);

    var result = await httpRequest(
      "",
      method: HttpMethod.post,
      body: generalMap,
      contentType: "application/json",
    );

    //请求失败的下次一起提交

    if (result.code != HttpCode.success) {
      AppLog.e("上报失败 ${type.name}, $eventId");
      // AppLog.e(logId);
      if(result.code?.toInt() == 500){
        //服务器错误
        // AppLog.e("服务器错误:${result.code}");
      }else{
        var box = await Hive.openBox("tbaErrorData");
        //存下来下次提交
        await box.put(logId, generalMap);
      }
    } else {
      // AppLog.i("上报成功 ${type.name}, $eventId，$eventData");
      // // AppLog.i("上报请求成功  $generalMap");
      // //请求成功了，先删除本次的
      // await box.delete(logId);
      //
      // //再次提交上次请求失败的数据
      // if (!isPostError) {
      //   var listErrorData = box.values.toList();
      //   postTbaErrorData(listErrorData);
      // }
    }

    return result;
  }

  var isPostError = false;

  postTbaErrorData() async {
    // if (data.isEmpty) {
    //   return;
    // }
    // isPostError = true;
    // var box = await Hive.openBox("tbaErrorData");
    // AppLog.i("上报上次未成功的tba: ${data.length}条");
    // AppLog.e(data.length);

    if(isPostError) return;
    isPostError = true;
    var box = await Hive.openBox("tbaErrorData");
    // AppLog.e("上报上次未成功的tba");
    // AppLog.e(data.length);
    var data = box.values.toList();
    AppLog.i("上报未成功的tba data:${data.length}");
    if (data.isEmpty) {
      isPostError = false;
      return;
    }

    if (data.length > 1000) {
      //太多了不上报
      await box.clear();
      isPostError = false;
      return;
    }

    for (int i = 0; i < data.length; i++) {
      var bodyMap = Map<String, dynamic>.from(data[i]);
      var httpData = await httpRequest(
        "",
        method: HttpMethod.post,
        body: bodyMap,
        contentType: "application/json",
      );
      if (httpData.code == HttpCode.success) {
        // AppLog.e("上次失败的上报成功$i");
        //
        // //TODO 注意修改为logid的路径
        // AppLog.e(bodyMap["queue"]?["muriatic"] ?? "");

        await box.delete(bodyMap["queue"]?["muriatic"] ?? "");
      }
    }
    isPostError = false;
  }
}
