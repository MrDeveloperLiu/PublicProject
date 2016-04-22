//
//  LYURLSession.m
//  NSURLSession_test
//
//  Created by 刘杨 on 15/10/3.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "LYURLSession.h"
#import "AppDelegate.h"

@interface LYURLSession ()<NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>{
    NSURLSessionConfiguration *_configuration;//会话配置
    NSURLSessionConfiguration *_backgroundConfiguration;//后台配置

    NSURLSessionTask *_defaultTask;//默认会话任务
    NSURLSessionDownloadTask *_downloadTask;//下载任务
    NSURLSessionUploadTask *_uploadTask;//上传任务
    NSOperationQueue *_queue;//队列
    NSData *_resumeData;//恢复下载的数据
    NSURL *_cacheURL;//缓存地址
}
@property (nonatomic, strong) NSURLSession *defaultSession;//默认会话，用于基于磁盘缓存策略，并在用户keychain中储存证书
@property (nonatomic, strong) NSURLSession *backgroundSession;//后台会话，基本类似于默认会话

/*
 在一个会话中，NSURLSession支持三种任务类型
 
 数据任务：使用NSData对象来发送和接收数据。数据任务可以分片返回数据，也可以通过完成处理器一次性返回数据。由于数据任务不存储数据到文件，所以不支持后台会话.
 下载任务：以文件的形式接收数据，当程序不运行时支持后台下载
 上传任务：通常以文件的形式发送数据，支持后台上传。
 */

@end

@implementation LYURLSession

+ (LYURLSession *)session{
    static LYURLSession *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LYURLSession alloc] init];
    });
    return _instance;
}

- (void)cancelTaskWithType:(CancelTaskType)type{
    switch (type) {
        case CancelRequestTask:
            [_defaultTask cancel];
            break;
        case CancelDownloadTask:{
            [_downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                _resumeData = [NSData dataWithData:resumeData];

            }];
        }
            break;
        case CancelUploadTask:
            [_uploadTask cancel];
            break;
    }
}

- (void)resumeDataTask{
    _downloadTask = [self.defaultSession downloadTaskWithResumeData:_resumeData
                                                  completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          NSLog(@"resume location ====>>>%@", location);
          if (!error) {
              [[NSFileManager defaultManager] moveItemAtURL:location toURL:_cacheURL error:nil];
              [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
          }
    }];
    [_downloadTask resume];
}

- (instancetype)init{
    if (self = [super init]) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

        //cache
        NSString *cachePath = @"MyCache";
        NSString *path = [self pathForCachesDirectories];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *fullPath = [[path stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
        NSLog(@"%@", fullPath);
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
        _configuration.URLCache = cache;
        _configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        _configuration.allowsCellularAccess = YES;
        //创建队列
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 10;
        }
    return self;
}

- (NSURLSession *)defaultSession{
    if (!_defaultSession) {
        _defaultSession = [NSURLSession sessionWithConfiguration:_configuration
                                                        delegate:self
                                                   delegateQueue:_queue];
    }
    return _defaultSession;
}

- (void)requestWithURLString:(NSString *)urlString completion:(void(^)(id backData, NSURLResponse *response))completion failed:(void(^)(NSError *error))failed{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    _defaultTask = [self.defaultSession dataTaskWithRequest:request
                                          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = nil;
        id back = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (data && back) {
            completion(back, response);
        }
        if (error) {
            failed(error);
        }else if (jsonError){
            failed(jsonError);
        }
    }];
    [_defaultTask resume];
}

- (void)downloadWithURLString:(NSString *)urlString completion:(void(^)(NSString *locationStr))completion failed:(void(^)(NSError *error))failed{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    _downloadTask = [self.defaultSession downloadTaskWithRequest:request
                                               completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[NSThread currentThread]);
        NSString *path = [self pathForCachesDirectories];
        NSURL *cacheDirectoryURL = [NSURL fileURLWithPath:path];
        _cacheURL = [cacheDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];//建议的文件名，原来就是服务器响应除去“/”的最后一段字符串
        NSLog(@"%@", _cacheURL);
        if (!error && completion) {
            completion([NSString stringWithFormat:@"%@", _cacheURL]);
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:_cacheURL error:nil];//将这个文件移到别的路径
            [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        }else if(error && failed){
            failed(error);
        }
    }];
    [_downloadTask resume];
}

- (void)uploadWithURLString:(NSString *)urlString fromData:(NSData *)fromData completion:(void(^)(NSData *data, NSURLResponse *response))completion failed:(void(^)(NSError *error))failed{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    _uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request
                                                             fromData:fromData
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        
                                                        if (error && failed) {
                                                            failed(error);
                                                        }else if(completion){
                                                            completion(data, response);
                                                        }
                                                    }];
    [_uploadTask resume];
}

//后台下载，需要一个后台下载配置
- (void)downloadInBackgroundWithURLString:(NSString *)urlString identifier:(NSString *)identifier{
    _backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:_backgroundConfiguration
                                                                   delegate:self
                                                              delegateQueue:_queue];
    NSURLSessionDownloadTask *backgroundDownloadTask = [self.backgroundSession downloadTaskWithURL:[NSURL URLWithString:urlString]];
    [backgroundDownloadTask resume];
}

//在AppDelegate中，拷贝这个- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
//中的completionHandler，用来完成未完成的下载任务
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"background event finish %@", session);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.completionHandler) {
        void(^handler)() = appDelegate.completionHandler;
        handler();
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSURL *toURL = [NSURL fileURLWithPath:[[self pathForCachesDirectories] stringByAppendingPathComponent:[downloadTask.response suggestedFilename]]];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
    [self.backgroundSession finishTasksAndInvalidate];//用于完成的后台会话，重置identifier
    NSLog(@"delegate.location=== %@", toURL);
}


- (NSString *)pathForCachesDirectories{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}
@end
