//
//  QNUploadRequestMetrics.m
//  QiniuSDK
//
//  Created by yangsen on 2020/4/29.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import "QNUtils.h"
#import "QNUploadRequestMetrics.h"
#import "NSURLRequest+QNRequest.h"
#import "QNZoneInfo.h"

@interface QNUploadMetrics()

@property (nullable, strong) NSDate *startDate;
@property (nullable, strong) NSDate *endDate;

@end
@implementation QNUploadMetrics
//MARK:-- 构造
+ (instancetype)emptyMetrics {
    return [[self alloc] init];
}

- (NSNumber *)totalElapsedTime{
    return [QNUtils dateDuration:self.startDate endDate:self.endDate];
}

- (void)start {
    self.startDate = [NSDate date];
}

- (void)end {
    self.endDate = [NSDate date];
}
@end

@interface QNUploadSingleRequestMetrics()
@property (nonatomic, assign) int64_t countOfRequestHeaderBytes;
@property (nonatomic, assign) int64_t countOfRequestBodyBytes;
@end
@implementation QNUploadSingleRequestMetrics

+ (instancetype)emptyMetrics{
    QNUploadSingleRequestMetrics *metrics = [[QNUploadSingleRequestMetrics alloc] init];
    return metrics;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData{
    _countOfRequestHeaderBytesSent = 0;
    _countOfRequestBodyBytesSent = 0;
    _countOfResponseHeaderBytesReceived = 0;
    _countOfResponseBodyBytesReceived = 0;
}

- (void)setRequest:(NSURLRequest *)request{
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:request.URL
                                                              cachePolicy:request.cachePolicy
                                                          timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    
    self.countOfRequestHeaderBytes = [NSString stringWithFormat:@"%@", request.allHTTPHeaderFields].length;
    self.countOfRequestBodyBytes = [request.qn_getHttpBody length];
    _totalBytes = @(self.countOfRequestHeaderBytes + self.countOfRequestBodyBytes);
    _request = [newRequest copy];
}

- (void)setResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
        [(NSHTTPURLResponse *)response statusCode] >= 200 &&
        [(NSHTTPURLResponse *)response statusCode] < 300) {
        _countOfRequestHeaderBytesSent = _countOfRequestHeaderBytes;
        _countOfRequestBodyBytesSent = _countOfRequestBodyBytes;
    }
    if (_countOfResponseBodyBytesReceived <= 0) {
        _countOfResponseBodyBytesReceived = response.expectedContentLength;
    }
    if (_countOfResponseHeaderBytesReceived <= 0 && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        _countOfResponseHeaderBytesReceived = [NSString stringWithFormat:@"%@", [(NSHTTPURLResponse *)response allHeaderFields]].length;
    }
    _response = [response copy];
}

- (BOOL)isForsureHijacked {
    return [self.hijacked isEqualToString:kQNMetricsRequestHijacked];
}

- (BOOL)isMaybeHijacked {
    return [self.hijacked isEqualToString:kQNMetricsRequestMaybeHijacked];
}

- (NSNumber *)totalElapsedTime{
    return [self timeFromStartDate:self.startDate
                         toEndDate:self.endDate];
}

- (NSNumber *)totalDnsTime{
    return [self timeFromStartDate:self.domainLookupStartDate
                         toEndDate:self.domainLookupEndDate];
}

- (NSNumber *)totalConnectTime{
    return [self timeFromStartDate:self.connectStartDate
                         toEndDate:self.connectEndDate];
}

- (NSNumber *)totalSecureConnectTime{
    return [self timeFromStartDate:self.secureConnectionStartDate
                         toEndDate:self.secureConnectionEndDate];
}

- (NSNumber *)totalRequestTime{
    return [self timeFromStartDate:self.requestStartDate
                         toEndDate:self.requestEndDate];
}

- (NSNumber *)totalWaitTime{
    return [self timeFromStartDate:self.requestEndDate
                         toEndDate:self.responseStartDate];
}

- (NSNumber *)totalResponseTime{
    return [self timeFromStartDate:self.responseStartDate
                         toEndDate:self.responseEndDate];
}

- (NSNumber *)bytesSend{
    int64_t totalBytes = [self totalBytes].integerValue;
    int64_t senderBytes = self.countOfRequestBodyBytesSent + self.countOfRequestHeaderBytesSent;
    int64_t bytes = MIN(totalBytes, senderBytes);
    return @(bytes);
}

- (NSNumber *)timeFromStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    return [QNUtils dateDuration:startDate endDate:endDate];
}

- (NSNumber *)perceptiveSpeed {
    int64_t size = self.bytesSend.longLongValue + _countOfResponseHeaderBytesReceived + _countOfResponseBodyBytesReceived;
    if (size == 0 || self.totalElapsedTime == nil) {
        return nil;
    }
    
    return [QNUtils calculateSpeed:size totalTime:self.totalElapsedTime.longLongValue];
}

@end


@interface QNUploadRegionRequestMetrics()

@property (nonatomic, strong) id <QNUploadRegion> region;
@property (nonatomic,   copy) NSMutableArray<QNUploadSingleRequestMetrics *> *metricsListInter;

@end
@implementation QNUploadRegionRequestMetrics

+ (instancetype)emptyMetrics{
    QNUploadRegionRequestMetrics *metrics = [[QNUploadRegionRequestMetrics alloc] init];
    return metrics;
}

