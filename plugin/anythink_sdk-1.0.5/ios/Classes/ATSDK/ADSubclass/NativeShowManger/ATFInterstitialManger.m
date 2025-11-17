//
//  ATFInterstitialManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import "ATFInterstitialManger.h"
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import "ATFCommonTool.h"
#import "ATFInterstitialDelegate.h"
#import "ATFConfiguration.h"

#define UseRewardedVideoAsInterstitialKey @"UseRewardedVideoAsInterstitialKey"
#define ATFInterstitialExtraAdSizeKey @"size"

@interface ATFInterstitialManger()

@property(nonatomic, strong) ATFInterstitialDelegate *interstitialDelegate;
 
@end

@implementation ATFInterstitialManger

#pragma mark - public
/// 加载插屏广告
- (void)loadInterstitialAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];

    // 激励视频当做插屏使用（调用Sigmob的激励视频API）
    if ([extraDic.allKeys containsObject:UseRewardedVideoAsInterstitialKey]) {
        [dic removeObjectForKey:UseRewardedVideoAsInterstitialKey];
        dic[kATInterstitialExtraUsesRewardedVideo] = extraDic[UseRewardedVideoAsInterstitialKey];
    }
    
    // 可通过以下代码设置穿山甲平台的插屏图片广告的尺寸
    if ([extraDic.allKeys containsObject:ATFInterstitialExtraAdSizeKey]) {
        
        [dic removeObjectForKey:ATFInterstitialExtraAdSizeKey];

        NSDictionary *tempDic = extraDic[ATFInterstitialExtraAdSizeKey];

        NSNumber *widthNumeber = tempDic[@"width"];
        NSNumber *heightNumeber = tempDic[@"height"];

        CGSize tempSize = CGSizeMake([widthNumeber doubleValue], [heightNumeber doubleValue]);

        dic[kATInterstitialExtraAdSizeKey] = [NSValue valueWithCGSize:tempSize];
    }
    
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.interstitialDelegate];
}

/// 插屏广告是否准备好
- (BOOL)hasInterstitialAdReady:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATAdManager sharedManager] interstitialReadyForPlacementID:placementID];
    return  isReady;
}

/// 获取当前广告位下所有可用广告的信息
- (NSString *)getInterstitialValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATAdManager sharedManager] getInterstitialValidAdsForPlacementID:placementID];

    NSString *str = [ATFCommonTool toReadableJSONString:array];

    return str;
}

/// 获取广告位的状态
- (NSDictionary *)checkInterstitialLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkInterstitialLoadStatusForPlacementID:placementID];

    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}
/// 展示插屏广告
- (void)showInterstitialAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate];
}

/// 展示场景插屏广告
- (void)showInterstitialAd:(NSString *)placementID sceneID:(NSString *)sceneID{
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate];
}

///  展示场景插屏广告通过config
- (void)showInterstitialAdWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:placementID];
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
     
    ATShowConfig * showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
    
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID showConfig:showConfig inViewController:[ATFCommonTool getRootViewController] delegate:self.interstitialDelegate nativeMixViewBlock:^(ATSelfRenderingMixInterstitialView * _Nonnull selfRenderingMixInterstitialView) {
        
    }]; 
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    ATFLog(@"entryInterScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);
    
    [[ATAdManager sharedManager] entryInterstitialScenarioWithPlacementID:placementID scene:sceneID];
}

/// 设置全自动加载
- (void)autoLoadInterstitialAD:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [ATInterstitialAutoAdManager sharedInstance].delegate = self.interstitialDelegate;

    [[ATInterstitialAutoAdManager sharedInstance] addAutoLoadAdPlacementIDArray:[placementID componentsSeparatedByString:@","]];
}

/// 取消全自动加载插屏
- (void)cancelAutoLoadInterstitialAD:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATInterstitialAutoAdManager sharedInstance] removeAutoLoadAdPlacementIDArray:[placementID componentsSeparatedByString:@","]];
}

/// 展示全自动加载插屏
- (void)showAutoLoadInterstitialADWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:placementID];
    
    [[ATInterstitialAutoAdManager sharedInstance] showAutoLoadInterstitialWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate];
}

/// 设置自动加载插屏广告回传参数，没传入extra内容可以用于清空
- (void)autoLoadInterstitialADSetLocalExtra:(NSString *)placementID extraDic:(NSDictionary *)extraDic {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
  
    // 激励视频当做插屏使用（调用Sigmob的激励视频API）
    if ([extraDic.allKeys containsObject:UseRewardedVideoAsInterstitialKey]) {
        [dic removeObjectForKey:UseRewardedVideoAsInterstitialKey];
        dic[kATInterstitialExtraUsesRewardedVideo] = extraDic[UseRewardedVideoAsInterstitialKey];
    }
    
    // 可通过以下代码设置穿山甲平台的插屏图片广告的尺寸
    if ([extraDic.allKeys containsObject:ATFInterstitialExtraAdSizeKey]) {
        
        [dic removeObjectForKey:ATFInterstitialExtraAdSizeKey];

        NSDictionary *tempDic = extraDic[ATFInterstitialExtraAdSizeKey];

        NSNumber *widthNumeber = tempDic[@"width"];
        NSNumber *heightNumeber = tempDic[@"height"];

        CGSize tempSize = CGSizeMake([widthNumeber doubleValue], [heightNumeber doubleValue]);

        dic[kATInterstitialExtraAdSizeKey] = [NSValue valueWithCGSize:tempSize];
    }
    
    [[ATInterstitialAutoAdManager sharedInstance] setLocalExtra:dic placementID:placementID];
}

#pragma mark - lazy
- (ATFInterstitialDelegate *)interstitialDelegate {

    if (_interstitialDelegate) return _interstitialDelegate;

    ATFInterstitialDelegate *interstitialDelegate = [ATFInterstitialDelegate new];

    return _interstitialDelegate = interstitialDelegate;
}

@end
