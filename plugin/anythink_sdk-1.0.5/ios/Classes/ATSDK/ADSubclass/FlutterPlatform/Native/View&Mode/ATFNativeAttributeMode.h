//
//  ATFNativeAttributeMode.h
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ATFNativeAttributeModeType) {
    ATFNativeAttributeModeTypeImage,
    ATFNativeAttributeModeTypeLabel,
    ATFNativeAttributeModeTypeView,
};

@interface ATFNativeAttributeMode : NSObject

@property(nonatomic, assign) double x;

@property(nonatomic, assign) double y;

@property(nonatomic, assign) double width;

@property(nonatomic, assign) double height;

@property(nonatomic, copy) NSString *backgroundColorStr;

@property(nonatomic, copy) NSString *textColorStr;

@property(nonatomic, assign) double textSize;

@property(nonatomic, copy) NSString *textAlignmentStr;

@property (nonatomic, assign) CGFloat cornerRadius;

// 自定义视图属性
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imagePath;


- (BOOL)unsetFrame;

@end

NS_ASSUME_NONNULL_END
