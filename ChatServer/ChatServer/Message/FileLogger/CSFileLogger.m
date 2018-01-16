//
//  CSFileLogger.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSFileLogger.h"

@interface CSFileLogger ()
@property (nonatomic) dispatch_queue_t loggerQueue;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation CSFileLogger

- (void)dealloc{
    _loggerQueue = nil;
    [_fileHandle closeFile];
}

+ (void)load{
    CSLog(@"运行日志");
}

+ (CSFileLogger *)logger{
    static CSFileLogger *_logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logger = [[CSFileLogger alloc] init];
    });
    return _logger;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initAllSetting];
    }
    return self;
}

- (void)initAllSetting{
    //创建目录
    NSString *fileDir = [self createLoggerDir];
    //创建日志文件
    if (!fileDir) {
        return;
    }
    NSString *filePath = [self createLogFile:fileDir];
    if (!filePath) {
        return;
    }
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    _loggerQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);
    NSLog(@"CSFileLogger PATH : %@", filePath);
}


- (NSString *)createLogFile:(NSString *)dir{
    NSString *dateString = [[CSDateUntil fullFormat] stringFromDate:[NSDate date]];
    NSString *filename = [@"LOG_" stringByAppendingString:dateString];
    NSString *filePath = [filename stringByAppendingPathExtension:@"txt"];
    return [CSFileUntil createFileOnDir:dir filename:filePath];
}
- (NSString *)createLoggerDir{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask,
                                                               YES) lastObject];
    NSString *loggerDir = [docPath stringByAppendingPathComponent:NSStringFromClass([self class])];
    NSError *error = [CSFileUntil createDirectory:loggerDir];
    if (error) {
        return nil;//fail
    }
    return loggerDir;
}

- (void)write:(NSString *)text{
    if (!text) {
        return;
    }
    NSLog(@"CSFileLogger: %@", text);
    [self.fileHandle seekToEndOfFile];
    NSString *logText = [text stringByAppendingString:@"\n"];
    NSData *data = [logText dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileHandle writeData:data];
    [self.fileHandle synchronizeFile];
}

- (void)writeWithFormat:(NSString *)format, ...{
    va_list arg;
    va_start(arg, format);
    NSString *text = [[NSString alloc] initWithFormat:format arguments:arg];
    va_end(arg);

    dispatch_sync(self.loggerQueue, ^{
        NSString *currentTime = [[CSDateUntil normalFormat] stringFromDate:[NSDate date]];
        NSString *logText = [currentTime stringByAppendingString:text];
        [self write:logText];
    });
}

@end
