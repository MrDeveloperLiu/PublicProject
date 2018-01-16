//
//  CSFileUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSFileUntil.h"

static NSErrorDomain CSFileManagerError = @"CSFileManagerError";

@implementation CSFileUntil

+ (NSError *)createDirectory:(NSString *)path{
    if (!path) {
        return [NSError errorWithDomain:CSFileManagerError
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey : @"mkdir, the path is nil"}];
    }
    if (![CSFileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        if ([CSFileManager createDirectoryAtPath:path withIntermediateDirectories:NO
                                      attributes:nil error:&error]) {
            return nil;//suc
        }else{
            return error;//fail
        }
    }
    return nil;//alerady have
}

+ (NSString *)createFileOnPath:(NSString *)filePath{
    if ([CSFileManager fileExistsAtPath:filePath]) {//already have
        return filePath;
    }
    if ([CSFileManager createFileAtPath:filePath contents:nil attributes:nil]) {//createfile
        return filePath;
    }
    return nil;
}

+ (NSString *)createFileOnDir:(NSString *)dirPath filename:(NSString *)filename{
    if (![CSFileManager fileExistsAtPath:dirPath]) {//doesn't have dir
        [self createDirectory:dirPath]; //create dir
    }
    NSString *filePath = [dirPath stringByAppendingPathComponent:filename];
    return [self createFileOnPath:filePath];
}

@end



