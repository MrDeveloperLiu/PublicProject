//
//  CSConnectSocket.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/30.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSConnectSocket.h"

@interface CSConnectSocket ()
@property (nonatomic, strong) CSGCDTimer *connectTimer;
@end

@implementation CSConnectSocket

- (void)dealloc{
    [self clearAllSourceBySocket];
}

- (instancetype)init{
    return [self initWithAcceptSource:nil socket:0 delegate:nil];
}

- (instancetype)initWithAcceptSource:(CSGCDAccept *)accept socket:(int)socket delegate:(id<CSConnectSocketDelegate>)delegate{
    if (self = [super init]) {
        _acceptSource  = accept;
        _connections = [NSMutableDictionary dictionary];
        _delegate = delegate;
        _socket = socket;
        [self maybeInitAcceptSource];
    }
    return self;
}

- (void)maybeInitAcceptSource{
    if (_acceptSource != NULL) {
        //accept
        [self startAcceptSource];
    }else{
        //connect
        dispatch_queue_t queue = NULL;
        if ([self.delegate respondsToSelector:@selector(delegateQueue)]) {
            queue = [self.delegate delegateQueue];
        }
        if (queue == NULL) {
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        }

        _connectTimer = [[CSGCDTimer alloc] initWithTimeInterval:0 start:0 queue:queue];
        __weak __typeof(self) ws = self;
        [_connectTimer setEventBlock:^{
            [ws connetTimerDidTimeOut];
        }];
    }
}

- (CSConnection *)addConnectionWithAddress:(NSData *)address socket:(int)socket{
    CSSocketAddress *addr = [[CSSocketAddress alloc] initWithAddress:address socket:socket];
    CSConnection *connection = [[CSConnection alloc] initWithAddress:addr delegate:self.delegate];
    [self addConnection:connection];
    return connection;
}

- (void)connetTimerDidTimeOut{
    //call disconnect remove
    CSConnection *connection = self.allConnections.firstObject;
    if ([self.delegate respondsToSelector:@selector(connectSocket:connection:connectDidTimeoutToTheHost:port:)]) {
        [self.delegate connectSocket:self connection:connection
          connectDidTimeoutToTheHost:connection.address.host port:connection.address.port];
    }
    [self connetDidDisConnectedToTheSocket:connection.socketFD error:[CSSocketError connectTimeoutError:_connectTimer.startInterval]];
}

- (void)connetWillBeginToTheAddress:(NSData *)address socketFD:(int)socketFD{
    //add
    CSConnection *connection = [self addConnectionWithAddress:address socket:socketFD];
    if ([self.delegate respondsToSelector:@selector(connectSocket:connection:willBeginConnectToTheHost:port:)]) {
        [self.delegate connectSocket:self connection:connection
           willBeginConnectToTheHost:connection.address.host port:connection.address.port];
    }
}
- (void)setSocketSetting:(int)socket{
    //set socket option
    int result = fcntl(socket, F_SETFL, O_NONBLOCK);
    if (result == -1){
        CSLogE(@"fcntl() O_NONBLOCK fail");
    }
    //no sigpipe
    int nosigpipe = 1;
    result = setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    if (result == -1){
        CSLogE(@"setsockopt() SO_NOSIGPIPE fail");
    }
}
- (void)connetDidConnectedToTheSocket:(int)socket address:(NSData *)address accept:(BOOL)accept{
    //keep it
    CSConnection *connection = [self connectionForKey:[CSConnection connectionKey:socket]];
    connection.acceptConnection = accept;
    
    [self setSocketSetting:socket];
    
    //open read and write source
    [self setReadAndWriteSourceWithSocket:socket];

    if (accept && [self.delegate respondsToSelector:@selector(connectSocket:connection:didAcceptToTheHost:port:)]) {
        [self.delegate connectSocket:self connection:connection
                  didAcceptToTheHost:connection.address.host port:connection.address.port];
    }
    if ([self.delegate respondsToSelector:@selector(connectSocket:connection:didConnectToTheHost:port:)]) {
        [self.delegate connectSocket:self connection:connection
                 didConnectToTheHost:connection.address.host port:connection.address.port];
    }
}
- (void)connetDidDisConnectedToTheSocket:(int)socket error:(NSError *)error{
    //close all dispatch source
    CSConnection *connection = [self connectionForKey:[CSConnection connectionKey:socket]];
    if (!connection) {
        CSLogE(@"connection is nil socket - (%d) error : %@", socket, error);
        return;
    }
    //close read and write source first
    [connection closeReadAndWriteSource];
    if ([self.delegate respondsToSelector:@selector(connectSocket:connection:didDisConnectToTheHost:port:error:)]) {
        [self.delegate connectSocket:self connection:connection
              didDisConnectToTheHost:connection.address.host port:connection.address.port error:error];
    }
    //and remove it
    [self removeConnection:connection];
    [self closeSocket:socket];
}

