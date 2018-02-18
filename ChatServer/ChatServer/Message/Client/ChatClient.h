//
//  ChatClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"
#import "ChatClientProtocol.h"
#import "CSEncryptUntil.h"

#define NotificationConnectionDisconnect @"CM:ConnectionDisconnect"
#define NotificationConnectionDidConnect @"CM:ConnectionDidConnect"

@interface ChatClient : NSObject

@property (nonatomic, strong) NSMutableDictionary *managers;

- (BOOL)openDatabase;
- (BOOL)updateDatabase;
- (void)registerManagers;
- (BOOL)registerManager:(id <ChatClientProtocol>)manager forKey:(NSString *)key;
- (id <ChatClientProtocol>)managerForKey:(NSString *)key;


+ (void)addObserver:(id)observer selector:(SEL)selector forNotificationName:(NSString *)name;
+ (void)removeObserver:(id)observer forName:(NSString *)name;
+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;
+ (void)removeObserver:(id)observer;

+ (void)__failedWithResponse:(ChatMessage *)response reason:(NSString *)reason;
+ (void)__innerGetMessageIdWithRequest:(ChatMessage *)request toResponse:(ChatMessage *)response;
+ (void)__innerGetMessageIdWithResponse:(ChatMessage *)response toResponse:(ChatMessage *)receiveResponse;
@end
