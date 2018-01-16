//
//  ChatiPhoneClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatiPhoneClient.h"
#import "ChatiPhoneTask.h"

@interface ChatiPhoneClient ()
@property (nonatomic, strong) CSSocket *socket;
@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) NSOperationQueue *requestQueue;

@property (nonatomic, strong) NSMutableArray *requestTasks;
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

- (CSSocket *)socket{
    if (!_socket) {
        _socketQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String],
                                             DISPATCH_QUEUE_CONCURRENT);
        _socket = [[CSSocket alloc] initWithDelegate:self handleQueue:_socketQueue];
    }
    return _socket;
}

- (NSMutableArray *)requestTasks{
    if (!_requestTasks) {
        _requestTasks = [NSMutableArray array];
    }
    return _requestTasks;
}

- (BOOL)addTask:(id<ChatiPhoneCallbackProtocol>)observer request:(ChatMessageRequest *)request{
    for (ChatiPhoneTask *t in self.requestTasks) {
        NSString *hasId = [t.request headerForKey:ChatMessageId];
        NSString *newId = [request headerForKey:ChatMessageId];
        if ([hasId isEqualToString:newId]) {
            return NO;
        }
    }
    ChatiPhoneTask *task = [[ChatiPhoneTask alloc] init];
    task.target = observer;
    task.request = request;
    [self.requestTasks addObject:task];

    return YES;
}

- (ChatiPhoneTask *)taskOfMessageId:(NSString *)messageId{
    for (ChatiPhoneTask *t in self.requestTasks) {
        NSString *hasId = [t.request headerForKey:ChatMessageId];
        if ([hasId isEqualToString:messageId]) {
            return t;
        }
    }
    return nil;
}
- (BOOL)removeTask:(ChatiPhoneTask *)task{
    NSInteger index = [self.requestTasks indexOfObject:task];
    if (index == NSNotFound) {
        return NO;
    }
    [self.requestTasks removeObject:task];
    return YES;
}

- (void)doLoginWithRequest:(ChatMessageRequest *)request completion:(id<ChatiPhoneCallbackProtocol>)completion{
    [self connectToTheHost:[CSUserDefaultStore host] port:[CSUserDefaultStore port]];
    [self addTask:completion request:request];
}

- (void)doLogoffWithRequest:(ChatMessageRequest *)request completion:(id<ChatiPhoneCallbackProtocol>)completion{
    [self addTask:completion request:request];
}


- (CSTcpRequest *)tcpRequestWithChatMessageRequest:(ChatMessageRequest *)request{
    CSTcpRequestOperation *operation = [[CSTcpRequestOperation alloc] initWithRequest:request];
    CSTcpRequest *retVal = [[CSTcpRequest alloc] initWithCSTcpRequestOperation:operation];
    return retVal;
}

- (BOOL)connectToTheHost:(NSString *)host port:(NSInteger)port{
    NSData *address = [CSSocketAddress ipv4WithHost:host port:port];
    return [self.socket connectToTheAddress:address timeOut:10 error:nil];
}

- (void)disconnect{
    [self.socket disconnect];
}

- (void)onSocket:(CSSocket *)s didDisConnectToTheHost:(NSString *)host port:(NSString *)port{
    [[self class] postNotificationName:NotificationConnectionDisconnect object:nil
                              userInfo:@{ @"host" : host, @"port" : port }];
}
- (void)onSocket:(CSSocket *)s didConnectToTheHost:(NSString *)host port:(NSString *)port{
    [[self class] postNotificationName:NotificationConnectionDidConnect object:nil
                              userInfo:@{ @"host" : host, @"port" : port }];
    
    for (ChatiPhoneTask *task in self.requestTasks) {
        [s writeData:task.request.toMessage timeOut:10];
    }
}
- (void)onSocket:(CSSocket *)s didReadDone:(NSData *)data{

    ChatMessage *message = [[ChatMessage alloc] initWithData:data];
    //reveive Message
    if ([[message chatMessageType] isEqualToString:ChatRequestMessage]) {
        ChatMessageRequest *request = [[ChatMessageRequest alloc] initWithData:data];
        [self onHandleRequestMessage:request connection:s];
    }else if ([[message chatMessageType] isEqualToString:ChatResponseMessage]) {
        ChatMessageResponse *response = [[ChatMessageResponse alloc] initWithData:data];
        [self onHandleResponseMessage:response connection:s];
    }else{
        //message
        [self onHandleMessage:message connection:s];
    }
}


- (void)onHandleRequestMessage:(ChatMessageRequest *)request connection:(CSSocket *)connection{
    //iphone no use ? must be
    //send OK
//    [connection sendResponseCode:ChatResponseOK toConnection:connection.currentConnection];
}

- (void)onHandleResponseMessage:(ChatMessageResponse *)response connection:(CSSocket *)connection{
    ChatMessageResponse *resp = [[ChatMessageResponse alloc] init];
    resp.responseCode = ChatResponseOK;
    [self __innerGetMessageIdWithResponse:resp toResponse:response];
//    [connection sendResponse:resp toConnection:connection.currentConnection];

    if ([[response headerForKey:@"Event"] isEqualToString:@"Login"]) {
        [self handleServerLoginResponse:response];
    }else if ([[response headerForKey:@"Event"] isEqualToString:@"Logoff"]) {
        [self handleServerLogoffResponse:response];
    }
}

- (void)onHandleMessage:(ChatMessage *)message connection:(CSSocket *)connection{
    
}

#pragma mark - Response
- (void)handleServerLoginResponse:(ChatMessageResponse *)response{
    NSString *messageId = [response headerForKey:ChatMessageId];
    ChatiPhoneTask *task = [self taskOfMessageId:messageId];
    if (task) {
        [task.target onResponse:response userInfo:nil];
        [self removeTask:task];
    }
}
- (void)handleServerLogoffResponse:(ChatMessageResponse *)response{
    NSString *messageId = [response headerForKey:ChatMessageId];
    ChatiPhoneTask *task = [self taskOfMessageId:messageId];
    if (task) {
        [task.target onResponse:response userInfo:nil];
        [self removeTask:task];
        [self.socket disconnect];
    }
}



@end
