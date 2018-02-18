//
//  ChatiPhoneClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatiPhoneClient.h"
#import "ChatConnectionReachable.h"

@interface ChatiPhoneClient ()
@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, strong) ChatConnection *connection;
@property (nonatomic, strong) dispatch_queue_t socketQueue;
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

- (instancetype)init{
    self = [super init];
    if (self) {        
        _maxCount = 20;
        
        _socketQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String],
                                             DISPATCH_QUEUE_CONCURRENT);
        
        _connection = [[ChatConnection alloc] initWithQueue:_socketQueue type:(ChatConnectionTypeClient)];
        
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
    }
    return self;
}

- (void)registerManagers{
    [self registerManager:[LoginiPhoneManager new] forKey:@"Login"];
}
- (BOOL)registerManager:(id <ChatiPhoneProtocol>)manager forKey:(NSString *)key{
    /*
    if ([key isKindOfClass:[NSString class]]) {
        NSString *tableName = nil;
        if ([manager respondsToSelector:@selector(tableName)]) {
            tableName = [manager tableName];
        }
        NSInteger currentVersion = 0;
        if ([manager respondsToSelector:@selector(datebaseVersion)]) {
            currentVersion = [manager datebaseVersion];
        }
        //quary version of table name
        NSInteger version = [(NSNumber *)[self.dbHelper staticsValueForKey:tableName] integerValue];
        if (version && version != currentVersion) {
            BOOL canUpdate = NO;
            if ([manager respondsToSelector:@selector(updateDatabase)]) {
                canUpdate = [manager updateDatabase];
            }
            if (canUpdate) {
                [self.dbHelper setStaticsValue:@(currentVersion) ForKey:tableName];
            }else{
                //更新失败
            }
        }
    }*/
    return [super registerManager:manager forKey:key];
}
- (id<ChatiPhoneProtocol>)managerForKey:(NSString *)key{
    return (id<ChatiPhoneProtocol>)[super managerForKey:key];
}


///
- (BOOL)loginWithTheAccount:(NSString *)account password:(NSString *)password{
    return [_connection connectToHost:[CSUserDefaultStore host] port:[CSUserDefaultStore port] timeout:10];
}
- (BOOL)connectToTheHost:(NSString *)secret{
    return [_connection connectToHost:[CSUserDefaultStore host] port:[CSUserDefaultStore port] timeout:10];
}
- (void)disconnect{
    return [_connection disconnect];
}
///

- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket status:(ChatConnectionStatus)status{
    if (status == ChatConnectionStatusDidConnected) {
        //发送验证信息
        LoginiPhoneManager *loginMgr = [self managerForKey:@"Login"];
        [connection sendRequest:(ChatMessage *)[loginMgr loginMessage]];
    }
}
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data{
    
    ChatMessage *request = [[ChatMessage alloc] initWithData:data];
    NSString *method = [request headerForKey:@"Method"];
    
    BOOL canHandle = NO;
    //mgr
    id <ChatiPhoneProtocol> manager = [self managerForKey:method];
    if (manager) {
        canHandle = [manager onHandleServerRequest:request connection:connection socket:socket];
    }
    //res
    if (!canHandle) {
        CSLogE(@"server can't handle message: %@", request);
        [connection sendResponseCode:ChatResponseNotFound toConnection:socket];
    }else{
        CSLogI(@"server handle message: %@", request);
    }
    
}

 - (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data progress:(double)progress{
 
 }


- (NSOperationQueue *)requestQueue{
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = _maxCount;
    }
    return _requestQueue;
}
- (CSTcpRequest *)tcpRequestWithChatMessage:(ChatMessage *)request{
    CSTcpRequestOperation *ope = [[CSTcpRequestOperation alloc] initWithRequest:request];
    CSTcpRequest *tcpReq = [[CSTcpRequest alloc] initWithCSTcpRequestOperation:ope];
    return tcpReq;
}

@end
