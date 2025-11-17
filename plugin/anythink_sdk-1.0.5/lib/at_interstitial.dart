import 'dart:async';
import 'package:anythink_sdk/anythink_sdk.dart';


final ATInterstitialManager = ATInterstitial();

class ATInterstitial {
/*Initialization*/
  ATInterstitial();

/*Load interstitial ad */
  Future<String> loadInterstitialAd({
    required String placementID,
    required Map extraMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("loadInterstitialAd", {
      "placementID": placementID,
      "extraDic": extraMap,
    });
  }

  String useRewardedVideoAsInterstitialKey() {
    return "UseRewardedVideoAsInterstitialKey";
  }

  String kATAdShowCustomExtKey(){
    return 'kATAdShowCustomExtKey';
  }

  Map createInterstitialSize(
    double width,
    double height,
  ) {
    return {
      'width': width,
      'height': height,
    };
  }

  /*Show interstitial ad */
  Future<String> showInterstitialAd({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showInterstitialAd", {
      "placementID": placementID,
    });
  }

  /*Interstitial ad*/
  Future<String> showSceneInterstitialAd({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showSceneInterstitialAd", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> showInterstitialAdWithShowConfig({
    required String placementID,
    required String sceneID,
    required String showCustomExt,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showInterstitialAdWithShowConfig", {
      "placementID": placementID,
      "sceneID": sceneID,
      "showCustomExt": showCustomExt,
    });
  }

/*Whether there is ad cache*/
  Future<bool> hasInterstitialAdReady({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("hasInterstitialAdReady", {
      "placementID": placementID,
    });
  }

/*Get information about all available ads in the current ad slot，v 5.7.53 and above version support */
  Future<String> getInterstitialValidAds({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("getInterstitialValidAds", {
      "placementID": placementID,
    });
  }

  /*Get information about all available ads in the current ad slot, supported by v 5.7.53 and above */
  Future<Map> checkInterstitialLoadStatus({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel
        .invokeMethod("checkInterstitialLoadStatus", {
      "placementID": placementID,
    });
  }

  Future<bool> entryInterstitialScenario({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("entryInterstitialScenario", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> autoLoadInterstitialAD({
    required String placementIDs
  }) async {
    return await AnythinkSdk.channel.invokeMethod("autoLoadInterstitialAD", {
      "placementIDMulti": placementIDs
    });
  }

  Future<String> cancelAutoLoadInterstitialAD({
    required String placementIDs,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("cancelAutoLoadInterstitialAD", {
      "placementIDMulti": placementIDs,
    });
  }

  Future<String> showAutoLoadInterstitialAD({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showAutoLoadInterstitialAD", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> autoLoadInterstitialADSetLocalExtra({
    required String placementID,
    required Map extraMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("autoLoadInterstitialADSetLocalExtra", {
      "placementIDMulti": placementID,//not multi , only support single
      "extraDic": extraMap,
    });
  }
}