- (instancetype)initWithRegion:(id<QNUploadRegion>)region{
    if (self = [super init]) {
        _region = region;
        _metricsListInter = [NSMutableArray array];
    }
    return self;
}

- (QNUploadSingleRequestMetrics *)lastMetrics {
    @synchronized (self) {
        return self.metricsListInter.lastObject;
    }
}

- (NSNumber *)requestCount{
    if (self.metricsList) {
        return @(self.metricsList.count);
    } else {
        return @(0);
    }
}

- (NSNumber *)bytesSend{
    if (self.metricsList) {
        long long bytes = 0;
        for (QNUploadSingleRequestMetrics *metrics in self.metricsList) {
            bytes += metrics.bytesSend.longLongValue;
        }
        return @(bytes);
    } else {
        return @(0);
    }
}

- (void)addMetricsList:(NSArray<QNUploadSingleRequestMetrics *> *)metricsList{
    @synchronized (self) {
        [_metricsListInter addObjectsFromArray:metricsList];
    }
}

- (void)addMetrics:(QNUploadRegionRequestMetrics*)metrics{
    if ([metrics.region.zoneInfo.regionId isEqualToString:self.region.zoneInfo.regionId]) {
        @synchronized (self) {
            [_metricsListInter addObjectsFromArray:metrics.metricsListInter];
        }
    }
}

- (NSArray<QNUploadSingleRequestMetrics *> *)metricsList{
    @synchronized (self) {
        return [_metricsListInter copy];
    }
}

@end


@interface QNUploadTaskMetrics()

@property (nonatomic,   copy) NSString *upType;
@property (nonatomic,   copy) NSMutableArray<NSString *> *metricsKeys;
@property (nonatomic, strong) NSMutableDictionary<NSString *, QNUploadRegionRequestMetrics *> *metricsInfo;

@end
@implementation QNUploadTaskMetrics

+ (instancetype)emptyMetrics{
    QNUploadTaskMetrics *metrics = [[QNUploadTaskMetrics alloc] init];
    return metrics;
}

+ (instancetype)taskMetrics:(NSString *)upType {
    QNUploadTaskMetrics *metrics = [self emptyMetrics];
    metrics.upType = upType;
    return metrics;
}

- (instancetype)init{
    if (self = [super init]) {
        _metricsKeys = [NSMutableArray array];
        _metricsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (QNUploadRegionRequestMetrics *)lastMetrics {
    if (self.metricsKeys.count < 1) {
        return nil;
    }
    
    @synchronized (self) {
        NSString *key = self.metricsKeys.lastObject;
        if (key == nil) {
            return nil;
        }
        return self.metricsInfo[key];
    }
}
- (NSNumber *)totalElapsedTime{
    NSDictionary *metricsInfo = [self syncCopyMetricsInfo];
    if (metricsInfo) {
        double time = 0;
        for (QNUploadRegionRequestMetrics *metrics in metricsInfo.allValues) {
            time += metrics.totalElapsedTime.doubleValue;
        }
        return time > 0 ? @(time) : nil;
    } else {
        return nil;
    }
}

- (NSNumber *)requestCount{
    NSDictionary *metricsInfo = [self syncCopyMetricsInfo];
    if (metricsInfo) {
        NSInteger count = 0;
        for (QNUploadRegionRequestMetrics *metrics in metricsInfo.allValues) {
            count += metrics.requestCount.integerValue;
        }
        return @(count);
    } else {
        return @(0);
    }
}

- (NSNumber *)bytesSend{
    NSDictionary *metricsInfo = [self syncCopyMetricsInfo];
    if (metricsInfo) {
        long long bytes = 0;
        for (QNUploadRegionRequestMetrics *metrics in metricsInfo.allValues) {
            bytes += metrics.bytesSend.longLongValue;
        }
        return @(bytes);
    } else {
        return @(0);
    }
}

- (NSNumber *)regionCount{
    NSDictionary *metricsInfo = [self syncCopyMetricsInfo];
    if (metricsInfo) {
        int count = 0;
        for (QNUploadRegionRequestMetrics *metrics in metricsInfo.allValues) {
            if (![metrics.region.zoneInfo.regionId isEqualToString:QNZoneInfoEmptyRegionId]) {
                count += 1;
            }
        }
        return @(count);
    } else {
        return @(0);
    }
}

- (void)setUcQueryMetrics:(QNUploadRegionRequestMetrics *)ucQueryMetrics {
    _ucQueryMetrics = ucQueryMetrics;
    [self addMetrics:ucQueryMetrics];
}

- (void)addMetrics:(QNUploadRegionRequestMetrics *)metrics{
    NSString *regionId = metrics.region.zoneInfo.regionId;
    if (!regionId) {
        return;
    }
    @synchronized (self) {
        QNUploadRegionRequestMetrics *metricsOld = self.metricsInfo[regionId];
        if (metricsOld) {
            [metricsOld addMetrics:metrics];
        } else {
            [self.metricsKeys addObject:regionId];
            self.metricsInfo[regionId] = metrics;
        }
    }
}

- (NSDictionary<NSString *, QNUploadRegionRequestMetrics *> *)syncCopyMetricsInfo {
    @synchronized (self) {
        return [_metricsInfo copy];
    }
}


@end
