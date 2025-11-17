//
//  ATFPlatfromBannerManger.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFPlatfromBannerManger.h"
#import <AnyThinkBanner/AnyThinkBanner.h>
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"
#import "ATFBannerDelegate.h"
#import "ATFBannerTool.h"
//5.6.6版本以上支持 admob 自适应banner （用到时再import该头文件）
//#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString *kATBannerAdLoadingExtraInlineAdaptiveWidthKey = @"adaptive_width";
static NSString *kATBannerAdLoadingExtraInlineAdaptiveOrientationKey = @"adaptive_orientation";

@interface ATFPlatfromBannerManger()

@property(nonatomic, strong) ATFBannerDelegate *bannerDelegate;

@end

@implementation ATFPlatfromBannerManger

#pragma mark - publice
/// 加载横幅广告
- (void)loadBannerWith:(NSString *)placementID extraDic:(NSDictionary *)extraDic{
    
    CGRect rect = [ATFBannerTool getSizeFromExtraDic:extraDic];
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



#pragma mark - lazy
- (ATFBannerDelegate *)bannerDelegate {

    if (_bannerDelegate) return _bannerDelegate;

    ATFBannerDelegate *bannerDelegate = [ATFBannerDelegate new];

    return _bannerDelegate = bannerDelegate;
}
@end
