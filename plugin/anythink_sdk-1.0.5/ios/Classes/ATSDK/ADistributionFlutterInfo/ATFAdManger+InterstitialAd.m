//
//  ATFAdManger+InterstitialAd.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import "ATFAdManger+InterstitialAd.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"

@implementation ATFAdManger (InterstitialAd)

- (void)interstitialAdFlutterInformation:(FlutterMethodCall *)call result:(FlutterResult)result{

    NSString *placementID = call.arguments[@"placementID"];
    NSDictionary *extraDic = call.arguments[@"extraDic"];
    NSString *sceneID = call.arguments[@"sceneID"];
    NSString *showCustomExt = call.arguments[@"showCustomExt"];
    NSString *placementIDs = call.arguments[@"placementIDMulti"];
    
    ATFLog(@"Interstitial ad slot:%@",placementID);

    // 加载插屏广告
    if ([LoadInterstitialAd isEqualToString:call.method]) {
        
        [self.interstitialManger loadInterstitialAd:placementID extraDic:extraDic];
    }
    // 插屏广告是否准备好
    else if ([HasInterstitialAdReady isEqualToString:call.method]) {
        BOOL isReady =   [self.interstitialManger hasInterstitialAdReady:placementID];
        result(@(isReady));

    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetInterstitialValidAds isEqualToString:call.method]) {
        NSString *str = [self.interstitialManger getInterstitialValidAds:placementID];
        result(str);
        
    }
    
    // 获取广告位的状态
    else if ([CheckInterstitialLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.interstitialManger checkInterstitialLoadStatus:placementID];
        result(dic);
    }
    
    // 展示插屏广告
    else if ([ShowInterstitialAd isEqualToString:call.method]) {
        [self.interstitialManger showInterstitialAd:placementID];
    }
    
    // 展示场景插屏广告
    else if ([ShowSceneInterstitialAd isEqualToString:call.method]) {
        if (kATFStringIsEmpty(sceneID)) {
            [self.interstitialManger showInterstitialAd:placementID];
        }else{
            [self.interstitialManger showInterstitialAd:placementID sceneID:sceneID];
        }
    }

    // 展示插屏广告带Config
    else if ([ShowInterstitialAdWithShowConfig isEqualToString:call.method]) {
        [self.interstitialManger showInterstitialAdWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
    }

    //场景到达统计
    else if ([EntryInterstitialScenario isEqualToString:call.method]) {
        [self.interstitialManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
    }

    //全自动加载相关
    else if ([AutoLoadInterstitialAD isEqualToString:call.method]) {
        [self.interstitialManger autoLoadInterstitialAD:placementIDs];
    }
    else if ([CancelAutoLoadInterstitialAD isEqualToString:call.method]) {
        [self.interstitialManger cancelAutoLoadInterstitialAD:placementIDs];
    }
    else if ([ShowAutoLoadInterstitialADWithPlacementID isEqualToString:call.method]) {
        [self.interstitialManger showAutoLoadInterstitialADWithPlacementID:placementID sceneID:sceneID];
    }
    else if ([AutoLoadInterstitialADSetLocalExtra isEqualToString:call.method]) {
        [self.interstitialManger autoLoadInterstitialADSetLocalExtra:placementIDs extraDic:extraDic];
    }
}

@end
