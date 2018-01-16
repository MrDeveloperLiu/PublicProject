//
//  ChatiPhoneCallbackProtocol.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/4.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatMessageResponse;
@protocol ChatiPhoneCallbackProtocol <NSObject>

- (void)onResponse:(ChatMessageResponse *)resp userInfo:(NSDictionary *)userInfo;

@end
