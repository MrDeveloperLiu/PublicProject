//
//  LoginiPhoneManager.h
//  ChatServer
//
//  Created by 刘杨 on 2018/2/14.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "ChatiPhoneProtocol.h"

#define CSiPhoneLoginStatusNotification @"CSiPhoneLoginStatusNotification"

@interface LoginiPhoneManager : NSObject <ChatiPhoneProtocol>

- (void)setSecret:(NSString *)secret;
- (void)setAccount:(NSString *)account password:(NSString *)password;
- (ChatMessage *)loginMessage;

@end
