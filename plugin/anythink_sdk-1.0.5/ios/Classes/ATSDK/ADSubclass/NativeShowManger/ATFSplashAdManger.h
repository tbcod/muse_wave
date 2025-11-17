//
//  ATFSplashAdManger.h
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFSplashAdManger : NSObject

/// 加载开屏
- (void)loadSplashAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic;

/// 是否有广告缓存
- (BOOL)splashAdReady:(NSString *)placementID;

/// 检查广告状态
- (NSDictionary *)checkSplashAdLoadStatus:(NSString *)placementID;

/// 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
- (NSString *)getSplashAdValidAds:(NSString *)placementID;

/// 展示开屏广告
- (void)showSplashAd:(NSString *)placementID;

///  展示场景开屏广告
- (void)showSplashAd:(NSString *)placementID sceneID:(NSString *)sceneID;

///  展示开屏广告通过config
- (void)showSplashAdWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt;

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID;

@end

NS_ASSUME_NONNULL_END
