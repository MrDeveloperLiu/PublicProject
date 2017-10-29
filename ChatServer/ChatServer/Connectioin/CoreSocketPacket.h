//
//  CoreSocketPacket.h
//  ChatServer
//
//  Created by Liu on 2017/10/27.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CoreSocketConnection;
@interface CoreSocketPacket : NSObject
@property (nonatomic, strong, readonly) NSMutableData *data;
@property (nonatomic, assign, readonly) NSInteger totalBytes;
@property (nonatomic, assign, readonly) int tag;
@property (nonatomic, assign) NSTimeInterval timeOut;
- (instancetype)initWithData:(NSData *)data;
@end

@interface CoreSocketReadPacket : CoreSocketPacket
@property (nonatomic, assign, readonly) NSInteger maxLength;
@property (nonatomic, assign, readonly) NSInteger readLength;
@property (nonatomic, assign, readonly) NSInteger byteAvaliable;
@property (nonatomic, assign, readonly) NSInteger offset;
@property (nonatomic, assign) BOOL finish;

- (instancetype)initWithBytesAvaliable:(size_t)bytesAvaliable
                            readMaxLen:(NSInteger)maxLen
                               timeOut:(NSTimeInterval)timeout;

- (uint8_t *)readLength:(size_t)bytesAvaliable;
- (size_t)readBuffer:(uint8_t *)buffer len:(size_t)len;

@end

@interface CoreSocketWritePacket : CoreSocketPacket
@end

@protocol CoreSocketConnectionDelegate <NSObject>
@required
- (void)onSocketConnection:(CoreSocketConnection *)connection writeSourceDidHandle:(int)socketFD;
- (void)onSocketConnection:(CoreSocketConnection *)connection readSourceDidHandle:(int)socketFD;
@end

@interface CoreSocketConnection : NSObject
@property (nonatomic, assign, readonly) int socketFD;
@property (nonatomic, strong, readonly) NSData *remoteAddress;
@property (nonatomic, strong, readonly) dispatch_source_t readSource;
@property (nonatomic, strong, readonly) dispatch_source_t writeSource;
@property (nonatomic, strong, readonly) dispatch_queue_t handleQueue;
@property (nonatomic, weak, readonly) id <CoreSocketConnectionDelegate> delegate;

- (void)destoryHandle;
- (instancetype)initWithSocketFD:(int)socketFD
                         address:(NSData *)address
                        delegate:(id<CoreSocketConnectionDelegate>)delegate;
@end







