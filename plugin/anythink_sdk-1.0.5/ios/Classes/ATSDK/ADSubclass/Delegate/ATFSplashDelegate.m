//
//  ATFSplashDelegate.m
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import "ATFSplashDelegate.h"
#import "ATFCommonTool.h"
#import "ATFSendSignalManger.h"
#import "ATFConfiguration.h"
#import "ATFDisposeDataTool.h"

#define SplashAdCallName  @"SplashCall"

//#define SplashAdDidFinishLoading  @"splashDidFinishLoading"

#define SplashAdDidFinishLoadingTimeout  @"splashDidFinishLoading"
#define SplashAdDidTimeout  @"splashDidTimeout"
#define SplashAdDidFailToLoad  @"splashDidFailToLoad"
#define SplashAdDidShowSucceed  @"splashDidShowSuccess"
#define SplashAdDidShowFail  @"splashDidShowFailed"
#define SplashAdDidClick  @"splashDidClick"
#define SplashAdDidClose  @"splashDidClose"
#define SplashAdWillClose  @"splashWillClose"

//#define SplashAdZoomOutViewDidClick  @"SplashAdZoomOutViewDidClick"

//#define SplashAdZoomOutViewDidClose  @"splashAdZoomOutViewDidClose"

#define SplashAdDetailsDidClose  @"splashAdDetailsDidClose"
#define SplashAdDidDeepLink  @"splashDidDeepLink"
//#define SplashAdDidCountdown  @"splashAdDidCountdown"


@implementation ATFSplashDelegate

#pragma mark - 广告源打印
- (void)didStartLoadingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary*)extra {
    ATFLog(@"ADSource--AD--Start--ATFSplashDelegate::didStartLoadingADSourceWithPlacementID:%@---extra:%@", placementID,extra);
}

- (void)didFinishLoadingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary*)extra {
    ATFLog(@"ADSource--AD--Finish--ATFSplashDelegate::didFinishLoadingADSourceWithPlacementID:%@---extra:%@", placementID,extra);
}

- (void)didFailToLoadADSourceWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra error:(NSError*)error {
    ATFLog(@"ADSource--AD--Fail--ATFSplashDelegate::didFailToLoadADSourceWithPlacementID:%@---error:%@", placementID,error);
}

#pragma mark - 广告源 级别回调 - 竞价
- (void)didStartBiddingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary*)extra {
    ATFLog(@"ADSource--bid--Start--ATFSplashDelegate::didStartBiddingADSourceWithPlacementID:%@---extra:%@", placementID,extra);
}

- (void)didFinishBiddingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary*)extra {
    ATFLog(@"ADSource--bid--Finish--ATFSplashDelegate::didFinishBiddingADSourceWithPlacementID:%@--extra:%@", placementID,extra);
}

- (void)didFailBiddingADSourceWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra error:(NSError*)error {
    ATFLog(@"ADSource--bid--Fail--ATFSplashDelegate::didFailBiddingADSourceWithPlacementID:%@--extra:%@--error:%@", placementID, extra, error);
}

#pragma mark - ATFSplashDelegate
// 开屏广告加载成功
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    
//    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidFinishLoading placementID:placementID extraDic:nil];
//
//    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
//    ATFLog(@"SplashAd ad loaded successfully");
}

// 广告加载失败
- (void)didFailToLoadADWithPlacementID:(NSString*)placementID
                                 error:(NSError*)error {
    NSMutableDictionary *dic = [ATFDisposeDataTool revampFailCallDic:SplashAdDidFailToLoad placementID:placementID extraDic:nil error:error];
    
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd failed to load%@",error);
}


// 加载成功
- (void)didFinishLoadingSplashADWithPlacementID:(NSString *)placementID
                                      isTimeout:(BOOL)isTimeout {
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidFinishLoadingTimeout placementID:placementID extraDic:nil];
    [dic setValue:@(isTimeout) forKey:@"isTimeout"];
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad loaded successfully-%@",placementID);
}


// 加载超时
- (void)didTimeoutLoadingSplashADWithPlacementID:(NSString *)placementID {
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampTimeoutCallDic:SplashAdDidTimeout placementID:placementID extraDic:nil];
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad loaded Timeout");
}

// 广告展示成功
- (void)splashDidShowForPlacementID:(NSString *)placementID
                              extra:(NSDictionary *)extra {
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidShowSucceed placementID:placementID extraDic:extra];
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad  Show-%@",placementID);
}

// 广告点击
- (void)splashDidClickForPlacementID:(NSString *)placementID
                               extra:(NSDictionary *)extra {
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidClick placementID:placementID extraDic:extra];
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad  Click-%@",placementID);
}

/// Splash ad will closed
- (void)splashWillCloseForPlacementID:(NSString *)placementID
                                extra:(NSDictionary *)extra {
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdWillClose placementID:placementID extraDic:extra];
    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad  Click-%@",placementID);
}

// 广告关闭
- (void)splashDidCloseForPlacementID:(NSString *)placementID
                               extra:(NSDictionary *)extra {
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidClose placementID:placementID extraDic:extra];
    [SendEventManger sendMethod:SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad  Close-%@",placementID);
}

// 展示失败
- (void)splashDidShowFailedForPlacementID:(NSString *)placementID
                                    error:(NSError *)error
                                    extra:(NSDictionary *)extra {

    if (placementID == nil || placementID.length == 0) {
        placementID = @"";
    }

    NSMutableDictionary *dic = [ATFDisposeDataTool revampFailCallDic:SplashAdDidShowFail placementID:placementID extraDic:extra error:error];
    [SendEventManger sendMethod:SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad  Close");
}


// DeepLinK
- (void)splashDeepLinkOrJumpForPlacementID:(NSString *)placementID
                                     extra:(NSDictionary *)extra
                                    result:(BOOL)success {
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidDeepLink placementID:placementID extraDic:extra];
    [SendEventManger sendMethod:SplashAdCallName arguments:dic result:nil];
    ATFLog(@"SplashAd ad splashDeepLinkOrJump");
}

// 详情页关闭
- (void)splashDetailDidClosedForPlacementID:(NSString *)placementID
                                      extra:(NSDictionary *)extra {
    
//    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDetailsDidClose placementID:placementID extraDic:extra];
//    [SendEventManger sendMethod:SplashAdCallName arguments:dic result:nil];
//    ATFLog(@"SplashAd ad Detail Close");
}

// 开屏点睛点击
- (void)splashZoomOutViewDidClickForPlacementID:(NSString *)placementID
                                          extra:(NSDictionary *)extra {

//    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdZoomOutViewDidClick placementID:placementID extraDic:extra];
//    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
//    ATFLog(@"SplashAd ad  ZoomOutView Click");
}

// 开屏点睛关闭
- (void)splashZoomOutViewDidCloseForPlacementID:(NSString *)placementID
                                          extra:(NSDictionary *)extra {
//    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdZoomOutViewDidClose placementID:placementID extraDic:extra];
//    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
//    ATFLog(@"SplashAd ad  ZoomOutView Close");
}

// 开屏倒计时
- (void)splashCountdownTime:(NSInteger)countdown
             forPlacementID:(NSString *)placementID
                      extra:(NSDictionary *)extra {
    
//    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:SplashAdDidCountdown placementID:placementID extraDic:extra];
//    [dic setValue:@(countdown) forKey:@"countdown"];
//    [SendEventManger sendMethod: SplashAdCallName arguments:dic result:nil];
//    ATFLog(@"SplashAd ad splashCountdownTime");
//
}

@end
