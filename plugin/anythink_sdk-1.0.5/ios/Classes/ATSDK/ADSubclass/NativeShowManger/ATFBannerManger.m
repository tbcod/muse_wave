//
//  ATFBannerManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/29.
//

#import "ATFBannerManger.h"
#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"
#import "ATFBannerDelegate.h"
#import "ATFBannerTool.h"

// 针对Admob平台，支持Admob banner广告自适应
//#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString *kATBannerAdLoadingExtraInlineAdaptiveWidthKey = @"adaptive_width";
static NSString *kATBannerAdLoadingExtraInlineAdaptiveOrientationKey = @"adaptive_orientation";

@interface ATFBannerManger()

@property (nonatomic,strong) NSMutableDictionary *rectDic;

@property (nonatomic,strong) NSMutableDictionary *bannerViewDic;


@property(nonatomic, strong) ATFBannerDelegate *bannerDelegate;



@end

@implementation ATFBannerManger

#pragma mark - publice
/// 加载横幅广告
- (void)loadBannerWith:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    CGRect rect = [ATFBannerTool getSizeFromExtraDic:extraDic];
    
    self.rectDic[placementID] = NSStringFromCGRect(rect);
    
    NSValue *adSize = [NSValue valueWithCGSize:CGSizeMake(rect.size.width,  rect.size.height)];
    
    if (extraDic[kATBannerAdLoadingExtraInlineAdaptiveWidthKey] != nil && extraDic[kATBannerAdLoadingExtraInlineAdaptiveOrientationKey] != nil) {

        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:@{

            kATAdLoadingExtraBannerAdSizeKey:adSize,
            
            kATAdLoadingExtraAdmobBannerSizeKey:adSize,
            kATAdLoadingExtraAdmobAdSizeFlagsKey:@(YES)

        } delegate:self.bannerDelegate];
        
    } else {
        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:@{kATAdLoadingExtraBannerAdSizeKey:adSize} delegate:self.bannerDelegate];
    }
}
  
/// 用位置和宽高属性来展示横幅广告
- (void)showBannerInRectangle:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    CGRect rect = [ATFBannerTool getSizeFromExtraDic:extraDic];
    
    id showCustomExt = extraDic[@"showCustomExt"];
    NSString *showCustomExtStr = @"";
    if ([showCustomExt isKindOfClass:[NSString class]] && !kATFStringIsEmpty(showCustomExt)) {
        showCustomExtStr = (NSString *)showCustomExt;
    }
    
    ATBannerView *bannerView = [ATFBannerTool getBannerViewAdRect:rect placementID:placementID sceneID:nil showCustomExt:showCustomExtStr];
    
    [self setBannerViewVlaue:bannerView placementID:placementID];
    
    [self showBanner:bannerView];
    
}

/// 用位置和宽高属性来展示横幅场景广告
- (void)showBannerInRectangle:(NSString *)placementID sceneID:(NSString *)sceneID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    CGRect rect = [ATFBannerTool getSizeFromExtraDic:extraDic];
    
    id showCustomExt = extraDic[@"showCustomExt"];
    NSString *showCustomExtStr = @"";
    if ([showCustomExt isKindOfClass:[NSString class]] && !kATFStringIsEmpty(showCustomExt)) {
        showCustomExtStr = (NSString *)showCustomExt;
    }
    
    ATBannerView *bannerView = [ATFBannerTool getBannerViewAdRect:rect placementID:placementID sceneID:sceneID showCustomExt:showCustomExtStr];
    
    [self setBannerViewVlaue:bannerView placementID:placementID];

    [self showBanner:bannerView];
}

/// 用预定义的位置来展示横幅广告
- (void)showAdInPosition:(NSString *)placementID position:(NSString *)positionStr {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    CGRect loadRect =  CGRectFromString(self.rectDic[placementID]);
     
    CGRect rect = [self getInPositionFromloadRect:loadRect positionStr:positionStr];
    
    ATFLog(@"自定义横幅位置:%@",NSStringFromCGRect(rect));
    
    ATBannerView *bannerView = [ATFBannerTool getBannerViewAdRect:rect placementID:placementID sceneID:nil showCustomExt:nil];
    [self setBannerViewVlaue:bannerView placementID:placementID];
    [self showBanner:bannerView];
}
 
