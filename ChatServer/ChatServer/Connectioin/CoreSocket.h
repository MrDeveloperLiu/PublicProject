//
//  CoreSocket.h
//  ChatServer
//
//  Created by Liu on 2017/10/15.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreSocketPacket.h"

@protocol CoreSocketDelegate;
@interface CoreSocket : NSObject

@property (nonatomic, weak) id <CoreSocketDelegate> delegate;
@property (nonatomic, assign, readonly) NSArray <CoreSocketConnection *> *connections;
//for client
- (BOOL)connectToTheAddress:(NSData *)address timeOut:(NSTimeInterval)timeout error:(NSError **)error;
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout;
- (BOOL)disconnect;

//for server
- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError **)error;
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout socket:(int)socketFD;
- (BOOL)disconnectSocket:(int)socketFD;
- (BOOL)serverDisconnect;

//ipv4
+ (NSUInteger)portFromIPv4:(NSData *)ipv4;
+ (NSString *)hostFromIPv4:(NSData *)ipv4;
+ (NSData *)ipv4WithHost:(NSString *)host port:(NSUInteger)port;
+ (NSData *)anyIPv4AddressWithPort:(NSUInteger)port;

@end


@protocol CoreSocketDelegate <NSObject>
@required
- (void)onCoreSocket:(CoreSocket *)socket didConnectToTheHost:(NSString *)host port:(NSInteger)port;
- (void)onCoreSocket:(CoreSocket *)socket disConnectToTheHost:(NSString *)host port:(NSInteger)port error:(NSError *)error;

- (void)onCoreSocket:(CoreSocket *)socket receiveData:(CoreSocketReadPacket *)packet;
- (void)onCoreSocket:(CoreSocket *)socket receiveDone:(CoreSocketReadPacket *)packet;

- (void)onCoreSocket:(CoreSocket *)socket writeDidTimeOut:(CoreSocketWritePacket *)packet;
- (void)onCoreSocket:(CoreSocket *)socket readDidTimeOut:(CoreSocketReadPacket *)packet;
@end
