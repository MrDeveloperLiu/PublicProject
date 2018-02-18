//
//  CSJsonUntil.h
//  ChatServer
//
//  Created by 刘杨 on 2018/2/16.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSJsonUntil : NSObject
+ (id)jsonWithData:(NSData *)data error:(NSError **)error;
+ (NSData *)toJsonWithObject:(id)object error:(NSError **)error;
@end
