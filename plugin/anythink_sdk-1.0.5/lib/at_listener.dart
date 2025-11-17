import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:anythink_sdk/at_index.dart';

final ATListenerManager = ATListener();

class ATListener {
  StreamController<ATInitResponse> _initEventHandlerController =
      new StreamController.broadcast();

  Stream<ATInitResponse> get initEventHandler =>
      _initEventHandlerController.stream;

  StreamController<ATBannerResponse> _bannerEventHandlerController =
      new StreamController.broadcast();

  Stream<ATBannerResponse> get bannerEventHandler =>
      _bannerEventHandlerController.stream;

  StreamController<ATInterstitialResponse> _interstitialEventHandlerController =
      new StreamController.broadcast();

  Stream<ATInterstitialResponse> get interstitialEventHandler =>
      _interstitialEventHandlerController.stream;

  StreamController<ATNativeResponse> _nativeEventHandlerController =
      new StreamController.broadcast();

  Stream<ATNativeResponse> get nativeEventHandler =>
      _nativeEventHandlerController.stream;

  StreamController<ATRewardResponse> _rewardedVideoEventHandlerController =
      new StreamController.broadcast();

  Stream<ATRewardResponse> get rewardedVideoEventHandler =>
      _rewardedVideoEventHandlerController.stream;

  StreamController<ATSplashResponse> _splashEventHandlerController =
  new StreamController.broadcast();

  Stream<ATSplashResponse> get splashEventHandler =>
      _splashEventHandlerController.stream;


  StreamController<ATDownloadResponse> _downloadEventHandlerController =
    new StreamController.broadcast();

  Stream<ATDownloadResponse> get downloadEventHandler =>
      _downloadEventHandlerController.stream;


  /*Initialization*/
  ATListener() {
    AnythinkSdk.channel.setMethodCallHandler(_adMethodHandler);
  }


  /*Advertising status callback */
  Future _adMethodHandler(MethodCall methodCall) {

    try {
      if (methodCall.method == 'NativeCall') {
        var tempInterstitialResponse = ATNativeResponse.withMap(methodCall.arguments);

        _nativeEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'BannerCall') {
        var tempInterstitialResponse = ATBannerResponse.withMap(methodCall.arguments);
        _bannerEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'InterstitialCall') {
        var tempInterstitialResponse = ATInterstitialResponse.withMap(methodCall.arguments);

        _interstitialEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'RewardedVideoCall') {
        var tempRewardResponse = ATRewardResponse.withMap(methodCall.arguments);

        _rewardedVideoEventHandlerController.add(tempRewardResponse);
      } else if (methodCall.method == 'SplashCall') {
        var tempSplashResponse = ATSplashResponse.withMap(methodCall.arguments);

        _splashEventHandlerController.add(tempSplashResponse);
      } else if (methodCall.method == 'InitCallName') {
        var tempInitdResponse = ATInitResponse.withMap(methodCall.arguments);

        _initEventHandlerController.add(tempInitdResponse);
      } else if (methodCall.method == 'DownloadCall') {//Only for Android

        if (Platform.isAndroid) {
          var tempDownloadResponse = ATDownloadResponse.withMap(methodCall.arguments);

          _downloadEventHandlerController.add(tempDownloadResponse);

        }
      }

    } catch (e, stack) {
      print("ATFlutterSDK error：" + e.toString());
      print("ATFlutterSDK error stack：" + stack.toString());
    }

    return Future.value();
  }
}
