//
//  ChatServerRegisterManager.m
//  ChatServer
//
//  Created by 刘杨 on 2018/2/4.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "ChatServerRegisterManager.h"
#import "ChatServerClient.h"

#define kRegisterManagerVersion_1_0 1024

@implementation ChatServerRegisterManager

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


#define kUserIdInitialCount 100000000
#pragma mark - 注册&验证
- (BOOL)onHandleServerRequest:(ChatMessage *)request connection:(ChatConnection *)connection socket:(CSConnection *)socket{
    
    NSString *event = [request headerForKey:@"Event"];
    if ([event isEqualToString:@"RegistAccount"]) {
        NSString *account = [request headerForKey:@"Account"];
        NSString *password = [request headerForKey:@"Password"];
        NSString *phone = [request headerForKey:@"Phone"];
        
        RegisterModel *rm = [CSRegisterDatabase quaryWithAccount:account];
        if (rm) {
            [connection sendResponseErrorReason:CSServerString(@"CSAccountExist") toConnection:socket];
        }else{
            NSInteger count = [CSRegisterDatabase quaryCount];
            NSUInteger userId = kUserIdInitialCount + count;
            
            RegisterModel *rm = [[RegisterModel alloc] initWithUserId:userId account:account password:password phone:phone state:0];
            if ([CSRegisterDatabase insertIntoTableWithModel:rm]) {
                [connection sendResponseCode:ChatResponseOK toConnection:socket];
            }else{
                [connection sendResponseCode:ChatResponseError toConnection:socket];
            }
            
        }
        return YES;
    }else if ([event isEqualToString:@"ConfirmAccount"]){
        NSString *account = [request headerForKey:@"Account"];
        RegisterModel *rm = [CSRegisterDatabase quaryWithAccount:account];
        if (rm) {
            [connection sendResponseErrorReason:CSServerString(@"CSAccountExist") toConnection:socket];
        }else{
            [connection sendResponseCode:ChatResponseOK toConnection:socket];
        }
        return YES;
    }

    return NO;
}

@end
