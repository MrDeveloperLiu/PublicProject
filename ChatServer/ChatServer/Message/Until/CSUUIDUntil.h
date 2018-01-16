//
//  CSUUIDUntil.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/4.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CSUUIDUntil : NSObject
+ (NSString *)uuidString;
+ (NSString *)toUUidString:(NSData *)data;

+ (NSData *)uuid;
+ (NSData *)toUUidData:(NSString *)string;

@end
