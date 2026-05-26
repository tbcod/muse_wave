import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muse_wave/muse_config.dart';
import 'package:muse_wave/tool/bus.dart';
import 'package:muse_wave/tool/remote_utils.dart';
import 'package:muse_wave/tool/tba/event_util.dart';
import 'package:muse_wave/ui/launch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import '../../main.dart';
import '../log.dart';
import '../tba/tba_util.dart';
import 'admob_util.dart';
import 'view/full_admob_native.dart';

// enum AdSense { open_cool, open_hot, open_first, play, search, download, detail, collection, back, home, library, set }

enum AdSense {
  cold,
  hot,
  first,
  home,
  play_page,
  search_page,
  library,
  minibar,
  artist_detail_page,
  playlist_page,
  song_list,
  setting
}

enum AdFunction { play, download, liked, return_, search, detail, unknown }

enum AdPosId {
  open,
  behavior,
  level_h,
  normalbanner,
  pagebanner,
  muse_local_int,
  muse_local_reward
} //homenative, nvpage_full

enum AdFirstType { launch_first, launch_other, int_main_first, int_main_other, banner_other }

class AdUtils {
  AdUtils._internal();

  static final AdUtils _instance = AdUtils._internal();

  static AdUtils get instance {
    return _instance;
  }

  DateTime? lastShowTime;

  Map<String, dynamic> get adJson => RemoteUtil.shareInstance.adJson;

  var fullNativeAdClicked = false.obs;
  var pageNativeAdClicked = false.obs;

  static int adTimeoutSeconds = 12;

  bool isFirstBehaviorAd = true;
  bool isFirstOpenAd = true;

  //是否超过广告间隔
  Future<bool> canShow() async {
    if (lastShowTime == null) {
      return true;
    }

    var nowTime = DateTime.now();

    Duration temp = nowTime.difference(lastShowTime!);
    num wait = num.tryParse(adJson["sameinterval"].toString()) ?? 60;
    // AppLog.e("广告间隔\n${lastShowTime}\n${nowTime}\n${temp.inSeconds}---${wait}");
    if (kDebugMode) {
      wait = 15;
    }

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

  //
  //       required AdFunction adFunction,
  loadAd(AdPosId adPosId,
      {required AdSense adSense, bool forceLocalJson = false, AdFirstType? adFirstType, LoadCallback? onLoad}) async {
    String key = adPosId.name;

    adFirstType ??= adPosId == AdPosId.open ? AdFirstType.launch_other : AdFirstType.int_main_other;

    // if (!Get.isRegistered<LaunchPageController>()) {
    if (bus.isAppLaunchFinish) {
      //除启动广告优先加载高价
      if (adPosId != AdPosId.level_h && adPosId != AdPosId.muse_local_reward) {
        //同步加载高价
        loadAd(AdPosId.level_h, forceLocalJson: forceLocalJson, adSense: adSense);
      }
    }

    AppLog.i("开始加载广告位:$key, 场景：${adSense.name}，本地：$forceLocalJson, ${adFirstType.name}");
    Map adJson = this.adJson;
    if (forceLocalJson) {
      adJson = MuseConfig.adJsonAnd;
    }

    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告位：$key");
      return;
    }

    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      AppLog.e("广告位：$key 配置为空");
      return;
    }

    if (adSense == AdSense.cold || adSense == AdSense.first) {
      EventUtils.instance.addEvent(
        "open_ad_request",
        data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold"},
      );
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
        //如果已经加载了并且没有超时就跳过
        int timeMs = loadedAdMap[ad_id]["timeMs"] ?? 0;
        //缓存过期时间
        int time = adPosId == AdPosId.open ? 1300 : 55; //分钟
        if (timeMs < DateTime.now().subtract(Duration(minutes: time)).millisecondsSinceEpoch) {
          //已过期,删除广告重新加载
          //销毁广告后删除
          // admob广告先销毁再删除
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
          // //未过期，加载下一条
          // continue;
          AppLog.i("广告缓存存在：$key， $source, $type, $ad_id");
          isLoadSuc = true;
          break;
        }
      }

      AppLog.i("广告单元开始加载：$key， $source, $type, ${adSense.name}, $ad_id");
      EventUtils.instance.addEvent(
        "ad_request",
        data: {
          "ad_pos_id": adPosId.name,
          "ad_sense": adPosId == AdPosId.open ? adSense.name : "",
          "ad_format": type == "native" ? "fullnative" : type,
          "ad_source_client": source,
          "ad_code_id": ad_id
        },
      );

      DateTime startTime = DateTime.now();

      String reason = "";
      Completer<bool> isCompleter = Completer();

      Timer? loadTimer;
      loadTimer = Timer(Duration(seconds: adTimeoutSeconds), () {
        if (!isCompleter.isCompleted) {
          reason = "time out";
          AppLog.e("广告加载超时：$key， $source, $type, $ad_id");
          isCompleter.complete(false);
        }
      });

