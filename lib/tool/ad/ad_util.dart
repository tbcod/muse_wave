import 'dart:async';
import 'package:anythink_sdk/at_index.dart';
import 'package:anythink_sdk/at_interstitial.dart';
import 'package:anythink_sdk/at_interstitial_response.dart';
import 'package:anythink_sdk/at_listener.dart';
import 'package:anythink_sdk/at_rewarded.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/tool/ad/topon_util.dart';
import 'package:muse_wave/tool/remote_utils.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/ui/launch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import '../../main.dart';
import '../log.dart';
import '../tba/tba_util.dart';
import 'admob_util.dart';
import 'max_util.dart';
import 'view/full_admob_native.dart';

enum AdScene { play, download, search, openCool, openHot, playlist, artist, collection, back }

enum AdPosition { open, behavior, level_h, homenative, normalbanner, pagebanner, nvpage_full }

class AdUtils {
  AdUtils._internal();

  static final AdUtils _instance = AdUtils._internal();

  static AdUtils get instance {
    return _instance;
  }

  // //and test
  // Map<String, dynamic> adJson = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 3, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/9257395921"},
  //     {"adweight": 2, "adtype": "interstitial", "adsource": "topon", "placementid": "n1gbeetrbtukca"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "06d5dd9f002c4700"},
  //   ],
  //   "behavior": [
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/1033173712"},
  //     {"adweight": 0, "adtype": "interstitial", "adsource": "max", "placementid": "06d5dd9f002c4700"},
  //     {"adweight": 8, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/5224354917"},
  //     {"adweight": 0, "adtype": "rewarded", "adsource": "max", "placementid": "211dd6273efd19a2"},
  //     {"adweight": 6, "adtype": "rewarded", "adsource": "topon", "placementid": "n1gbeetrbtugji"},
  //     {"adweight": 5, "adtype": "interstitial", "adsource": "topon", "placementid": "n1gbeetrbtukca"},
  //   ],
  //   "level_h": [
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/1033173712"},
  //   ],
  //   "homenative": [
  //     {"adweight": 9, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/2247696110"},
  //     {"adweight": 2, "adtype": "native", "adsource": "max", "placementid": "92c6b07927de912a"},
  //     {"adweight": 3, "adtype": "native", "adsource": "topon", "placementid": "n1gbeetrbtu7ci"},
  //   ],
  //   "normalbanner": [
  //     {"adweight": 3, "adtype": "banner", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/9214589741"},
  //     {"adweight": 2, "adtype": "banner", "adsource": "max", "placementid": "b076089954d872da"},
  //     {"adweight": 1, "adtype": "banner", "adsource": "topon", "placementid": "n1gbeetrbtudei"},
  //   ],
  //   "pagebanner": [
  //     {"adweight": 3, "adtype": "banner", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/9214589741"},
  //     {"adweight": 2, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/2247696110"},
  //     {"adweight": 1, "adtype": "banner", "adsource": "max", "placementid": "b076089954d872da"},
  //     {"adweight": 10, "adtype": "banner", "adsource": "topon", "placementid": "n1gbeetrbtudei"},
  //     {"adweight": 0, "adtype": "native", "adsource": "max", "placementid": "92c6b07927de912a"},
  //     {"adweight": 9, "adtype": "native", "adsource": "topon", "placementid": "n1gbeetrbtu7ci"},
  //   ],
  // };
  //
  // //ios test
  // Map<String, dynamic> adJsonIos = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 2, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/5575463023"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "fbd6076120e63535"},
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "topon", "placementid": "b1g8t40knh0dqb"},
  //   ],
  //   "behavior": [
  //     {"adweight": 3, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/4411468910"},
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "max", "placementid": "fbd6076120e63535"},
  //     {"adweight": 4, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/1712485313"},
  //     {"adweight": 2, "adtype": "rewarded", "adsource": "max", "placementid": "7aa2c1ce7a11fe8b"},
  //     {"adweight": 8, "adtype": "rewarded", "adsource": "topon", "placementid": "b1g8t40knh0541"},
  //     {"adweight": 9, "adtype": "interstitial", "adsource": "topon", "placementid": "b1g8t40knh0dqb"},
  //   ],
  //   "homenative": [
  //     {"adweight": 1, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-3940256099942544/3986624511"},
  //     // {
  //     //   "adweight": 2,
  //     //   "adtype": "native",
  //     //   "adsource": "topon",
  //     //   "placementid": "b1g8t40knh0lt8"
  //     // },
  //     // {
  //     //   "adweight": 2,
  //     //   "adtype": "banner",
  //     //   "adsource": "topon",
  //     //   "placementid": "b1g8t40knh0rb9"
  //     // }
  //   ],
  // };
  //
  // //and
  // Map<String, dynamic> adJsonRelease = {
  //   "sameinterval": 60,
  //   "timeout": 7,
  //   "playpointtime": 600,
  //   "open": [
  //     {"adweight": 3, "adtype": "open", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/1746930585"},
  //   ],
  //   "behavior": [
  //     {"adweight": 1, "adtype": "interstitial", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/6497195390"},
  //     {"adweight": 1, "adtype": "rewarded", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/2261935904"},
  //   ],
  //   "homenative": [
  //     {"adweight": 1, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/9433848915"},
  //   ],
  //   "level_h": [],
  //   "normalbanner": [
  //     {"adweight": 3, "adtype": "banner", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/5978638847"},
  //     {"adweight": 2, "adtype": "banner", "adsource": "max", "placementid": "ef71fab89b67c425"},
  //     {"adweight": 1, "adtype": "banner", "adsource": "topon", "placementid": "n1gbef4lcr6cof"},
  //   ],
  //   "pagebanner": [
  //     {"adweight": 2, "adtype": "banner", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/5978638847"},
  //     {"adweight": 1, "adtype": "native", "adsource": "admob", "placementid": "ca-app-pub-5737687418229244/9433848915"},
  //   ],
  // };

  //ios
  // Map<String, dynamic> adJsonIosRelease = {"sameinterval": 60, "timeout": 7, "playpointtime": 600, "open": [], "behavior": [], "homenative": []};

  DateTime? lastShowTime;

  Map<String, dynamic> get adJson => RemoteUtil.shareInstance.adJson;

  var fullNativeAdClicked = false.obs;
  var pageNativeAdClicked = false.obs;

  //是否超过广告间隔
  Future<bool> canShow() async {
    if (lastShowTime == null) {
      return true;
    }

    var nowTime = DateTime.now();

    Duration temp = nowTime.difference(lastShowTime!);
    num wait = num.tryParse(adJson["sameinterval"].toString()) ?? 60;
    // AppLog.e("广告间隔\n${lastShowTime}\n${nowTime}\n${temp.inSeconds}---${wait}");

    if (temp.inSeconds > wait || temp.inSeconds < 0) {
      return true;
    } else {
      AppLog.i("广告间隔中:${temp.inSeconds}s---需要${wait}s");
      return false;
    }
  }

  //设置上次显示广告时间
  Future setShowTime() async {
    // AppLog.e("保存关闭广告时间");
    lastShowTime = DateTime.now();
    // var sp = await SharedPreferences.getInstance();
    // await sp.setInt("lastShowAdMs", DateTime.now().millisecondsSinceEpoch);
  }

  //已加载的广告，key为广告id，显示后移除对应广告
  var loadedAdMap = {};
  Timer? loadTimer;

  //load
  loadAd(String key, {required String positionKey, LoadCallback? onLoad}) async {
    if (!Get.isRegistered<LaunchPageController>()) {
      //除启动广告优先加载高价
      if (key != "level_h") {
        //同步加载高价
        loadAd("level_h", positionKey: positionKey);
      }
    }

    AppLog.i("开始加载广告:$key");
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告$key");
      return;
    }
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    bool isLoadSuc = false;
    //循环加载广告

    EventUtils.instance.addEvent("ad_load_start", data: {"ad_pos_id": key});

    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];
      int ad_weight = item["adweight"];

      if (loadedAdMap.containsKey(ad_id)) {
        //如果已经加载了并且没有超时就跳过
        int timeMs = loadedAdMap[ad_id]["timeMs"] ?? 0;
        //缓存过期时间
        if (timeMs < DateTime.now().subtract(Duration(minutes: 55)).millisecondsSinceEpoch) {
          //已过期,删除广告重新加载
          //销毁广告后删除

          // admob广告先销毁再删除
          if (ad_id.startsWith("ca-app-pub")) {
            // AdWithoutView? adView = loadedAdMap[ad_id]["admob_ad"];
            // adView?.dispose();

            final adView = loadedAdMap[ad_id]["admob_ad"];
            if (adView is NativeAd) {
              adView.dispose();
            } else if (adView is AdWithoutView) {
              adView.dispose();
            }
          }
          loadedAdMap.remove(ad_id);
        } else {
          // //未过期，加载下一条
          // continue;
          AppLog.i("广告缓存存在：$key， $source, $type, $ad_id");
          isLoadSuc = true;
          break;
        }
      }
      AppLog.i("广告开始加载：$key， $source, $type, $ad_id");
      String reason = "";
      Completer<bool> isCompleter = Completer();
      loadTimer?.cancel();
      loadTimer = Timer(Duration(seconds: 12), () {
        if (!isCompleter.isCompleted) {
          reason = "time out";
          AppLog.e("广告加载超时：$key， $source, $type, $ad_id");
          isCompleter.complete(false);
        }
      });

      if (source == "admob") {
        //加载admob广告
        if (type == "open") {
          AppLog.e("admob 开始加载open");

          AppOpenAd.load(
            adUnitId: ad_id,
            request: AdRequest(),
            adLoadCallback: AppOpenAdLoadCallback(
              onAdLoaded: (ad) {
                AppLog.e("admob 成功加载open");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (e) {
                AppLog.e("admob 加载open失败");
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
            ),
          );
        } else if (type == "interstitial") {
          AppLog.e("admob 开始加载interstitial");
          InterstitialAd.load(
            adUnitId: ad_id,
            request: AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                AppLog.e("admob 加载完成interstitial");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (e) {
                AppLog.e("admob 加载失败interstitial");
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
              },
            ),
          );
        } else if (type == "rewarded") {
          // AppLog.e("admob 开始加载rewarded");
          RewardedAd.load(
            adUnitId: ad_id,
            request: AdRequest(),
            rewardedAdLoadCallback: RewardedAdLoadCallback(
              onAdLoaded: (ad) {
                // AppLog.e("admob 加载完成rewarded");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (e) {
                AppLog.e("admob 加载失败rewarded");
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
            ),
          );
        } else if (type == "native") {
          NativeAd nativeAd = NativeAd(
            adUnitId: ad_id,
            factoryId: 'admob_full_native',
            request: const AdRequest(),
            listener: admob.NativeAdListener(
              onAdLoaded: (ad) async {
                AppLog.i("广告加载成功：$key， $source, $type, $ad_id, adweight:${item['adweight']}");
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (ad, e) {
                AppLog.e("广告加载失败：$key， $source, $type, $ad_id, adweight:$ad_weight，${e.toString()}");
                ad.dispose();
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdClicked: (ad) {
                fullNativeAdClicked.refresh();
                AppLog.i("原生广告点击:${ad.adUnitId}");
              },
              onAdImpression: (ad) {
                adIsShowing = true;
                AppLog.i("原生广告onAdImpression:${ad.adUnitId}");
              },
              onAdClosed: (ad) {
                //关闭
                // adIsShowing = false;
                // //设置显示时间以判断广告间隔
                // setShowTime();
                // //重新加载一轮广告
                // loadAd(key);
              },
              onAdWillDismissScreen: (ad) {
                // AppLog.i("原生广告onAdWillDismissScreen:${ad.adUnitId}");
              },
              onAdOpened: (ad) {
                AppLog.i("原生广告onAdOpened:${ad.adUnitId}");
                adIsShowing = true;
              },
              onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
                TbaUtils.instance.postAd(
                  ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "admob",
                  ad_format: "native",
                  ad_source: "admob",
                  ad_unit_id: ad.adUnitId,
                  ad_pos_id: "full_native",
                  ad_pre_ecpm: valueMicros.toString(),
                  currency: currencyCode,
                  ad_sence: key,
                );
              },
            ),
            nativeTemplateStyle: null,
            // nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium, cornerRadius: 8),
          );
          await nativeAd.load();
        } else {
          reason = "unSupport type loader:$type";
          if (!isCompleter.isCompleted) isCompleter.complete(false);
        }
      } else if (source == "max") {
        //加载max广告
        if (type == "open") {
          AppLovinMAX.setAppOpenAdListener(
            AppOpenAdListener(
              onAdLoadedCallback: (ad) {
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {},
            ),
          );
          AppLovinMAX.loadAppOpenAd(ad_id);
        } else if (type == "interstitial") {
          AppLovinMAX.setInterstitialListener(
            InterstitialListener(
              onAdLoadedCallback: (ad) {
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {},
            ),
          );
          AppLovinMAX.loadInterstitial(ad_id);
        } else if (type == "rewarded") {
          AppLovinMAX.setRewardedAdListener(
            RewardedAdListener(
              onAdLoadedCallback: (ad) {
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdLoadFailedCallback: (adId, e) {
                if (onLoad != null) {
                  onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdDisplayedCallback: (ad) {},
              onAdDisplayFailedCallback: (ad, e) {},
              onAdClickedCallback: (ad) {},
              onAdHiddenCallback: (ad) {},
              onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {},
            ),
          );
          AppLovinMAX.loadRewardedAd(ad_id);
        } else {
          reason = "unSupport type loader:$type";
          if (!isCompleter.isCompleted) isCompleter.complete(false);
        }
      } else if (source == "topon") {
        if (type == "interstitial") {
          TopOnUtils.instance.interstitialStream?.cancel();
          TopOnUtils.instance.interstitialStream = null;

          AppLog.e("加载topon插屏");
          TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
            if (e.interstatus == InterstitialStatus.interstitialAdDidFinishLoading) {
              //加载成功
              AppLog.e("topon插屏加载成功");
              if (onLoad != null) {
                onLoad(e.placementID, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": null,
                "load_pos": positionKey,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
              };
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            } else if (e.interstatus == InterstitialStatus.interstitialAdFailToLoadAD) {
              //加载失败
              AppLog.e("topon插屏加载失败:${e.requestMessage}");
              if (onLoad != null) {
                onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
              }
              reason = e.requestMessage;
              if (!isCompleter.isCompleted) isCompleter.complete(false);
            }
          });
          ATInterstitialManager.loadInterstitialAd(placementID: ad_id, extraMap: {});
        } else if (type == "rewarded") {
          TopOnUtils.instance.rewardedStream?.cancel();
          TopOnUtils.instance.rewardedStream = null;

          AppLog.e("加载topon激励");
          TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
            if (e.rewardStatus == RewardedStatus.rewardedVideoDidFinishLoading) {
              //加载成功
              AppLog.e("topon激励加载成功");
              if (onLoad != null) {
                onLoad(e.placementID, true, null);
              }
              AdUtils.instance.loadedAdMap[ad_id] = {
                "data": item,
                "admob_ad": null,
                "load_pos": positionKey,
                "timeMs": DateTime.now().millisecondsSinceEpoch,
                "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
              };
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToLoad) {
              //加载失败
              AppLog.e("topon激励加载失败:${e.requestMessage}");
              if (onLoad != null) {
                onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
              }
              reason = e.requestMessage;
              if (!isCompleter.isCompleted) isCompleter.complete(false);
            }
          });
          ATRewardedManager.loadRewardedVideo(placementID: ad_id, extraMap: {});
        } else {
          reason = "unSupport type loader:$type";
          if (!isCompleter.isCompleted) isCompleter.complete(false);
        }
      } else {
        reason = "unSupport source:$source";
        if (!isCompleter.isCompleted) isCompleter.complete(false);
      }
      isLoadSuc = await isCompleter.future;
      if (isLoadSuc) {
        EventUtils.instance.addEvent("ad_load_succ", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source": source, "ad_type": type});
        AppLog.i("广告瀑布流请求完成：$key, adweight:$ad_weight, $source, $type, $ad_id");
        break;
      } else {
        AppLog.e("广告瀑布流请求失败：$key, $source, $type, adweight:$ad_weight, $ad_id, reason:$reason");
        EventUtils.instance.addEvent("ad_load_fail", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source": source, "ad_type": type, "reason": reason});
        continue;
      }
    }
    return isLoadSuc;
  }

  bool adIsShowing = false;

  Future<bool> showAd(String key, {required AdScene adScene, ShowCallback? onShow}) async {
    final load_pos = adScene.name;
    if (adIsShowing) {
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "ad is showing"));
      }
      return false;
    }

    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告：$key");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "show key error"));
      }
      return false;
    }

    if (Get.find<Application>().isAppBack == true) {
      AppLog.e("app在后台");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "app is background"));
      }
      return false;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    // AppLog.e("广告网络：$connectivityResult");
    if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
      //没有网络
      AppLog.e("没有网络，不显示广告");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no network"));
      }
      return false;
    }

    if (!await canShow()) {
      // AppLog.e("广告间隔未到");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "ad interval has not expired"));
      }
      return false;
    }

    //优先显示高价
    if (key != "level_h") {
      var isShow = await showAd("level_h", adScene: adScene);

      // AppLog.e("高价显示：$isShow");
      if (isShow) {
        return true;
      }
    }

    //显示广告逻辑
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return false;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    //循环判断广告是否加载
    AppLog.i("开始显示广告:$key");

    EventUtils.instance.addEvent("ad_chance", data: {"ad_pos_id": adScene.name, "ad_scene":key});

    var isShowAd = false;
    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];

      if (!loadedAdMap.containsKey(ad_id)) {
        //没有加载跳过
        continue;
      }

      var loadedItem = loadedAdMap[ad_id] ?? {};

      if (source == "admob") {
        //显示admob广告
        if (type == "open") {
          AppOpenAd? openAd = loadedItem["admob_ad"];
          //设置显示事件
          openAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdClicked: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告显示失败: $key, $type, $source, $ad_id");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key, positionKey: load_pos);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            },
            onAdShowedFullScreenContent: (ad) {
              AppLog.i("广告显示成功: $key, $type, $source, $ad_id");
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            },
          );
          //设置收益事件
          openAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
              ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
              ad_format: "open",
              ad_source: "admob",
              ad_unit_id: ad.adUnitId,
              ad_pos_id: adScene.name,
              ad_pre_ecpm: valueMicros.toString(),
              currency: currencyCode,
              ad_sence: key,
              // precision_type: precision.name,
              // positionKey: loadedItem["load_pos"],
            );
          };
          openAd?.show();
          isShowAd = true;
          break;
        } else if (type == "interstitial") {
          InterstitialAd? interstitialAd = loadedItem["admob_ad"];
          //设置显示事件
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdClicked: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告显示失败: $key, $type, $source, $ad_id");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key, positionKey: load_pos);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            },
            onAdShowedFullScreenContent: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            },
          );
          //设置收益事件
          interstitialAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
              ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
              ad_format: "interstitial",
              ad_source: "admob",
              ad_unit_id: ad.adUnitId,
              ad_pos_id: key,
              ad_pre_ecpm: valueMicros.toString(),
              currency: currencyCode,
              ad_sence: adScene.name,
              // precision_type: precision.name,
              // positionKey: loadedItem["load_pos"],
            );
          };
          interstitialAd?.show();
          isShowAd = true;
          break;
        } else if (type == "rewarded") {
          RewardedAd? rewardedAd = loadedItem["admob_ad"];
          //设置显示事件
          rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdClicked: (ad) {
              if (onShow != null) {
                onShow.onClick!(ad.adUnitId);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告显示失败: $key, $type, $source, $ad_id");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(key, positionKey: load_pos);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
            },
            onAdShowedFullScreenContent: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
            },
          );
          //设置收益事件
          rewardedAd?.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            //上报广告收益
            TbaUtils.instance.postAd(
              ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "",
              ad_format: "rewarded",
              ad_source: "admob",
              ad_unit_id: ad.adUnitId,
              ad_pos_id: adScene.name,
              ad_pre_ecpm: valueMicros.toString(),
              currency: currencyCode,
              ad_sence: key,
              // precision_type: precision.name,
              // positionKey: loadedItem["load_pos"],
            );
          };
          rewardedAd?.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              //用户看完激励广告
            },
          );
          isShowAd = true;
          break;
        } else if (type == 'native') {
          NativeAd? ad = loadedItem["admob_ad"];
          if (ad != null) {
            adIsShowing = true;
            if (key == AdPosition.open.name || key == AdPosition.behavior.name || key == AdPosition.level_h.name) {
              Get.bottomSheet(
                FullAdmobNativePage(
                  ad: ad,
                  onClose: () async {
                    adIsShowing = false;
                    setShowTime();
                    await ad.dispose();
                    loadedAdMap.remove(ad.adUnitId);
                    loadAd(key, positionKey: load_pos);
                    if (onShow != null) {
                      onShow.onClose!(ad.adUnitId);
                    }
                  },
                ),
                isScrollControlled: true,
                enableDrag: false,
                isDismissible: false,
                backgroundColor: Colors.black,
                useRootNavigator: true,
              );
            }
            isShowAd = true;
            break;
          }
        }
      } else if (source == "max") {
        //Max广告

        if (type == "open") {
          var isReady = await AppLovinMAX.isAppOpenAdReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setAppOpenAdListener(
              AppOpenAdListener(
                onAdLoadedCallback: (ad) {
                  //已经加载成功，无需回调此方法
                },
                onAdLoadFailedCallback: (adId, e) {
                  AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
                },
                onAdDisplayedCallback: (ad) {
                  adIsShowing = true;
                  if (onShow != null) {
                    onShow.onShow!(ad.adUnitId);
                  }
                },
                onAdDisplayFailedCallback: (ad, e) {
                  loadedAdMap.remove(ad.adUnitId);
                  if (onShow != null) {
                    onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
                  }
                },
                onAdClickedCallback: (ad) {
                  if (onShow != null) {
                    onShow.onClick!(ad.adUnitId);
                  }
                },
                onAdHiddenCallback: (ad) {
                  adIsShowing = false;
                  //广告关闭
                  //删除缓存
                  loadedAdMap.remove(ad.adUnitId);
                  //设置显示时间以判断广告间隔
                  setShowTime();
                  //重新加载一轮广告
                  loadAd(key, positionKey: load_pos);

                  if (onShow != null) {
                    onShow.onClose!(ad.adUnitId);
                  }
                },
                onAdRevenuePaidCallback: (ad) {
                  //收益上报
                  TbaUtils.instance.postAd(
                    ad_network: ad.networkName,
                    ad_pos_id: adScene.name,
                    ad_source: "max",
                    ad_unit_id: ad.adUnitId,
                    ad_format: "open",
                    ad_pre_ecpm: ad.revenue.toString(),
                    currency: "USD",
                    ad_sence: key,
                    // precision_type: ad.revenuePrecision,
                    // positionKey: loadedItem["load_pos"],
                  );
                },
              ),
            );

            AppLovinMAX.showAppOpenAd(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "interstitial") {
          var isReady = await AppLovinMAX.isInterstitialReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setInterstitialListener(
              InterstitialListener(
                onAdLoadedCallback: (ad) {
                  //已经加载成功，无需回调此方法
                },
                onAdLoadFailedCallback: (adId, e) {
                  AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
                },
                onAdDisplayedCallback: (ad) {
                  adIsShowing = true;
                  if (onShow != null) {
                    onShow.onShow!(ad.adUnitId);
                  }
                },
                onAdDisplayFailedCallback: (ad, e) {
                  loadedAdMap.remove(ad.adUnitId);
                  if (onShow != null) {
                    onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
                  }
                },
                onAdClickedCallback: (ad) {
                  if (onShow != null) {
                    onShow.onClick!(ad.adUnitId);
                  }
                },
                onAdHiddenCallback: (ad) {
                  adIsShowing = false;
                  //广告关闭
                  //删除缓存
                  loadedAdMap.remove(ad.adUnitId);
                  //设置显示时间以判断广告间隔
                  setShowTime();
                  //重新加载一轮广告
                  loadAd(key, positionKey: load_pos);

                  if (onShow != null) {
                    onShow.onClose!(ad.adUnitId);
                  }
                },
                onAdRevenuePaidCallback: (ad) {
                  //收益上报
                  TbaUtils.instance.postAd(
                    ad_network: ad.networkName,
                    ad_pos_id: adScene.name,
                    ad_source: "max",
                    ad_unit_id: ad.adUnitId,
                    ad_format: "interstitial",
                    ad_pre_ecpm: ad.revenue.toString(),
                    currency: "",
                    ad_sence: key,
                    // precision_type: ad.revenuePrecision,
                    // positionKey: loadedItem["load_pos"],
                  );
                },
              ),
            );

            AppLovinMAX.showInterstitial(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "rewarded") {
          var isReady = await AppLovinMAX.isRewardedAdReady(ad_id);

          if (isReady ?? false) {
            //重新设置显示监听
            AppLovinMAX.setRewardedAdListener(
              RewardedAdListener(
                onAdLoadedCallback: (ad) {
                  //已经加载成功，无需回调此方法
                },
                onAdLoadFailedCallback: (adId, e) {
                  AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
                },
                onAdDisplayedCallback: (ad) {
                  adIsShowing = true;
                  if (onShow != null) {
                    onShow.onShow!(ad.adUnitId);
                  }
                },
                onAdDisplayFailedCallback: (ad, e) {
                  loadedAdMap.remove(ad.adUnitId);
                  if (onShow != null) {
                    onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
                  }
                },
                onAdClickedCallback: (ad) {
                  if (onShow != null) {
                    onShow.onClick!(ad.adUnitId);
                  }
                },
                onAdHiddenCallback: (ad) {
                  adIsShowing = false;
                  //广告关闭
                  //删除缓存
                  loadedAdMap.remove(ad.adUnitId);
                  //设置显示时间以判断广告间隔
                  setShowTime();
                  //重新加载一轮广告
                  loadAd(key, positionKey: load_pos);

                  if (onShow != null) {
                    onShow.onClose!(ad.adUnitId);
                  }
                },
                onAdRevenuePaidCallback: (ad) {
                  // 收益上报
                  TbaUtils.instance.postAd(
                    ad_network: ad.networkName,
                    ad_pos_id: adScene.name,
                    ad_source: "max",
                    ad_unit_id: ad.adUnitId,
                    ad_format: "rewarded",
                    ad_pre_ecpm: ad.revenue.toString(),
                    currency: "USD",
                    ad_sence: key,
                    // precision_type: ad.revenuePrecision,
                    // positionKey: loadedItem["load_pos"],
                  );
                },
                onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
                  //用户看完激励视频
                },
              ),
            );

            AppLovinMAX.showRewardedAd(ad_id);
            // loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        }
      } else if (source == "topon") {
        //增加topon

        if (type == "interstitial") {
          var isReady = await ATInterstitialManager.hasInterstitialAdReady(placementID: ad_id);
          if (isReady) {
            TopOnUtils.instance.interstitialStream?.cancel();
            TopOnUtils.instance.interstitialStream = null;

            TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
              if (e.interstatus == InterstitialStatus.interstitialFailedToShow) {
                //展示失败
                AppLog.e("广告加载失败:$key, $source,  $type, $ad_id, ${e.toString()} ");
                if (onShow != null) {
                  onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
                }
              } else if (e.interstatus == InterstitialStatus.interstitialDidShowSucceed) {
                //展示
                adIsShowing = true;
                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }

                var revenueData = e.extraMap;
                // 收益上报
                TbaUtils.instance.postAd(
                  ad_network: revenueData["network_name"] ?? "",
                  ad_pos_id: adScene.name,
                  ad_source: "topon",
                  ad_unit_id: revenueData["adunit_id"] ?? "",
                  ad_format: "interstitial",
                  ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
                  currency: revenueData["currency"] ?? "USD",
                  ad_sence: key,
                  // precision_type: revenueData["precision"] ?? "",
                  // positionKey: loadedItem["load_pos"],
                );
              } else if (e.interstatus == InterstitialStatus.interstitialAdDidClose) {
                //关闭
                adIsShowing = false;
                //设置显示时间以判断广告间隔
                setShowTime();
                //重新加载一轮广告
                loadAd(key, positionKey: load_pos);
                if (onShow != null) {
                  onShow.onClose!(e.placementID);
                }

                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }
              }
            });
            ATInterstitialManager.showInterstitialAd(placementID: ad_id);
            loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        } else if (type == "rewarded") {
          var isReady = await ATRewardedManager.rewardedVideoReady(placementID: ad_id);
          if (isReady) {
            TopOnUtils.instance.rewardedStream?.cancel();
            TopOnUtils.instance.rewardedStream = null;

            TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
              if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToPlay) {
                //展示失败
                AppLog.e("广告加载失败:$key, $source,  $type, $ad_id, ${e.toString()} ");
                if (onShow != null) {
                  onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
                }
              } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidStartPlaying) {
                //展示
                adIsShowing = true;
                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }

                var revenueData = e.extraMap;
                // 收益上报
                TbaUtils.instance.postAd(
                  ad_network: revenueData["network_name"] ?? "",
                  ad_pos_id: adScene.name,
                  ad_source: "topon",
                  ad_unit_id: revenueData["adunit_id"] ?? "",
                  ad_format: "rewarded",
                  ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
                  currency: revenueData["currency"] ?? "USD",
                  ad_sence: key,
                  // precision_type: revenueData["precision"] ?? "",
                  // positionKey: loadedItem["load_pos"],
                );
              } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidClose) {
                //关闭
                adIsShowing = false;
                //设置显示时间以判断广告间隔
                setShowTime();
                //重新加载一轮广告
                loadAd(key, positionKey: load_pos);
                if (onShow != null) {
                  onShow.onClose!(e.placementID);
                }

                if (onShow != null) {
                  onShow.onShow!(e.placementID);
                }
              }
            });
            ATRewardedManager.showRewardedVideo(placementID: ad_id);
            loadedAdMap.remove(ad_id);
            isShowAd = true;
            break;
          }
        }
      }
    }

    //没有显示广告
    //重新加载
    if (!isShowAd) {
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no ad show"));
      }
      loadAd(key, positionKey: load_pos);
    }
    return isShowAd;
  }

  //load
  Future loadPageNativeAd(String key, {required String positionKey, LoadCallback? onLoad}) async {
    AppLog.i("开始加载广告:$key");
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告$key");
      return;
    }
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    bool isLoadSuc = false;
    //循环加载广告
    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];
      int ad_weight = item["adweight"];

      if (loadedAdMap.containsKey(ad_id)) {
        int timeMs = loadedAdMap[ad_id]["timeMs"] ?? 0;
        //缓存过期时间
        if (timeMs < DateTime.now().subtract(Duration(minutes: 55)).millisecondsSinceEpoch) {
          if (ad_id.startsWith("ca-app-pub")) {
            final adView = loadedAdMap[ad_id]["admob_ad"];
            if (adView is NativeAd) {
              adView.dispose();
            } else if (adView is AdWithoutView) {
              adView.dispose();
            }
          }
          loadedAdMap.remove(ad_id);
        } else {
          AppLog.i("广告缓存存在：$key， $source, $type, $ad_id");
          isLoadSuc = true;
          break;
        }
      }
      AppLog.i("广告开始加载：$key， $source, $type, $ad_id");
      String reason = "";
      Completer<bool> isCompleter = Completer();
      loadTimer?.cancel();
      loadTimer = Timer(Duration(seconds: 12), () {
        if (!isCompleter.isCompleted) {
          reason = "time out";
          AppLog.e("广告加载超时：$key， $source, $type, $ad_id");
          isCompleter.complete(false);
        }
      });

      if (source == "admob") {
        if (type == "native") {
          NativeAd nativeAd = NativeAd(
            adUnitId: ad_id,
            factoryId: "admob_page_native",
            request: const AdRequest(),
            listener: admob.NativeAdListener(
              onAdLoaded: (ad) async {
                AppLog.i("广告加载成功：$key， $source, $type, $ad_id, adweight:${item['adweight']}");
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (ad, e) {
                AppLog.e("广告加载失败：$key， $source, $type, $ad_id, adweight:$ad_weight，${e.toString()}");
                ad.dispose();
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = e.message;
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdClicked: (ad) {
                pageNativeAdClicked.refresh();
                AppLog.i("原生广告点击:${ad.adUnitId}");
              },
              onAdImpression: (ad) {
                loadedAdMap.remove(ad.adUnitId);
                AppLog.i("原生广告onAdImpression:${ad.adUnitId}");
              },
              onAdClosed: (ad) {},
              onAdWillDismissScreen: (ad) {},
              onAdOpened: (ad) {},
              onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
                TbaUtils.instance.postAd(
                  ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "admob",
                  ad_format: "native",
                  ad_source: "admob",
                  ad_unit_id: ad.adUnitId,
                  ad_pos_id: "page_native",
                  ad_pre_ecpm: valueMicros.toString(),
                  currency: currencyCode,
                  ad_sence: key,
                );
              },
            ),
            nativeTemplateStyle: null,
          );
          await nativeAd.load();
        } else {
          reason = "unSupport type loader:$type";
          if (!isCompleter.isCompleted) isCompleter.complete(false);
        }
      } else {
        reason = "unSupport source:$source";
        if (!isCompleter.isCompleted) isCompleter.complete(false);
      }
      isLoadSuc = await isCompleter.future;
      if (isLoadSuc) {
        EventUtils.instance.addEvent("ad_load_succ", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source": source, "ad_type": type});
        AppLog.i("广告瀑布流请求完成：$key ,adweight: $ad_weight, $source, $type, $ad_id");
        break;
      } else {
        AppLog.e("广告瀑布流请求失败：$key, $source, $type, adweight:$ad_weight, $ad_id, reason:$reason");
        EventUtils.instance.addEvent("ad_load_fail", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source": source, "ad_weight": ad_weight, "ad_type": type, "reason": reason});
        continue;
      }
    }
    return isLoadSuc;
  }

  NativeAd? getPageNativeAd(String key, {required AdScene adScene, ShowCallback? onShow}) {
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告：$key");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "show key error"));
      }
      return null;
    }

    //显示广告逻辑
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      return null;
    }

    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    //循环判断广告是否加载
    AppLog.i("开始显示广告:$key");

    EventUtils.instance.addEvent("ad_chance", data: {"ad_pos_id": key});

    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];

      if (!loadedAdMap.containsKey(ad_id)) {
        //没有加载跳过
        continue;
      }

      var loadedItem = loadedAdMap[ad_id] ?? {};

      if (source == "admob") {
        if (type == 'native') {
          NativeAd? ad = loadedItem["admob_ad"];
          if (ad != null) {
            return ad;
          }
        }
      }
    }

    if (onShow != null) {
      onShow.onShowFail!("", AdError(-1, "", "no ad show"));
    }
    loadPageNativeAd(key, positionKey: adScene.name);
    return null;
  }
}

