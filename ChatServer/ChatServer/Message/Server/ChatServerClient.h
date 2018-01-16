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
#import "CSSocket.h"

#define CSServerString(key) NSLocalizedStringFromTable(key, @"ServerString", nil)

@interface ChatServerClient : ChatClient <CSSocketDelegate>

+ (ChatServerClient *)server;

@property (nonatomic, strong, readonly) SqliteHelper *dbHelper;

- (BOOL)beginListenToThePort:(NSInteger)port;
- (BOOL)endListen;
@end
