//
//  ATFAdManger+SplashAd.m
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import "ATFAdManger+SplashAd.h"
#import "ATFConfiguration.h"


@implementation ATFAdManger (SplashAd)


- (void)splashAdFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString *placementID = call.arguments[@"placementID"];
    NSString *sceneID = call.arguments[@"sceneID"];
    NSDictionary *extraDic = call.arguments[@"extraDic"];
    NSString *showCustomExt = call.arguments[@"showCustomExt"];
    ATFLog(@"Rewarded video ad slot:%@",placementID);
    
    // 加载开屏
    if ([LoadSplashAd isEqualToString:call.method]) {
        [self.splashAdManger loadSplashAd:placementID extraDic:extraDic];
    }
    // 是否有广告缓存
    else if ([SplashAdReadyReady isEqualToString:call.method]) {
       BOOL isReady = [self.splashAdManger splashAdReady:placementID];
        result(@(isReady));
    }
    // 检查开屏状态
    else if ([CheckSplashAdLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.splashAdManger checkSplashAdLoadStatus:placementID];
        result(dic);
    }
    // 展示开屏
    else if ([ShowSplashAd isEqualToString:call.method]) {
         [self.splashAdManger showSplashAd:placementID];
    }
    // 展示场景开屏
    else if ([ShowSceneSplashAd isEqualToString:call.method]) {
        
        if (sceneID == nil || sceneID.length == 0) {
            [self.splashAdManger showSplashAd:placementID];
        }else{
            [self.splashAdManger showSplashAd:placementID sceneID:sceneID];
        }
    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetSplashAdValidAds isEqualToString:call.method]) {
        NSString *str = [self.splashAdManger getSplashAdValidAds:placementID];
        result(str);
    }
    // 展示广告带Config
    else if ([ShowSplashAdWithShowConfig isEqualToString:call.method]) {
        [self.splashAdManger showSplashAdWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
    }
    else if ([EntrySplashScenario isEqualToString:call.method]) {
        [self.splashAdManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
    }
}

@end
