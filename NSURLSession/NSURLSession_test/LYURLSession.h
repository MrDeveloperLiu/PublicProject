//
//  LYURLSession.h
//  NSURLSession_test
//
//  Created by 刘杨 on 15/10/3.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CancelTaskType) {
    CancelRequestTask,
    CancelDownloadTask,
    CancelUploadTask,
};

@interface LYURLSession : NSObject

+ (LYURLSession *)session;

- (void)cancelTaskWithType:(CancelTaskType)type;
- (void)resumeDataTask;

//简单的请求，下载，上传
- (void)requestWithURLString:(NSString *)urlString completion:(void(^)(id backData, NSURLResponse *response))completion failed:(void(^)(NSError *error))failed;
- (void)downloadWithURLString:(NSString *)urlString completion:(void(^)(NSString *locationStr))completion failed:(void(^)(NSError *error))failed;
- (void)uploadWithURLString:(NSString *)urlString fromData:(NSData *)fromData completion:(void(^)(NSData *data, NSURLResponse *response))completion failed:(void(^)(NSError *error))failed;

//后台下载
- (void)downloadInBackgroundWithURLString:(NSString *)urlString identifier:(NSString *)identifier;

@end
