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
@property (nonatomic, strong) dispatch_queue_t socketQueue;
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

- (instancetype)init{
    self = [super init];
    if (self) {
        _socketQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String],
                                             DISPATCH_QUEUE_CONCURRENT);
        _connection = [[ChatConnection alloc] initWithQueue:_socketQueue type:ChatConnectionTypeClient];
        
        __weak __typeof (self) ws = self;
        [_connection setDataBlock:^(ChatConnection *connection, CSConnection *socket, NSData *data) {
            [ws connection:connection socket:socket data:data];
        }];
        /*
        [_connection setProgressBlock:^(ChatConnection *connection, CSConnection *socket, NSData *data, double progress) {
            [ws connection:connection socket:socket data:data progress:progress];
        }];
         */
        [_connection setStatusBlock:^(ChatConnection *connection, CSConnection *socket, ChatConnectionStatus status) {
            [ws connection:connection socket:socket status:status];
        }];

    }
    return self;
}

- (BOOL)beginListen:(NSUInteger)port{
    return [_connection acceptToPort:port error:nil];
}
- (void)endListen{
    [_connection disconnect];
}

- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket status:(ChatConnectionStatus)status{
    if (status == ChatConnectionStatusDidConnected) {
        [ChatClient postNotificationName:ChatServerStringNotification
                                  object:nil userInfo:@{@"method" : ChatServerStringDidConnected,
                                                        @"connection" : socket}];
    }else if (status == ChatConnectionStatusDidDisconnected){
        [ChatClient postNotificationName:ChatServerStringNotification
                                  object:nil userInfo:@{@"method" : ChatServerStringDidDisconnected,
                                                        @"connection" : socket}];
    }
}
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data{
    ChatMessageRequest *request = [[ChatMessageRequest alloc] initWithData:data];
    CSLogI(@"server: %@", request);
    [connection sendResponseCode:ChatResponseOK toConnection:socket];
}
/*
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data progress:(double)progress{

}
*/

@end
