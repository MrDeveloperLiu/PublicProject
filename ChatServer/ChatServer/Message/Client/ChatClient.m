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
- (void)__failedWithResponse:(ChatMessageResponse *)response reason:(NSString *)reason{
    response.responseCode = ChatResponseUnAvaiable;
    [response addHeader:reason forKey:@"Reason"];
}
- (void)__innerGetMessageIdWithRequest:(ChatMessageRequest *)request toResponse:(ChatMessageResponse *)response{
    [response addHeader:[request headerForKey:@"Event"] forKey:@"Event"];
    [response addHeader:[request headerForKey:ChatMessageId] forKey:ChatMessageId];
}
- (void)__innerGetMessageIdWithResponse:(ChatMessageResponse *)response toResponse:(ChatMessageResponse *)receiveResponse{
    [response addHeader:[receiveResponse headerForKey:@"Event"] forKey:@"Event"];
    [response addHeader:[receiveResponse headerForKey:ChatMessageId] forKey:ChatMessageId];
}

@end