      if (source == "admob") {
        //加载admob广告
        if (type == "open") {
          // AppLog.e("admob 开始加载open");

          AppOpenAd.load(
            adUnitId: ad_id,
            request: AdRequest(),
            adLoadCallback: AppOpenAdLoadCallback(
              onAdLoaded: (ad) {
                // AppLog.e("admob 成功加载open");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  // "load_pos": positionKey,
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
                reason = "${e.code},${e.message}";
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
            ),
          );
        } else if (type == "interstitial") {
          // AppLog.e("admob 开始加载interstitial");
          InterstitialAd.load(
            adUnitId: ad_id,
            request: AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                // AppLog.e("admob 加载完成interstitial");
                if (onLoad != null) {
                  onLoad(ad.adUnitId, true, null);
                }
                AdUtils.instance.loadedAdMap[ad_id] = {
                  "data": item,
                  "admob_ad": ad,
                  // "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (e) {
                AppLog.e("广告加载失败：$key， $source, $type, $ad_id, $ad_weight,error:${e.code},${e.message}");
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = "${e.code},${e.message}";
                if (!isCompleter.isCompleted) isCompleter.complete(false);
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
                  // "load_pos": positionKey,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (e) {
                AppLog.e("admob 加载失败rewarded,${e.message}");
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = "${e.code},${e.message}";
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
                  // "ad_sense": adSense.name,
                  // "ad_function": adFunction.name,
                  "timeMs": DateTime.now().millisecondsSinceEpoch,
                  "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
                };
                if (!isCompleter.isCompleted) isCompleter.complete(true);
              },
              onAdFailedToLoad: (ad, e) {
                AppLog.e("广告加载失败：$key， $source, $type, $ad_id, adweight:$ad_weight，${e.message}");
                ad.dispose();
                if (onLoad != null) {
                  onLoad(ad_id, false, e);
                }
                reason = "${e.code},${e.message}";
                if (!isCompleter.isCompleted) isCompleter.complete(false);
              },
              onAdClicked: (ad) {
                fullNativeAdClicked.refresh();
                AppLog.i("原生广告点击:${ad.adUnitId}");
                EventUtils.instance.addEvent(
                  "ad_click",
                  data: {
                    "ad_format": "fullnative",
                    "ad_source_client": source,
                    "ad_code_id": ad_id,
                    "ad_pos_id": adPosId.name,
                    "ad_sense": AdUtils.instance.loadedAdMap[ad_id]["ad_sense"] ?? adSense.name,
                    "ad_function": AdUtils.instance.loadedAdMap[ad_id]["ad_function"] ?? AdFunction.play.name,
                  },
                );
                if (adSense == AdSense.cold || adSense == AdSense.first) {
                  EventUtils.instance.addEvent("open_ad_click",
                      data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
                }
              },
              onAdImpression: (ad) {
                adIsShowing = true;

                if (adSense == AdSense.cold || adSense == AdSense.first) {
                  EventUtils.instance.addEvent(
                    "open_ad_show",
                    data: {
                      "en_time": bus.getTimeDiffNow(bus.appLaunchTime),
                      "appearance": bus.isFirstAppLaunch ? "first" : "cold",
                      "type": type
                    },
                  );
                }
                // AppLog.i("原生广告onAdImpression:${ad.adUnitId}");
              },
              onAdClosed: (ad) {
                // EventUtils.instance.addEvent(
                //   "ad_close",
                //   data: {
                //     "ad_format": "fullnative",
                //     "ad_source_client": source,
                //     "ad_code_id": ad_id,
                //     "ad_pos_id": adPosId.name,
                //     "ad_sense": AdUtils.instance.loadedAdMap[ad_id]["ad_sense"] ?? adSense.name,
                //     "ad_function": AdUtils.instance.loadedAdMap[ad_id]["ad_function"] ?? AdFunction.play.name,
                //   },
                // );
                // if (adSense == AdSense.cold || adSense == AdSense.first) {
                //   EventUtils.instance.addEvent("open_ad_click",
                //       data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
                // }

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
                // AppLog.i("原生广告onAdOpened:${ad.adUnitId}");
                adIsShowing = true;
              },
              onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
                String sense = AdUtils.instance.loadedAdMap[ad_id]["ad_sense"] ?? adSense.name;
                String function = AdUtils.instance.loadedAdMap[ad_id]["ad_function"] ?? AdFunction.play.name;
                TbaUtils.instance.postAd(
                  ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "admob",
                  ad_format: "fullnative",
                  ad_source: "admob",
                  ad_unit_id: ad.adUnitId,
                  adSense: sense,
                  ad_pre_ecpm: valueMicros.toString(),
                  currency: currencyCode,
                  adPosName: key,
                  adFunction: function,
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
      }
      // else if (source == "max") {
      //   //加载max广告
      //   if (type == "open") {
      //     AppLovinMAX.setAppOpenAdListener(
      //       AppOpenAdListener(
      //         onAdLoadedCallback: (ad) {
      //           if (onLoad != null) {
      //             onLoad(ad.adUnitId, true, null);
      //           }
      //           AdUtils.instance.loadedAdMap[ad_id] = {
      //             "data": item,
      //             "admob_ad": ad,
      //             // "load_pos": positionKey,
      //             "timeMs": DateTime.now().millisecondsSinceEpoch,
      //             "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
      //           };
      //           if (!isCompleter.isCompleted) isCompleter.complete(true);
      //         },
      //         onAdLoadFailedCallback: (adId, e) {
      //           if (onLoad != null) {
      //             onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
      //           }
      //           reason = "${e.code},${e.message}";
      //           if (!isCompleter.isCompleted) isCompleter.complete(false);
      //         },
      //         onAdDisplayedCallback: (ad) {},
      //         onAdDisplayFailedCallback: (ad, e) {},
      //         onAdClickedCallback: (ad) {},
      //         onAdHiddenCallback: (ad) {},
      //       ),
      //     );
      //     AppLovinMAX.loadAppOpenAd(ad_id);
      //   } else if (type == "interstitial") {
      //     AppLovinMAX.setInterstitialListener(
      //       InterstitialListener(
      //         onAdLoadedCallback: (ad) {
      //           if (onLoad != null) {
      //             onLoad(ad.adUnitId, true, null);
      //           }
      //           AdUtils.instance.loadedAdMap[ad_id] = {
      //             "data": item,
      //             "admob_ad": ad,
      //             // "load_pos": positionKey,
      //             "timeMs": DateTime.now().millisecondsSinceEpoch,
      //             "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
      //           };
      //           if (!isCompleter.isCompleted) isCompleter.complete(true);
      //         },
      //         onAdLoadFailedCallback: (adId, e) {
      //           if (onLoad != null) {
      //             onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
      //           }
      //           reason = "${e.code},${e.message}";
      //           if (!isCompleter.isCompleted) isCompleter.complete(false);
      //         },
      //         onAdDisplayedCallback: (ad) {},
      //         onAdDisplayFailedCallback: (ad, e) {},
      //         onAdClickedCallback: (ad) {},
      //         onAdHiddenCallback: (ad) {},
      //       ),
      //     );
      //     AppLovinMAX.loadInterstitial(ad_id);
      //   } else if (type == "rewarded") {
      //     AppLovinMAX.setRewardedAdListener(
      //       RewardedAdListener(
      //         onAdLoadedCallback: (ad) {
      //           if (onLoad != null) {
      //             onLoad(ad.adUnitId, true, null);
      //           }
      //           AdUtils.instance.loadedAdMap[ad_id] = {
      //             "data": item,
      //             "admob_ad": ad,
      //             // "load_pos": positionKey,
      //             "timeMs": DateTime.now().millisecondsSinceEpoch,
      //             "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
      //           };
      //           if (!isCompleter.isCompleted) isCompleter.complete(true);
      //         },
      //         onAdLoadFailedCallback: (adId, e) {
      //           if (onLoad != null) {
      //             onLoad(adId, false, AdError(e.code.value, e.waterfall.toString(), e.message));
      //           }
      //           reason = "${e.code},${e.message}";
      //           if (!isCompleter.isCompleted) isCompleter.complete(false);
      //         },
      //         onAdDisplayedCallback: (ad) {},
      //         onAdDisplayFailedCallback: (ad, e) {},
      //         onAdClickedCallback: (ad) {},
      //         onAdHiddenCallback: (ad) {},
      //         onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {},
      //       ),
      //     );
      //     AppLovinMAX.loadRewardedAd(ad_id);
      //   } else {
      //     reason = "unSupport type loader:$type";
      //     if (!isCompleter.isCompleted) isCompleter.complete(false);
      //   }
      // }
      // else if (source == "topon") {
      //   if (type == "interstitial") {
      //     TopOnUtils.instance.interstitialStream?.cancel();
      //     TopOnUtils.instance.interstitialStream = null;
      //
      //     AppLog.i("加载topon插屏");
      //     TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
      //       if (e.interstatus == InterstitialStatus.interstitialAdDidFinishLoading) {
      //         //加载成功
      //         // AppLog.e("topon插屏加载成功");
      //         if (onLoad != null) {
      //           onLoad(e.placementID, true, null);
      //         }
      //         AdUtils.instance.loadedAdMap[ad_id] = {
      //           "data": item,
      //           "admob_ad": null,
      //           // "load_pos": positionKey,
      //           "timeMs": DateTime.now().millisecondsSinceEpoch,
      //           "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
      //         };
      //         if (!isCompleter.isCompleted) isCompleter.complete(true);
      //       } else if (e.interstatus == InterstitialStatus.interstitialAdFailToLoadAD) {
      //         //加载失败
      //         // AppLog.e("topon插屏加载失败:${e.requestMessage}");
      //         if (onLoad != null) {
      //           onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
      //         }
      //         reason = e.requestMessage;
      //         if (!isCompleter.isCompleted) isCompleter.complete(false);
      //       }
      //     });
      //     ATInterstitialManager.loadInterstitialAd(placementID: ad_id, extraMap: {});
      //   } else if (type == "rewarded") {
      //     TopOnUtils.instance.rewardedStream?.cancel();
      //     TopOnUtils.instance.rewardedStream = null;
      //
      //     AppLog.i("加载topon激励");
      //     TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
      //       if (e.rewardStatus == RewardedStatus.rewardedVideoDidFinishLoading) {
      //         //加载成功
      //         // AppLog.e("topon激励加载成功");
      //         if (onLoad != null) {
      //           onLoad(e.placementID, true, null);
      //         }
      //         AdUtils.instance.loadedAdMap[ad_id] = {
      //           "data": item,
      //           "admob_ad": null,
      //           // "load_pos": positionKey,
      //           "timeMs": DateTime.now().millisecondsSinceEpoch,
      //           "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2,
      //         };
      //         if (!isCompleter.isCompleted) isCompleter.complete(true);
      //       } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToLoad) {
      //         //加载失败
      //         AppLog.e("topon激励加载失败:${e.requestMessage}");
      //         if (onLoad != null) {
      //           onLoad(e.placementID, false, AdError(-101, "", e.requestMessage));
      //         }
      //         reason = e.requestMessage;
      //         if (!isCompleter.isCompleted) isCompleter.complete(false);
      //       }
      //     });
      //     ATRewardedManager.loadRewardedVideo(placementID: ad_id, extraMap: {});
      //   } else {
      //     reason = "unSupport type loader:$type";
      //     if (!isCompleter.isCompleted) isCompleter.complete(false);
      //   }
      // }
      else {
        reason = "unSupport source:$source";
        if (!isCompleter.isCompleted) isCompleter.complete(false);
      }

      loadTimer.cancel();
      loadTimer = null;
      isLoadSuc = await isCompleter.future;
      if (isLoadSuc) {
        EventUtils.instance.addEvent(
          "ad_return_sucess",
          data: {
            "ad_pos_id": adPosId.name,
            // "ad_sense": adPosId == AdPosId.open ? adSense.name : "",
            "ad_format": type == "native" ? "fullnative" : type,
            "ad_source_client": source,
            "ad_code_id": ad_id,
            "ad_request_time": DateTime.now().difference(startTime).inMilliseconds,
          },
        );
        break;
      } else {
        EventUtils.instance.addEvent(
          "ad_return_fail",
          data: {
            "ad_pos_id": adPosId.name,
            "ad_format": type == "native" ? "fullnative" : type,
            // "ad_sense": adPosId == AdPosId.open ? adSense.name : "",
            "ad_source_client": source,
            "ad_code_id": ad_id,
            "ad_request_time": DateTime.now().difference(startTime).inMilliseconds,
            "reason": reason,
          },
        );
        if (reason.contains("JavascriptEngine")) {
          await Future.delayed(Duration(seconds: 3));
        }
        continue;
      }
    }

    if (isLoadSuc) {
      AppLog.i("广告瀑布流请求结束，成功：$key");
    } else {
      AppLog.e("广告瀑布流请求结束，失败，$key");
    }

    if (adSense == AdSense.cold || adSense == AdSense.first) {
      EventUtils.instance.addEvent(
        "open_ad_request_return",
        data: {
          "en_time": bus.getTimeDiffNow(bus.appLaunchTime),
          "appearance": bus.isFirstAppLaunch ? "first" : "cold",
          "result": isLoadSuc ? "succ" : "fail",
        },
      );
    }

    return isLoadSuc;
  }

  bool adIsShowing = false;

  Future<bool> showAd(AdPosId adPosId,
      {required AdSense adSense,
      required AdFunction adFunction,
      bool forceLocalJson = false,
      ShowCallback? onShow}) async {
    if (adIsShowing) {
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "ad is showing"));
      }
      AppLog.e("广告正在展示中");
      if (adPosId == AdPosId.behavior) {
        adIsShowing = false;
      }
      return false;
    }

