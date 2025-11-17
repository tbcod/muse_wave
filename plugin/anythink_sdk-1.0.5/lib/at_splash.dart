import 'dart:async';

import 'package:anythink_sdk/anythink_sdk.dart';

final ATSplashManager = ATSplash();

class ATSplash{

/*Initialization */
  ATSplash();

  String tolerateTimeout() {
    return 'tolerateTimeout';
  }

/*Load splash  ad */
  Future<String> loadSplash({
    required String placementID,
    required Map extraMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("loadSplash", {
      "placementID": placementID,
      "extraDic": extraMap,
    });
  }

  /*Show splash ad */
  Future<String> showSplash({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showSplash", {
      "placementID": placementID,
    });
  }

  /*Show scene splash ad */
  Future<String> showSceneSplash({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showSceneSplash", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> showSplashAdWithShowConfig({
    required String placementID,
    required String sceneID,
    required String showCustomExt,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showSplashAdWithShowConfig", {
      "placementID": placementID,
      "sceneID": sceneID,
      "showCustomExt": showCustomExt,
    });
  }

/*Whether there is ad cache */
  Future<bool> splashReady({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("splashReady", {
      "placementID": placementID,
    });
  }

/*Check ad status */
  Future<Map> checkSplashLoadStatus({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("checkSplashLoadStatus", {
      "placementID": placementID,
    });
  }

  /*Get information about all available ads in the current ad slot*/
  Future<String> getSplashValidAds({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("getSplashValidAds", {
      "placementID": placementID,
    });
  }

  Future<bool> entrySplashScenario({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("entrySplashScenario", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }
}
