//
//  ATFBannerManger.h
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/29.
//

#import <Foundation/Foundation.h>

@class ATBannerView;
 
@interface ATFBannerManger : NSObject

#pragma mark - flutter api
/// 加载横幅广告
- (void)loadBannerWith:(NSString *)placementID extraDic:(NSDictionary *)extraDic;

/// 用位置和宽高属性来展示横幅广告
- (void)showBannerInRectangle:(NSString *)placementID extraDic:(NSDictionary *) extraDic;

/// 用预定义的位置来展示横幅广告
- (void)showAdInPosition:(NSString *)placementID position:(NSString *) positionStr;

/// 用位置和宽高属性来展示横幅场景广告
- (void)showBannerInRectangle:(NSString *)placementID sceneID:(NSString *)sceneID extraDic:(NSDictionary *) extraDic;

/// 用预定义的位置来展示横幅场景广告
- (void)showAdInPosition:(NSString *)placementID sceneID:(NSString *)sceneID position:(NSString *)positionStr showCustomExt:(NSString *)showCustomExt;

/// 移除横幅广告
- (void)removeBannerAd:(NSString *)placementID;

/// 隐藏横幅广告
- (void)hideBannerAd:(NSString *)placementID;

/// 重新展示横幅广告
- (void)afreshShowBannerAd:(NSString *)placementID;

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID;

@end
