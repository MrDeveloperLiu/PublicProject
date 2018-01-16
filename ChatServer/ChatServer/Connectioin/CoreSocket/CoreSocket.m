//
//  CoreSocket.m
//  ChatServer
//
//  Created by Liu on 2017/10/15.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CoreSocket.h"
#import <sys/socket.h>
#import <arpa/inet.h>
#import <unistd.h>

#define LogTrace(fmt, ...) NSLog(@"[line: %d] (func: %s)- " fmt, __LINE__, __FUNCTION__, ##__VA_ARGS__)

//#define LogTrace(fmt, ...) CSLogS(fmt, ##__VA_ARGS__)

NSErrorDomain const CoreSocketConnectFailedError = @"CoreSocketConnectFailedError";
NSErrorDomain const CoreSocketCommonFailedError = @"CoreSocketCommonFailedError";

#define kReadMaxLen 1024
#define kReadTimeout 30

@interface CoreSocket () <CoreSocketConnectionDelegate> {
    
    dispatch_source_t _accept4Source;
    
    NSMutableData *_readData;
    
    dispatch_queue_t _socketQueue;

    dispatch_source_t _connectTimer;
    dispatch_source_t _writeTimer;
    dispatch_source_t _readTimer;
    
    CoreSocketReadPacket *_currentRead;
}

@property (nonatomic, assign) int socketFD;
@property (nonatomic, strong) NSMutableArray *sendDatas;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, CoreSocketConnection *>*acceptConnections;
@end

@implementation CoreSocket
- (void)dealloc{
}

- (NSArray<CoreSocketConnection *> *)connections{
    return _acceptConnections.allValues;
}

- (instancetype)init{
    if (self = [super init]) {
        _sendDatas = [NSMutableArray array];
        _socketQueue = dispatch_queue_create("socketQueue", DISPATCH_QUEUE_SERIAL);
        _acceptConnections = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - DISCONNECT
- (BOOL)disconnectLocalSocket{
    if (_socketFD > 0) {//如果当前是服务自己断开的链接
        if (_accept4Source) {//清除 接受源
            dispatch_source_cancel(_accept4Source);
        }
        close(_socketFD);
        LogTrace(@"local accept_source_cancel and close(%d) socket", _socketFD);
        _socketFD = -1;
        return YES;
    }
    return NO;
}

- (BOOL)allDisconnect{
    return [self serverDisconnect];
}

- (BOOL)serverDisconnect{
    for (CoreSocketConnection *connection in _acceptConnections.allValues) {
        dispatch_sync(_socketQueue, ^{
            [self doDidDisConnected:connection.socketFD address:connection.remoteAddress error:nil];
        });
    }
    LogTrace(@"disconnect all sockets");
    return [self disconnectLocalSocket];
}

- (BOOL)disconnect{
    CoreSocketConnection *connection = _acceptConnections.allValues.firstObject;
    if (!connection) {
        return NO;
    }
    [self doDidDisConnected:connection.socketFD
                    address:connection.remoteAddress
                      error:nil];
    return [self disconnectLocalSocket];
}

- (BOOL)disconnectSocket:(int)socketFD{
    CoreSocketConnection *connection = [self connectionObjectForKey:@(socketFD)];
    if (!connection) {
        return NO;
    }
    [self doDidDisConnected:connection.socketFD
                    address:connection.remoteAddress
                      error:nil];
    return YES;
}

#pragma mark - CONNECT
- (BOOL)connectToTheAddress:(NSData *)address timeOut:(NSTimeInterval)timeout error:(NSError **)error{
    LogTrace();
    [self allDisconnect];
    
    __block int socketFD;
    BOOL (^createBlock)()  = ^BOOL(){
        //create
        socketFD = socket(AF_INET, SOCK_STREAM, 0);
        if (socketFD == -1) {
            LogTrace(@"fail in socket()");
            return NO;
        }

        //set no sigpipe
        int nosigpipe = 1;
        setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
        
        LogTrace(@"create connect socket success");
        return YES;
    };
    
    if (!createBlock()) {
        return NO;
    }
    //record
    _socketFD = socketFD;
    
    __weak __typeof(self) ws = self;
    dispatch_async(_socketQueue, ^{
        [self setConnectTimer:timeout socket:socketFD];
        int connectRes = connect(socketFD, (const struct sockaddr *)address.bytes, (socklen_t)address.length);
        if (connectRes == 0) {//suc
            [ws doDidConnected:socketFD address:address];
        }else{//fail
            [ws doDidDisConnected:socketFD address:address error:[self connectFailedError]];
        }
        [self endConnectTimer];
    });
    
    //begin connect to the host
    LogTrace(@"begin connecting");

    return YES;
}
#pragma mark - ERRORS
- (NSError *)connectFailedError{
    return [NSError errorWithDomain:CoreSocketConnectFailedError
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey : @"Fail with connect() function"}];
}
- (NSError *)commonFailedErrorWithDesc:(NSString *)desc{
    return [NSError errorWithDomain:CoreSocketCommonFailedError
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey : desc}];
}

