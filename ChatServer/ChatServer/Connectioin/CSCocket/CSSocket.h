//
//  CSSocket.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSConnectSocket.h"

@class CSSocket;
@protocol CSSocketDelegate <NSObject>
@optional
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection willBeginConnectToTheHost:(NSString *)host port:(NSString *)port;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didConnectToTheHost:(NSString *)host port:(NSString *)port;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didDisConnectToTheHost:(NSString *)host port:(NSString *)port;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection connectDidTimeoutToTheHost:(NSString *)host port:(NSString *)port;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didAcceptToTheHost:(NSString *)host port:(NSString *)port;

- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeQueueDidSchedule:(CSGCDWrite *)writeSource;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeQueueDidUnSchedule:(CSGCDWrite *)writeSource;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readQueueDidSchedule:(CSGCDRead *)readSource;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readQueueDidUnSchedule:(CSGCDRead *)readSource;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readAndReadQueueDidOpened:(BOOL)opened;

- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection remoteShoudBeClosed:(CSSocketAddress *)remote;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didWriteData:(NSData *)data;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didReadData:(NSData *)data progress:(double)progress;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection didReadDone:(NSData *)data;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection writeDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout;
- (void)onSocket:(CSSocket *)s connection:(CSConnection *)connection readDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout;
@end

@interface CSSocket : NSObject

@property (nonatomic, weak) id <CSSocketDelegate> delegate;
@property (nonatomic, readonly) dispatch_queue_t socketQueue;
@property (nonatomic, strong, readonly) CSConnectSocket *connectionSocket;

- (instancetype)initWithDelegate:(id <CSSocketDelegate>)delegate handleQueue:(dispatch_queue_t)queue;

- (BOOL)connectToTheAddress:(NSData *)address timeOut:(NSTimeInterval)timeout error:(NSError **)error;
- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError **)error;

- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout;
- (void)writeData:(NSData *)data timeOut:(NSTimeInterval)timeout socket:(int)socketFD;

- (BOOL)disconnect;
- (BOOL)disconnectSocket:(int)socketFD;
@end
