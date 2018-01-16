//
//  CSUUIDUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/4.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSUUIDUntil.h"

@implementation CSUUIDUntil
+ (NSString *)uuidString{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    return CFBridgingRelease(stringRef);
}
+ (NSData *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidRef);
    CFRelease(uuidRef);
    CFDataRef uuidDataRef = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&bytes, (CFIndex)sizeof(bytes));
    return CFBridgingRelease(uuidDataRef);
}
+ (NSString *)toUUidString:(NSData *)data{
    CFUUIDBytes bytes = *((CFUUIDBytes *)data.bytes);
    CFUUIDRef uuidRef = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, bytes);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    return CFBridgingRelease(stringRef);
}
+ (NSData *)toUUidData:(NSString *)string{
    CFStringRef stringRef = (__bridge CFStringRef)string;
    CFUUIDRef uuidRef = CFUUIDCreateFromString(kCFAllocatorDefault, stringRef);
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidRef);
    CFRelease(uuidRef);
    CFDataRef uuidDataRef = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&bytes, (CFIndex)sizeof(bytes));
    return CFBridgingRelease(uuidDataRef);
}


@end
