//
//  QNUploadDelegate.h
//  QiniuSDK
//
//  Created by zwb on 2021/4/13.
//  Copyright © 2021 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QNUploadManager;
@class QNResponseInfo;

@protocol QNUploadDelegate <NSObject>

@optional

/// 将要上传的数据，提交给外部处理，处理完成之后返回数据并上传
/// @param data 可提交给外部处理的chunk data
-(NSData * _Nonnull)QNWillUploadChunkData:(NSData * _Nonnull)data NS_SWIFT_NAME(qnWillUploadChunk(data:));

/// 一个文件上传完成之后回调
/// @param handler 上传完成之后的回调
-(void)QNUploadDataDidFinish:(QNResponseInfo  * _Nullable)info key:(NSString * _Nonnull)key resp:(NSDictionary * _Nonnull)resp NS_SWIFT_NAME(qnUploadDidFinish(info:key:resp:));

@end
