import 'package:advertising_id/advertising_id.dart';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/base_api.dart';
import '../../main.dart';
import '../log.dart';

class CUtil extends BaseApi {
  CUtil._internal()
    : super(GetPlatform.isIOS ? "" : "https://gaulle.muse-wave.com");
  static final CUtil _instance = CUtil._internal();
  static CUtil get instance {
    return _instance;
  }

  Future<BaseModel> checkCloak() async {
    // httpClient.baseUrl =
    //     GetPlatform.isIOS ? "https://jocose.littlemusicmuse.com" : "";

    var packageInfo = await PackageInfo.fromPlatform();
    var userAppUuid = Get.find<Application>().userAppUuid;
    var netResult = await Connectivity().checkConnectivity();

    if (GetPlatform.isAndroid) {
      var androidId = await AndroidId().getId();

      var androidInfo = await DeviceInfoPlugin().androidInfo;

      String advertisingId = "";
      try {
        advertisingId = (await AdvertisingId.id(true)) ?? "";
        AppLog.e("获取gaid成功:$advertisingId");
      } catch (e) {
        AppLog.e("获取gaid出错");
        AppLog.e(e);
      }

      return httpRequest(
        "/keyes/han/mullen",
        method: HttpMethod.get,
        body: {
          //distinct_id
          "flatbed": userAppUuid,
          //client_ts
          "canadian": DateTime.now().millisecondsSinceEpoch,
          //device_model
          "conceal": androidInfo.model,
          //bundle_id
          "nib": packageInfo.packageName,
          //os_version
          "helmet": androidInfo.version.sdkInt,
          //gaid
          "stark": advertisingId,
          // //android_id
          "blow": androidId,
          //os
          "chauncey": "titanium",
          //app_version
          "crowbar": packageInfo.version,
        },
      );
    } else {
      return BaseModel(code: -1);
    }
  }
}
