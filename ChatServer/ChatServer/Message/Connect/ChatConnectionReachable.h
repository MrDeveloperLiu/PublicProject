//
//  ChatConnectionReachable.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/1.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

FOUNDATION_EXPORT NSString *const ChatConnectionReachableNotificationName;

typedef enum {
    ChatConnectionReachableUnkown = -1,
    ChatConnectionReachableNotAvaliable = 0x0,
    ChatConnectionReachableWifi         = 0x1,
    ChatConnectionReachableWLAN
} ChatConnectionReachablity;

@interface ChatConnectionReachable : NSObject

@property (nonatomic, assign) ChatConnectionReachablity reachStatus;

+ (ChatConnectionReachable *)defaultReachable;

- (instancetype)initWithHost:(NSString *)host;
- (BOOL)startMonitoring;
- (BOOL)stopMonitoring;

- (void)setReachableStatusChanged:(void (^)(ChatConnectionReachablity status))block;

@end
