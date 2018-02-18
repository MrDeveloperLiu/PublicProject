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

@class ChatConnection;
typedef enum : NSUInteger {
    ChatConnectionTypeClient = 1, //客户端
    ChatConnectionTypeServer      //服务
} ChatConnectionType;

typedef enum : NSUInteger {
    ChatConnectionStatusWillBeginConnected = 1,
    ChatConnectionStatusDidConnected,
    ChatConnectionStatusDidDisconnected,
    ChatConnectionStatusDidTimeout,
    ChatConnectionStatusRemoteShouldBeClosed
} ChatConnectionStatus;

typedef void(^ChatConnectionStatusBlock)(ChatConnection *connection, CSConnection *socket, ChatConnectionStatus status);
typedef void(^ChatConnectionProgressBlock)(ChatConnection *connection, CSConnection *socket, NSData *data, double progress);
typedef void(^ChatConnectionDataBlock)(ChatConnection *connection, CSConnection *socket, NSData *data);
typedef void(^ChatConnectionWriteTimeoutBlock)(ChatConnection *connection, CSConnection *socket, int tag);
typedef void(^ChatConnectionReadTimeoutBlock)(ChatConnection *connection, CSConnection *socket, int tag);


@interface ChatConnection : NSObject

@property (nonatomic, assign, readonly) ChatConnectionType connectionType;
@property (nonatomic, strong, readonly) CSSocket *socket;

@property (nonatomic, copy) ChatConnectionStatusBlock statusBlock;
@property (nonatomic, copy) ChatConnectionProgressBlock progressBlock;
@property (nonatomic, copy) ChatConnectionDataBlock dataBlock;
@property (nonatomic, copy) ChatConnectionWriteTimeoutBlock writeTimeoutBlock;
@property (nonatomic, copy) ChatConnectionReadTimeoutBlock readTimeoutBlock;

- (instancetype)initWithQueue:(dispatch_queue_t)queue type:(ChatConnectionType)type;

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port timeout:(NSTimeInterval)timeout;
- (BOOL)acceptToPort:(NSInteger)port error:(NSError **)error;

- (void)sendMessage:(ChatMessage *)message;

- (void)sendRequest:(ChatMessage *)request;
- (void)sendResponse:(ChatMessage *)response;

- (void)sendResponse:(ChatMessage *)response toConnection:(CSConnection *)connetion;
- (void)sendResponseCode:(ChatResponseCode)responseCode toConnection:(CSConnection *)connetion;
- (void)sendResponseCode:(ChatResponseCode)responseCode addMessageId:(ChatMessage *)request toConnection:(CSConnection *)connetion;
- (void)sendResponseErrorReason:(NSString *)reason toConnection:(CSConnection *)connetion;

- (void)disconnect;
- (BOOL)disconnectConnection:(CSConnection *)connection;
@end
