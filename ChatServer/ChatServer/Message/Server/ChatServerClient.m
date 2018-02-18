//
//  ChatServerClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatServerClient.h"
#import "RegisterSqliteHelper.h"
#import "SqliteHelper.h"
#import "ChatMessage.h"

//managers
#import "ChatServerRegisterManager.h"
#import "ChatServerLoginManager.h"

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

+ (void)inDatabase:(void (^)(FMDatabase *))database{
    [[ChatServerClient server].dbHelper.databaseQueue inDatabase:database];
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

        
        _dbHelper = [[SqliteHelper alloc] init];
    }
    return self;
}

- (void)registerManagers{    
    [self registerManager:[ChatServerRegisterManager new] forKey:@"Register"];
    [self registerManager:[ChatServerLoginManager new] forKey:@"Login"];
}
- (BOOL)registerManager:(id <ChatServerProtocol>)manager forKey:(NSString *)key{
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
    }
    return [super registerManager:manager forKey:key];
}
- (id<ChatServerProtocol>)managerForKey:(NSString *)key{
    return (id<ChatServerProtocol>)[super managerForKey:key];
}

- (BOOL)beginListen:(NSUInteger)port{
    [self registerManagers];
    [self openDatabase];
    NSError *error = nil;
    BOOL ret = [_connection acceptToPort:port error:&error];
    return ret;
}
- (void)endListen{
    [_connection disconnect];
    self.managers = nil;
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
    ChatMessage *request = [[ChatMessage alloc] initWithData:data];
    NSString *method = [request headerForKey:@"Method"];
    
    BOOL canHandle = NO;
    //mgr
    id <ChatServerProtocol> manager = [self managerForKey:method];
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
/*
- (void)connection:(ChatConnection *)connection socket:(CSConnection *)socket data:(NSData *)data progress:(double)progress{

}
*/
@end
