//
//  CSSocketAddress.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#import "CSFileLogger.h"

@interface CSSocketAddress : NSObject <NSCopying>

@property (nonatomic, assign) BOOL online;

@property (nonatomic, assign, readonly) int socket;
@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *port;
@property (nonatomic, strong, readonly) NSString *address;
@property (nonatomic, strong, readonly) NSData *addrData;

- (instancetype)initWithAddress:(NSData *)address socket:(int)socket;

+ (NSUInteger)portFromIPv4:(NSData *)ipv4;
+ (NSString *)hostFromIPv4:(NSData *)ipv4;
+ (NSData *)ipv4WithHost:(NSString *)host port:(NSUInteger)port;
+ (NSData *)anyIPv4AddressWithPort:(NSUInteger)port;
+ (NSString *)ipv4ToString:(NSData *)ipv4;
@end
