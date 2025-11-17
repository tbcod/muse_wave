//
//  ATFNativeManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/29.
//

#import "ATFNativeManger.h"
#import <AnyThinkNative/AnyThinkNative.h>
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"

#import "ATFSendSignalManger.h"
#import "ATFDisposeDataTool.h"

#import "ATFNativeSelfRenderView.h"
#define NativeCallName  @"NativeCall"


#define NativeAdFailToLoadAD  @"nativeAdFailToLoadAD"
#define NativeAdDidFinishLoading  @"nativeAdDidFinishLoading"
#define NativeAddidClick  @"nativeAdDidClick"
#define NativeAdDidDeepLink  @"nativeAdDidDeepLink"
#define NativeAddidEndPlayingVideo  @"nativeAdDidEndPlayingVideo"
#define NativeAdEnterFullScreenVideo  @"nativeAdEnterFullScreenVideo"
#define NativeAdExitFullScreenVideoInAd  @"nativeAdExitFullScreenVideoInAd"
#define NativeAddidShowNativeAd  @"nativeAdDidShowNativeAd"
#define NativeAddidStartPlayingVideo  @"nativeAdDidStartPlayingVideo"
#define NativeAddidTapCloseButton  @"nativeAdDidTapCloseButton"
#define NativeAdDidCloseDetailInAdView  @"nativeAdDidCloseDetailInAdView"

#define NativeAddidLoadSuccessDraw  @"nativeAdDidLoadSuccessDraw"

static NSString *customView = @"customView";

@interface ATFNativeManger()<ATNativeADDelegate>
@property(nonatomic,strong) UIButton * container;
@property(nonatomic,copy)NSString * placementID;
@property (nonatomic,strong) NSMutableDictionary *nativeViewDic;

@end

@implementation ATFNativeManger

/// 加载原生广告
- (void)loadNativeWith:(NSString *)placementID extraDic:(NSDictionary *)extraDic{

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFNativeAttributeMode *parentMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:NativeSize];
    BOOL isAdaptiveHeight = [extraDic[IsAdaptiveHeight] boolValue];
    
    ATFLog(@"原生广告--加载的大小-1--%@",NSStringFromCGSize(CGSizeMake(parentMode.width, parentMode.height)));
    
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:@
     {
    kATExtraNativeIconImageSizeKey: @(AT_SIZE_72X72),
    kATExtraStartAPPNativeMainImageSizeKey:@(AT_SIZE_1200X628),
        kATExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(parentMode.width, parentMode.height)]
        ,kATNativeAdSizeToFitKey:@(isAdaptiveHeight)
    } delegate:self];
}

/// 展示原生广告
- (void)showNative:(NSString *)placementID isAdaptiveHeight:(BOOL)isAdaptiveHeight extraDic:(NSDictionary *)extraDic {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATNativeADConfiguration *config = [self getATNativeADConfiguration:extraDic isAdaptiveHeight:isAdaptiveHeight];

    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID];
    ATFLog(@"原生广告--是否为模板广告:%d-平台:%ld-size宽:%f 高:%f",offer.nativeAd.isExpressAd,offer.networkFirmID,offer.nativeAd.nativeExpressAdViewWidth,offer.nativeAd.nativeExpressAdViewHeight);
    ATFNativeSelfRenderView *selfRenderView = [self getSelfRenderViewOffer:offer];
    
    ATNativeADView *adView = [self getNativeADView:config offer:offer selfRenderView:selfRenderView withPlacementId:placementID extraDic:extraDic];
    
    [selfRenderView setUIWidget:extraDic];

    [self prepareWithNativePrepareInfo:selfRenderView nativeADView:adView];
    
    [offer rendererWithConfiguration:config selfRenderView:selfRenderView nativeADView:adView];
    // 是否隐藏内部渲染logoView
    adView.logoImageView.hidden = selfRenderView.isHiddenLogo;
            
    if (adView != nil) {
        [self removeNativeAdView:placementID];
        
        self.nativeViewDic[placementID] = adView;
    }

    [self addNativeView:extraDic placementID:placementID];
}

- (ATFNativeSelfRenderView *)getSelfRenderViewOffer:(ATNativeAdOffer *)offer{
    
    ATFNativeSelfRenderView *selfRenderView = [[ATFNativeSelfRenderView alloc]initWithOffer:offer];
             
    return selfRenderView;
}

#define kNavigationBarHeight ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? ([[UIApplication sharedApplication]statusBarFrame].size.height + 44) : ([[UIApplication sharedApplication]statusBarFrame].size.height - 4))

