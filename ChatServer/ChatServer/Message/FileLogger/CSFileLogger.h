//
//  CSFileLogger.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSFileUntil.h"
#import "CSDateUntil.h"

#define CSLog(format, ...) [[CSFileLogger logger] writeWithFormat:format, ##__VA_ARGS__]

#define CSLogF(format, info, ...) CSLog(@" [%@][File: %@ Line: %d] %s " format @"\n", \
info, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, ##__VA_ARGS__)

#define CSLogI(format, ...) CSLogF(format, @"INFO", ##__VA_ARGS__)
#define CSLogE(format, ...) CSLogF(format, @"ERROR", ##__VA_ARGS__)
#define CSLogW(format, ...) CSLogF(format, @"WRANING", ##__VA_ARGS__)
#define CSLogS(format, ...) CSLogF(format, @"SOCKET", ##__VA_ARGS__)


@interface CSFileLogger : NSObject

+ (CSFileLogger *)logger;
- (void)write:(NSString *)text;
- (void)writeWithFormat:(NSString *)format, ...;

@end