    String key = adPosId.name;
    Map adJson = this.adJson;
    bool isLocalJson = false;
    if (forceLocalJson) {
      adJson = MuseConfig.adJsonAnd;
      isLocalJson = true;
    }

    if (adPosId == AdPosId.behavior && bus.isBehaviorFirstShowAd) {
      adJson = MuseConfig.adJsonAnd;
      bus.setFirstShowAd();
      isLocalJson = true;
    }

    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告：$key");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "show key error"));
      }
      return false;
    }

    //显示广告逻辑
    List configList = adJson[key] ?? [];
    if (configList.isEmpty) {
      AppLog.e("没有对应广告：$key");
      return false;
    }

    if (Get.find<Application>().isAppBack == true) {
      AppLog.e("app在后台");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "app is background"));
      }
      return false;
    }

    if (adPosId == AdPosId.muse_local_reward) {
    } else {
      if (!await canShow()) {
        // AppLog.e("广告间隔未到");
        if (onShow != null) {
          onShow.onShowFail!("", AdError(-1, "", "ad interval has not expired"));
        }
        return false;
      }
    }

    //优先显示高价
    if (adPosId != AdPosId.level_h && adPosId != AdPosId.muse_local_reward) {
      var isShow = await showAd(AdPosId.level_h, adSense: adSense, adFunction: adFunction);
      // AppLog.e("高价显示：$isShow");
      if (isShow) {
        return true;
      }
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    // AppLog.e("广告网络：$connectivityResult");
    if (!connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.mobile) &&
        !connectivityResult.contains(ConnectivityResult.ethernet) &&
        !connectivityResult.contains(ConnectivityResult.vpn)) {
      //没有网络
      AppLog.e("没有网络，不显示广告");
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no network"));
      }
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
    AppLog.i("开始显示广告位:$key，场景：${adSense.name}， 共${configList.length}层， 本地json：$isLocalJson");

    // AdFirstType adFirstType = AdFirstType.int_main_other;
    // if (adPosId == AdPosId.open) {
    //   adFirstType = !bus.isAppLaunchFinish ? AdFirstType.launch_first : AdFirstType.launch_other;
    //   isFirstOpenAd = false;
    // } else if (adPosId == AdPosId.behavior) {
    //   adFirstType = isFirstBehaviorAd ? AdFirstType.int_main_first : AdFirstType.int_main_other;
    //   isFirstBehaviorAd = false;
    // }

    EventUtils.instance.addEvent("ad_chance", data: {
      "ad_pos_id": key,
      "ad_sense": adSense.name,
      "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name
    });
    var isShowAd = false;

    Completer<bool> isCompleter = Completer();
    String reason = "";

    String type = "";
    String source = "";
    String ad_id = "";

    for (var item in configList) {
      type = item["adtype"];
      source = item["adsource"];
      ad_id = item["placementid"];

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
              EventUtils.instance.addEvent(
                "ad_click",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );

              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告展示失败:$key, $source, $type, $ad_id, ${e.message} ");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
              reason = e.message;
              if (!isCompleter.isCompleted) isCompleter.complete(false);
            },
            onAdDismissedFullScreenContent: (ad) {
              EventUtils.instance.addEvent(
                "ad_close",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
              }

              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              setShowTime();

              //重新加载一轮广告
              loadAd(adPosId, adSense: (adSense == AdSense.cold || adSense == AdSense.first) ? AdSense.hot : adSense);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            },
            onAdShowedFullScreenContent: (ad) {
              AppLog.i("广告显示成功: $key, $type, $source, $ad_id");
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent(
                  "open_ad_show",
                  data: {
                    "en_time": bus.getTimeDiffNow(bus.appLaunchTime),
                    "appearance": bus.isFirstAppLaunch ? "first" : "cold",
                    "type": type
                  },
                );
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
                adSense: adSense.name,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                adPosName: key,
                adFunction: adFunction.name
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
              EventUtils.instance.addEvent(
                "ad_click",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告展示失败:$key, $source, $type, $ad_id, ${e.message} ");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
              reason = e.message;
              if (!isCompleter.isCompleted) isCompleter.complete(false);
            },
            onAdDismissedFullScreenContent: (ad) {
              EventUtils.instance.addEvent(
                "ad_close",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
              }

              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              setShowTime();
              //重新加载一轮广告
              loadAd(adPosId, adSense: (adSense == AdSense.cold || adSense == AdSense.first) ? AdSense.hot : adSense);
              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            },
            onAdShowedFullScreenContent: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent(
                  "open_ad_show",
                  data: {
                    "en_time": bus.getTimeDiffNow(bus.appLaunchTime),
                    "appearance": bus.isFirstAppLaunch ? "first" : "cold",
                    "type": type
                  },
                );
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
                adSense: adSense.name,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                adPosName: key,
                adFunction: adFunction.name
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
              EventUtils.instance.addEvent(
                "ad_click",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
              }
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              //显示失败删除缓存广告
              AppLog.e("广告展示失败:$key, $source, $type, $ad_id, ${e.message} ");
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();

              if (onShow != null) {
                onShow.onShowFail!(ad.adUnitId, e);
              }
              reason = e.message;
              if (!isCompleter.isCompleted) isCompleter.complete(false);
            },
            onAdDismissedFullScreenContent: (ad) {
              EventUtils.instance.addEvent(
                "ad_close",
                data: {
                  "ad_format": type,
                  "ad_source_client": source,
                  "ad_code_id": ad_id,
                  "ad_pos_id": adPosId.name,
                  "ad_sense": adSense.name,
                  "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                },
              );
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent("open_ad_click",
                    data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
              }

              adIsShowing = false;
              //广告关闭
              //删除缓存
              loadedAdMap.remove(ad.adUnitId);
              ad.dispose();
              //设置显示时间以判断广告间隔
              if (adPosId != AdPosId.muse_local_reward) {
                setShowTime();
              }
              //重新加载一轮广告
              loadAd(adPosId, adSense: (adSense == AdSense.cold || adSense == AdSense.first) ? AdSense.hot : adSense);

              if (onShow != null) {
                onShow.onClose!(ad.adUnitId);
              }
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            },
            onAdShowedFullScreenContent: (ad) {
              adIsShowing = true;
              if (onShow != null) {
                onShow.onShow!(ad.adUnitId);
              }
              if (adSense == AdSense.cold || adSense == AdSense.first) {
                EventUtils.instance.addEvent(
                  "open_ad_show",
                  data: {
                    "en_time": bus.getTimeDiffNow(bus.appLaunchTime),
                    "appearance": bus.isFirstAppLaunch ? "first" : "cold",
                    "type": type
                  },
                );
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
                adSense: adSense.name,
                ad_pre_ecpm: valueMicros.toString(),
                currency: currencyCode,
                adPosName: key,
                adFunction: adFunction.name
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
            if (key == AdPosId.open.name || key == AdPosId.behavior.name || key == AdPosId.level_h.name) {
              loadedAdMap[ad_id]["ad_function"] = adFunction == AdFunction.unknown ? "" : adFunction.name;
              loadedAdMap[ad_id]["ad_sense"] = adSense.name;
              await Get.bottomSheet(
                FullAdmobNativePage(
                  ad: ad,
                  onClose: () async {
                    EventUtils.instance.addEvent(
                      "ad_close",
                      data: {
                        "ad_format": "fullnative",
                        "ad_source_client": source,
                        "ad_code_id": ad_id,
                        "ad_pos_id": adPosId.name,
                        "ad_sense": adSense.name,
                        "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
                      },
                    );
                    if (adSense == AdSense.cold || adSense == AdSense.first) {
                      EventUtils.instance.addEvent("open_ad_click",
                          data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
                    }
                    adIsShowing = false;
                    setShowTime();
                    await ad.dispose();
                    loadedAdMap.remove(ad.adUnitId);
                    loadAd(adPosId,
                        adSense: (adSense == AdSense.cold || adSense == AdSense.first) ? AdSense.hot : adSense);
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
              if (!isCompleter.isCompleted) isCompleter.complete(true);
            }
            isShowAd = true;
            break;
          }
        }
      }
      // else if (source == "max") {
      //   //Max广告
      //
      //   if (type == "open") {
      //     var isReady = await AppLovinMAX.isAppOpenAdReady(ad_id);
      //
      //     if (isReady ?? false) {
      //       //重新设置显示监听
      //       AppLovinMAX.setAppOpenAdListener(
      //         AppOpenAdListener(
      //           onAdLoadedCallback: (ad) {
      //             //已经加载成功，无需回调此方法
      //           },
      //           onAdLoadFailedCallback: (adId, e) {
      //             AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
      //           },
      //           onAdDisplayedCallback: (ad) {
      //             adIsShowing = true;
      //             if (onShow != null) {
      //               onShow.onShow!(ad.adUnitId);
      //             }
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent(
      //                 "open_ad_show",
      //                 data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold", "type": type},
      //               );
      //             }
      //           },
      //           onAdDisplayFailedCallback: (ad, e) {
      //             loadedAdMap.remove(ad.adUnitId);
      //             if (onShow != null) {
      //               onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
      //             }
      //             reason = e.message;
      //             if (!isCompleter.isCompleted) isCompleter.complete(false);
      //           },
      //           onAdClickedCallback: (ad) {
      //             if (onShow != null) {
      //               onShow.onClick!(ad.adUnitId);
      //             }
      //             EventUtils.instance.addEvent(
      //               "ad_click",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
      //             }
      //           },
      //           onAdHiddenCallback: (ad) {
      //             EventUtils.instance.addEvent(
      //               "ad_close",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
      //             }
      //             adIsShowing = false;
      //             //广告关闭
      //             //删除缓存
      //             loadedAdMap.remove(ad.adUnitId);
      //             //设置显示时间以判断广告间隔
      //             setShowTime();
      //             //重新加载一轮广告
      //             loadAd(adPosId, adSense: (adSense == AdScene.open_cool || adSense == AdScene.open_first) ? AdScene.open_hot : adSense);
      //
      //             if (onShow != null) {
      //               onShow.onClose!(ad.adUnitId);
      //             }
      //             if (!isCompleter.isCompleted) isCompleter.complete(true);
      //           },
      //           onAdRevenuePaidCallback: (ad) {
      //             //收益上报
      //             TbaUtils.instance.postAd(
      //               ad_network: ad.networkName,
      //               adSense: adSense.name,
      //               ad_source: "max",
      //               ad_unit_id: ad.adUnitId,
      //               ad_format: "open",
      //               ad_pre_ecpm: ad.revenue.toString(),
      //               currency: "USD",
      //               adPosName: key,
      //               // precision_type: ad.revenuePrecision,
      //               // positionKey: loadedItem["load_pos"],
      //             );
      //           },
      //         ),
      //       );
      //
      //       AppLovinMAX.showAppOpenAd(ad_id);
      //       // loadedAdMap.remove(ad_id);
      //       isShowAd = true;
      //       break;
      //     }
      //   } else if (type == "interstitial") {
      //     var isReady = await AppLovinMAX.isInterstitialReady(ad_id);
      //
      //     if (isReady ?? false) {
      //       //重新设置显示监听
      //       AppLovinMAX.setInterstitialListener(
      //         InterstitialListener(
      //           onAdLoadedCallback: (ad) {
      //             //已经加载成功，无需回调此方法
      //           },
      //           onAdLoadFailedCallback: (adId, e) {
      //             AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
      //           },
      //           onAdDisplayedCallback: (ad) {
      //             adIsShowing = true;
      //             if (onShow != null) {
      //               onShow.onShow!(ad.adUnitId);
      //             }
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent(
      //                 "open_ad_show",
      //                 data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold", "type": type},
      //               );
      //             }
      //           },
      //           onAdDisplayFailedCallback: (ad, e) {
      //             loadedAdMap.remove(ad.adUnitId);
      //             if (onShow != null) {
      //               onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
      //             }
      //             reason = e.message;
      //             if (!isCompleter.isCompleted) isCompleter.complete(false);
      //           },
      //           onAdClickedCallback: (ad) {
      //             if (onShow != null) {
      //               onShow.onClick!(ad.adUnitId);
      //             }
      //             EventUtils.instance.addEvent(
      //               "ad_click",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
      //             }
      //           },
      //           onAdHiddenCallback: (ad) {
      //             EventUtils.instance.addEvent(
      //               "ad_close",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
      //             }
      //
      //             adIsShowing = false;
      //             //广告关闭
      //             //删除缓存
      //             loadedAdMap.remove(ad.adUnitId);
      //             //设置显示时间以判断广告间隔
      //             setShowTime();
      //             //重新加载一轮广告
      //             loadAd(adPosId, adSense: (adSense == AdScene.open_cool || adSense == AdScene.open_first) ? AdScene.open_hot : adSense);
      //
      //             if (onShow != null) {
      //               onShow.onClose!(ad.adUnitId);
      //             }
      //             if (!isCompleter.isCompleted) isCompleter.complete(true);
      //           },
      //           onAdRevenuePaidCallback: (ad) {
      //             //收益上报
      //             TbaUtils.instance.postAd(
      //               ad_network: ad.networkName,
      //               adSense: adSense.name,
      //               ad_source: "max",
      //               ad_unit_id: ad.adUnitId,
      //               ad_format: "interstitial",
      //               ad_pre_ecpm: ad.revenue.toString(),
      //               currency: "",
      //               adPosName: key,
      //               // precision_type: ad.revenuePrecision,
      //               // positionKey: loadedItem["load_pos"],
      //             );
      //           },
      //         ),
      //       );
      //
      //       AppLovinMAX.showInterstitial(ad_id);
      //       // loadedAdMap.remove(ad_id);
      //       isShowAd = true;
      //       break;
      //     }
      //   } else if (type == "rewarded") {
      //     var isReady = await AppLovinMAX.isRewardedAdReady(ad_id);
      //
      //     if (isReady ?? false) {
      //       //重新设置显示监听
      //       AppLovinMAX.setRewardedAdListener(
      //         RewardedAdListener(
      //           onAdLoadedCallback: (ad) {
      //             //已经加载成功，无需回调此方法
      //           },
      //           onAdLoadFailedCallback: (adId, e) {
      //             AppLog.e("广告加载失败:$key, $source,  $type, $adId, ${e.toString()} ");
      //           },
      //           onAdDisplayedCallback: (ad) {
      //             adIsShowing = true;
      //             if (onShow != null) {
      //               onShow.onShow!(ad.adUnitId);
      //             }
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent(
      //                 "open_ad_show",
      //                 data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold", "type": type},
      //               );
      //             }
      //           },
      //           onAdDisplayFailedCallback: (ad, e) {
      //             loadedAdMap.remove(ad.adUnitId);
      //             if (onShow != null) {
      //               onShow.onShowFail!(ad.adUnitId, AdError(e.code.value, e.waterfall.toString(), e.message));
      //             }
      //             reason = e.message;
      //             if (!isCompleter.isCompleted) isCompleter.complete(false);
      //           },
      //           onAdClickedCallback: (ad) {
      //             if (onShow != null) {
      //               onShow.onClick!(ad.adUnitId);
      //             }
      //             EventUtils.instance.addEvent(
      //               "ad_click",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
      //             }
      //           },
      //           onAdHiddenCallback: (ad) {
      //             EventUtils.instance.addEvent(
      //               "ad_close",
      //               data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //             );
      //             if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //               EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
      //             }
      //
      //             adIsShowing = false;
      //             //广告关闭
      //             //删除缓存
      //             loadedAdMap.remove(ad.adUnitId);
      //             //设置显示时间以判断广告间隔
      //             if (adPosId != AdPosId.muse_local_reward) {
      //               setShowTime();
      //             }
      //             //重新加载一轮广告
      //             loadAd(adPosId, adSense: (adSense == AdScene.open_cool || adSense == AdScene.open_first) ? AdScene.open_hot : adSense);
      //
      //             if (onShow != null) {
      //               onShow.onClose!(ad.adUnitId);
      //             }
      //             if (!isCompleter.isCompleted) isCompleter.complete(true);
      //           },
      //           onAdRevenuePaidCallback: (ad) {
      //             // 收益上报
      //             TbaUtils.instance.postAd(
      //               ad_network: ad.networkName,
      //               adSense: adSense.name,
      //               ad_source: "max",
      //               ad_unit_id: ad.adUnitId,
      //               ad_format: "rewarded",
      //               ad_pre_ecpm: ad.revenue.toString(),
      //               currency: "USD",
      //               adPosName: key,
      //               // precision_type: ad.revenuePrecision,
      //               // positionKey: loadedItem["load_pos"],
      //             );
      //           },
      //           onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
      //             //用户看完激励视频
      //           },
      //         ),
      //       );
      //
      //       AppLovinMAX.showRewardedAd(ad_id);
      //       // loadedAdMap.remove(ad_id);
      //       isShowAd = true;
      //       break;
      //     }
      //   }
      // }
      // else if (source == "topon") {
      //   //增加topon
      //   if (type == "interstitial") {
      //     var isReady = await ATInterstitialManager.hasInterstitialAdReady(placementID: ad_id);
      //     if (isReady) {
      //       TopOnUtils.instance.interstitialStream?.cancel();
      //       TopOnUtils.instance.interstitialStream = null;
      //
      //       TopOnUtils.instance.interstitialStream = ATListenerManager.interstitialEventHandler.listen((e) {
      //         if (e.interstatus == InterstitialStatus.interstitialFailedToShow) {
      //           //展示失败
      //           AppLog.e("广告展示失败:$key, $source, $type, $ad_id, ${e.requestMessage} ");
      //           if (onShow != null) {
      //             onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
      //           }
      //           reason = e.requestMessage;
      //           if (!isCompleter.isCompleted) isCompleter.complete(false);
      //         } else if (e.interstatus == InterstitialStatus.interstitialDidShowSucceed) {
      //           //展示
      //           adIsShowing = true;
      //           if (onShow != null) {
      //             onShow.onShow!(e.placementID);
      //           }
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent(
      //               "open_ad_show",
      //               data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold", "type": type},
      //             );
      //           }
      //
      //           var revenueData = e.extraMap;
      //           // 收益上报
      //           TbaUtils.instance.postAd(
      //             ad_network: revenueData["network_name"] ?? "",
      //             adSense: adSense.name,
      //             ad_source: "topon",
      //             ad_unit_id: revenueData["adunit_id"] ?? "",
      //             ad_format: "interstitial",
      //             ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
      //             currency: revenueData["currency"] ?? "USD",
      //             adPosName: key,
      //             // precision_type: revenueData["precision"] ?? "",
      //             // positionKey: loadedItem["load_pos"],
      //           );
      //         } else if (e.interstatus == InterstitialStatus.interstitialAdDidClose) {
      //           EventUtils.instance.addEvent(
      //             "ad_close",
      //             data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //           );
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
      //           }
      //           //关闭
      //           adIsShowing = false;
      //           //设置显示时间以判断广告间隔
      //           setShowTime();
      //           //重新加载一轮广告
      //           loadAd(adPosId, adSense: (adSense == AdScene.open_cool || adSense == AdScene.open_first) ? AdScene.open_hot : adSense);
      //
      //           if (onShow != null) {
      //             onShow.onClose!(e.placementID);
      //           }
      //
      //           // if (onShow != null) {
      //           //   onShow.onShow!(e.placementID);
      //           // }
      //           if (!isCompleter.isCompleted) isCompleter.complete(true);
      //         } else if (e.interstatus == InterstitialStatus.interstitialAdDidClick) {
      //           if (onShow != null) {
      //             onShow.onClick!(e.placementID);
      //           }
      //           EventUtils.instance.addEvent(
      //             "ad_click",
      //             data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //           );
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
      //           }
      //         }
      //       });
      //       ATInterstitialManager.showInterstitialAd(placementID: ad_id);
      //       loadedAdMap.remove(ad_id);
      //       isShowAd = true;
      //       break;
      //     }
      //   } else if (type == "rewarded") {
      //     var isReady = await ATRewardedManager.rewardedVideoReady(placementID: ad_id);
      //     if (isReady) {
      //       TopOnUtils.instance.rewardedStream?.cancel();
      //       TopOnUtils.instance.rewardedStream = null;
      //       TopOnUtils.instance.rewardedStream = ATListenerManager.rewardedVideoEventHandler.listen((e) {
      //         if (e.rewardStatus == RewardedStatus.rewardedVideoDidFailToPlay) {
      //           //展示失败
      //           AppLog.e("广告加载失败:$key, $source,  $type, $ad_id, ${e.toString()} ");
      //           if (onShow != null) {
      //             onShow.onShowFail!(e.placementID, AdError(-102, "", e.requestMessage));
      //           }
      //           reason = e.requestMessage;
      //           if (!isCompleter.isCompleted) isCompleter.complete(false);
      //         } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidStartPlaying) {
      //           //展示
      //           adIsShowing = true;
      //           if (onShow != null) {
      //             onShow.onShow!(e.placementID);
      //           }
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent(
      //               "open_ad_show",
      //               data: {"en_time": bus.getTimeDiffNow(bus.appLaunchTime), "appearance": bus.isFirstAppLaunch ? "first" : "cold", "type": type},
      //             );
      //           }
      //
      //           var revenueData = e.extraMap;
      //           // 收益上报
      //           TbaUtils.instance.postAd(
      //             ad_network: revenueData["network_name"] ?? "",
      //             adSense: adSense.name,
      //             ad_source: "topon",
      //             ad_unit_id: revenueData["adunit_id"] ?? "",
      //             ad_format: "rewarded",
      //             ad_pre_ecpm: "${revenueData["publisher_revenue"] ?? ""}",
      //             currency: revenueData["currency"] ?? "USD",
      //             adPosName: key,
      //             // precision_type: revenueData["precision"] ?? "",
      //             // positionKey: loadedItem["load_pos"],
      //           );
      //         } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidClose) {
      //           EventUtils.instance.addEvent(
      //             "ad_close",
      //             data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //           );
      //
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "close"});
      //           }
      //           //关闭
      //           adIsShowing = false;
      //           //设置显示时间以判断广告间隔
      //           if (adPosId != AdPosId.muse_local_reward) {
      //             setShowTime();
      //           }
      //           //重新加载一轮广告
      //           loadAd(adPosId, adSense: (adSense == AdScene.open_cool || adSense == AdScene.open_first) ? AdScene.open_hot : adSense);
      //
      //           if (onShow != null) {
      //             onShow.onClose!(e.placementID);
      //           }
      //
      //           // if (onShow != null) {
      //           //   onShow.onShow!(e.placementID);
      //           // }
      //           //
      //           if (!isCompleter.isCompleted) isCompleter.complete(true);
      //         } else if (e.rewardStatus == RewardedStatus.rewardedVideoDidClick) {
      //           if (onShow != null) {
      //             onShow.onClick!(e.placementID);
      //           }
      //           EventUtils.instance.addEvent(
      //             "ad_click",
      //             data: {"ad_format": type, "ad_source_client": source, "ad_code_id": ad_id, "ad_pos_id": adPosId.name, "ad_sense": adSense.name},
      //           );
      //           if (adSense == AdScene.open_cool || adSense == AdScene.open_first) {
      //             EventUtils.instance.addEvent("open_ad_click", data: {"appearance": bus.isFirstAppLaunch ? "first" : "cold", "kid": "ad_click"});
      //           }
      //         }
      //       });
      //       ATRewardedManager.showRewardedVideo(placementID: ad_id);
      //       loadedAdMap.remove(ad_id);
      //       isShowAd = true;
      //       break;
      //     }
      //   }
      // }
    }

    //没有显示广告
    //重新加载
    if (!isShowAd) {
      if (!isCompleter.isCompleted) isCompleter.complete(false);
      if (onShow != null) {
        onShow.onShowFail!("", AdError(-1, "", "no ad show"));
      }
      reason = "ad_nocache";
      loadAd(adPosId, adSense: (adSense == AdSense.cold || adSense == AdSense.first) ? AdSense.hot : adSense);
    }
    bool isSuc = await isCompleter.future;
    if (!isSuc) {
      AppLog.e("广告显示失败:$key, reason: $reason");
      EventUtils.instance.addEvent(
        "ad_impression_fail",
        data: {
          "ad_format": type,
          "ad_source_client": source,
          "ad_code_id": ad_id,
          "ad_pos_id": adPosId.name,
          "ad_sense": adSense.name,
          "reason": reason,
          "ad_function": adFunction == AdFunction.unknown ? "" : adFunction.name,
        },
      );
    }

    return isSuc;
  }

//   //load
//   Future loadPageNativeAd(String key, {required AdScene adSense, LoadCallback? onLoad}) async {
//     AppLog.i("开始加载广告:$key");
//     if (!adJson.containsKey(key)) {
//       AppLog.e("没有对应广告$key");
//       return;
//     }
//     List configList = adJson[key] ?? [];
//     if (configList.isEmpty) {
//       return;
//     }
//     //按照优先级降序排序
//     configList.sort((a, b) {
//       int al = a["adweight"];
//       int bl = b["adweight"];
//       //降序
//       return bl.compareTo(al);
//     });
//
//     bool isLoadSuc = false;
//     //循环加载广告
//     for (var item in configList) {
//       String type = item["adtype"];
//       String source = item["adsource"];
//       String ad_id = item["placementid"];
//       int ad_weight = item["adweight"];
//
//       if (loadedAdMap.containsKey(ad_id)) {
//         int timeMs = loadedAdMap[ad_id]["timeMs"] ?? 0;
//         //缓存过期时间
//         if (timeMs < DateTime.now().subtract(Duration(minutes: 55)).millisecondsSinceEpoch) {
//           if (ad_id.startsWith("ca-app-pub")) {
//             final adView = loadedAdMap[ad_id]["admob_ad"];
//             if (adView is NativeAd) {
//               adView.dispose();
//             } else if (adView is AdWithoutView) {
//               adView.dispose();
//             }
//           }
//           loadedAdMap.remove(ad_id);
//         } else {
//           AppLog.i("广告缓存存在：$key， $source, $type, $ad_id");
//           isLoadSuc = true;
//           break;
//         }
//       }
//       AppLog.i("广告开始加载：$key， $source, $type, $ad_id");
//       String reason = "";
//       Completer<bool> isCompleter = Completer();
//
//       Timer? loadTimer;
//       loadTimer = Timer(Duration(seconds: 12), () {
//         if (!isCompleter.isCompleted) {
//           reason = "time out";
//           AppLog.e("广告加载超时：$key， $source, $type, $ad_id");
//           isCompleter.complete(false);
//         }
//       });
//
//       if (source == "admob") {
//         if (type == "native") {
//           NativeAd nativeAd = NativeAd(
//             adUnitId: ad_id,
//             factoryId: "admob_page_native",
//             request: const AdRequest(),
//             listener: admob.NativeAdListener(
//               onAdLoaded: (ad) async {
//                 AppLog.i("广告加载成功：$key， $source, $type, $ad_id, adweight:${item['adweight']}");
//                 AdUtils.instance.loadedAdMap[ad_id] = {"data": item, "admob_ad": ad, "ad_sense": adSense.name, "timeMs": DateTime.now().millisecondsSinceEpoch, "orientation": Get.mediaQuery.orientation == Orientation.portrait ? 1 : 2};
//                 if (!isCompleter.isCompleted) isCompleter.complete(true);
//               },
//               onAdFailedToLoad: (ad, e) {
//                 AppLog.e("广告加载失败：$key， $source, $type, $ad_id, adweight:$ad_weight，${e.toString()}");
//                 ad.dispose();
//                 if (onLoad != null) {
//                   onLoad(ad_id, false, e);
//                 }
//                 reason = "${e.code},${e.message}";
//                 if (!isCompleter.isCompleted) isCompleter.complete(false);
//               },
//               onAdClicked: (ad) {
//                 pageNativeAdClicked.refresh();
//                 AppLog.i("原生广告点击:${ad.adUnitId}");
//               },
//               onAdImpression: (ad) {
//                 loadedAdMap.remove(ad.adUnitId);
//                 AppLog.i("原生广告onAdImpression:${ad.adUnitId}");
//               },
//               onAdClosed: (ad) {},
//               onAdWillDismissScreen: (ad) {},
//               onAdOpened: (ad) {},
//               onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
//                 TbaUtils.instance.postAd(
//                   ad_network: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? "admob",
//                   ad_format: "native",
//                   ad_source: "admob",
//                   ad_unit_id: ad.adUnitId,
//                   adSense: AdUtils.instance.loadedAdMap[ad.adUnitId]?["ad_sense"] ?? AdScene.play.name,
//                   ad_pre_ecpm: valueMicros.toString(),
//                   currency: currencyCode,
//                   adPosName: key,
//                 );
//               },
//             ),
//             nativeTemplateStyle: null,
//           );
//           await nativeAd.load();
//         } else {
//           reason = "unSupport type loader:$type";
//           if (!isCompleter.isCompleted) isCompleter.complete(false);
//         }
//       } else {
//         reason = "unSupport source:$source";
//         if (!isCompleter.isCompleted) isCompleter.complete(false);
//       }
//       loadTimer.cancel();
//       loadTimer = null;
//       isLoadSuc = await isCompleter.future;
//       if (isLoadSuc) {
//         EventUtils.instance.addEvent("ad_load_succ", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source_client": source, "ad_type": type});
//         AppLog.i("广告瀑布流请求完成：$key ,adweight: $ad_weight, $source, $type, $ad_id");
//         break;
//       } else {
//         AppLog.e("广告瀑布流请求失败：$key, $source, $type, adweight:$ad_weight, $ad_id, reason:$reason");
//         EventUtils.instance.addEvent("ad_load_fail", data: {"ad_pos_id": key, "ad_id": ad_id, "ad_source_client": source, "ad_weight": ad_weight, "ad_type": type, "reason": reason});
//         continue;
//       }
//     }
//     return isLoadSuc;
//   }
//
//   NativeAd? getPageNativeAd(String key, {required AdScene adSense, ShowCallback? onShow}) {
//     if (!adJson.containsKey(key)) {
//       AppLog.e("没有对应广告：$key");
//       if (onShow != null) {
//         onShow.onShowFail!("", AdError(-1, "", "show key error"));
//       }
//       return null;
//     }
//
//     //显示广告逻辑
//     List configList = adJson[key] ?? [];
//     if (configList.isEmpty) {
//       return null;
//     }
//
//     //按照优先级降序排序
//     configList.sort((a, b) {
//       int al = a["adweight"];
//       int bl = b["adweight"];
//       //降序
//       return bl.compareTo(al);
//     });
//
//     //循环判断广告是否加载
//     AppLog.i("开始显示广告:$key");
//
//     EventUtils.instance.addEvent("ad_chance", data: {"ad_pos_id": key});
//
//     for (var item in configList) {
//       String type = item["adtype"];
//       String source = item["adsource"];
//       String ad_id = item["placementid"];
//
//       if (!loadedAdMap.containsKey(ad_id)) {
//         //没有加载跳过
//         continue;
//       }
//
//       var loadedItem = loadedAdMap[ad_id] ?? {};
//
//       if (source == "admob") {
//         if (type == 'native') {
//           NativeAd? ad = loadedItem["admob_ad"];
//           if (ad != null) {
//             return ad;
//           }
//         }
//       }
//     }
//
//     if (onShow != null) {
//       onShow.onShowFail!("", AdError(-1, "", "no ad show"));
//     }
//     loadPageNativeAd(key, adSense: adSense); //positionKey: adScene.name
//     return null;
//   }
}

class BannerNativeAdView extends GetView<BannerNativeAdViewController> {
  final AdPosId posId;
  final AdSense adScene;
  final bool isSmall;

  @override
  String? get tag => "${posId.name}_${adScene.name}";

  const BannerNativeAdView({super.key, required this.posId, required this.adScene, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BannerNativeAdViewController(posId, adScene, isSmall), tag: tag);
    return Container(alignment: Alignment.center, child: Obx(() => controller.adView.value));
  }
}

class BannerNativeAdViewController extends GetxController {
  BannerNativeAdViewController(this.adPosId, this.adScene, this.isSmall);

  AdPosId adPosId;
  AdSense adScene;
  var isSmall = false;
  var adId = "";

  Rx<Widget> adView = Container().obs;

  //0未加载 1.2admob 3.4max 5.6topon
  var loadType = 0.obs;

  Ad? admobAd;

  loadAd(AdPosId adPosId, AdSense adSense) async {
    String key = adPosId.name;
    AppLog.i("开始加载广告位:$key, ${adSense.name}");

    adView.value = Container();

    var adJson = AdUtils.instance.adJson;
    if (!adJson.containsKey(key)) {
      AppLog.e("没有对应广告:$key");
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

    var isOk = false;
    for (var item in configList) {
      String type = item["adtype"];
      String source = item["adsource"];
      String ad_id = item["placementid"];
      AppLog.i("开始加载原生广告:$type, $source, ${adSense.name}, $ad_id");

      if (source == "admob") {
        if (type == "native") {
          var ad = await AdmobUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
          if (ad != null) {
            loadType.value = 1;
            isOk = true;
            admobAd = ad;
          }
        } else if (type == "banner") {
          var ad = await AdmobUtils.instance.loadBanner(ad_id, key, adSense, adView, isSmall: isSmall);
          if (ad != null) {
            loadType.value = 2;
            isOk = true;
            admobAd = ad;
          }
        }
      }
      // else if (source == "max") {
      //   if (type == "native") {
      //     var isLoadMaxAd = await MaxUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
      //     if (isLoadMaxAd) {
      //       isOk = true;
      //       loadType.value = 3;
      //     }
      //   } else if (type == "banner") {
      //     var isLoadMaxAd = await MaxUtils.instance.loadBanner(ad_id, key, adSense, adView, isSmall: isSmall);
      //     if (isLoadMaxAd) {
      //       isOk = true;
      //       loadType.value = 4;
      //     }
      //   }
      // }
      // else if (source == "topon") {
      //   if (type == "native") {
      //     var isLoadOk = await TopOnUtils.instance.loadNativeAd(ad_id, key, adSense, adView);
      //     if (isLoadOk) {
      //       isOk = true;
      //       loadType.value = 5;
      //     }
      //   } else if (type == "banner") {
      //     var isLoadOk = await TopOnUtils.instance.loadBannerAd(ad_id, key, adSense, adView, isSmall: isSmall);
      //     if (isLoadOk) {
      //       isOk = true;
      //       loadType.value = 6;
      //     }
      //   }
      // }

      adId = ad_id;
      if (isOk) {
        AppLog.i("原生广告加载完成: ${isOk ? "成功" : "失败"}---$type, $source, $ad_id");
        break;
      } else {
        AppLog.e("原生广告加载: ${isOk ? "成功" : "失败"}---$type, $source, $ad_id");
        //加载失败加载下一条
        continue;
      }
    }

    if (!isOk) {
      EventUtils.instance.addEvent(
        "ad_impression_fail",
        data: {
          "ad_format": "",
          "ad_source_client": "",
          "ad_code_id": "",
          "ad_pos_id": adPosId.name,
          "ad_sense": adSense.name,
          "reason": "ad_nocache",
          "ad_function": "",
        },
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAd(adPosId, adScene);
  }

  @override
  void onClose() {
    super.onClose();
    // AppLog.i("原生广告页面关闭：${admobAd?.adUnitId}");

    admobAd?.dispose();
    //
    // if (loadType.value == 5 || loadType.value == 6) {
    //   //topon 删除
    //   TopOnUtils.instance.allCom.remove(adId);
    // }
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