- (BOOL)closeSocket:(int)socket{
    return close(socket);
}

- (void)clearAllSourceBySocket{
    if (_acceptSource != NULL) {//accept source
        [_acceptSource cancel];
    }
    if (_connectTimer) {
        [_connectTimer cancel];
    }
    [self closeSocket:_socket];//close socket
}

- (void)startConnectToAddress:(NSData *)address timeout:(NSTimeInterval)timeout{
    dispatch_queue_t queue = NULL;
    if ([self.delegate respondsToSelector:@selector(delegateQueue)]) {
        queue = [self.delegate delegateQueue];
    }
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    [_connectTimer setStartInterval:timeout];
    [_connectTimer setTimer];
    dispatch_async(queue, ^{
        [self connetWillBeginToTheAddress:address socketFD:_socket];
        [_connectTimer resume];//begin connect timer
        int result = connect(_socket, (const struct sockaddr *)address.bytes, (socklen_t)address.length);
        if (result == CSSocketErrorSuccess) {
            [self connetDidConnectedToTheSocket:_socket address:address accept:NO];
        }else{
            [self connetDidDisConnectedToTheSocket:_socket error:[CSSocketError connectError]];
        }
        [_connectTimer cancel];//end connect timer
    });
}

- (void)startAcceptSource{
    __weak __typeof (self) ws = self;
    dispatch_source_t accpet = ws.acceptSource.internal;
    int socketFD = ws.socket;
    [_acceptSource setEventBlock:^{
        unsigned long i = 0;
        unsigned long connections = dispatch_source_get_data(accpet);
        NSError *error = nil;
        while ([ws accept:socketFD error:&error] && ++i < connections) ;
        
        if (error) {
            CSLogE(@"accept source event error: %@", error.localizedDescription);
        }
    }];
    [_acceptSource resume];
}

- (BOOL)accept:(int)socketFD error:(NSError **)error{
    struct sockaddr_in address;
    socklen_t len = sizeof(address);
    //accept
    int childSocketFD = accept(socketFD, (struct sockaddr *)&address, &len);
    
    NSData *remoteAddress = [NSData dataWithBytes:&address length:sizeof(address)];
    [self connetWillBeginToTheAddress:remoteAddress socketFD:childSocketFD];

    if (childSocketFD == CSSocketErrorError) {
        *error = [CSSocketError acceptError];
        [self connetDidDisConnectedToTheSocket:childSocketFD error:[CSSocketError acceptError]]; //call disconnect
        return NO;
    }
    [self connetDidConnectedToTheSocket:childSocketFD address:remoteAddress accept:YES];
    return YES;
}

- (void)setReadAndWriteSourceWithSocket:(int)socket{
    CSConnection *connection = [self connectionForKey:[CSConnection connectionKey:socket]];
    //schudle read and write source with it's private queue
    [connection writeQueueSchedule];
    [connection readQueueSchedule];
}

// setter getter
- (void)setSocket:(int)socket{
    _socket = socket;
}

- (NSArray *)allConnections{
    return _connections.allValues;
}

- (NSArray *)allKeys{
    return _connections.allKeys;
}

- (void)addConnection:(CSConnection *)connection{
    NSNumber *key = [connection socketKey];
    if (!_connections[key]) {
        _connections[key] = connection;
    }
}
- (CSConnection *)connectionForKey:(NSNumber *)key{
    return _connections[key];
}
- (BOOL)removeConnection:(CSConnection *)connection{
    NSNumber *key = [connection socketKey];
    if (_connections[key]) {
        [_connections removeObjectForKey:key];
        return YES;
    }
    return NO;
}
- (BOOL)removeConnectionWithKey:(NSNumber *)key{
    if (_connections[key]) {
        [_connections removeObjectForKey:key];
        return YES;
    }
    return NO;
}
@end
