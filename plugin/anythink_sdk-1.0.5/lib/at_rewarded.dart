import 'dart:async';

import 'package:anythink_sdk/anythink_sdk.dart';

final ATRewardedManager = ATRewarded();

class ATRewarded{

/*Initialization */
  ATRewarded();

/*Load rewarded video ad */
  Future<String> loadRewardedVideo({
    required String placementID,
    required Map extraMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("loadRewardedVideo", {
      "placementID": placementID,
      "extraDic": extraMap,
    });
  }

  String kATAdLoadingExtraUserDataKeywordKey(){
    return 'kATAdLoadingExtraUserDataKeywordKey';
  }
  String kATAdLoadingExtraUserIDKey(){
    return 'kATAdLoadingExtraUserIDKey';
  }

  /*Show rewarded video ad */
  Future<String> showRewardedVideo({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showRewardedVideo", {
      "placementID": placementID,
    });
  }

  /*Showcase rewarded video ad */
  Future<String> showSceneRewardedVideo({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showSceneRewardedVideo", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> showRewardedVideoWithShowConfig({
    required String placementID,
    required String sceneID,
    required String showCustomExt,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showRewardedVideoWithShowConfig", {
      "placementID": placementID,
      "sceneID": sceneID,
      "showCustomExt": showCustomExt,
    });
  }

/*Whether there is ad cache */
  Future<bool> rewardedVideoReady({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("rewardedVideoReady", {
      "placementID": placementID,
    });
  }

/*Check ad status */
  Future<Map> checkRewardedVideoLoadStatus({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("checkRewardedVideoLoadStatus", {
      "placementID": placementID,
    });
  }

  /*Get information about all available ads in the current ad slot, supported by v 5.7.53 and above */
  Future<String> getRewardedVideoValidAds({
    required String placementID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("getRewardedVideoValidAds", {
      "placementID": placementID,
    });
  }

  Future<String> entryRewardedVideoScenario({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("entryRewardedVideoScenario", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> autoLoadRewardedVideo({
    required String placementIDs
  }) async {
    return await AnythinkSdk.channel.invokeMethod("autoLoadRewardedVideoAD", {
      "placementIDMulti": placementIDs
    });
  }

  Future<String> cancelAutoLoadRewardedVideo({
    required String placementIDs,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("cancelAutoLoadRewardedVideoAD", {
      "placementIDMulti": placementIDs,
    });
  }

  Future<String> showAutoLoadRewardedVideoAD({
    required String placementID,
    required String sceneID,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showAutoLoadRewardedVideoAD", {
      "placementID": placementID,
      "sceneID": sceneID,
    });
  }

  Future<String> autoLoadRewardedVideoSetLocalExtra({
    required String placementID,
    required Map extraMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("autoLoadRewardedVideoADSetLocalExtra", {
      "placementIDMulti": placementID,//not multi , only support single
      "extraDic": extraMap,
    });
  }
}
