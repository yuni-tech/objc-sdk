//
//  QNUploadServerFreezeManager.m
//  QiniuSDK
//
//  Created by yangsen on 2020/6/2.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import "QNUploadServerFreezeManager.h"

@interface QNUploadServerFreezeItem : NSObject
@property(nonatomic,   copy)NSString *host;
@property(nonatomic,   copy)NSString *type;
@property(nonatomic, strong)NSDate *freezeDate;
@end
@implementation QNUploadServerFreezeItem
+ (instancetype)item:(NSString *)host type:(NSString *)type{
    QNUploadServerFreezeItem *item = [[QNUploadServerFreezeItem alloc] init];
    item.host = host;
    item.type = type;
    return item;
}
- (BOOL)isFreezedByDate:(NSDate *)date{
    BOOL isFreezed = YES;
    @synchronized (self) {
        if (!self.freezeDate || [self.freezeDate timeIntervalSinceDate:date] < 0){
            isFreezed = NO;
        }
    }
    return isFreezed;
}
- (void)freeze{
    @synchronized (self) {
        self.freezeDate = [NSDate dateWithTimeIntervalSinceNow:20*60];
    }
}
@end

@interface QNUploadServerFreezeManager()

@property(nonatomic, strong)NSMutableDictionary *freezeInfo;

@end
@implementation QNUploadServerFreezeManager

+ (instancetype)shared{
    static QNUploadServerFreezeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QNUploadServerFreezeManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        _freezeInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isFreezeHost:(NSString *)host type:(NSString *)type{
    if (!host || host.length == 0) {
        return true;
    }
    BOOL isFreezed = true;
    NSString *infoKey = [NSString stringWithFormat:@"%@%@", host, type];
    QNUploadServerFreezeItem *item = self.freezeInfo[infoKey];
    if (!item || ![item isFreezedByDate:[NSDate date]]) {
        isFreezed = false;
    }
    return isFreezed;
}

- (void)freezeHost:(NSString *)host type:(NSString *)type{
    if (!host || host.length == 0) {
        return;
    }
    NSString *infoKey = [NSString stringWithFormat:@"%@%@", host, type];
    QNUploadServerFreezeItem *item = self.freezeInfo[infoKey];
    if (!item) {
        item = [QNUploadServerFreezeItem item:host type:type];
        self.freezeInfo[infoKey] = item;
    }
    [item freeze];
}

@end