class MyNativeAdView extends GetView<MyNativeAdViewController> {
  final String adKey;
  final String positionKey;
  final bool isSmall;

  @override
  String? get tag => positionKey;

  const MyNativeAdView({super.key, required this.adKey, required this.positionKey, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MyNativeAdViewController(adKey, positionKey, isSmall), tag: tag);
    return Container(alignment: Alignment.center, child: Obx(() => controller.adView.value));
  }
}

class MyNativeAdViewController extends GetxController {
  MyNativeAdViewController(this.adKey, this.positionKey, this.isSmall);

  var adKey = "";
  var positionKey = "";
  var isSmall = false;
  var adId = "";

  Rx<Widget> adView = Container().obs;

  //0未加载 1.2admob 3.4max 5.6topon
  var loadType = 0.obs;

  Ad? admobAd;

  loadAd(String key, String positionKey) async {
    AppLog.i("开始加载原生广告:$key,$positionKey");

    adView.value = Container();

    var adJson = AdUtils.instance.adJson;
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告:$key");
      // AppLog.e(adJson);
      return;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    AppLog.e("广告网络：$connectivityResult");
    if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
      return;
    }

    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      AppLog.e("广告key数据空");

      return;
    }
    //按照优先级降序排序
    configList.sort((a, b) {
      int al = a["adweight"];
      int bl = b["adweight"];
      //降序
      return bl.compareTo(al);
    });

    // AppLog.e(configList);

    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];
      AppLog.e("开始加载原生广告:$type,$source,$positionKey,$ad_id");

      var isOk = false;
      if (source == "admob") {
        if (type == "native") {
          var ad = await AdmobUtils.instance.loadNativeAd(ad_id, key, positionKey, adView);
          if (ad != null) {
            loadType.value = 1;
            isOk = true;
            admobAd = ad;
          }
        } else if (type == "banner") {
          var ad = await AdmobUtils.instance.loadBanner(ad_id, key, positionKey, adView, isSmall: isSmall);
          if (ad != null) {
            loadType.value = 2;
            isOk = true;
            admobAd = ad;
          }
        }
      } else if (source == "max") {
        if (type == "native") {
          // var ad= await AdmobUtils.instance
          //     .loadNativeAd(ad_id, key, positionKey, adView);
          var isLoadMaxAd = await MaxUtils.instance.loadNativeAd(ad_id, key, positionKey, adView);
          if (isLoadMaxAd) {
            isOk = true;
            loadType.value = 3;
          }
        } else if (type == "banner") {
          var isLoadMaxAd = await MaxUtils.instance.loadBanner(ad_id, key, positionKey, adView, isSmall: isSmall);
          if (isLoadMaxAd) {
            isOk = true;
            loadType.value = 4;
          }
        }
      } else if (source == "topon") {
        if (type == "native") {
          var isLoadOk = await TopOnUtils.instance.loadNativeAd(ad_id, key, positionKey, adView);
          if (isLoadOk) {
            isOk = true;
            loadType.value = 5;
          }
        } else if (type == "banner") {
          var isLoadOk = await TopOnUtils.instance.loadBannerAd(ad_id, key, positionKey, adView, isSmall: isSmall);
          if (isLoadOk) {
            isOk = true;
            loadType.value = 6;
          }
        }
      }

      adId = ad_id;
      AppLog.e("结束加载原生广告:${isOk ? "成功" : "失败"}---$type,$source");
      if (isOk) {
        //加载成功跳出循环
        break;
      } else {
        //加载失败加载下一条
        continue;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAd(adKey, positionKey);
  }

  @override
  void onClose() {
    super.onClose();
    admobAd?.dispose();

    if (loadType.value == 5 || loadType.value == 6) {
      //topon 删除
      TopOnUtils.instance.allCom.remove(adId);
    }
  }
}

//加载回调
typedef LoadCallback = void Function(String adId, bool isOk, AdError? e);

//显示相关回调
typedef OnShow = void Function(String adId);
typedef OnClose = void Function(String adId);
typedef OnClick = void Function(String adId);
typedef OnShowFail = void Function(String? adId, AdError? e);

//显示回调
class ShowCallback {
  final OnShow? onShow;
  final OnClose? onClose;
  final OnClick? onClick;
  final OnShowFail? onShowFail;

  const ShowCallback({this.onShow, this.onClose, this.onClick, this.onShowFail});
}