/// 展示场景原生广告
- (void)showNative:(NSString *)placementID sceneID:(NSString *)sceneID isAdaptiveHeight:(BOOL)isAdaptiveHeight extraDic:(NSDictionary *) extraDic{

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATNativeADConfiguration *config = [self getATNativeADConfiguration:extraDic isAdaptiveHeight:isAdaptiveHeight];

    if (sceneID == nil || sceneID.length == 0) {
        sceneID = @"";
    }
    
    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID scene:sceneID];
    ATFLog(@"原生广告--是否为模板广告:%d-平台:%ld-size宽:%f 高:%f",offer.nativeAd.isExpressAd,offer.networkFirmID,offer.nativeAd.nativeExpressAdViewWidth,offer.nativeAd.nativeExpressAdViewHeight);
    ATFNativeSelfRenderView *selfRenderView = [self getSelfRenderViewOffer:offer];

    ATNativeADView *adView = [self getNativeADView:config offer:offer selfRenderView:selfRenderView withPlacementId:placementID extraDic:extraDic] ;
    
    [offer rendererWithConfiguration:config selfRenderView:selfRenderView nativeADView:adView];
    // 是否隐藏内部渲染logoView
    adView.logoImageView.hidden = selfRenderView.isHiddenLogo;
            
    if (adView != nil) {
        [self removeNativeAdView:placementID];

        self.nativeViewDic[placementID] = adView;
    }

    [self addNativeView:extraDic placementID:placementID];
}

/// 展示原生广告带showCustomExt
- (void)showNative:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt isAdaptiveHeight:(BOOL)isAdaptiveHeight extraDic:(NSDictionary *) extraDic {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATNativeADConfiguration *config = [self getATNativeADConfiguration:extraDic isAdaptiveHeight:isAdaptiveHeight];

    if (sceneID == nil || sceneID.length == 0) {
        sceneID = @"";
    }

    if (showCustomExt == nil || showCustomExt.length == 0 || ![showCustomExt isKindOfClass:[NSString class]]) {
        ATFLog(@"showNative showCustomExt:%@",showCustomExt);
        showCustomExt = @"";
    }
    
    ATShowConfig *showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
    
    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID showConfig:showConfig];
    ATFLog(@"原生广告--是否为模板广告:%d-平台:%ld-size宽:%f 高:%f",offer.nativeAd.isExpressAd,offer.networkFirmID,offer.nativeAd.nativeExpressAdViewWidth,offer.nativeAd.nativeExpressAdViewHeight);
    ATFNativeSelfRenderView *selfRenderView = [self getSelfRenderViewOffer:offer];

    ATNativeADView *adView = [self getNativeADView:config offer:offer selfRenderView:selfRenderView withPlacementId:placementID extraDic:extraDic] ;
    
    [offer rendererWithConfiguration:config selfRenderView:selfRenderView nativeADView:adView];
    // 是否隐藏内部渲染logoView
    adView.logoImageView.hidden = selfRenderView.isHiddenLogo;
            
    if (adView != nil) {
        [self removeNativeAdView:placementID];

        self.nativeViewDic[placementID] = adView;
    }

    [self addNativeView:extraDic placementID:placementID];
}

