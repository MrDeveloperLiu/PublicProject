//
//  CSUserDefaultStore.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSUserDefaultStore.h"

#define CSUserDefaultStoreHost @"CM:Host"
#define CSUserDefaultStorePort @"CM:Port"

@implementation CSUserDefaultStore
+ (void)setObject:(id)object forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}
+ (id)objectForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}



+ (void)setHost:(NSString *)host{
    [[self class] setObject:host forKey:CSUserDefaultStoreHost];
}
+ (NSString *)host{
    return [[self class] objectForKey:CSUserDefaultStoreHost];
}

+ (void)setPort:(NSInteger)port{
    [[self class] setObject:@(port) forKey:CSUserDefaultStorePort];
}
+ (NSInteger)port{
    return [[[self class] objectForKey:CSUserDefaultStorePort] integerValue];
}

@end
