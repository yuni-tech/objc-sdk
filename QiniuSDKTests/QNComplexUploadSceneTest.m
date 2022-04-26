//
//  QNComplexUploadSceneTestC.m
//  QiniuSDK
//
//  Created by yangsen on 2020/5/11.
//  Copyright © 2020 Qiniu. All rights reserved.
//
#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper.h>
#import "QiniuSDK.h"
#import "QNTempFile.h"
#import "QNTestConfig.h"
#import "QNUploadBaseTest.h"

@interface QNComplexUploadSceneTest : QNUploadBaseTest
@end
@implementation QNComplexUploadSceneTest

- (void)testMutiUploadV1{
    int maxCount = 40;
    __block int completeCount = 0;
    __block int successCount = 0;
    
    int start = 35;
    for (int i=start; i<maxCount; i++) {
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.resumeUploadVersion = QNResumeUploadVersionV1;
            builder.useConcurrentResumeUpload = YES;
            builder.concurrentTaskCount = 3;
            builder.chunkSize = (i%4 + 1) * 1014 * 1024 + i;
        }];
        int size = (i + 1) * 50;
        NSString *keyUp = [NSString stringWithFormat:@"complex_upload_v1_%dk", size];
        QNTempFile *tempFile = [QNTempFile createTempFileWithSize:size * 1024 identifier:keyUp];
        [self upload:tempFile key:keyUp config:config option:nil complete:^(QNResponseInfo * _Nonnull responseInfo, NSString * _Nonnull key) {
            NSLog(@"complex_upload v1 response info: %@", responseInfo);
            @synchronized (self) {
                if (responseInfo.isOK) {
                    successCount += 1;
                }
                completeCount += 1;
            }
        }];
    }
    
    AGWW_WAIT_WHILE(completeCount != (maxCount - start), 600 * 10);
    
    NSLog(@"complex_upload v1 successCount: %d", successCount);
    XCTAssertTrue(completeCount == successCount, @"complete count:%d success count:%d", completeCount, successCount);
    XCTAssertTrue(completeCount == (maxCount - start), @"complete count:%d total count:%d", completeCount, (maxCount - start));
}

- (void)test100UploadV1{
    int maxCount = 100;
    __block int completeCount = 0;
    __block int successCount = 0;
    
    int start = 50;
    for (int i=start; i<maxCount; i++) {
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.resumeUploadVersion = QNResumeUploadVersionV1;
            builder.useConcurrentResumeUpload = YES;
            builder.concurrentTaskCount = 3;
            builder.chunkSize = 4 * 1014 * 1024;
        }];
        int size = (i + 1) * 50;
        NSString *keyUp = [NSString stringWithFormat:@"complex_100_upload_v1_%dk", size];
        QNTempFile *tempFile = [QNTempFile createTempFileWithSize:size * 1024 identifier:keyUp];
        [self upload:tempFile key:keyUp config:config option:nil complete:^(QNResponseInfo * _Nonnull responseInfo, NSString * _Nonnull key) {
            NSLog(@"complex_100_upload v1 response info: %@", responseInfo);
            @synchronized (self) {
                if (responseInfo.isOK || responseInfo.statusCode == 614) {
                    successCount += 1;
                }
                completeCount += 1;
            }
        }];
    }
    
    AGWW_WAIT_WHILE(completeCount != (maxCount - start), 600 * 10);
    
    NSLog(@"complex_100_upload v1 successCount: %d", successCount);
    XCTAssertTrue(completeCount == successCount, @"complete count:%d success count:%d", completeCount, successCount);
    XCTAssertTrue(completeCount == (maxCount - start), @"complete count:%d total count:%d", completeCount, (maxCount - start));
}

- (void)testMutiUploadV2{
    int maxCount = 37;
    __block int completeCount = 0;
    __block int successCount = 0;
    
    int start = 36;
    for (int i=start; i<maxCount; i++) {
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.resumeUploadVersion = QNResumeUploadVersionV2;
            builder.useConcurrentResumeUpload = YES;
            builder.concurrentTaskCount = 3;
            builder.chunkSize = (i%4 + 1) * 1024 * 1024 + i;
        }];
        int size = (i + 1) * 50;
        NSString *keyUp = [NSString stringWithFormat:@"complex_upload_v2_%dk", size];
        QNTempFile *tempFile = [QNTempFile createTempFileWithSize:size * 1024 identifier:keyUp];
        [self upload:tempFile key:keyUp config:config option:nil complete:^(QNResponseInfo * _Nonnull responseInfo, NSString * _Nonnull key) {
            NSLog(@"complex_upload v2 response info: %@", responseInfo);
            @synchronized (self) {
                if (responseInfo.isOK) {
                    successCount += 1;
                }
                completeCount += 1;
            }
        }];
    }
    
    AGWW_WAIT_WHILE(completeCount != (maxCount - start), 600 * 30);
    
    NSLog(@"complex_upload v2 successCount: %d", successCount);
    XCTAssertTrue(completeCount == successCount, @"complete count:%d success count:%d", completeCount, successCount);
    XCTAssertTrue(completeCount == (maxCount - start), @"complete count:%d total count:%d", completeCount, (maxCount - start));
}

- (void)test100UploadV2{
    int maxCount = 100;
    __block int completeCount = 0;
    __block int successCount = 0;
    
    int start = 50;
    for (int i=start; i<maxCount; i++) {
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.resumeUploadVersion = QNResumeUploadVersionV2;
            builder.useConcurrentResumeUpload = YES;
            builder.concurrentTaskCount = 3;
            builder.chunkSize = 4 * 1024 * 1024 + i;
        }];
        int size = (i + 1) * 50;
        NSString *keyUp = [NSString stringWithFormat:@"complex_100_upload_v2_%dk", size];
        QNTempFile *tempFile = [QNTempFile createTempFileWithSize:size * 1024 identifier:keyUp];
        [self upload:tempFile key:keyUp config:config option:nil complete:^(QNResponseInfo * _Nonnull responseInfo, NSString * _Nonnull key) {
            NSLog(@"complex_100_upload v2 response info: %@", responseInfo);
            @synchronized (self) {
                if (responseInfo.isOK || responseInfo.statusCode == 614) {
                    successCount += 1;
                }
                completeCount += 1;
            }
        }];
    }
    
    AGWW_WAIT_WHILE(completeCount != (maxCount - start), 600 * 30);
    
    NSLog(@"complex_100_upload v2 successCount: %d", successCount);
    XCTAssertTrue(completeCount == successCount, @"complete count:%d success count:%d", completeCount, successCount);
    XCTAssertTrue(completeCount == (maxCount - start), @"complete count:%d total count:%d", completeCount, (maxCount - start));
}

@end
