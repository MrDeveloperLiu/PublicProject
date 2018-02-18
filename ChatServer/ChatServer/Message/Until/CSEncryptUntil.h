//
//  CSEncryptUntil.h
//  ChatServer
//
//  Created by 刘杨 on 2018/2/10.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSEncryptUntil : NSObject

+ (NSString *)md5String:(NSString *)string;

+ (NSData *)base64DataWithString:(NSString *)string;
+ (NSString *)base64StringWithData:(NSData *)data;

@end
