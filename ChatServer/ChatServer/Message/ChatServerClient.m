//
//  ChatServerClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatServerClient.h"

@interface ChatServerClient ()
@property (nonatomic, strong) SqliteHelper *dbHelper;
@property (nonatomic, strong) ChatConnection *connection;
@end

@implementation ChatServerClient

+ (ChatServerClient *)server{
    static ChatServerClient *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ChatServerClient alloc] init];
    });
    return _instance;
}

- (ChatConnection *)connection{
    if (!_connection) {
        _connection = [[ChatConnection alloc] init];
        _connection.delegate = self;
    }
    return _connection;
}

- (BOOL)beginListenToThePort:(NSInteger)port{
    return [self.connection acceptToPort:port error:nil];
}

- (BOOL)endListen{
    return [self.connection serverDisconnect];
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
    
    if ([[request method] isEqualToString:ChatRequestMethodPOST]) {
        [ChatClient postNotificationName:@"IMAGE" object:[request bodyData] userInfo:nil];
    }else if ([[request method] isEqualToString:ChatRequestMethodGET]) {
        
    }
    //send OK
    [connection sendResponseCode:ChatResponseOK toConnection:connection.currentConnection];
}

- (void)onHandleResponseMessage:(ChatMessageResponse *)response connection:(ChatConnection *)connection{
    
}

- (void)onHandleMessage:(ChatMessage *)message connection:(ChatConnection *)connection{
    
}

@end
