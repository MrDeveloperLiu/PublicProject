//
//  ChatConnection.h
//  ChatServer
//
//  Created by 刘杨 on 2018/1/16.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSocket.h"
#import "ChatMessage.h"

typedef enum : NSUInteger {
    ChatConnectionTypeClient = 1, //客户端
    ChatConnectionTypeServer      //服务
} ChatConnectionType;

@interface ChatConnection : NSObject

@property (nonatomic, assign, readonly) ChatConnectionType connectionType;
@property (nonatomic, strong, readonly) CSSocket *socket;

- (instancetype)initWithDelegate:(id)delegate type:(ChatConnectionType)type;

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port timeout:(NSTimeInterval)timeout;
- (BOOL)acceptToPort:(NSInteger)port error:(NSError **)error;

- (void)sendMessage:(ChatMessage *)message;

- (void)sendRequest:(ChatMessageRequest *)request;
- (void)sendResponse:(ChatMessageResponse *)response;

- (void)sendResponse:(ChatMessageResponse *)response toConnection:(CSConnection *)connetion;
- (void)sendResponseCode:(ChatResponseCode)responseCode toConnection:(CSConnection *)connetion;;

- (void)disconnect;
- (BOOL)disconnectConnection:(CSConnection *)connection;
@end
