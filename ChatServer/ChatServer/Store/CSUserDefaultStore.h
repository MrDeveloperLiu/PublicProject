//
//  CSUserDefaultStore.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUserDefaultStore : NSObject
+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)setHost:(NSString *)host;
+ (NSString *)host;

+ (void)setPort:(NSInteger)port;
+ (NSInteger)port;

+ (void)setUsername:(NSString *)username;
+ (NSString *)username;

+ (void)setPassword:(NSString *)password;
+ (NSString *)password;
@end
