//
//  ATNativeSelfRenderView.m
//  AnyThinkSDKDemo
//
//  Created by GUO PENG on 2022/5/7.
//  Copyright © 2022 AnyThink. All rights reserved.
//

#import "ATFNativeSelfRenderView.h"


#import <AnyThinkSDK/ATImageLoader.h>
#import "ATFNativeAttributeMode.h"
#import "ATFDisposeDataTool.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"


@interface ATFNativeSelfRenderView()

@property (nonatomic, strong) NSDictionary *extraDic;

@property(nonatomic, strong) ATNativeAdOffer *nativeAdOffer;
@property(nonatomic, strong) ATFNativeAttributeMode *parentMode;
@property(nonatomic, strong) ATFNativeAttributeMode *appIconMode;
@property(nonatomic, strong) ATFNativeAttributeMode *mainImageMode;
@property(nonatomic, strong) ATFNativeAttributeMode *mainTitleMode;
@property(nonatomic, strong) ATFNativeAttributeMode *descMode;
//@property(nonatomic, strong) ATFNativeAttributeMode *adLogoMode;
@property(nonatomic, strong) ATFNativeAttributeMode *ctaMode;
@property(nonatomic, strong) ATFNativeAttributeMode *dislikeMode;

@property (nonatomic, strong) NSMutableArray<ATFNativeAttributeMode *> *attributeModes;

@end


@implementation ATFNativeSelfRenderView

- (instancetype) initWithOffer:(ATNativeAdOffer *)offer{

    if (self = [super init]) {
        
        _attributeModes = @[].mutableCopy;
        _customViews = @[].mutableCopy;
        _nativeAdOffer = offer;
        [self addView];
        [self setupUI];
    }
    return self;
}

- (void)updateUIWithoffer:(ATNativeAdOffer *)offer{
    self.nativeAdOffer = offer;
    [self setupUI];
}
- (void)setUIWidget:(NSDictionary *)extraDic {
    self.extraDic = extraDic;
    [self setMode];
    [self setViewValue];
    [self setViewLayout];
}

- (void)setMode{
    
    self.parentMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:Parent];
    
    self.mainImageMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:MainImage];
    
    self.appIconMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:AppIcon];
    
    self.mainTitleMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:MainTitle];
    
    self.descMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:Desc];
    ATFNativeAttributeMode *adLogoMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:AdLogo];
    self.hiddenAdLogo = [adLogoMode unsetFrame];
    
    self.ctaMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:Cta];
    
    self.dislikeMode = [ATFDisposeDataTool disposeNativeData:self.extraDic keyStr:Dislike];
}

