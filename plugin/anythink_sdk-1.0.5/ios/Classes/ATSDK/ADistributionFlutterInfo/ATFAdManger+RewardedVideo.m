//
//  ATFAdManger+RewardedVideo.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFAdManger+RewardedVideo.h"
#import "ATFConfiguration.h"


@implementation ATFAdManger (RewardedVideo)

- (void)rewardedVideoFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    NSString *placementID = call.arguments[@"placementID"];
    NSString *sceneID = call.arguments[@"sceneID"];
    NSString *showCustomExt = call.arguments[@"showCustomExt"];
    NSString *placementIDs = call.arguments[@"placementIDMulti"];
    
    NSDictionary *extraDic = call.arguments[@"extraDic"];
    ATFLog(@"Rewarded video ad slot:%@",placementID);

    // 加载视频
    if ([LoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger loadRewardedVideo:placementID extraDic:extraDic];
    }
    // 是否有广告缓存
    else if ([RewardedVideoReady isEqualToString:call.method]) {
       BOOL isReady = [self.rewardedVideoManger rewardedVideoReady:placementID];
        result(@(isReady));
    }
    // 检查视频状态
    else if ([CheckRewardedVideoLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.rewardedVideoManger checkRewardedVideoLoadStatus:placementID];
        result(dic);
    }
    // 展示激励视频
    else if ([ShowRewardedVideo isEqualToString:call.method]) {
         [self.rewardedVideoManger showRewardedVideo:placementID];
    }
    // 展示场景激励视频
    else if ([ShowSceneRewardedVideo isEqualToString:call.method]) {
        
        if (sceneID == nil || sceneID.length == 0) {
            [self.rewardedVideoManger showRewardedVideo:placementID];
        }else{
            [self.rewardedVideoManger showRewardedVideo:placementID sceneID:sceneID];
        }

    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetRewardedVideoValidAds isEqualToString:call.method]) {
        NSString *str = [self.rewardedVideoManger getRewardedVideoValidAds:placementID];
        result(str);
    }
    // 展示广告带Config
    else if ([ShowRewardedVideoWithShowConfig isEqualToString:call.method]) {
        [self.rewardedVideoManger showRewardedVideoWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
    }
    //场景统计
    else if ([EntryRewardedVideoScenario isEqualToString:call.method]) {
        [self.rewardedVideoManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
    }
    //全自动加载相关
    else if ([AutoLoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger autoLoadRewardedVideo:placementIDs];
    }
    else if ([CancelAutoLoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger cancelAutoLoadRewardedVideo:placementIDs];
    }
    else if ([ShowAutoLoadRewardedVideoAD isEqualToString:call.method]) {
        [self.rewardedVideoManger showAutoLoadRewardedVideoAD:placementID sceneID:sceneID];
    }
    else if ([AutoLoadRewardedVideoSetLocalExtra isEqualToString:call.method]) {
        [self.rewardedVideoManger autoLoadRewardedVideoSetLocalExtra:placementIDs extraDic:extraDic];
    }
}

@end
