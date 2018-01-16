//
//  CSFileUntil.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSFileManager [NSFileManager defaultManager]

@interface CSFileUntil : NSObject

+ (NSError *)createDirectory:(NSString *)path;

+ (NSString *)createFileOnPath:(NSString *)filePath;
+ (NSString *)createFileOnDir:(NSString *)dirPath filename:(NSString *)filename;


@end
