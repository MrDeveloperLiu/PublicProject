//
//  ChatClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatClient.h"

@implementation ChatClient

+ (void)addObserver:(id)observer selector:(SEL)selector forNotificationName:(NSString *)name{
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:name object:nil];
}
+ (void)removeObserver:(id)observer forName:(NSString *)name{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
}
+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}
+ (void)removeObserver:(id)observer{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}


#pragma mark - Private Method
//set failed
+ (void)__failedWithResponse:(ChatMessage *)response reason:(NSString *)reason{
    [response addHeader:reason forKey:@"Reason"];
}
+ (void)__innerGetMessageIdWithRequest:(ChatMessage *)request toResponse:(ChatMessage *)response{
    [response addHeader:[request headerForKey:@"Method"] forKey:@"Method"];
    [response addHeader:[request headerForKey:@"Event"] forKey:@"Event"];
    [response addHeader:[request headerForKey:ChatMessageIdKey] forKey:ChatMessageIdKey];
}
+ (void)__innerGetMessageIdWithResponse:(ChatMessage *)response toResponse:(ChatMessage *)receiveResponse{
    [response addHeader:[receiveResponse headerForKey:@"Method"] forKey:@"Method"];
    [response addHeader:[receiveResponse headerForKey:@"Event"] forKey:@"Event"];
    [response addHeader:[receiveResponse headerForKey:ChatMessageIdKey] forKey:ChatMessageIdKey];
}

- (instancetype)init{
    if (self = [super init]) {
        _managers = [NSMutableDictionary dictionary];
    }
    return self;
}
- (BOOL)openDatabase{
    BOOL ret = NO;
    for (id <ChatClientProtocol> manager in [self.managers allValues]) {
        if ([manager respondsToSelector:@selector(openDatabase)]) {
            ret = [manager openDatabase];
        }
    }
    return ret;
}
- (BOOL)updateDatabase{
    BOOL ret = NO;
    for (id <ChatClientProtocol> manager in [self.managers allValues]) {
        if ([manager respondsToSelector:@selector(updateDatabase)]) {
            ret = [manager updateDatabase];
        }
    }
    return ret;
}

- (void)registerManagers{

}

- (BOOL)registerManager:(id <ChatClientProtocol>)manager forKey:(NSString *)key{
    if ([key isKindOfClass:[NSString class]]) {
        self.managers[key] = manager;
        return YES;
    }
    return NO;
}
- (id <ChatClientProtocol>)managerForKey:(NSString *)key{
    return self.managers[key];
}

@end