/// 用预定义的位置来展示横幅场景广告
- (void)showAdInPosition:(NSString *)placementID sceneID:(NSString *)sceneID position:(NSString *)positionStr showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    CGRect loadRect =  CGRectFromString(self.rectDic[placementID]);
    CGRect rect = [self getInPositionFromloadRect:loadRect positionStr:positionStr];
    ATFLog(@"自定义场景横幅位置:%@",NSStringFromCGRect(rect));
    ATBannerView *bannerView = [ATFBannerTool getBannerViewAdRect:rect placementID:placementID sceneID:sceneID showCustomExt:showCustomExt];
    [self setBannerViewVlaue:bannerView placementID:placementID];
    
    [self showBanner:bannerView];
}


/// 移除横幅广告
- (void)removeBannerAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    if ([self.bannerViewDic.allKeys containsObject:placementID]) {
        
        UIView *tempView = self.bannerViewDic[placementID];
        [tempView removeFromSuperview];
        tempView = nil;
        [self.bannerViewDic removeObjectForKey:placementID];
    }
}

/// 隐藏横幅广告
- (void)hideBannerAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    if ([self.bannerViewDic.allKeys containsObject:placementID]) {
        UIView *tempView = self.bannerViewDic[placementID];
        tempView.hidden = YES;
    }
}

/// 重新展示横幅广告
- (void)afreshShowBannerAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    if ([self.bannerViewDic.allKeys containsObject:placementID]) {
        UIView *tempView = self.bannerViewDic[placementID];
        tempView.hidden = NO;
    }
}
 
#pragma mark - private

- (void)showBanner:(ATBannerView *)bannerView {
    
    UIView *containerView = [ATFCommonTool getRootViewController].view;

    [containerView addSubview:bannerView];

}

- (void)setBannerViewVlaue:(ATBannerView *)bannerView placementID:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    bannerView.delegate = self.bannerDelegate;
    bannerView.backgroundColor = [UIColor whiteColor];
    bannerView.presentingViewController = [ATFCommonTool getRootViewController];
    
    if (bannerView != nil) {
        self.bannerViewDic[placementID] = bannerView;
    }else {
        ATFLog(@"retrieveBannerView  failed");
    }
}


- (CGRect)getInPositionFromloadRect:(CGRect)loadRect positionStr:(NSString *)positionStr {
    
    CGRect rect = CGRectMake(0, NavBarHeight, loadRect.size.width,loadRect.size.height);
        
    if ([positionStr isEqualToString:@"kATBannerAdShowingPositionTop"]) {
        rect.origin.x = 0;
        rect.origin.y = NavBarHeight + 20;
    }
    
    else if ([positionStr isEqualToString:@"kATBannerAdShowingPositionBottom"]) {
        
        rect.origin.x = 0;
        rect.origin.y = SCREEN_HEIGHT - loadRect.size.height - TabbarSafeBottomMargin;
    }
    return  rect;
}

- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entryBannerScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);

    [[ATAdManager sharedManager] entryBannerScenarioWithPlacementID:placementID scene:sceneID];
}

#pragma mark - lazy
- (NSMutableDictionary *)rectDic {

    if (_rectDic) return _rectDic;

    NSMutableDictionary *rectDic = [NSMutableDictionary new];

    return _rectDic = rectDic;
}

- (NSMutableDictionary *)bannerViewDic {

    if (_bannerViewDic) return _bannerViewDic;

    NSMutableDictionary *bannerViewDic = [NSMutableDictionary new];

    return _bannerViewDic = bannerViewDic;
}

- (ATFBannerDelegate *)bannerDelegate {

    if (_bannerDelegate) return _bannerDelegate;

    ATFBannerDelegate *bannerDelegate = [ATFBannerDelegate new];

    return _bannerDelegate = bannerDelegate;
}

 
@end