- (void)setViewValue{
    
    self.backgroundColor =  [ATFCommonTool colorWithHexString:self.parentMode.backgroundColorStr];
    if (self.parentMode.cornerRadius != 0) {
        self.layer.cornerRadius = self.parentMode.cornerRadius;
        self.layer.masksToBounds = YES;
    }
    
    self.iconImageView.backgroundColor = [ATFCommonTool colorWithHexString:self.appIconMode.backgroundColorStr];
    if (self.appIconMode.cornerRadius != 0) {
        self.iconImageView.layer.cornerRadius = self.appIconMode.cornerRadius;
        self.iconImageView.layer.masksToBounds = YES;
    }
    
    self.mainImageView.backgroundColor = [ATFCommonTool colorWithHexString:self.mainImageMode.backgroundColorStr];
    if (self.mainImageMode.cornerRadius != 0) {
        self.mainImageView.layer.cornerRadius = self.mainImageMode.cornerRadius;
        self.mainImageView.layer.masksToBounds = YES;
        
        if (self.mediaView) {
            self.mediaView.layer.cornerRadius = self.mainImageMode.cornerRadius;
            self.mediaView.layer.masksToBounds = YES;
        }
    }
    
    self.dislikeButton.backgroundColor = [ATFCommonTool colorWithHexString:self.dislikeMode.backgroundColorStr];
    if (self.dislikeMode.cornerRadius != 0) {
        self.dislikeButton.layer.cornerRadius = self.dislikeMode.cornerRadius;
        self.dislikeButton.layer.masksToBounds = YES;
    }
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:self.mainTitleMode.textSize];
    self.titleLabel.textColor = [ATFCommonTool colorWithHexString:self.mainTitleMode.textColorStr];
    self.titleLabel.backgroundColor =  [ATFCommonTool colorWithHexString:self.mainTitleMode.backgroundColorStr];
    self.titleLabel.textAlignment = [self setLabelTextAlignment:self.mainTitleMode.textAlignmentStr];
    if (self.mainTitleMode.cornerRadius != 0) {
        self.titleLabel.layer.cornerRadius = self.mainTitleMode.cornerRadius;
        self.titleLabel.layer.masksToBounds = YES;
    }
    
    self.textLabel.font = [UIFont systemFontOfSize:self.descMode.textSize];
    self.textLabel.textColor = [ATFCommonTool colorWithHexString:self.descMode.textColorStr];
    self.textLabel.backgroundColor =  [ATFCommonTool colorWithHexString:self.descMode.backgroundColorStr];
    self.textLabel.textAlignment = [self setLabelTextAlignment:self.descMode.textAlignmentStr];
    if (self.descMode.cornerRadius != 0) {
        self.textLabel.layer.cornerRadius = self.descMode.cornerRadius;
        self.textLabel.layer.masksToBounds = YES;
    }

    self.ctaLabel.font = [UIFont systemFontOfSize:self.ctaMode.textSize];
    self.ctaLabel.textColor = [ATFCommonTool colorWithHexString:self.ctaMode.textColorStr];
    self.ctaLabel.backgroundColor =  [ATFCommonTool colorWithHexString:self.ctaMode.backgroundColorStr];
    self.ctaLabel.textAlignment = [self setLabelTextAlignment:self.ctaMode.textAlignmentStr];
    if (self.ctaMode.cornerRadius != 0) {
        self.ctaLabel.layer.cornerRadius = self.ctaMode.cornerRadius;
        self.ctaLabel.layer.masksToBounds = YES;
    }
    
//    self.logoImageView.backgroundColor = [ATFCommonTool colorWithHexString:self.adLogoMode.backgroundColorStr];
//    if (self.adLogoMode.cornerRadius != 0) {
//        self.logoImageView.layer.cornerRadius = self.adLogoMode.cornerRadius;
//        self.logoImageView.layer.masksToBounds = YES;
//    }
    
}

