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

#define CSUserDefaultStoreUserId @"CM:UserId"
#define CSUserDefaultStoreUsername @"CM:Username"
#define CSUserDefaultStorePassword @"CM:Password"

@implementation CSUserDefaultStore
+ (void)setObject:(id)object forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (id)objectForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


+ (void)setUserId:(NSString *)userId{
    [[self class] setObject:userId forKey:CSUserDefaultStoreUserId];
}
+ (NSString *)userId{
    return [[self class] objectForKey:CSUserDefaultStoreUserId];
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


+ (void)setUsername:(NSString *)username{
    [[self class] setObject:username forKey:CSUserDefaultStoreUsername];
}
+ (NSString *)username{
    return [[self class] objectForKey:CSUserDefaultStoreUsername];
}

+ (void)setPassword:(NSString *)password{
    NSData *data = [password dataUsingEncoding:NSASCIIStringEncoding];
    [[self class] setObject:data forKey:CSUserDefaultStorePassword];
}
+ (NSString *)password{
    NSData *data = [[self class] objectForKey:CSUserDefaultStorePassword];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
