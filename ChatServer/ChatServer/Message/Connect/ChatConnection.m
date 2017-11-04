//
//  ChatConnection.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatConnection.h"
#import "ChatConnectionReachable.h"

@interface ChatConnection () <CoreSocketDelegate>
@property (nonatomic, strong) CoreSocket *socket;
@end

@implementation ChatConnection

+ (void)initialize{
    [[ChatConnectionReachable defaultReachable] startMonitoring];
}

- (void)dealloc{
}

- (instancetype)init{
    if (self = [super init]) {
        [self __initSocket];
    }
    return self;
}

- (void)__initSocket{
    _socket = [[CoreSocket alloc] init];
    _socket.delegate = self;
}

- (void)sendMessage:(ChatMessage *)message{
    [_socket writeData:message.toMessage timeOut:10];
}

- (void)sendRequest:(ChatMessageRequest *)request{
    [self sendMessage:request];
}

- (void)sendResponse:(ChatMessageResponse *)response{
    [self sendResponse:response toConnection:nil];
}

- (void)sendResponse:(ChatMessageResponse *)response toConnection:(CoreSocketConnection *)connetion{
    if (connetion) {
        [_socket writeData:response.toMessage timeOut:10 socket:connetion.socketFD];
    }else{
        [_socket writeData:response.toMessage timeOut:10];
    }
}

- (void)sendResponseCode:(ChatResponseCode)responseCode toConnection:(CoreSocketConnection *)connetion{
    ChatMessageResponse *response = [[ChatMessageResponse alloc] init];
    response.responseCode = responseCode;
    if (!connetion) {
        connetion = self.connections.firstObject;
    }
    [self sendResponse:response toConnection:connetion];
}

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port timeout:(NSTimeInterval)timeout{
    NSData *address = [CoreSocket ipv4WithHost:host port:port];
    return [_socket connectToTheAddress:address timeOut:10 error:nil];
}
- (BOOL)acceptToPort:(NSInteger)port error:(NSError *__autoreleasing *)error{
    return [_socket acceptOnPort:port error:error];
}

- (void)disconnect{
    [_socket disconnect];
}

- (BOOL)disconnectOneconnection:(CoreSocketConnection *)connection{
    return [_socket disconnectSocket:connection.socketFD];
}

- (BOOL)serverDisconnect{
    return [_socket serverDisconnect];
}

- (NSArray *)connections{
    if (_clientType == ChatConnectionServer) {
        return _socket.connections;
    }
    return nil;
}

#pragma mark - CoreSocketDelegate
- (void)onCoreSocket:(CoreSocket *)socket receiveData:(CoreSocketReadPacket *)packet connection:(CoreSocketConnection *)connection{
    if ([self.delegate respondsToSelector:@selector(chatConnection:didReceiveData:progress:)]) {
        _currentConnection = connection;
        double progress = packet.offset / packet.totalBytes;
        [self.delegate chatConnection:self didReceiveData:packet.data progress:progress];
        _currentConnection = nil;
    }
}
- (void)onCoreSocket:(CoreSocket *)socket receiveDone:(CoreSocketReadPacket *)packet connection:(CoreSocketConnection *)connection{
    if ([self.delegate respondsToSelector:@selector(chatConnection:didReceiveDone:)]) {
        _currentConnection = connection;
        [self.delegate chatConnection:self didReceiveDone:packet.data];
        _currentConnection = nil;
    }
}

- (void)onCoreSocket:(CoreSocket *)socket readDidTimeOut:(CoreSocketReadPacket *)packet{
    NSLog(@"%@ : read timeout", packet);
}
- (void)onCoreSocket:(CoreSocket *)socket writeDidTimeOut:(CoreSocketWritePacket *)packet{
    NSLog(@"%@ : write timeout", packet);
}

- (void)onCoreSocket:(CoreSocket *)socket didConnectToTheHost:(NSString *)host port:(NSInteger)port connection:(CoreSocketConnection *)connection{
    if ([self.delegate respondsToSelector:@selector(chatConnection:didConnectToHost:)]) {
        _currentConnection = connection;
        _remoteIpAddress = [NSString stringWithFormat:@"%@:%@", host, @(port)];
        NSData *localAddress = [socket localAddress];
        NSString *localHost = [CoreSocket hostFromIPv4:localAddress];
        NSInteger localPort = [CoreSocket portFromIPv4:localAddress];
        _localIpAddress = [NSString stringWithFormat:@"%@:%@", localHost, @(localPort)];
        [self.delegate chatConnection:self didConnectToHost:_remoteIpAddress];
        _currentConnection = nil;
    }
}
- (void)onCoreSocket:(CoreSocket *)socket disConnectToTheHost:(NSString *)host port:(NSInteger)port error:(NSError *)error connection:(CoreSocketConnection *)connection{
    if ([self.delegate respondsToSelector:@selector(chatConnection:didDisconnectToHost:error:)]) {
        _currentConnection = connection;
        NSString *remoteAddress = [NSString stringWithFormat:@"%@:%@", host, @(port)];
        _remoteIpAddress = nil;
        _localIpAddress = nil;
        [self.delegate chatConnection:self didDisconnectToHost:remoteAddress error:error];
        _currentConnection = nil;
    }
}
@end
