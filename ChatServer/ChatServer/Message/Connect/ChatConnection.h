//
//  ChatConnection.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import <CoreFoundation/CoreFoundation.h>
#import "CoreSocket.h"
#import "ChatMessage.h"

typedef enum {
    ChatConnectionServer = 0x01,
    ChatConnectionClient
} ChatConnectionType;

@protocol ChatConnectionDelegate;
@interface ChatConnection : NSObject

@property (nonatomic, strong, readonly) NSString *localIpAddress;
@property (nonatomic, strong, readonly) NSString *remoteIpAddress;
@property (nonatomic, assign, readonly) ChatConnectionType clientType;
@property (nonatomic, assign, readonly) NSArray <CoreSocketConnection *> *connections;

@property (nonatomic, weak, readonly) CoreSocketConnection *currentConnection;

@property (nonatomic, weak) id <ChatConnectionDelegate> delegate;

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port timeout:(NSTimeInterval)timeout;
- (BOOL)acceptToPort:(NSInteger)port error:(NSError **)error;

- (void)sendMessage:(ChatMessage *)message;

- (void)sendRequest:(ChatMessageRequest *)request;
- (void)sendResponse:(ChatMessageResponse *)response;

- (void)sendResponse:(ChatMessageResponse *)response toConnection:(CoreSocketConnection *)connetion;
- (void)sendResponseCode:(ChatResponseCode)responseCode toConnection:(CoreSocketConnection *)connetion;;

- (void)disconnect;
- (BOOL)disconnectOneconnection:(CoreSocketConnection *)connection;
- (BOOL)serverDisconnect;
@end

@protocol ChatConnectionDelegate <NSObject>
@optional
- (void)chatConnection:(ChatConnection *)connection didConnectToHost:(NSString *)host;
- (void)chatConnection:(ChatConnection *)connection didDisconnectToHost:(NSString *)host error:(NSError *)error;

- (void)chatConnection:(ChatConnection *)connection didReceiveData:(NSData *)data progress:(double)progress;
- (void)chatConnection:(ChatConnection *)connection didReceiveDone:(NSData *)response;
@end
