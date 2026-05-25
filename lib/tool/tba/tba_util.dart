import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/static/db_key.dart';
import 'package:muse_wave/tool/ad/ad_util.dart';
import 'package:muse_wave/tool/adjust_util.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/native_utils.dart';
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

  double _accumulateAdRevenue001 = 0; //累计的广告价值
  double _accumulateAdRevenue002 = 0; //累计的广告价值
  double _accumulateAdRevenue003 = 0; //累计的广告价值
  double _accumulateAdRevenue005 = 0; //累计的广告价值

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

    AppLog.i("上报install");

    // return BaseModel(code: -1);

    //android
    var andInfo = await DeviceInfoPlugin().androidInfo;

    ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

    // referrerDetails.googlePlayInstantParam;

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
    // AppLog.i("上报session");
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
    required String adFunction,
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

    if (kDebugMode && !MuseConfig.isUser && realMoney == 0) {
      realMoney = 0.005 * 1000000; //测试环境，非用户，金额为0时，默认上报0.005美元的广告价值，方便测试广告价值相关功能
    }

    // final adMoney = realMoney.toDouble();
    //不是admob广告，其他平台不是admob聚合
    // double amount = (num.tryParse(ad_pre_ecpm) ?? 0).toDouble();
    double amount = realMoney / 1000000;

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

    try {
      AdjustUtil.instance.addRevenueEvent(ad_source, amount: amount, network: ad_network, placement: adPosName);
      AdjustUtil.instance.addPurchaseEvent(name: "ad_impression_and", amount: amount);

      NativeUtils.instance.logEventFB(name: "ad_impression_revenue", valueToSum: amount);
      NativeUtils.instance.logEventFB(
          name: "AdImpression", parameters: {"fb_currency": "USD", "fb_ad_type": ad_source}, valueToSum: amount);
      NativeUtils.instance.logPurchaseFB(amount: amount);

      // FacebookAppEvents().logEvent(name: "ad_impression_revenue", valueToSum: amount);
      // FacebookAppEvents().logEvent(name: FacebookAppEvents.eventNameAdImpression, parameters: {FacebookAppEvents.paramNameCurrency: "USD", FacebookAppEvents.paramNameAdType: ad_source}, valueToSum: amount);
      // FacebookAppEvents().logPurchase(amount: amount, currency: "USD");
    } catch (e) {
      AppLog.e("上报广告价值失败：$e");
    }

    _postAdRevenue001(amount);
    _postAdRevenue002(amount);
    _postAdRevenue003(amount);
    _postAdRevenue005(amount);

    AppLog.i(
      "广告价值 ad_impression:$ad_pre_ecpm, adSource:$ad_source, adFormat:$ad_format, adSense:$adSense, adPosId:$adPosName,  adNetwork:$ad_network, $ad_unit_id",
    );

    // if (adSense == AdScene.open_cool.name && bus.isFirstAppLaunch) {
    //   adSense = AdScene.open_first.name;
    // }
    return TbaAnd.instance.postData(
      TbaType.ad,
      eventData: {
        "ketch": ad_network,
        "corey": ad_source, //广告SDK，admob，max等
        "century": ad_unit_id, //广告id
        "ploy": ad_format, //广告类型，插屏，原生，banner，激励视频等
        "coppery": adPosName, //广告位逻辑编号，例如：page1_bottom, connect_finished
        "victrola": realMoney.toString(),
        "habitant": currency,
        "tilth": adSense, //广告场景 home
        "joyride/ad_function": adFunction, //触发广告点，例如：play
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

  void _postAdRevenue001(double revenue) => _postAdRevenue(
      revenue: revenue,
      threshold: 0.01,
      eventName: "ads_revenue_001",
      dbKey: DBKey.keyAdImpression001,
      current: _accumulateAdRevenue001,
      setCurrent: (value) => _accumulateAdRevenue001 = value);

  void _postAdRevenue002(double revenue) => _postAdRevenue(
      revenue: revenue,
      threshold: 0.02,
      eventName: "ads_revenue_002",
      dbKey: DBKey.keyAdImpression002,
      current: _accumulateAdRevenue002,
      setCurrent: (value) => _accumulateAdRevenue002 = value);

  void _postAdRevenue003(double revenue) => _postAdRevenue(
      revenue: revenue,
      threshold: 0.03,
      eventName: "ads_revenue_003",
      dbKey: DBKey.keyAdImpression003,
      current: _accumulateAdRevenue003,
      setCurrent: (value) => _accumulateAdRevenue003 = value);

  void _postAdRevenue005(double revenue) => _postAdRevenue(
      revenue: revenue,
      threshold: 0.05,
      eventName: "ads_revenue_005",
      dbKey: DBKey.keyAdImpression005,
      current: _accumulateAdRevenue005,
      setCurrent: (value) => _accumulateAdRevenue005 = value);

  void _postAdRevenue({
    required double revenue,
    required double threshold,
    required String eventName,
    required String dbKey,
    required double current,
    required void Function(double value) setCurrent,
  }) {
    double accumulate = current;
    if (accumulate == 0) {
      accumulate = museSp.getDouble(dbKey);
    }
    accumulate = accumulate + revenue;

    if (accumulate >= threshold) {
      AppLog.i("累计广告价值达到$threshold美元，触发事件$eventName, 累计价值：$accumulate");
      try {
        if (eventName == "ads_revenue_001") {
          EventUtils.instance.addEvent(eventName, data: {"value": accumulate, "currency": "USD"}, hasPrefix: true);
        }
        EventUtils.instance.addEvent(eventName, data: {"value": accumulate, "currency": "USD"}, hasPrefix: false);
        AdjustUtil.instance.addPurchaseEvent(amount: accumulate, name: eventName);
        NativeUtils.instance.logEventFB(name: eventName, valueToSum: accumulate, parameters: {"currency": "USD"});
      } catch (_) {}
      setCurrent(0);
      museSp.setDouble(dbKey, 0);
    } else {
      setCurrent(accumulate);
      museSp.setDouble(dbKey, accumulate);
    }
  }
}

enum TbaType { install, session, ad, event, cloak, userInfo }
