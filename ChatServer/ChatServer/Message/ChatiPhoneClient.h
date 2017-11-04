//
//  ChatiPhoneClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatClient.h"
#import "ChatConnection.h"
#import "CSTcpRequest.h"

@interface ChatiPhoneClient : ChatClient <ChatConnectionDelegate>

@property (nonatomic, strong, readonly) ChatConnection *connection;
@property (nonatomic, strong, readonly) NSOperationQueue *requestQueue;

- (BOOL)connectToTheHost:(NSString *)host port:(NSInteger)port;
- (void)disconnect;

- (CSTcpRequest *)tcpRequestWithChatMessageRequest:(ChatMessageRequest *)request;
@end
