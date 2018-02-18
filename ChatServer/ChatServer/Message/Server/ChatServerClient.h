//
//  ChatServerClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteHelper.h"
#import "ChatClient.h"
#import "ChatConnection.h"
#import "ChatServerProtocol.h"

#define ChatServerStringNotification @"ChatServerStringNotification"
#define ChatServerStringDidConnected @"ChatServerStringDidConnected"
#define ChatServerStringDidDisconnected @"ChatServerStringDidDisconnected"

#define CSServerString(key) NSLocalizedStringFromTable(key, @"ServerString", nil)
#define CSRegisterDatabase [[[ChatServerClient server] dbHelper] registerHelper]


@interface ChatServerClient : ChatClient <CSSocketDelegate>

+ (ChatServerClient *)server;

@property (nonatomic, strong, readonly) SqliteHelper *dbHelper;

+ (void)inDatabase:(void (^)(FMDatabase *db))database;
- (BOOL)beginListen:(NSUInteger)port;
- (void)endListen;

- (BOOL)registerManager:(id <ChatServerProtocol>)manager forKey:(NSString *)key;
- (id <ChatServerProtocol>)managerForKey:(NSString *)key;

@end
