//
//  LoginiPhoneManager.m
//  ChatServer
//
//  Created by 刘杨 on 2018/2/14.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "LoginiPhoneManager.h"

@interface LoginiPhoneManager ()
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *method;
@end
@implementation LoginiPhoneManager
- (void)setSecret:(NSString *)secret{
    _secret = secret;
    [self setMethod:@"Reconnect"];
}
- (void)setAccount:(NSString *)account password:(NSString *)password{
    [self setAccount:account];
    [self setPassword:password];
    NSString *s = [NSString stringWithFormat:@"%@-%@", account, password];
    [self setSecret:[CSEncryptUntil md5String:s]];
    [self setMethod:@"Login"];
}
- (ChatMessage *)loginMessage{
    ChatMessage *request = [[ChatMessage alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Login" forKey:@"Method"];
    [request addHeader:self.method forKey:@"Event"];
    [request addHeader:self.secret forKey:@"EncryptCode"];
    [request addHeader:[CSUserDefaultStore userId] forKey:@"UserId"];
    [request addHeader:self.account forKey:@"Account"];
    [request addHeader:self.password forKey:@"Password"];
    return request;
}

- (void)postLoginStatusNotification:(int)status{
    NSDictionary *userInfo = @{
                               @"Status" : [NSNumber numberWithInt:status]                               
                               };
    dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSiPhoneLoginStatusNotification
                                                            object:nil
                                                          userInfo:userInfo];
    } });
}

- (BOOL)onHandleServerRequest:(ChatMessage *)request connection:(ChatConnection *)connection socket:(CSConnection *)socket{
    NSString *event = [request headerForKey:@"Event"];
    if ([event isEqualToString:@"Login"]) {
        
        return YES;
    }else if ([event isEqualToString:@"Logout"]){

        return YES;
    }else if ([event isEqualToString:@"Reconnect"]){

        return YES;
    }
    return NO;
}

- (BOOL)openDatabase{
    return NO;
}
- (BOOL)updateDatabase{
    return NO;
}
- (NSString *)tableName{
    return nil;
}
- (NSInteger)datebaseVersion{
    return 0;
}

@end
