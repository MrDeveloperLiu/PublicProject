//
//  CSSocket.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSSocket.h"

@interface CSSocket () <CSConnectSocketDelegate, CSConnectionDelegate>
@property (nonatomic, strong) CSConnectSocket *connectionSocket;
@end

@implementation CSSocket

- (instancetype)initWithDelegate:(id <CSSocketDelegate>)delegate handleQueue:(dispatch_queue_t)queue{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _socketQueue = queue;
    }
    return self;
}

- (BOOL)connectToTheAddress:(NSData *)address timeOut:(NSTimeInterval)timeout error:(NSError **)error{
    if (_connectionSocket) {
        CSLogE(@"_connectionSocket already has been create with - connect func");
        return NO;
    }
    //create
    int socketFD = socket(AF_INET, SOCK_STREAM, 0);
    if (socketFD == CSSocketErrorError) {
        *error = [CSSocketError createSocketError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    //set no sigpipe
    int nosigpipe = 1;
    int result = setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    if (result == CSSocketErrorError) {
        *error = [CSSocketError nosigpipeError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }

    _connectionSocket = [[CSConnectSocket alloc] initWithAcceptSource:nil socket:socketFD delegate:self];
    [_connectionSocket startConnectToAddress:address timeout:timeout];
    CSLogI(@"create connect source to the address : %@", [CSSocketAddress ipv4ToString:address]);
    return YES;
}

- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError **)error{
    if (_connectionSocket) {
        CSLogE(@"_connectionSocket already has been create with - accept func");
        return NO;
    }
    NSData *address = [CSSocketAddress anyIPv4AddressWithPort:port];
    //create
    int socketFD = socket(AF_INET, SOCK_STREAM, 0);
    if (socketFD == CSSocketErrorError) {
        *error = [CSSocketError createSocketError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    int result;
    //set socket option
    result = fcntl(socketFD, F_SETFL, O_NONBLOCK);
    if (result == CSSocketErrorError) {
        *error = [CSSocketError nonBlockError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    //reuse
    int reuse = 1;
    result = setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    if (result == CSSocketErrorError) {
        *error = [CSSocketError reuseAddressError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    //bind
    result = bind(socketFD, (const struct sockaddr *)address.bytes, (socklen_t)address.length);
    if (result == CSSocketErrorError) {
        *error = [CSSocketError bindError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    //listen
    result = listen(socketFD, 1024);
    if (result == CSSocketErrorError) {
        *error = [CSSocketError listenError];
        CSLogE(@"%@", [(* error) localizedDescription]);
        return NO;
    }
    CSGCDAccept *accept = [[CSGCDAccept alloc] initWithSocket:socketFD queue:_socketQueue];
    _connectionSocket = [[CSConnectSocket alloc] initWithAcceptSource:accept socket:socketFD delegate:self];
    CSLogS(@"create accept source on address : %@", [CSSocketAddress ipv4ToString:address]);
    return YES;
}
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout{
    CSConnection *connection = _connectionSocket.allConnections.firstObject;
    if (!connection) {
        return;
    }
    [connection write:data timeout:timeout];
}
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout socket:(int)socketFD{
    CSConnection *connection = [_connectionSocket connectionForKey:[CSConnection connectionKey:socketFD]];
    if (!connection) {
        return;
    }
    [connection write:data timeout:timeout];
}

- (BOOL)disconnect{
    if (_connectionSocket.acceptSource) {//accept
        CSLogS(@"all disconnect");
        for (CSConnection *connection in _connectionSocket.allConnections) {
            [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                          error:[CSSocketError disconnectError]];
            [_connectionSocket removeConnection:connection];
        }
    }else{
        CSConnection *connection = _connectionSocket.allConnections.firstObject;
        [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                      error:[CSSocketError disconnectError]];
        CSLogS(@"disconnect : %@", connection);
        [_connectionSocket removeConnection:connection];
    }
    if (!_connectionSocket.allKeys.count) {
        [_connectionSocket clearAllSourceBySocket];
        _connectionSocket = nil;
    }
    return YES;
}
- (BOOL)disconnectSocket:(int)socketFD{
    CSConnection *connection = [_connectionSocket connectionForKey:[CSConnection connectionKey:socketFD]];
    [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                  error:[CSSocketError disconnectError]];
    CSLogS(@"disconnect : %@", connection);
    [_connectionSocket removeConnection:connection];
    if (!_connectionSocket.allKeys.count) {
        [_connectionSocket clearAllSourceBySocket];
        _connectionSocket = nil;
    }
    return YES;
}

//delegate

- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection willBeginConnectToTheHost:(NSString *)host port:(NSString *)port{
    CSLogS(@"socket address : host - %@ port - %@", host, port);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:willBeginConnectToTheHost:port:)]) {
        [self.delegate onSocket:self connection:connection willBeginConnectToTheHost:host port:port];
    }
}
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didConnectToTheHost:(NSString *)host port:(NSString *)port{
    CSLogS(@"socket address : host - %@ port - %@", host, port);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didConnectToTheHost:port:)]) {
        [self.delegate onSocket:self connection:connection didConnectToTheHost:host port:port];
    }
}
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didDisConnectToTheHost:(NSString *)host port:(NSString *)port error:(NSError *)error{
    CSLogS(@"socket address : host - %@ port - %@", host, port);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didDisConnectToTheHost:port:)]) {
        [self.delegate onSocket:self connection:connection didDisConnectToTheHost:host port:port];
    }
}
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection connectDidTimeoutToTheHost:(NSString *)host port:(NSString *)port{
    CSLogS(@"socket address : host - %@ port - %@", host, port);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:connectDidTimeoutToTheHost:port:)]) {
        [self.delegate onSocket:self connection:connection connectDidTimeoutToTheHost:host port:port];
    }
}

- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didAcceptToTheHost:(NSString *)host port:(NSString *)port{
    CSLogS(@"socket address : host - %@ port - %@", host, port);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didAcceptToTheHost:port:)]) {
        [self.delegate onSocket:self connection:connection didAcceptToTheHost:host port:port];
    }
}

//connection delegate
- (dispatch_queue_t)delegateQueue{
    return self.socketQueue;
}
- (void)connection:(CSConnection *)connection writeQueueDidSchedule:(CSGCDWrite *)writeSource{
    CSLogS(@"writeSource did schedule : %@", connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:writeQueueDidSchedule:)]) {
        [self.delegate onSocket:self connection:connection writeQueueDidSchedule:writeSource];
    }
}
- (void)connection:(CSConnection *)connection writeQueueDidUnSchedule:(CSGCDWrite *)writeSource{
    CSLogS(@"writeSource did unschedule : %@", connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:writeQueueDidUnSchedule:)]) {
        [self.delegate onSocket:self connection:connection writeQueueDidUnSchedule:writeSource];
    }
}
- (void)connection:(CSConnection *)connection readQueueDidSchedule:(CSGCDRead *)readSource{
    CSLogS(@"readSource did schedule : %@", connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:readQueueDidSchedule:)]) {
        [self.delegate onSocket:self connection:connection readQueueDidSchedule:readSource];
    }
}
- (void)connection:(CSConnection *)connection readQueueDidUnSchedule:(CSGCDRead *)readSource{
    CSLogS(@"readSource did unschedule : %@", connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:readQueueDidUnSchedule:)]) {
        [self.delegate onSocket:self connection:connection readQueueDidUnSchedule:readSource];
    }
}
- (void)connection:(CSConnection *)connection readAndReadQueueDidOpened:(BOOL)opened{
    CSLogS(@"readSource and writeSource did opened (%@) : %@", @(opened), connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:readAndReadQueueDidOpened:)]) {
        [self.delegate onSocket:self connection:connection readAndReadQueueDidOpened:opened];
    }
}

- (void)connection:(CSConnection *)connection remoteShoudBeClosed:(CSSocketAddress *)remote{
    CSLogS(@"remote shoud be closed : %@", connection);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:remoteShoudBeClosed:)]) {
        [self.delegate onSocket:self connection:connection remoteShoudBeClosed:remote];
    }
    [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                  error:[CSSocketError remoteDisconnectError]];
    [_connectionSocket removeConnection:connection];
}
- (void)connection:(CSConnection *)connection didWriteData:(NSData *)data{
    CSLogS(@"did send data : %@ - len: %ld", connection, data.length);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didWriteData:)]) {
        [self.delegate onSocket:self connection:connection didWriteData:data];
    }
}

- (void)connection:(CSConnection *)connection didReadData:(NSData *)data progress:(double)progress{
    CSLogS(@"receive data : %@ - len: %ld progress : (%f)", connection, data.length, progress);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didReadData:progress:)]) {
        [self.delegate onSocket:self connection:connection didReadData:data progress:progress];
    }
}
- (void)connection:(CSConnection *)connection didReadDone:(NSData *)data{
    CSLogS(@"receive data done : %@ - len: %ld", connection, data.length);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:didReadDone:)]) {
        [self.delegate onSocket:self connection:connection didReadDone:data];
    }
}

- (void)connection:(CSConnection *)connection writeDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout{
    CSLogS(@"write data timeout (%f) : %@ tag - : %ld", timeout, connection, tag);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:writeDidTimeout:timeout:)]) {
        [self.delegate onSocket:self connection:connection writeDidTimeout:tag timeout:timeout];
    }
    [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                  error:[CSSocketError writeTimeoutError:timeout]];
    [_connectionSocket removeConnection:connection];
}
- (void)connection:(CSConnection *)connection readDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout{
    CSLogS(@"read data timeout (%f) : %@ tag - : %ld", timeout, connection, tag);
    if ([self.delegate respondsToSelector:@selector(onSocket:connection:readDidTimeout:timeout:)]) {
        [self.delegate onSocket:self connection:connection readDidTimeout:tag timeout:timeout];
    }
    [_connectionSocket connetDidDisConnectedToTheSocket:connection.socketFD
                                                  error:[CSSocketError readTimeoutError:timeout]];
    [_connectionSocket removeConnection:connection];
}

@end
