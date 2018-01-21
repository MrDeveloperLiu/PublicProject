//
//  ChatConnection.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/16.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "ChatConnection.h"

@interface ChatConnection () <CSSocketDelegate>

@end

@implementation ChatConnection

- (void)dealloc{
    _statusBlock = nil;
    _progressBlock = nil;
    _dataBlock = nil;
    _writeTimeoutBlock = nil;
    _readTimeoutBlock = nil;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue type:(ChatConnectionType)type{
    self = [super init];
    if (self) {
        if (queue == NULL) {
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        }
        _socket = [[CSSocket alloc] initWithDelegate:self handleQueue:queue];
        _connectionType = type;
    }
    return self;
}

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port timeout:(NSTimeInterval)timeout{
    NSData *address = [CSSocketAddress ipv4WithHost:host port:port];
    return [_socket connectToTheAddress:address timeOut:timeout error:nil];
}
- (BOOL)acceptToPort:(NSInteger)port error:(NSError **)error{
    return [_socket acceptOnPort:port error:error];
}

- (void)sendMessage:(ChatMessage *)message{
    [_socket writeData:message.toMessage timeOut:10];
}

- (void)sendRequest:(ChatMessageRequest *)request{
    [_socket writeData:request.toMessage timeOut:10];
}
- (void)sendResponse:(ChatMessageResponse *)response{
    [_socket writeData:response.toMessage timeOut:10];
}

- (void)sendResponse:(ChatMessageResponse *)response toConnection:(CSConnection *)connetion{
    [_socket writeData:response.toMessage timeOut:10 socket:connetion.socketFD];
}
- (void)sendResponseCode:(ChatResponseCode)responseCode toConnection:(CSConnection *)connetion{
    ChatMessageResponse *response = [[ChatMessageResponse alloc] init];
    response.responseCode = responseCode;
    [_socket writeData:response.toMessage timeOut:10 socket:connetion.socketFD];
}

- (void)disconnect{
    [_socket disconnect];
}
- (BOOL)disconnectConnection:(CSConnection *)connection{
    return [_socket disconnectSocket:connection.socketFD];
}


- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection willBeginConnectToTheHost:(NSString *)host port:(NSString *)port{
    __weak __typeof (self) ws = self;
    if (self.statusBlock) {
        self.statusBlock(ws, connection, ChatConnectionStatusWillBeginConnected);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didConnectToTheHost:(NSString *)host port:(NSString *)port{
    __weak __typeof (self) ws = self;
    if (self.statusBlock) {
        self.statusBlock(ws, connection, ChatConnectionStatusDidConnected);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didDisConnectToTheHost:(NSString *)host port:(NSString *)port{
    __weak __typeof (self) ws = self;
    if (self.statusBlock) {
        self.statusBlock(ws, connection, ChatConnectionStatusDidDisconnected);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection connectDidTimeoutToTheHost:(NSString *)host port:(NSString *)port{
    __weak __typeof (self) ws = self;
    if (self.statusBlock) {
        self.statusBlock(ws, connection, ChatConnectionStatusDidTimeout);
    }
}
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didAcceptToTheHost:(NSString *)host port:(NSString *)port;
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeQueueDidSchedule:(CSGCDWrite *)writeSource;
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeQueueDidUnSchedule:(CSGCDWrite *)writeSource;
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readQueueDidSchedule:(CSGCDRead *)readSource;
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readQueueDidUnSchedule:(CSGCDRead *)readSource;
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readAndReadQueueDidOpened:(BOOL)opened;

- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection remoteShoudBeClosed:(CSSocketAddress *)remote{
    __weak __typeof (self) ws = self;
    if (self.statusBlock) {
        self.statusBlock(ws, connection, ChatConnectionStatusRemoteShouldBeClosed);
    }
}
//- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didWriteData:(NSData *)data;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didReadData:(NSData *)data progress:(double)progress{
    __weak __typeof (self) ws = self;
    if (self.progressBlock) {
        self.progressBlock(ws, connection, data, progress);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didReadDone:(NSData *)data{
    __weak __typeof (self) ws = self;
    if (self.dataBlock) {
        self.dataBlock(ws, connection, data);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout{
    __weak __typeof (self) ws = self;
    if (self.writeTimeoutBlock) {
        self.writeTimeoutBlock(ws, connection, (int)tag);
    }
}
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout{
    __weak __typeof (self) ws = self;
    if (self.readTimeoutBlock) {
        self.readTimeoutBlock(ws, connection, (int)tag);
    }
}
@end
