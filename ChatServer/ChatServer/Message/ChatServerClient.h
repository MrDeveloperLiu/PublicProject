//
//  ChatServerClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteHelper.h"
#import "ChatConnection.h"
#import "ChatClient.h"


@interface ChatServerClient : ChatClient <ChatConnectionDelegate>

+ (ChatServerClient *)server;

@property (nonatomic, strong, readonly) SqliteHelper *dbHelper;

@property (nonatomic, strong, readonly) ChatConnection *connection;

- (BOOL)beginListenToThePort:(NSInteger)port;
- (BOOL)endListen;
@end