- (NSTextAlignment)setLabelTextAlignment:(NSString *)textAlignmentStr {

    if ([textAlignmentStr isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    } else if ([textAlignmentStr isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    } else if ([textAlignmentStr isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    } else {
        return NSTextAlignmentLeft;
    }
}

- (void)setViewLayout{
    self.iconImageView.frame = [self getRect:self.appIconMode];
    self.dislikeButton.frame = [self getRect:self.dislikeMode];
    self.titleLabel.frame = [self getRect:self.mainTitleMode];
    self.textLabel.frame = [self getRect:self.descMode];
    self.ctaLabel.frame = [self getRect:self.ctaMode];
//    self.logoImageView.frame = [self getRect:self.adLogoMode];
    self.mainImageView.frame = [self getRect:self.mainImageMode];
    self.mediaView.frame = _mainImageView.frame;
}

- (CGRect)getRect:(ATFNativeAttributeMode *)mode{
    CGRect rect = CGRectMake(mode.x, mode.y, mode.width,mode.height);
    return rect;
}

- (void)setIconImageView:(UIImageView *)iconImageView {
    _iconImageView = iconImageView;
}

- (void)addView{
    
    self.advertiserLabel = [[UILabel alloc]init];
    self.advertiserLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.advertiserLabel.textColor = [UIColor blackColor];
    self.advertiserLabel.textAlignment = NSTextAlignmentLeft;
    self.advertiserLabel.userInteractionEnabled = YES;
    [self addSubview:self.advertiserLabel];
        
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.userInteractionEnabled = YES;

    [self addSubview:self.titleLabel];
    
    self.textLabel = [[UILabel alloc]init];
    self.textLabel.font = [UIFont systemFontOfSize:15.0f];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.userInteractionEnabled = YES;

    [self addSubview:self.textLabel];
    
    self.ctaLabel = [[UILabel alloc]init];
    self.ctaLabel.font = [UIFont systemFontOfSize:15.0f];
    self.ctaLabel.textColor = [UIColor blackColor];
    self.ctaLabel.userInteractionEnabled = YES;

    [self addSubview:self.ctaLabel];

    self.ratingLabel = [[UILabel alloc]init];
    self.ratingLabel.font = [UIFont systemFontOfSize:15.0f];
    self.ratingLabel.textColor = [UIColor blackColor];
    self.ratingLabel.userInteractionEnabled = YES;

    [self addSubview:self.ratingLabel];
    
    self.iconImageView = [[UIImageView alloc]init];
    self.iconImageView.layer.cornerRadius = 4.0f;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImageView.userInteractionEnabled = YES;
    [self addSubview:self.iconImageView];
    
    
    self.mainImageView = [[UIImageView alloc]init];
    self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mainImageView.userInteractionEnabled = YES;
    [self addSubview:self.mainImageView];
    
//    self.logoImageView = [[UIImageView alloc]init];
//    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.logoImageView.userInteractionEnabled = YES;
//
//    [self addSubview:self.logoImageView];
    
    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
//    UIImage *closeImg = [UIImage imageNamed:@"icon_webview_close" inBundle:[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"AnyThinkSDK" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
    
    [self.dislikeButton setImage:[self getCloseImage] forState:0];
    [self addSubview:self.dislikeButton];
}

- (UIImage *)getCloseImage {
    
    NSString *imageBase64String = @"iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAIRlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAAEigAwAEAAAAAQAAAEgAAAAAYwsr7AAAAAlwSFlzAAALEwAACxMBAJqcGAAAABxpRE9UAAAAAgAAAAAAAAAkAAAAKAAAACQAAAAkAAACiSuooU0AAAJVSURBVHgB5JqhbsMwEECLisqGhldYNNaxqlJRP2CoY8Wjo/ub4UllI5VGy8f6ASMBA0XbvWiuXKtpnOQcO+lJJ8eRY989351dqYNBuzKU5W5EJ6IPogvRx39dS2ureb+U94zlm1vR3glQcA5Hn0RtCHWfmetOdCTaSbGh1IXg+52B1QlQgLkX1YoUX0iMIyVZO8moignGhWhACas0hMKJUa6hsfvYRJ2KJkTNVDQ2iLL1sRFbWxXyPMWoKYKFra3VJlIqRhEuct73PTYHT7mJLOJrUKrj8CGIcISm6nRVu/BFVfoQOS5EtUgib93J+9KnnjaSkXzdxYLsu4H4ho+1ZChfdeko94XijsNHfK0sXbgEus7W7eNrJelz3SmCWKkeXUNquaC8U61P9x0XQlm/9H5ERb/G6DHgONWGl4qRSvRsNpv3/X7/tdvtPufz+YssaAxQb99ElNe6GEWNowc4v5ZkWfYdCtK5tRQ2ozCKVE4udtPikz+GgOTCMWvOZjONiD37M2SpQH+93W4/jLF2qwmpCA5raPggc8DiREbSU6kP4/H4GUNtOOZZA1IRnMPh8LNarV61/JB5Toq1SnoZ46g5ISC1CIdgmYgehZBSiSAzjzakluHA4iTNVOFoQ4oABx7H04zfIEEAMW/TSIoEx/DgfwR5rpkXQdq6kCLDgUVeh6bsdGitCikBODCBTV6MggNiA3whJQIHJgsANf55gfO+Wgap6KIZ4J7jYzNs2gUEyEuQzKXSbiPBAWAOyIek+hhfSBHhGJ/904Pd19QySAnAWf8BAAD///Z/hqsAAAJUSURBVOWaoVLDQBCGT6HqUGgqq3CVnc5U9QFQwVVja3mMGjSamTpMXwBbXB8AU4Gogv1DfyYtuSS929xd2p25WSYkd/992d3bMBhjzCzmWK1Wb98W2263n+PxeB5Tn6wdD9ByuXy1sPm7nAAkcx8DUhM4pBQREtiEB2SDs9vtvgCDYIo+EqQpAE1kBKtDVXCyLHtCzUkIUg5oGApQHRzqSAgS2JgBhbXpm8KhhkQggY25pqi2/KlwqCMBSDeixVzJeKAobe8KhzoiQxIZv4ZipF6ofeFQUyRIeYHe89GvQ1pwIkK6JRx4pJlaBGnDobbAkdQDmKKppNlisXguNnj8GU0g+hxZ0OtFVEHabDYfvvPvnz9IL0IaaEwOkYRCrwWH+qogjUajOe/z8AfpJfPkhjTzPs3W6/U7wcBrwxGNeQTaIPX7/Ufe4+jz7y95ttTu5KpaCrQFhxqLkLDWixh/5+HBwGoqUSSzzxDqCm+z0ctSXAvR8684H9PyjiIA6uiojB6CQhRF+RtRZKiVtYdw6PEN0tUocNVdenIRSJkfXhAk7PVku5RUQ2phr06Giu7dG8kcrmHf9nPYW+2pVUfunOvRyXXHBkvlMySxSMKeVO2c+qNG/Y4LvXOIJPXIOQaJvO1i4YZm1NMg1pNVutRtQys0BzX0Dl1oJqHRuc/RIIqUSzGaoClYSjUBiZMhBVCoNdASNWpswJDnsUAlDaYMGFJvKqPtzwWsMZCRZMSIrlpDVGnCQqR0HkoVNRROvHGcLtgo6lZZ7eL1yf5ePIP/IwgaKT805vxmzF7SHAAAAABJRU5ErkJggg==";
        
        UIImage *closeImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:imageBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    
    return closeImage;
}

- (void)setupUI{
    
    if (self.nativeAdOffer.nativeAd.icon) {
        self.iconImageView.image = self.nativeAdOffer.nativeAd.icon;
    } else {
        [[ATImageLoader shareLoader]loadImageWithURL:[NSURL URLWithString:self.nativeAdOffer.nativeAd.iconUrl] completion:^(UIImage *image, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.iconImageView setImage:image];
                });
            }
        }];
    }
    
    if (self.nativeAdOffer.nativeAd.mainImage) {
        self.mainImageView.image = self.nativeAdOffer.nativeAd.mainImage;
    } else {
        [[ATImageLoader shareLoader]loadImageWithURL:[NSURL URLWithString:self.nativeAdOffer.nativeAd.imageUrl] completion:^(UIImage *image, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mainImageView setImage:image];
                });
            }
        }];
    }
    
//    if (self.nativeAdOffer.nativeAd.logo) {
//        self.logoImageView.image = self.nativeAdOffer.nativeAd.logo;
//    } else {
//        [[ATImageLoader shareLoader]loadImageWithURL:[NSURL URLWithString:self.nativeAdOffer.nativeAd.logoUrl] completion:^(UIImage *image, NSError *error) {
//            if (!error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.logoImageView setImage:image];
//                });
//            }
//        }];
//    }
    
    self.advertiserLabel.text = self.nativeAdOffer.nativeAd.advertiser;

    self.titleLabel.text = self.nativeAdOffer.nativeAd.title;
  
    self.textLabel.text = self.nativeAdOffer.nativeAd.mainText;
     
    self.ctaLabel.text = self.nativeAdOffer.nativeAd.ctaText;
  
    self.ratingLabel.text = [NSString stringWithFormat:@"%@", self.nativeAdOffer.nativeAd.rating ? self.nativeAdOffer.nativeAd.rating : @""];
}

@end
