//
//  ChatiPhoneClient.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatClient.h"
#import "CSTcpRequest.h"
#import "ChatConnection.h"
#import "ChatiPhoneProtocol.h"

//managers
#import "LoginiPhoneManager.h"

#define CSIPhoneString(key) NSLocalizedStringFromTable(key, @"iPhoneString", nil)

@interface ChatiPhoneClient : ChatClient

@property (nonatomic, strong, readonly) NSOperationQueue *requestQueue;
- (CSTcpRequest *)tcpRequestWithChatMessage:(ChatMessage *)request;

+ (ChatiPhoneClient *)iPhone;

- (BOOL)loginWithTheAccount:(NSString *)account password:(NSString *)password;
- (BOOL)connectToTheHost:(NSString *)secret;
- (void)disconnect;

//重载super
- (BOOL)registerManager:(id <ChatiPhoneProtocol>)manager forKey:(NSString *)key;
- (id<ChatiPhoneProtocol>)managerForKey:(NSString *)key;
@end
