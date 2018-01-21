//
//  CSTcpRequestOperation.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSTcpRequestOperation.h"

@interface CSTcpRequestOperation ()
@property (nonatomic, strong) CSGCDTimer *timer;
@property (nonatomic, strong) ChatMessageRequest *request;
@property (nonatomic, strong) ChatConnection *connection;
@end

@implementation CSTcpRequestOperation

- (void)dealloc{
    [self.timer cancel];
    _progressBlock = nil;
    _finshedBlock = nil;
    _failedBlock = nil;
}

- (instancetype)initWithRequest:(ChatMessageRequest *)request{
    if (self = [super init]) {
        _request = request;
        _connection = [[ChatConnection alloc] initWithQueue:nil type:ChatConnectionTypeClient];
        __weak __typeof (self) ws = self;
        [_connection setDataBlock:^(ChatConnection *connection, CSConnection *socket, NSData *data) {
            [ws connection:connection socket:socket data:data];
        }];
        [_connection setProgressBlock:^(ChatConnection *connection, CSConnection *socket, NSData *data, double progress) {
            [ws connection:connection socket:socket data:data progress:progress];
        }];
        [_connection setStatusBlock:^(ChatConnection *connection, CSConnection *socket, ChatConnectionStatus status) {
            [ws connection:connection socket:socket status:status];
        }];
        
        NSTimeInterval timeout = 60.0;
        _timer = [[CSGCDTimer alloc] initWithTimeInterval:timeout start:timeout queue:nil];
        [_timer setEventBlock:^{
            [ws onTimeout];
        }];
    }
    return self;
}

- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket status:(ChatConnectionStatus)status{
    if (status == ChatConnectionStatusDidConnected) {
        [connection sendRequest:_request];
    }else if (status == ChatConnectionStatusDidDisconnected){
        [self.timer cancel];
        self.failedBlock = nil;
        self.progressBlock = nil;
        self.failedBlock = nil;
        self.finished = YES;
    }
}
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data{
    ChatMessageResponse *resp = [[ChatMessageResponse alloc] initWithData:data];
    [self callFinish:resp];
    [_connection disconnect];
}
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data progress:(double)progress{
    if (self.progressBlock) {
        self.progressBlock(self, data, progress);
    }
}

- (void)start{
    [super start];
    
    NSString *host = [CSUserDefaultStore host];
    NSInteger port = [CSUserDefaultStore port];
    if (host && port) {
        [_connection connectToHost:host port:port timeout:10];
        [self beginCurrentTimer];
    }else{
        [self callError:[NSError errorWithDomain:@"host and port nil" code:0 userInfo:nil]];
    }
}
- (void)callError:(NSError *)error{
    if (self.failedBlock) {
        self.failedBlock(self, error);
        self.failedBlock = nil;
    }
    self.finished = YES;
}
- (void)callFinish:(ChatMessageResponse *)resp{
    if (self.finshedBlock) {
        self.finshedBlock(self, resp);
        self.finshedBlock = nil;
    }
}

- (void)onTimeout{
    [self.timer cancel];
    [self callError:[NSError errorWithDomain:@"connection timeout" code:0 userInfo:nil]];
}

- (void)beginCurrentTimer{
    [self.timer resume];
}
@end