#pragma mark - TIMEOUT HANDLE
- (void)doConnectTimeoutSocket:(int)socketFD{
    [self endConnectTimer];
    CoreSocketConnection *connection = [self connectionObjectForKey:@(socketFD)];
    [self doDidDisConnected:socketFD
                    address:connection.remoteAddress
                      error:[self commonFailedErrorWithDesc:@"connection timeout"]];
}
- (void)doReadTimeoutSocket:(int)socketFD{
    [self endReadTimer];
    [self.delegate onCoreSocket:self readDidTimeOut:_currentRead];
    _currentRead = nil;
    CoreSocketConnection *connection = [self connectionObjectForKey:@(socketFD)];
    [self doDidDisConnected:socketFD
                    address:connection.remoteAddress
                      error:[self commonFailedErrorWithDesc:@"read timeout"]];
}
- (void)doWriteTimeoutSocket:(int)socketFD{
    [self endWriteTimer];
    CoreSocketWritePacket *writePacket = self.sendDatas.firstObject;
    [self.delegate onCoreSocket:self writeDidTimeOut:writePacket];
    [self.sendDatas removeObject:writePacket];
    
    CoreSocketConnection *connection = [self connectionObjectForKey:@(socketFD)];
    [self doDidDisConnected:socketFD
                    address:connection.remoteAddress
                      error:[self commonFailedErrorWithDesc:@"write timeout"]];
}
#pragma mark - TIMER
- (void)setConnectTimer:(NSTimeInterval)timeOut socket:(int)socketFD{
    __weak __typeof(self) ws = self;
    _connectTimer = [self beginTimerAfter:timeOut timeout:^{
        __strong __typeof(ws) ss = ws;
        [ss doConnectTimeoutSocket:socketFD];
    } cancel:^{
        _connectTimer = nil;
    }];
}
- (void)endConnectTimer{
    if (_connectTimer) {
        dispatch_source_cancel(_connectTimer);
    }
}
- (void)setReadTimer:(NSTimeInterval)timeOut socket:(int)socketFD{
    __weak __typeof(self) ws = self;
    _readTimer = [self beginTimerAfter:timeOut timeout:^{
        __strong __typeof(ws) ss = ws;
        [ss doReadTimeoutSocket:socketFD];
    } cancel:^{
        _readTimer = nil;
    }];
}
- (void)endReadTimer{
    if (_readTimer) {
        dispatch_source_cancel(_readTimer);
    }
}
- (void)setWriteTimer:(NSTimeInterval)timeOut socket:(int)socketFD{
    __weak __typeof(self) ws = self;
    _writeTimer = [self beginTimerAfter:timeOut timeout:^{
        __strong __typeof(ws) ss = ws;
        [ss doWriteTimeoutSocket:socketFD];
    } cancel:^{
        _writeTimer = nil;
    }];
}
- (void)endWriteTimer{
    if (_writeTimer) {
        dispatch_source_cancel(_writeTimer);
    }
}

