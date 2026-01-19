import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:muse_wave/static/db_key.dart';
import 'package:muse_wave/tool/adjust_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/tool/tba/tba_and.dart';

import '../../api/base_api.dart';
import '../log.dart';

class TbaUtils {
  TbaUtils._internal();

  static final TbaUtils _instance = TbaUtils._internal();

  static TbaUtils get instance {
    return _instance;
  }

  double _accumulateAdRevenue = 0; //累计的广告价值

  Future checkUnFinishedEvent() async {
    await TbaAnd.instance.postTbaErrorData();
  }

  Future<BaseModel> postEvent(String id, Map<String, dynamic>? data) async {
    if (GetPlatform.isIOS) {
      return BaseModel(code: -1);
    }

    //android
    return TbaAnd.instance.postData(TbaType.event, eventData: data, eventId: id);
  }

  Future<BaseModel> postInstall() async {
    if (GetPlatform.isIOS) {
      return BaseModel(code: -1);
    }

    AppLog.e("上报install");

    // return BaseModel(code: -1);

    //android
    var andInfo = await DeviceInfoPlugin().androidInfo;

    ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

    referrerDetails.googlePlayInstantParam;

    return TbaAnd.instance.postData(
      TbaType.install,
      eventData: {
        "trunkful": "build/${andInfo.version.release}",
        "stew": "",
        "bog": "bookish",
        //referrer_click_timestamp_seconds
        "maltese": referrerDetails.referrerClickTimestampSeconds,
        //install_begin_timestamp_seconds
        "buenos": referrerDetails.installBeginTimestampSeconds,
        //referrer_click_timestamp_server_seconds
        "bambi": referrerDetails.referrerClickTimestampServerSeconds,
        //install_begin_timestamp_server_seconds
        "trickery": referrerDetails.installBeginTimestampServerSeconds,
        //install_first_seconds
        "quixotic": "0",
        //last_update_seconds
        "manna": "0",
        //referrer_url
        "sculpt": referrerDetails.installReferrer,
        //install_version
        "gender": referrerDetails.installVersion,
      },
    );
  }

  Future<BaseModel> postSession() async {
    AppLog.i("上报session");
    if (GetPlatform.isIOS) {
      return BaseModel(code: -1);
    }
    return TbaAnd.instance.postData(TbaType.session);
  }

  Future<BaseModel> postAd({
    required String ad_network,
    required String ad_format,
    required String ad_source,
    required String ad_unit_id,
    required String adSense,
    required String ad_pre_ecpm,
    required String currency,
    required String adPosName,
    // required String precision_type,
    // required String positionKey,
  }) async {
    if (GetPlatform.isIOS) {
      return BaseModel(code: -1);
    }

    //增加广告显示位置的埋点
    // EventUtils.instance.addEvent(
    //   "ad_impression_show",
    //   data: {"pos": showPos, "ad_show_type": ad_type},
    // );

    num realMoney = num.tryParse(ad_pre_ecpm) ?? 0;
    //android
    if (ad_source == "max" || ad_source == "topon") {
      realMoney = realMoney * 1000000;
    }

    // final adMoney = realMoney.toDouble();
    //不是admob广告，其他平台不是admob聚合
    double amount = (num.tryParse(ad_pre_ecpm) ?? 0).toDouble();
    if (ad_source != "admob" && (!ad_network.toLowerCase().contains("admob"))) {
      FirebaseAnalytics.instance.logAdImpression(
        adFormat: ad_format,
        adPlatform: ad_network,
        adSource: ad_source,
        adUnitName: ad_unit_id,
        //这里是不乘10的6次方的值
        value: amount,
        currency: currency,
      );
    }

    AdjustUtil.instance.addRevenueEvent(ad_source, amount: amount, network: ad_network, placement: adPosName);
    AdjustUtil.instance.addPurchaseEvent(name: "ad_impression_and", amount: amount);

    _postAdRevenue001(amount);

    AppLog.i("ad_impression广告价值:$ad_pre_ecpm, adSource:$ad_source, adFormat:${adPosName}_$ad_format, adSense:$adSense, adPosId:$adPosName,  adNetwork:$ad_network, $ad_unit_id");

    return TbaAnd.instance.postData(
      TbaType.ad,
      eventData: {
        "ketch": ad_network,
        "corey": ad_source, //广告SDK，admob，max等
        "century": ad_unit_id, //广告id
        "ploy": "${adPosName}_$ad_format", //广告类型，插屏，原生，banner，激励视频等
        "coppery": adPosName, //广告位逻辑编号，例如：page1_bottom, connect_finished
        "victrola": realMoney.toString(),
        "habitant": currency,
        "tilth": adSense, //广告场景: backplay,enterplay,open,pause,playing,search
        // "watanabe": precision_type, //google ltvpingback的预估收益类型
      },
      positionKey: adSense,
      // positionKey: positionKey,
    );
  }

  Future<BaseModel> postUserData(Map<String, dynamic> data) async {
    if (GetPlatform.isIOS) {
      return BaseModel(code: -1);
    }

    return TbaAnd.instance.postData(TbaType.userInfo, eventData: data);
  }

  void _postAdRevenue001(double revenue) {
    if (_accumulateAdRevenue == 0) {
      _accumulateAdRevenue = museSp.getDouble(DBKey.keyAdImpression001);
    }
    _accumulateAdRevenue = _accumulateAdRevenue + revenue;

    if (_accumulateAdRevenue > 0.001) {
      EventUtils.instance.addEvent("ads_revenue_001", data: {"value": _accumulateAdRevenue, "currency": "USD"});
      AdjustUtil.instance.addPurchaseEvent(amount: _accumulateAdRevenue, name: "ads_revenue_001");
      _accumulateAdRevenue = 0;
      museSp.setDouble(DBKey.keyAdImpression001, 0);
    } else {
      museSp.setDouble(DBKey.keyAdImpression001, _accumulateAdRevenue);
    }
  }
}

enum TbaType { install, session, ad, event, cloak, userInfo }
