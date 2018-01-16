//
//  ChatiPhoneClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatClient.h"
#import "CSTcpRequest.h"
#import "ChatiPhoneCallbackProtocol.h"
#import "CSSocket.h"

#define CSIPhoneString(key) NSLocalizedStringFromTable(key, @"iPhoneString", nil)


@interface ChatiPhoneClient : ChatClient <CSSocketDelegate>


@property (nonatomic, strong, readonly) NSOperationQueue *requestQueue;

- (BOOL)connectToTheHost:(NSString *)host port:(NSInteger)port;
- (void)disconnect;

- (CSTcpRequest *)tcpRequestWithChatMessageRequest:(ChatMessageRequest *)request;

- (void)doLoginWithRequest:(ChatMessageRequest *)request completion:(id <ChatiPhoneCallbackProtocol>)completion;
- (void)doLogoffWithRequest:(ChatMessageRequest *)request completion:(id <ChatiPhoneCallbackProtocol>)completion;
@end
