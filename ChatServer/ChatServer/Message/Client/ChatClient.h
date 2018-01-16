//
//  ChatClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

#define NotificationConnectionDisconnect @"CM:ConnectionDisconnect"
#define NotificationConnectionDidConnect @"CM:ConnectionDidConnect"

@interface ChatClient : NSObject

+ (void)addObserver:(id)observer selector:(SEL)selector forNotificationName:(NSString *)name;
+ (void)removeObserver:(id)observer forName:(NSString *)name;
+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;
+ (void)removeObserver:(id)observer;

- (void)__failedWithResponse:(ChatMessageResponse *)response reason:(NSString *)reason;
- (void)__innerGetMessageIdWithRequest:(ChatMessageRequest *)request toResponse:(ChatMessageResponse *)response;
- (void)__innerGetMessageIdWithResponse:(ChatMessageResponse *)response toResponse:(ChatMessageResponse *)receiveResponse;
@end
