//
//  ChatiPhoneClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatiPhoneClient.h"

@interface ChatiPhoneClient ()
@property (nonatomic, strong) ChatConnection *connection;
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@end

@implementation ChatiPhoneClient

+ (ChatiPhoneClient *)iPhone{
    static ChatiPhoneClient *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ChatiPhoneClient alloc] init];
    });
    return _instance;
}

- (NSOperationQueue *)requestQueue{
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 10;
    }
    return _requestQueue;
}

- (ChatConnection *)connection{
    if (!_connection) {
        _connection = [[ChatConnection alloc] init];
        _connection.delegate = self;
    }
    return _connection;
}

- (CSTcpRequest *)tcpRequestWithChatMessageRequest:(ChatMessageRequest *)request{
    CSTcpRequestOperation *operation = [[CSTcpRequestOperation alloc] initWithRequest:request];
    CSTcpRequest *retVal = [[CSTcpRequest alloc] initWithCSTcpRequestOperation:operation];
    return retVal;
}

- (BOOL)connectToTheHost:(NSString *)host port:(NSInteger)port{
    return [self.connection connectToHost:host port:port timeout:10];
}

- (void)disconnect{
    [self.connection disconnect];
}

- (void)chatConnection:(ChatConnection *)connection didDisconnectToHost:(NSString *)host error:(NSError *)error{
    [[self class] postNotificationName:NotificationConnectionDisconnect object:error userInfo:@{
                                                                                              @"address" : host
                                                                                              }];
}
- (void)chatConnection:(ChatConnection *)connection didConnectToHost:(NSString *)host{
    [[self class] postNotificationName:NotificationConnectionDidConnect object:nil userInfo:@{
                                                                                              @"address" : host
                                                                                              }];
}
- (void)chatConnection:(ChatConnection *)connection didReceiveData:(NSData *)data progress:(double)progress{
    
}
- (void)chatConnection:(ChatConnection *)connection didReceiveDone:(NSData *)data{
    ChatMessage *message = [[ChatMessage alloc] initWithData:data];
    //reveive Message
    if ([[message chatMessageType] isEqualToString:ChatRequestMessage]) {
        ChatMessageRequest *request = [[ChatMessageRequest alloc] initWithData:data];
        [self onHandleRequestMessage:request connection:connection];
    }else if ([[message chatMessageType] isEqualToString:ChatResponseMessage]) {
        ChatMessageResponse *response = [[ChatMessageResponse alloc] initWithData:data];
        [self onHandleResponseMessage:response connection:connection];
    }else{
        //message
        [self onHandleMessage:message connection:connection];
    }
}


- (void)onHandleRequestMessage:(ChatMessageRequest *)request connection:(ChatConnection *)connection{
    
    //send OK
    [connection sendResponseCode:ChatResponseOK toConnection:connection.currentConnection];
}

- (void)onHandleResponseMessage:(ChatMessageResponse *)response connection:(ChatConnection *)connection{
    
}

- (void)onHandleMessage:(ChatMessage *)message connection:(ChatConnection *)connection{
    
}


@end
