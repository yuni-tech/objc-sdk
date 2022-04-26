//
//  QNUploadFlowTest.h
//  QiniuSDK
//
//  Created by yangsen on 2020/12/2.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import "QNUploadBaseTest.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNUploadFlowTest : QNUploadBaseTest

//MARK: ----- 取消上传
- (void)allFileTypeCancelTest:(long long)cancelBytes
                     tempFile:(QNTempFile * _Nullable)tempFile
                          key:(NSString * _Nullable)key
                       config:(QNConfiguration * _Nullable)config
                       option:(QNUploadOption * _Nullable)option;

- (void)cancelTest:(long long)cancelBytes
          tempFile:(QNTempFile * _Nullable)tempFile
               key:(NSString * _Nullable)key
            config:(QNConfiguration * _Nullable)config
            option:(QNUploadOption * _Nullable)option;

//MARK: ----- 断点续传
- (void)allFileTypeResumeUploadTest:(long long)resumeSize
                           tempFile:(QNTempFile * _Nullable)tempFile
                                key:(NSString * _Nullable)key
                             config:(QNConfiguration * _Nullable)config
                             option:(QNUploadOption * _Nullable)option;

- (void)resumeUploadTest:(long long)resumeSize
                tempFile:(QNTempFile * _Nullable)tempFile
                     key:(NSString * _Nullable)key
                  config:(QNConfiguration * _Nullable)config
                  option:(QNUploadOption * _Nullable)option;

//MARK: ----- 切换Region
- (void)allFileTypeSwitchRegionTestWithFile:(QNTempFile * _Nullable)tempFile
                                        key:(NSString * _Nullable)key
                                     config:(QNConfiguration * _Nullable)config
                                     option:(QNUploadOption * _Nullable)option;

- (void)switchRegionTestWithFile:(QNTempFile * _Nullable)tempFile
                             key:(NSString * _Nullable)key
                          config:(QNConfiguration * _Nullable)config
                          option:(QNUploadOption * _Nullable)option;

@end

NS_ASSUME_NONNULL_END