- (ATNativeADView *)getNativeADView:(ATNativeADConfiguration *)config offer:(ATNativeAdOffer *)offer selfRenderView:(ATFNativeSelfRenderView *)selfRenderView withPlacementId:(NSString*)placementID extraDic:(NSDictionary *) extraDic {
    
    ATNativeADView *nativeADView = [[ATNativeADView alloc]initWithConfiguration:config currentOffer:offer placementID:placementID];
    
    UIView *mediaView = [nativeADView getMediaView];

    NSMutableArray *array = [@[selfRenderView.iconImageView,selfRenderView.titleLabel,selfRenderView.textLabel,selfRenderView.ctaLabel,selfRenderView.mainImageView] mutableCopy];
    
    if (mediaView) {
        [array addObject:mediaView];
        selfRenderView.mediaView = mediaView;
        [selfRenderView addSubview:mediaView];
        
    }
    
    NSArray<ATFNativeAttributeMode *> *modes = [ATFDisposeDataTool disposeCustomViewNativeData:extraDic keyStr:customView];
    [modes enumerateObjectsUsingBlock:^(ATFNativeAttributeMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ATFNativeAttributeModeType type = (ATFNativeAttributeModeType)obj.type.integerValue;
        switch (type) {
            case ATFNativeAttributeModeTypeImage: {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj.imagePath]];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    imageView.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                imageView.frame = CGRectMake(obj.x, obj.y, obj.width, obj.height);
                if (obj.cornerRadius > 0) {
                    imageView.layer.cornerRadius = obj.cornerRadius;
                    imageView.layer.masksToBounds = YES;
                }
                [selfRenderView addSubview:imageView];
                [selfRenderView.customViews addObject:imageView];
            }
                break;
            case ATFNativeAttributeModeTypeLabel: {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(obj.x, obj.y, obj.width, obj.height)];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    label.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                label.text = obj.title;
                label.textColor = [ATFCommonTool colorWithHexString:obj.textColorStr];
                if (obj.cornerRadius > 0) {
                    label.layer.cornerRadius = obj.cornerRadius;
                    label.layer.masksToBounds = YES;
                }
                label.font = [UIFont systemFontOfSize:obj.textSize];
                if ([obj.textAlignmentStr isEqualToString:@"left"]) {
                    label.textAlignment = NSTextAlignmentLeft;
                }
                if ([obj.textAlignmentStr isEqualToString:@"center"]) {
                    label.textAlignment = NSTextAlignmentCenter;
                }
                if ([obj.textAlignmentStr isEqualToString:@"right"]) {
                    label.textAlignment = NSTextAlignmentRight;
                }
                [selfRenderView addSubview:label];
                [selfRenderView.customViews addObject:label];
            }
                break;
            case ATFNativeAttributeModeTypeView: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(obj.x, obj.y, obj.width, obj.height)];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    view.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                
                if (obj.cornerRadius > 0) {
                    view.layer.cornerRadius = obj.cornerRadius;
                    view.layer.masksToBounds = YES;
                }
                
                [selfRenderView addSubview:view];
                [selfRenderView.customViews addObject:view];
            }
                break;
                
            default:
                break;
        }
    }];
    
    [array addObjectsFromArray:selfRenderView.customViews];
    [nativeADView registerClickableViewArray:array];

    return nativeADView;
}


- (void)prepareWithNativePrepareInfo:(ATFNativeSelfRenderView *)selfRenderView nativeADView:(ATNativeADView *)nativeADView{
    
    ATNativePrepareInfo *info = [ATNativePrepareInfo loadPrepareInfo:^(ATNativePrepareInfo * _Nonnull prepareInfo) {
        prepareInfo.textLabel = selfRenderView.textLabel;
        prepareInfo.advertiserLabel = selfRenderView.advertiserLabel;
        prepareInfo.titleLabel = selfRenderView.titleLabel;
        prepareInfo.ratingLabel = selfRenderView.ratingLabel;
        prepareInfo.iconImageView = selfRenderView.iconImageView;
        prepareInfo.mainImageView = selfRenderView.mainImageView;
//        prepareInfo.logoImageView = selfRenderView.logoImageView;
        prepareInfo.dislikeButton = selfRenderView.dislikeButton;
        prepareInfo.ctaLabel = selfRenderView.ctaLabel;
        prepareInfo.mediaView = selfRenderView.mediaView;
    }];
    
    [nativeADView prepareWithNativePrepareInfo:info];
}

/// 移除原生广告
- (void)removeNative:(NSString *)placementID {
    [self removeNativeAdView:placementID];
}
 
#pragma mark - ATNativeADDelegate
// 广告加载失败
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampFailCallDic:NativeAdFailToLoadAD placementID:placementID extraDic:nil error:error];
    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];

    ATFLog(@"原生广告加载失败%@",error);
}

// 广告加载成功
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }

    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic: NativeAdDidFinishLoading placementID:placementID extraDic:nil];

    [SendEventManger sendMethod:NativeCallName arguments:dic result:nil];
    ATFLog(@"原生广告加载成功");
}

// 广告点击
- (void)didClickNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidClick placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];

    ATFLog(@"原生广告点击");
}

// 广告点击跳转是否为Deeplink形式，目前只针对TopOn Adx的广告返回
- (void)didDeepLinkOrJumpInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra result:(BOOL)success {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAdDidDeepLink placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    ATFLog(@"原生广告点击跳转是否为Deeplink形式");
}

// 广告视频结束播放，部分广告平台有此回调
- (void)didEndPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidEndPlayingVideo placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    ATFLog(@"原生广告视频结束播放，部分广告平台有此回调");
}

// 广告进入全屏播放
- (void)didEnterFullScreenVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAdEnterFullScreenVideo placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    ATFLog(@"原生广告进入全屏播放");
}

