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

#define CSServerString(key) NSLocalizedStringFromTable(key, @"ServerString", nil)

#define ChatServerStringNotification @"ChatServerStringNotification"
#define ChatServerStringDidConnected @"ChatServerStringDidConnected"
#define ChatServerStringDidDisconnected @"ChatServerStringDidDisconnected"

@interface ChatServerClient : ChatClient <CSSocketDelegate>

+ (ChatServerClient *)server;

@property (nonatomic, strong, readonly) SqliteHelper *dbHelper;

- (BOOL)beginListen:(NSUInteger)port;
- (void)endListen;

@end
