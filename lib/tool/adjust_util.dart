import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:get/get.dart';
import 'package:muse_wave/main.dart';
import 'package:muse_wave/muse_config.dart';

import 'log.dart' show AppLog;

class AdjustUtil {
  AdjustUtil._() : super();
  static final AdjustUtil _instance = AdjustUtil._();

  static AdjustUtil get instance {
    return _instance;
  }

  void initSdk() {
    try {
      AdjustConfig config = AdjustConfig(MuseConfig.adjustAppId, MuseConfig.isUser ? AdjustEnvironment.production : AdjustEnvironment.sandbox);
      String distinctId = Get.find<Application>().userAppUuid;
      Adjust.addGlobalCallbackParameter('customer_user_id', distinctId);
      Adjust.initSdk(config);
    } catch (e) {
      AppLog.e("initAdjust init fail:$e");
    }
  }

  void addRevenueEvent(String adSource, {double amount = 0, String? network, String? placement, String? adId}) {
    String source = "admob_sdk";
    if (adSource.toLowerCase() == 'max') {
      source = "applovin_max_sdk";
    } else if (adSource.toLowerCase() == 'topon') {
      source = "topon_sdk";
    }
    AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue(source);
    adjustAdRevenue.setRevenue(amount, "USD");
    adjustAdRevenue.adRevenueUnit = adId;
    adjustAdRevenue.adRevenueNetwork = network;
    adjustAdRevenue.adRevenuePlacement = placement;
    Adjust.trackAdRevenue(adjustAdRevenue);
    AppLog.i('【Adjust】价值上报 amount:$amount, source:$source, network:$network');
  }

  void addPurchaseEvent({required double amount, required String name}) {
    AdjustEvent event = AdjustEvent(_getTokenName(name));
    event.setRevenue(amount, 'USD');
    Adjust.trackEvent(event);
    AppLog.i('【Adjust】事件上报 amount:$amount, name:$name');
  }


  String _getTokenName(String name) {
    String token = "";
    name = name.toLowerCase();
    if (MuseConfig.isUser) {
      if (name == 'ads_revenue_001') {
        token = "4joj3w";
      } else if (name == 'ad_impression_and') {
        token = "h5fbr3";
      }
    } else {
      if (name == 'ads_revenue_001') {
        token = "53lzf8";
      } else if (name == 'ad_impression_and') {
        token = "g3qup0";
      }
    }
    return token;
  }
}