- (dispatch_source_t)beginTimerAfter:(NSTimeInterval)time
                             timeout:(dispatch_block_t)timeoutBlock
                              cancel:(dispatch_block_t)cancelBlock{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0,
                                                     0,
                                                     _socketQueue);
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW,
                                            NSEC_PER_SEC * time),
                              0,
                              0);
    dispatch_source_set_event_handler(timer, timeoutBlock);
    dispatch_source_set_cancel_handler(timer, cancelBlock);
    dispatch_resume(timer);
    return timer;
}

#pragma mark - CLOSE
- (CoreSocketConnection *)disconnect:(int)sock{
    //移除即释放
    if (_connectTimer) {
        dispatch_source_cancel(_connectTimer);
    }
    if (_readTimer) {
        dispatch_source_cancel(_readTimer);
    }
    if (_writeTimer) {
        dispatch_source_cancel(_writeTimer);
    }
    
    CoreSocketConnection *connection = [self connectionObjectForKey:@(sock)];
    [connection destoryHandle];
    
    
    return connection;
}

#pragma mark - ACCEPT
- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError **)error{
    LogTrace();
    [self allDisconnect];
    
    int (^createBlock)(NSData *address) = ^int(NSData *address){
        //create
        int socketFD = socket(AF_INET, SOCK_STREAM, 0);
        if (socketFD == -1) {
            LogTrace(@"fail in socket()");
            return -1;
        }
        int result;
        //set socket option
        result = fcntl(socketFD, F_SETFL, O_NONBLOCK);
        if (result == -1) {
            NSString *desc = @"fail in fcntl()";
            LogTrace(@"%@", desc);
            [self doDidDisConnected:socketFD address:address
                              error:[self commonFailedErrorWithDesc:desc]];
            return -1;
        }
        //reuse
        int reuse = 1;
        result = setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
        if (result == -1) {
            NSString *desc = @"fail in setsockopt() - reuse addr";
            LogTrace(@"%@", desc);
            [self doDidDisConnected:socketFD address:address
                              error:[self commonFailedErrorWithDesc:desc]];
            return -1;
        }
        //bind
        result = bind(socketFD, (const struct sockaddr *)address.bytes, (socklen_t)address.length);
        if (result == -1) {
            NSString *desc = @"fail in bind()";
            LogTrace(@"%@", desc);
            [self doDidDisConnected:socketFD address:address
                              error:[self commonFailedErrorWithDesc:desc]];
            return -1;
        }
        //listen
        result = listen(socketFD, 1024);
        if (result == -1) {
            NSString *desc = @"fail in listen()";
            LogTrace(@"%@", desc);
            [self doDidDisConnected:socketFD address:address
                              error:[self commonFailedErrorWithDesc:desc]];
            return -1;
        }
        LogTrace(@"create accept socket success");
        return socketFD;
    };
    
    NSData *anyAddress = [[self class] anyIPv4AddressWithPort:port];
    int socket = createBlock(anyAddress);
    if (socket == -1) {
        return NO;
    }
    //record socket
    _socketFD = socket;

    _accept4Source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, socket, 0, _socketQueue);
    __weak __typeof(self) ws = self;
    dispatch_source_set_event_handler(_accept4Source, ^{
        __strong __typeof(ws) ss = ws;
        unsigned long i = 0;
        unsigned long connections = dispatch_source_get_data(_accept4Source);
        while ([ss doAccept:socket] && ++i < connections) ;
    });
    dispatch_source_set_cancel_handler(_accept4Source, ^{
        //do nothing
        _accept4Source = nil;
    });
    dispatch_resume(_accept4Source);
    
    return YES;
}

