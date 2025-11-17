//
//  ATFNativePlatformView.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFNativePlatformView.h"
#import "ATFNativeTool.h"
#import "ATFCommonTool.h"
#import "ATFNativeDelegate.h"
#import "ATFNativeTool.h"
#import "ATFNativeSelfRenderView.h"
#import "ATFConfiguration.h"
#import "ATFDisposeDataTool.h"

#define ATFkScreenW ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? UIScreen.mainScreen.bounds.size.width : UIScreen.mainScreen.bounds.size.height)

#define ATFkNavigationBarHeight ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? ([[UIApplication sharedApplication]statusBarFrame].size.height + 44) : ([[UIApplication sharedApplication]statusBarFrame].size.height - 4))

#define ATFkScreenH ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? UIScreen.mainScreen.bounds.size.height : UIScreen.mainScreen.bounds.size.width)

@interface ATFNativePlatformView()

@property(nonatomic, assign)  int64_t viewId;;

@property(nonatomic, strong) id args;

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@property(nonatomic, assign) CGRect frame;

@property(nonatomic, strong) ATFNativeDelegate *nativeDelegate;

@property(nonatomic, strong) ATFNativeSelfRenderView *nativeSelfRenderView;

@end

@implementation ATFNativePlatformView

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    
    if (self = [super init]){
        
        self.frame = frame;
        self.viewId = viewId;
        self.args = args;
        self.messenger = messenger;
    }
    return  self;
}

#pragma mark - FlutterPlatformView
- (UIView*)view {
    
    NSDictionary *extraDic;
    if ([self.args isKindOfClass:[NSDictionary class]]) {
        extraDic = (NSDictionary *)self.args;
    }
    
    BOOL isAdaptiveHeight = [extraDic[@"isAdaptiveHeight"] boolValue];
    NSString *placementID = extraDic[@"placementID"];
    NSDictionary *dic = extraDic[@"extraMap"];
    
    NSString *showCustomExt = dic[@"showCustomExt"];
    
    id sceneID = extraDic[@"sceneID"];
    NSString *sceneIDStr = @"";
    if ([sceneID isKindOfClass:[NSString class]]) {
        sceneIDStr = (NSString *)sceneID;
    }
    
    ATShowConfig *showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
    
    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID showConfig:showConfig];
    ATFNativeSelfRenderView *selfRenderView = [self getSelfRenderViewOffer:offer];
    
    ATNativeADConfiguration *config = [ATFNativeTool getATNativeADConfiguration:dic];
    config.delegate = self.nativeDelegate;
    config.sizeToFit = isAdaptiveHeight;
    ATFLog(@"原生广告--是否为模板广告:%d-平台:%ld-size宽:%f 高:%f",offer.nativeAd.isExpressAd,offer.networkFirmID,offer.nativeAd.nativeExpressAdViewWidth,offer.nativeAd.nativeExpressAdViewHeight);
    
    ATNativeADView *adView = [self getNativeADView:config offer:offer selfRenderView:selfRenderView withPlacementId:placementID extraDic:dic];
    [selfRenderView setUIWidget:dic];

    [self prepareWithNativePrepareInfo:selfRenderView nativeADView:adView];
    [offer rendererWithConfiguration:config selfRenderView:selfRenderView nativeADView:adView];
    // 是否隐藏内部渲染logoView
    adView.logoImageView.hidden = selfRenderView.isHiddenLogo;
    
    
    if (adView != nil) {
        return adView;
    }else{
        UILabel *label = [[UILabel alloc]init];
        label.text = @"Ad view failed to load";
        return label;
    }
}

- (ATFNativeSelfRenderView *)getSelfRenderViewOffer:(ATNativeAdOffer *)offer{
    ATFNativeSelfRenderView *selfRenderView = [[ATFNativeSelfRenderView alloc]initWithOffer:offer];
    self.nativeSelfRenderView = selfRenderView;
    return selfRenderView;
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
    
    NSArray<ATFNativeAttributeMode *> *modes = [ATFDisposeDataTool disposeCustomViewNativeData:extraDic keyStr:@"customView"];
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

#pragma mark - lazy
- (ATFNativeDelegate *)nativeDelegate {

    if (_nativeDelegate) return _nativeDelegate;

    ATFNativeDelegate *nativeDelegate = [ATFNativeDelegate new];

    return _nativeDelegate = nativeDelegate;
}
@end
