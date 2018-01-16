//
//  ChatiPhoneTask.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/4.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatiPhoneCallbackProtocol.h"
#import "ChatMessage.h"

@interface ChatiPhoneTask : NSObject
@property (nonatomic, weak) id <ChatiPhoneCallbackProtocol> target;
@property (nonatomic, strong) ChatMessageRequest *request;
@end
