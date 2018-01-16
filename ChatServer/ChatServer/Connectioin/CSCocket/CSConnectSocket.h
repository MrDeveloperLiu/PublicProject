//
//  CSConnectSocket.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/30.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSConnection.h"

@class CSConnectSocket;
@protocol CSConnectSocketDelegate <CSConnectionDelegate>
@optional
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection willBeginConnectToTheHost:(NSString *)host port:(NSString *)port;
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didConnectToTheHost:(NSString *)host port:(NSString *)port;
- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didDisConnectToTheHost:(NSString *)host port:(NSString *)port error:(NSError *)error;

- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection connectDidTimeoutToTheHost:(NSString *)host port:(NSString *)port;

- (void)connectSocket:(CSConnectSocket *)s connection:(CSConnection *)connection didAcceptToTheHost:(NSString *)host port:(NSString *)port;
@end

@interface CSConnectSocket : NSObject

@property (nonatomic, weak) id <CSConnectSocketDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableDictionary *connections;
@property (nonatomic, strong, readonly) NSArray *allConnections;
@property (nonatomic, strong, readonly) NSArray *allKeys;
@property (nonatomic, strong, readonly) CSGCDAccept *acceptSource;
@property (nonatomic, assign, readonly) int socket;


- (instancetype)initWithAcceptSource:(CSGCDAccept *)accept socket:(int)socket delegate:(id <CSConnectSocketDelegate>)delegate;

- (void)startConnectToAddress:(NSData *)address timeout:(NSTimeInterval)timeout;
- (void)startAcceptSource;

- (void)connetDidDisConnectedToTheSocket:(int)socket error:(NSError *)error;
- (void)clearAllSourceBySocket;

- (void)setSocket:(int)socket;
- (void)addConnection:(CSConnection *)connection;
- (CSConnection *)connectionForKey:(NSNumber *)key;
- (BOOL)removeConnection:(CSConnection *)connection;
- (BOOL)removeConnectionWithKey:(NSNumber *)key;
@end
