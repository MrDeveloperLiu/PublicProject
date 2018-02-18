//
//  ChatClientProtocol.h
//  ChatServer
//
//  Created by 刘杨 on 2018/2/10.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSEncryptUntil.h"
#import "ChatMessage.h"
#import "CSUserDefaultStore.h"

@class ChatMessage, CSConnection, ChatConnection;
@protocol ChatClientProtocol <NSObject>

- (BOOL)onHandleServerRequest:(ChatMessage *)request connection:(ChatConnection *)connection socket:(CSConnection *)socket;
- (BOOL)openDatabase;
- (BOOL)updateDatabase;
- (NSString *)tableName;
- (NSInteger)datebaseVersion;

@end