#pragma mark - CONNECT STATUS
#pragma Did Connect
- (BOOL)doDidConnected:(int)sockeFD address:(NSData *)address{
    
    //set socket option
    int result = fcntl(sockeFD, F_SETFL, O_NONBLOCK);
    if (result == -1){
        NSString *desc = @"fail in fcntl()";
        LogTrace(@"%@", desc);
        [self doDidDisConnected:sockeFD
                        address:address
                          error:[self commonFailedErrorWithDesc:desc]];
        return NO;
    }
    //no sigpipe
    int nosigpipe = 1;
    setsockopt(sockeFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    
    //set read and write
    CoreSocketConnection *c = [self doSetWriteAndReadEventHandlerWithSocketFD:sockeFD address:address];
    
    NSString *host = [[self class] hostFromIPv4:address];
    NSInteger port = [[self class] portFromIPv4:address];

    LogTrace(@"socket did connect (%@:%d)", host, (int)port);
    [self.delegate onCoreSocket:self didConnectToTheHost:host port:port connection:c];

    return YES;
}
#pragma Did DisConnect
- (void)doDidDisConnected:(int)sockFD address:(NSData *)address error:(NSError *)error{
    
    CoreSocketConnection *c = [self disconnect:sockFD];
    LogTrace(@"disconnect and remove ref socket(%d)", sockFD);
    [self removeConnectionForKey:@(sockFD)];
    
    NSString *host = [[self class] hostFromIPv4:address];
    NSInteger port = [[self class] portFromIPv4:address];

    LogTrace(@"socket did disconnected (%@:%d)", host, (int)port);
    [self.delegate onCoreSocket:self disConnectToTheHost:host port:port error:error connection:c];
    
}
#pragma Did Accept
- (BOOL)doAccept:(int)socketFD{
    LogTrace();
    //ipv4
    struct sockaddr_in address;
    socklen_t len = sizeof(address);
    //accept
    int childSocketFD = accept(socketFD, (struct sockaddr *)&address, &len);
    if (childSocketFD == -1) {
        LogTrace(@"fail in accept() fd = %d", socketFD);
        return NO;
    }
    
    NSData *remoteAddress = [NSData dataWithBytes:&address length:sizeof(address)];
    return [self doDidConnected:childSocketFD address:remoteAddress];
}

#pragma mark - delegate
- (void)onSocketConnection:(CoreSocketConnection *)connection readSourceDidHandle:(int)socketFD{
    //read
    unsigned long bytesAvaliable = dispatch_source_get_data(connection.readSource);
    if (bytesAvaliable == 0) {//应该是对方关闭了链接
        [self doDidDisConnected:socketFD
                        address:connection.remoteAddress
                          error:[self commonFailedErrorWithDesc:@"remote close() this connection"]];
        LogTrace(@"dispatch_source_get_data bytesAvaliable = 0, close current socket, do disconnect");
        return;
    }
    if (!self -> _currentRead) {
        self -> _currentRead = [[CoreSocketReadPacket alloc] initWithBytesAvaliable:bytesAvaliable
                                                                       readMaxLen:kReadMaxLen
                                                                          timeOut:kReadTimeout];
        [self setReadTimer:self -> _currentRead.timeOut socket:socketFD];
    }
    uint8_t *buffer = [self -> _currentRead readLength:bytesAvaliable];
    if (read(socketFD, buffer, self -> _currentRead.readLength)) {
        [self -> _currentRead readBuffer:buffer len:self -> _currentRead.readLength];
    }
    //read progress
    [self.delegate onCoreSocket:self receiveData:self -> _currentRead connection:connection];
    //read finish
    if (self -> _currentRead.finish) {
        [self endReadTimer];
        [self.delegate onCoreSocket:self receiveDone:self -> _currentRead connection:connection];
        self -> _currentRead = nil;
    }
}
- (void)onSocketConnection:(CoreSocketConnection *)connection writeSourceDidHandle:(int)socketFD{
    //write
    CoreSocketWritePacket *writePacket = self.sendDatas.firstObject;
    [self setWriteTimer:writePacket.timeOut socket:socketFD];
    
    uint8_t *buffer = (uint8_t *)[writePacket.data bytes];
    size_t bytesAvailable = writePacket.data.length;
    if (!bytesAvailable) {
        [self endWriteTimer];
        return;
    }
    ssize_t len = write(socketFD, buffer, bytesAvailable);
    if (len) {
        [self.sendDatas removeObject:writePacket];
        
        dispatch_suspend(connection.writeSource);
        [self endWriteTimer];
    }
    LogTrace(@"send : %ld", (long)len);
}

#pragma mark - SET READ AND WRITE
- (CoreSocketConnection *)doSetWriteAndReadEventHandlerWithSocketFD:(int)socketFD address:(NSData *)address{
    
    CoreSocketConnection *connection = [[CoreSocketConnection alloc] initWithSocketFD:socketFD
                                                                              address:address
                                                                             delegate:self];
    [self addConnection:connection forKey:@(socketFD)];
    
    dispatch_resume(connection.readSource);
    return connection;
}
#pragma mark - WRITE
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout{
    CoreSocketWritePacket *writePacket = [[CoreSocketWritePacket alloc] initWithData:data];
    writePacket.timeOut = timeout;
    [_sendDatas addObject:writePacket];
    
    //if one connection
    CoreSocketConnection *connection = _acceptConnections.allValues.firstObject;
    dispatch_resume(connection.writeSource);
}

- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout socket:(int)socketFD{
    CoreSocketWritePacket *writePacket = [[CoreSocketWritePacket alloc] initWithData:data];
    writePacket.timeOut = timeout;
    [_sendDatas addObject:writePacket];
    
    //if one connection
    CoreSocketConnection *connection = [self connectionObjectForKey:@(socketFD)];
    if (!connection) {
        [_sendDatas removeObject:writePacket];
        return;
    }
    dispatch_resume(connection.writeSource);
}


#pragma mark - CONNECTION STORE
- (BOOL)addConnection:(CoreSocketConnection *)connection forKey:(id)key{
    if (![_acceptConnections.allKeys containsObject:key]) {
        [_acceptConnections setObject:connection forKey:key];
        return YES;
    }
    return NO;
}
- (CoreSocketConnection *)connectionObjectForKey:(id)key{
    return _acceptConnections[key];
}
- (BOOL)removeConnectionForKey:(id)key{
    if ([_acceptConnections.allKeys containsObject:key]) {
        [_acceptConnections removeObjectForKey:key];
        return YES;
    }
    return NO;
}


#pragma mark - ADDRESS
+ (NSUInteger)portFromIPv4:(NSData *)ipv4{
    struct sockaddr_in *addr = (struct sockaddr_in *)ipv4.bytes;
    return ntohs(addr -> sin_port);
}
+ (NSString *)hostFromIPv4:(NSData *)ipv4{
    struct sockaddr_in *addr = (struct sockaddr_in *)ipv4.bytes;
    const char *host = inet_ntoa(addr -> sin_addr);
    if (!host) {
        return nil;
    }
    return [NSString stringWithUTF8String:host];
}
+ (NSData *)ipv4WithHost:(NSString *)host port:(NSUInteger)port{
    const char *hostChar = host.UTF8String;
    if (!hostChar) {
        return nil;
    }
    struct sockaddr_in          addr;
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_family             = AF_INET;
    addr.sin_port               = htons(port);
    addr.sin_addr.s_addr        = inet_addr(hostChar);
    addr.sin_len                = sizeof(addr);
    
    return [NSData dataWithBytes:&addr length:sizeof(addr)];
}
+ (NSData *)anyIPv4AddressWithPort:(NSUInteger)port{
    struct sockaddr_in          addr;
    memset(&addr, 0, sizeof(addr));

    addr.sin_family             = AF_INET;
    addr.sin_port               = htons(port);
    addr.sin_addr.s_addr        = htonl(INADDR_ANY);
    addr.sin_len                = sizeof(addr);
     
    return [NSData dataWithBytes:&addr length:sizeof(addr)];
}
+ (NSData *)localAddressWithSocket:(int)socketFD{
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    
    socklen_t len;
    int ret = getsockname(socketFD, (struct sockaddr *)&addr, &len);
    if (0 == ret) {
        
    }else{
    
    }
    return [NSData dataWithBytes:&addr length:len];
}
- (NSData *)localAddress{
    return [[self class] localAddressWithSocket:_socketFD];
}
@end
