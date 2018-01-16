//
//  CSConnection.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/31.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSocketAddress.h"
#import "CSGCD.h"
#import "CSSocketPack.h"

@class CSConnection;
@protocol CSConnectionDelegate <NSObject>
@optional
- (dispatch_queue_t)delegateQueue;
- (void)connection:(CSConnection *)connection writeQueueDidSchedule:(CSGCDWrite *)writeSource;
- (void)connection:(CSConnection *)connection writeQueueDidUnSchedule:(CSGCDWrite *)writeSource;
- (void)connection:(CSConnection *)connection readQueueDidSchedule:(CSGCDRead *)readSource;
- (void)connection:(CSConnection *)connection readQueueDidUnSchedule:(CSGCDRead *)readSource;
- (void)connection:(CSConnection *)connection readAndReadQueueDidOpened:(BOOL)opened;

- (void)connection:(CSConnection *)connection remoteShoudBeClosed:(CSSocketAddress *)remote;
- (void)connection:(CSConnection *)connection didWriteData:(NSData *)data;

- (void)connection:(CSConnection *)connection didReadData:(NSData *)data progress:(double)progress;
- (void)connection:(CSConnection *)connection didReadDone:(NSData *)data;

- (void)connection:(CSConnection *)connection writeDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout;
- (void)connection:(CSConnection *)connection readDidTimeout:(NSInteger)tag timeout:(NSTimeInterval)timeout;
@end

@interface CSConnection : NSObject

@property (nonatomic, weak) id <CSConnectionDelegate> delegate;
@property (nonatomic, assign, readonly) int socketFD;
@property (nonatomic, strong, readonly) CSSocketAddress *address;
@property (nonatomic, strong, readonly) CSGCDRead *readQueue;
@property (nonatomic, strong, readonly) CSGCDWrite *writeQueue;
@property (nonatomic, strong, readonly) CSGCDTimer *readTimer;
@property (nonatomic, strong, readonly) CSGCDTimer *writeTimer;

@property (nonatomic, assign, readonly) int readPackTag;
@property (nonatomic, assign, readonly) int writePackTag;

@property (nonatomic, assign, readonly) int readMaxLen;

@property (nonatomic, assign) NSTimeInterval readTimeout;
@property (nonatomic, assign) NSTimeInterval writeTimeout;
- (NSNumber *)socketKey;
@property (nonatomic, assign, getter=isAcceptConnection) BOOL acceptConnection;

- (instancetype)initWithAddress:(CSSocketAddress *)address delegate:(id <CSConnectionDelegate>)delegate;

- (void)readQueueSchedule;
- (void)writeQueueSchedule;

- (void)readQueueUnSchedule;
- (void)writeQueueUnSchedule;
//callback delegate
- (void)closeReadAndWriteSource;

- (unsigned long)write:(NSData *)data timeout:(NSTimeInterval)timeout;

+ (NSNumber *)connectionKey:(int)socketFD;
@end
