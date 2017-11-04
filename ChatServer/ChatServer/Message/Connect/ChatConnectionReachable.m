//
//  ChatConnectionReachable.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/1.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatConnectionReachable.h"
#import <arpa/inet.h>


NSString *const ChatConnectionReachableNotificationName = @"ChatConnectionReachableNotificationName";

@interface ChatConnectionReachable ()
@property (nonatomic, strong) id networkAbility;
@property (nonatomic, assign) ChatConnectionReachablity reachAble;
@property (nonatomic, copy) void (^changedBlock)(ChatConnectionReachablity status);
@end

@implementation ChatConnectionReachable

- (void)dealloc{
    _changedBlock = nil;
}

+ (ChatConnectionReachable *)defaultReachable{
    static ChatConnectionReachable *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ChatConnectionReachable alloc] initWithHost:nil];
    });
    return _instance;
}

- (instancetype)initWithHost:(NSString *)host{
    if (self = [super init]) {
        
        struct sockaddr_in addr;
        bzero(&addr, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        if (host.length) {
            addr.sin_addr.s_addr = inet_addr([host UTF8String]);
        }
        
        SCNetworkReachabilityRef reachAbilitiyRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                                                                           (struct sockaddr *)&addr);
        self.networkAbility = CFBridgingRelease(reachAbilitiyRef);
        self.reachAble = ChatConnectionReachableUnkown;
    }
    return self;
}

- (instancetype)init{
    return nil;
}

void ChatConnectionSCNetworkReachabilityCallBack(SCNetworkReachabilityRef target,
                                                 SCNetworkReachabilityFlags flags,
                                                 void *info){
    ChatConnectionReachable *reachCallBack = (__bridge ChatConnectionReachable *)(info);
    [reachCallBack reachabilityCallBack:flags];
}


ChatConnectionReachablity ChatConnectionNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    ChatConnectionReachablity status = ChatConnectionReachableUnkown;
    if (isNetworkReachable == NO) {
        status = ChatConnectionReachableNotAvaliable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = ChatConnectionReachableWLAN;
    }
#endif
    else {
        status = ChatConnectionReachableWifi;
    }
    return status;
}

- (void)reachabilityCallBack:(SCNetworkReachabilityFlags)flags{
    ChatConnectionReachablity status = ChatConnectionNetworkReachabilityStatusForFlags(flags);
    self.reachStatus = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
        NSNumber *object = @(status);
        NSDictionary *info = @{@"status" : object};
        [[NSNotificationCenter defaultCenter] postNotificationName:ChatConnectionReachableNotificationName
                                                            object:object userInfo:info];
        
        if (_changedBlock) {
            self.changedBlock(status);
        }
    } });
}

- (void)setReachableStatusChanged:(void (^)(ChatConnectionReachablity))block{
    self.changedBlock = block;
}

- (BOOL)startMonitoring{
    [self stopMonitoring];
    
    id networkAbility = self.networkAbility;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback((__bridge SCNetworkReachabilityRef)networkAbility,
                                     ChatConnectionSCNetworkReachabilityCallBack,
                                     &context);
    SCNetworkReachabilityScheduleWithRunLoop((__bridge SCNetworkReachabilityRef)networkAbility,
                                             CFRunLoopGetMain(),
                                             kCFRunLoopCommonModes);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags((__bridge SCNetworkReachabilityRef)networkAbility, &flags)) {
            [self reachabilityCallBack:flags];
        }
    });

    return YES;
}

- (BOOL)stopMonitoring{
    
    id networkAbility = self.networkAbility;
    if (!networkAbility) {
        return NO;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop((__bridge SCNetworkReachabilityRef)networkAbility,
                                               CFRunLoopGetMain(),
                                               kCFRunLoopCommonModes);

    
    return YES;
}

@end
