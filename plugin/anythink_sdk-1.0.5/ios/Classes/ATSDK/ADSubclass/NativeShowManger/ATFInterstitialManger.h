//
//  ATFInterstitialManger.h
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFInterstitialManger : NSObject
/// 加载插屏广告
- (void)loadInterstitialAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic;

/// 插屏广告是否准备好
- (BOOL)hasInterstitialAdReady:(NSString *)placementID;

/// 获取当前广告位下所有可用广告的信息 v5.7.53及以上版本支持
- (NSString *)getInterstitialValidAds:(NSString *)placementID;

/// 获取广告位的状态
- (NSDictionary *)checkInterstitialLoadStatus:(NSString *)placementID;

/// 展示插屏广告
- (void)showInterstitialAd:(NSString *)placementID;

/// 展示场景插屏广告
- (void)showInterstitialAd:(NSString *)placementID sceneID:(NSString *)sceneID;

///  展示场景插屏广告通过config
- (void)showInterstitialAdWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt;

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID;

/// 设置全自动加载
- (void)autoLoadInterstitialAD:(NSString *)placementID;

/// 取消全自动加载插屏
- (void)cancelAutoLoadInterstitialAD:(NSString *)placementID;

/// 展示全自动加载插屏
- (void)showAutoLoadInterstitialADWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID;

/// 设置自动加载插屏广告回传参数，没传入extra内容可以用于清空
- (void)autoLoadInterstitialADSetLocalExtra:(NSString *)placementID extraDic:(NSDictionary *)extraDic;

@end

NS_ASSUME_NONNULL_END