// 离开全屏播放
- (void)didExitFullScreenVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAdExitFullScreenVideoInAd placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName arguments:dic result:nil];
    ATFLog(@"原生广告离开全屏播放");
}

// 广告展示成功
- (void)didShowNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidShowNativeAd placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName arguments:dic result:nil];
    ATFLog(@"原生广告展示成功");
}

// 广告视频开始播放，部分广告平台有此回调
- (void)didStartPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidStartPlayingVideo placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName arguments:dic result:nil];
    ATFLog(@"原生广告视频开始播放，部分广告平台有此回调");
}

// 广告关闭按钮被点击，部分广告平台有此回调
- (void)didTapCloseButtonInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidTapCloseButton placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    [self removeNativeAdView:placementID];
    ATFLog(@"原生广告关闭按钮被点击，部分广告平台有此回调");
}

- (void)didLoadSuccessDrawWith:(NSArray *)views placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAddidLoadSuccessDraw placementID:placementID extraDic:extra];
    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    ATFLog(@"原生广告加载Draw成功");
}

- (void)didCloseDetailInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [ATFDisposeDataTool revampSucceedCallDic:NativeAdDidCloseDetailInAdView placementID:placementID extraDic:extra];

    [SendEventManger sendMethod: NativeCallName  arguments:dic result:nil];
    [self removeNativeAdView:placementID];
    ATFLog(@"原生广告细节关闭，部分广告平台有此回调");
}

#pragma mark - private
- (void)removeNativeAdView:(NSString *)placementID{

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    if ([self.nativeViewDic.allKeys containsObject:placementID]) {
        ATNativeADView *adView = self.nativeViewDic[placementID];
        [adView removeFromSuperview];
        [self.nativeViewDic removeObjectForKey:placementID];
        adView = nil;
        [self.container removeFromSuperview];
        self.container = nil;
    }
}

- (ATNativeADConfiguration *)getATNativeADConfiguration:(NSDictionary *)extraDic isAdaptiveHeight:(BOOL)isAdaptiveHeight {

    ATFNativeAttributeMode *parentMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:Parent];
    ATFNativeAttributeMode *mainImageMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:MainImage];
    ATFNativeAttributeMode *adLogoMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:AdLogo];
    
    UIViewController *tempController = [ATFCommonTool getRootViewController];
    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
    config.ADFrame = CGRectMake(parentMode.x, parentMode.y, parentMode.width, parentMode.height);
    config.mediaViewFrame = CGRectMake(mainImageMode.x, mainImageMode.y, mainImageMode.width, mainImageMode.height);
    config.logoViewFrame = CGRectMake(adLogoMode.x, adLogoMode.y, adLogoMode.width, adLogoMode.height);
    config.delegate = self;
    config.rootViewController = tempController;
    config.sizeToFit = isAdaptiveHeight;
    config.context = @{
        kATNativeAdConfigurationContextAdOptionsViewFrameKey:[NSValue valueWithCGRect:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 43.0f, .0f, 43.0f, 18.0f)],
        kATNativeAdConfigurationContextAdLogoViewFrameKey:[NSValue valueWithCGRect:CGRectMake(.0f, .0f, 54.0f, 18.0f)],
        kATNativeAdConfigurationContextNetworkLogoViewFrameKey:[NSValue valueWithCGRect:CGRectMake(CGRectGetWidth(config.ADFrame) - 54.0f, CGRectGetHeight(config.ADFrame) - 18.0f, 54.0f, 18.0f)]
    };
    ATFLog(@"原生广告--Config-NativeShow-frame:%@",NSStringFromCGRect(config.ADFrame));
    return  config;
}

- (void)addNativeView:(NSDictionary *)extraDic placementID:(NSString *)placementID {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    UIView *tempView = [ATFCommonTool getRootViewController].view;
 
    if ([self.nativeViewDic.allKeys containsObject:placementID]) {

        ATNativeADView *adView = self.nativeViewDic[placementID];
        [tempView addSubview:adView];
        
        //[tempView addSubview:adView];
    }else {
        ATFLog(@"retrive ad view failed");
    }
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entryNativeScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);

    [[ATAdManager sharedManager] entryNativeScenarioWithPlacementID:placementID scene:sceneID];
}

#pragma mark - lazy
- (NSMutableDictionary *)nativeViewDic {

    if (_nativeViewDic) return _nativeViewDic;

    NSMutableDictionary *nativeViewDic = [NSMutableDictionary new];

    return _nativeViewDic = nativeViewDic;
}

@end
