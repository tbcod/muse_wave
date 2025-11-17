//
//  ATFDisposeDataTool.m
//  Pods-Runner
//
//  Created by GUO PENG on 2021/6/25.
//

#import "ATFDisposeDataTool.h"
#import "ATFCoconfigurManger.h"
#import "ATFConfiguration.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

@implementation ATFDisposeDataTool


+ (void)disposeInitData:(NSDictionary *)dic{
    [[ATFCoconfigurManger sharedManager] setValuesForKeysWithDictionary:dic];
    
    ATFLog(@"%@",[ATFCoconfigurManger sharedManager].description);
    
}

+ (NSArray<ATFNativeAttributeMode *> *)disposeCustomViewNativeData:(NSDictionary *)dic keyStr:(NSString *)keyStr{
    NSMutableArray<ATFNativeAttributeMode *> *models = @[].mutableCopy;

    if ([dic.allKeys containsObject:keyStr] == NO) {
        return models;
    }
    
    id tempDic = dic[keyStr];
    if ([tempDic isKindOfClass:[NSDictionary class]]) {
        ATFNativeAttributeMode *nativeAttributeMode = [[ATFNativeAttributeMode alloc]init];
        [nativeAttributeMode setValuesForKeysWithDictionary:tempDic];
        [models addObject:nativeAttributeMode];
    } else if ([tempDic isKindOfClass:[NSArray class]]) {
        NSArray *itemDict = (NSArray *)tempDic;
        [itemDict enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ATFNativeAttributeMode *nativeAttributeMode = [[ATFNativeAttributeMode alloc]init];
            [nativeAttributeMode setValuesForKeysWithDictionary:obj];
            [models addObject:nativeAttributeMode];
        }];
    }
    
    return models;
}

+ (ATFNativeAttributeMode *)disposeNativeData:(NSDictionary *)dic keyStr:(NSString *)keyStr{
    
    ATFNativeAttributeMode *nativeAttributeMode = [[ATFNativeAttributeMode alloc]init];

    if ([dic.allKeys containsObject:keyStr] == NO) {
        return  nativeAttributeMode;
    }
    
    NSDictionary *tempDic = dic[keyStr];
    [nativeAttributeMode setValuesForKeysWithDictionary:tempDic];
    return nativeAttributeMode;
}

+ (NSMutableDictionary *)revampTimeoutCallDic:(NSString *)callNameKey placementID:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    tempDic[CallNameKey] = callNameKey;
    tempDic[PlacementID] = placementID;
    if (extraDic != nil && extraDic.count != 0) {
        tempDic[ExtraDic] = extraDic;
    }
    return  tempDic;
}

+ (NSMutableDictionary *)revampSucceedCallDic:(NSString *)callNameKey placementID:(NSString *)placementID extraDic:(NSDictionary *)extraDic{
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    tempDic[CallNameKey] = callNameKey;
    
    tempDic[PlacementID] = placementID;

    tempDic[RequestMessage] = @"succeed";
    if (extraDic != nil && extraDic.count != 0) {
        
        NSMutableDictionary *extraDictM = [NSMutableDictionary dictionaryWithDictionary:extraDic];
        NSMutableDictionary *extraDataTemp = [NSMutableDictionary dictionary];
        NSMutableDictionary *extraDataDictM = [NSMutableDictionary dictionaryWithDictionary:extraDic[UserExtraKey]];
        for (NSString *key in extraDataDictM.allKeys) {
            if ([extraDataDictM[key] isKindOfClass:[NSString class]] || [extraDataDictM[key] isKindOfClass:[NSNumber class]]) {
                [extraDataTemp setValue:extraDataDictM[key] forKey:key];
            }
        }
        if ([extraDataTemp count]) {
            [extraDictM setValue:extraDataTemp forKey:UserExtraKey];
        } else {
            [extraDictM removeObjectForKey:UserExtraKey];
        }
        tempDic[ExtraDic] = extraDictM;
    }
    return  tempDic;
}

+ (NSMutableDictionary *)revampFailCallDic:(NSString *)callNameKey placementID:(NSString *)placementID extraDic:(NSDictionary *)extraDic error:(NSError *)error{
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    
    tempDic[CallNameKey] = callNameKey;
    tempDic[PlacementID] = placementID;
    tempDic[RequestMessage] = error.description;
    if (extraDic != nil && extraDic.count != 0) {
        
        NSMutableDictionary *extraDictM = [NSMutableDictionary dictionaryWithDictionary:extraDic];
        NSMutableDictionary *extraDataTemp = [NSMutableDictionary dictionary];
        NSMutableDictionary *extraDataDictM = [NSMutableDictionary dictionaryWithDictionary:extraDic[UserExtraKey]];
        for (NSString *key in extraDataDictM.allKeys) {
            if ([extraDataDictM[key] isKindOfClass:[NSString class]] || [extraDataDictM[key] isKindOfClass:[NSNumber class]]) {
                [extraDataTemp setValue:extraDataDictM[key] forKey:key];
            }
        }
        if ([extraDataTemp count]) {
            [extraDictM setValue:extraDataTemp forKey:UserExtraKey];
        } else {
            [extraDictM removeObjectForKey:UserExtraKey];
        }
        tempDic[ExtraDic] = extraDictM;
    }
    return tempDic;
}

@end
