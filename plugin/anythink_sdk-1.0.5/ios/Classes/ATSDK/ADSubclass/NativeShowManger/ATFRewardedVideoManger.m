//
//  ATFRewardedVideoManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFRewardedVideoManger.h"
//#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import "ATFCommonTool.h"
#import "ATFRewardedVideoDelegate.h"
#import "ATFConfiguration.h"

#define kATAdLoadingExtraUserData  @"kATAdLoadingExtraMediaExtraKey"
#define kATAdLoadingExtraUserDataKeywordKey  @"kATAdLoadingExtraUserDataKeywordKey"
#define kATAdLoadingExtraUserID  @"kATAdLoadingExtraUserIDKey"

@interface ATFRewardedVideoManger()

@property(nonatomic, strong) ATFRewardedVideoDelegate *rewardedVideoDelegate;



@end


@implementation ATFRewardedVideoManger

#pragma mark - public
/// 加载激励视频
- (void)loadRewardedVideo:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];

    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserDataKeywordKey]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserDataKeywordKey];
        dic[kATAdLoadingExtraMediaExtraKey] = extraDic[kATAdLoadingExtraUserDataKeywordKey];
    }
    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserID]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserID];
        dic[kATAdLoadingExtraUserIDKey] = extraDic[kATAdLoadingExtraUserID];
    }
    
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.rewardedVideoDelegate];
}


/// 展示激励视频广告
- (void)showRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

///  展示场景激励视频广告
- (void)showRewardedVideo:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

///  展示激励视频广告通过config
- (void)showRewardedVideoWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
     
    ATShowConfig * showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
    
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID config:showConfig inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}


/// 是否有广告缓存
- (BOOL)rewardedVideoReady:(NSString *)placementID{
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATAdManager sharedManager] rewardedVideoReadyForPlacementID:placementID];
    return  isReady;
}

/// 检查广告状态
- (NSDictionary *)checkRewardedVideoLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkRewardedVideoLoadStatusForPlacementID:placementID];

    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}

///  获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
- (NSString *)getRewardedVideoValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATAdManager sharedManager] getRewardedVideoValidAdsForPlacementID:placementID];
    
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    
    return str;
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entryRewardedVideoScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);

    [[ATAdManager sharedManager] entryRewardedVideoScenarioWithPlacementID:placementID scene:sceneID];
}
 
/// 设置全自动加载激励视频广告
- (void)autoLoadRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [ATRewardedVideoAutoAdManager sharedInstance].delegate = self.rewardedVideoDelegate;
    [[ATRewardedVideoAutoAdManager sharedInstance] addAutoLoadAdPlacementIDArray:[placementID componentsSeparatedByString:@","]];
}

/// 取消全自动加载激励视频广告
- (void)cancelAutoLoadRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATRewardedVideoAutoAdManager sharedInstance] removeAutoLoadAdPlacementIDArray:[placementID componentsSeparatedByString:@","]];
}

/// 展示全自动加载激励视频广告
- (void)showAutoLoadRewardedVideoAD:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    [[ATRewardedVideoAutoAdManager sharedInstance] showAutoLoadRewardedVideoWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

/// 设置自动加载激励视频广告回传参数，没传入extra内容可以用于清空
- (void)autoLoadRewardedVideoSetLocalExtra:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];

    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserDataKeywordKey]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserDataKeywordKey];
        dic[kATAdLoadingExtraMediaExtraKey] = extraDic[kATAdLoadingExtraUserDataKeywordKey];
    }
    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserID]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserID];
        dic[kATAdLoadingExtraUserIDKey] = extraDic[kATAdLoadingExtraUserID];
    }
     
    [[ATRewardedVideoAutoAdManager sharedInstance] setLocalExtra:dic placementID:placementID];
}
 
#pragma mark - lazy
- (ATFRewardedVideoDelegate *)rewardedVideoDelegate {

    if (_rewardedVideoDelegate) return _rewardedVideoDelegate;

    ATFRewardedVideoDelegate *rewardedVideoDelegate = [ATFRewardedVideoDelegate new];

    return _rewardedVideoDelegate = rewardedVideoDelegate;
}

@end



