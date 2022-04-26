//
//  QNHttpClient.h
//  AppTest
//
//  Created by yangsen on 2020/4/7.
//  Copyright © 2020 com.qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QNCFHttpClientInnerDelegate <NSObject>

- (void)redirectedToRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse;

- (void)onError:(NSError *)error;

- (void)didSendBodyData:(int64_t)bytesSent
         totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

- (void)onReceiveResponse:(NSURLResponse *)response httpVersion:(NSString *)httpVersion;

- (void)didLoadData:(NSData *)data;

- (void)didFinish;

@end

@interface QNCFHttpClientInner : NSOperation

@property(nonatomic, strong, readonly)NSMutableURLRequest *request;
@property(nonatomic, strong, readonly)NSDictionary *connectionProxy;

@property(nonatomic, weak)id <QNCFHttpClientInnerDelegate> delegate;

+ (instancetype)client:(NSURLRequest *)request connectionProxy:(NSDictionary *)connectionProxy;

@end

NS_ASSUME_NONNULL_END
