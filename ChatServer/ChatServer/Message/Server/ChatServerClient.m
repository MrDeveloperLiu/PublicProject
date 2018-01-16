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
@property (nonatomic, strong) CSSocket *socket;
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

- (CSSocket *)socket{
    if (!_socket) {
        _socketQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String],
                                             DISPATCH_QUEUE_CONCURRENT);
        _socket = [[CSSocket alloc] initWithDelegate:self handleQueue:_socketQueue];
    }
    return _socket;
}
- (SqliteHelper *)dbHelper{
    if (!_dbHelper) {
        _dbHelper = [[SqliteHelper alloc] init];
    }
    return _dbHelper;
}

- (BOOL)beginListenToThePort:(NSInteger)port{
    return [self.socket acceptOnPort:port error:nil];
}

- (BOOL)endListen{
    return [self.socket disconnect];
}

- (void)onSocket:(CSSocket *)s didDisConnectToTheHost:(NSString *)host port:(NSString *)port{
    [[self class] postNotificationName:NotificationConnectionDisconnect object:nil
                              userInfo:@{ @"host" : host, @"port" : port }];
}
- (void)onSocket:(CSSocket *)s didConnectToTheHost:(NSString *)host port:(NSString *)port{
    [[self class] postNotificationName:NotificationConnectionDisconnect object:nil
                              userInfo:@{ @"host" : host, @"port" : port }];
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
    
    ChatMessageResponse *resp = [[ChatMessageResponse alloc] init];
    if ([[request method] isEqualToString:ChatRequestMethodPOST]) {
        if ([[request headerForKey:@"Event"] isEqualToString:@"Register"]) {
            [self handleRegisterEvent:request response:resp];
        }else if ([[request headerForKey:@"Event"] isEqualToString:@"Login"]) {
            [self handleLoginEvent:request response:resp];
        }else if ([[request headerForKey:@"Event"] isEqualToString:@"Logoff"]) {
            [self handleLogoffEvent:request response:resp];
        }
    }else if ([[request method] isEqualToString:ChatRequestMethodGET]) {
        
    }
    //send OK
    [self __innerGetMessageIdWithRequest:request toResponse:resp];
    [connection writeData:resp.toMessage timeOut:10];
}

- (void)onHandleResponseMessage:(ChatMessageResponse *)response connection:(CSSocket *)connection{
    
}

- (void)onHandleMessage:(ChatMessage *)message connection:(CSSocket *)connection{
    
}

#pragma mark - Event
#pragma mark Register

- (void)handleRegisterEvent:(ChatMessageRequest *)request response:(ChatMessageResponse *)response{
    
    NSString *account = [request headerForKey:@"Account"];
    NSString *password = [request headerForKey:@"Password"];
    if (account.length && password.length) {
        RegisterModel *preRegModel = [self.dbHelper.registerHelper quaryWithAccount:account].lastObject;;
        NSInteger preUserId = preRegModel.userid;
        if (preRegModel) {
            [self __failedWithResponse:response reason:CSServerString(@"CSAccountExist")];
            return;
        }
        if ([self.dbHelper.registerHelper insertIntoTableWithAccount:account password:password state:0 userId:++preUserId]) {
            response.responseCode = ChatResponseOK;
        }else{
            [self __failedWithResponse:response reason:CSServerString(@"SCServerWrong")];
        }
    }else{
        [self __failedWithResponse:response reason:CSServerString(@"CSAccountNull")];
    }
}

- (void)handleLoginEvent:(ChatMessageRequest *)request response:(ChatMessageResponse *)response{

    NSString *account = [request headerForKey:@"Account"];
    NSString *password = [request headerForKey:@"Password"];
    RegisterModel *regModel = [self.dbHelper.registerHelper quaryWithAccount:account].lastObject;
    if (regModel) {
        if (![regModel.password isEqualToString:password]) {
            [self __failedWithResponse:response reason:CSServerString(@"CSPasswordWrong")];
            return;
        }
        if ([self.dbHelper.registerHelper updateTableWithAccount:account password:nil state:1]) {
            response.responseCode = ChatResponseOK;
        }else{
            [self __failedWithResponse:response reason:CSServerString(@"SCServerWrong")];
        }
    }else{
        [self __failedWithResponse:response reason:CSServerString(@"SCUserNotExist")];
    }

}
- (void)handleLogoffEvent:(ChatMessageRequest *)request response:(ChatMessageResponse *)response{
    uint64_t userid = [[request headerForKey:@"UserId"] longLongValue];
    
    RegisterModel *regModel = [self.dbHelper.registerHelper quaryWithUserid:userid].lastObject;
    if (regModel) {
        if ([self.dbHelper.registerHelper updateTableWithAccount:nil password:nil state:0]) {
            response.responseCode = ChatResponseOK;
        }else{
            [self __failedWithResponse:response reason:CSServerString(@"SCServerWrong")];
        }
    }else{
        [self __failedWithResponse:response reason:CSServerString(@"SCUserNotExist")];
    }
}


@end
