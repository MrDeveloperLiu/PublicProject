//
//  ChatServerLoginManager.m
//  ChatServer
//
//  Created by 刘杨 on 2018/2/10.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "ChatServerLoginManager.h"
#import "ChatServerClient.h"

#define kRegisterManagerVersion_1_0 1024

@implementation ChatServerLoginManager

- (BOOL)openDatabase{
    return [CSRegisterDatabase createTable];
}
- (BOOL)updateDatabase{
    NSInteger version = [self datebaseVersion];
    return [CSRegisterDatabase updateTable:version];
}
- (NSString *)tableName{
    return [CSRegisterDatabase tableName];
}
- (NSInteger)datebaseVersion{
    return kRegisterManagerVersion_1_0;
}

#pragma mark - 登录
- (BOOL)onHandleServerRequest:(ChatMessage *)request connection:(ChatConnection *)connection socket:(CSConnection *)socket{
    NSString *event = [request headerForKey:@"Event"];
    if ([event isEqualToString:@"Login"]) {
        NSString *account = [request headerForKey:@"Account"];
        NSString *password = [request headerForKey:@"Password"];
        RegisterModel *rm = [CSRegisterDatabase quaryWithAccount:account];
        if (rm) {
            if ([rm.password isEqualToString:password]) {
                if ([CSRegisterDatabase updateSocketKey:socket.socketFD address:socket.address.address withUserid:rm.userid]) {
                    [connection sendResponseCode:ChatResponseOK addMessageId:request toConnection:socket];
                }else{
                    [connection sendResponseErrorReason:CSServerString(@"CSDatabaseWrong") toConnection:socket];
                    [connection disconnectConnection:socket];
                }
            }else{
                [connection sendResponseErrorReason:CSServerString(@"CSEncryptCodeWrong") toConnection:socket];
                [connection disconnectConnection:socket];
            }
        }else{
            [connection sendResponseErrorReason:CSServerString(@"SCUserNotExist") toConnection:socket];
            [connection disconnectConnection:socket];
        }
    }else if ([event isEqualToString:@"Logout"]){
        NSString *userId = [request headerForKey:@"UserId"];
        RegisterModel *rm = [CSRegisterDatabase quaryWithUserid:userId.longLongValue];
        if (rm) {
            [connection sendResponseCode:ChatResponseOK addMessageId:request toConnection:socket];
        }else{
            [connection sendResponseErrorReason:CSServerString(@"SCUserNotExist") toConnection:socket];
        }
        [connection disconnectConnection:socket];
    }else if ([event isEqualToString:@"Reconnect"]){
        NSString *userId = [request headerForKey:@"UserId"];
        NSString *encryptCode = [request headerForKey:@"EncryptCode"];
        RegisterModel *rm = [CSRegisterDatabase quaryWithUserid:userId.longLongValue];
        if (rm) {
            NSString *encrypt = [NSString stringWithFormat:@"%@-%@", rm.account, rm.password];
            NSString *md5String = [CSEncryptUntil md5String:encrypt];
            if ([md5String isEqualToString:encryptCode]) {
                [connection sendResponseCode:ChatResponseOK addMessageId:request toConnection:socket];
            }else{
                [connection sendResponseErrorReason:CSServerString(@"CSEncryptCodeWrong") toConnection:socket];
                [connection disconnectConnection:socket];
            }
        }else{
            [connection sendResponseErrorReason:CSServerString(@"SCUserNotExist") toConnection:socket];
            [connection disconnectConnection:socket];
        }
        return YES;
    }
    return NO;
}


@end
