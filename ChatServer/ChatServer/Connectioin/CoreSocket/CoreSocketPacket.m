//
//  CoreSocketPacket.m
//  ChatServer
//
//  Created by Liu on 2017/10/27.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CoreSocketPacket.h"

static int CoreSocketReadPacketTag = 0;
static int CoreSocketWritePacketTag = 0;

@interface CoreSocketPacket () {
@protected
    NSMutableData   *_data;
    NSInteger       _totalBytes;
    NSTimeInterval  _timeOut;
    int             _tag;
}
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger totalBytes;
@end

@implementation CoreSocketPacket

- (instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        _data = [NSMutableData dataWithData:data];
    }
    return self;
}

@end


@implementation CoreSocketReadPacket
- (instancetype)initWithBytesAvaliable:(size_t)bytesAvaliable
                            readMaxLen:(NSInteger)maxLen
                               timeOut:(NSTimeInterval)timeout{
    if (self = [super init]) {
        _data = [NSMutableData dataWithCapacity:bytesAvaliable];
        _totalBytes = bytesAvaliable;
        _maxLength = maxLen;
        _timeOut = timeout;
        _offset = 0;
        _finish = NO;
        
        if (MAX(65335, CoreSocketReadPacketTag) == CoreSocketReadPacketTag) {
            CoreSocketReadPacketTag = 0;
        }
        _tag = ++CoreSocketReadPacketTag;
        
    }
    return self;
}

- (uint8_t *)readLength:(size_t)bytesAvaliable{
    //first read max len
    _readLength = _maxLength;
    //if max len < avaliable then finished,
    if (bytesAvaliable < _readLength) {
        //reset read len
        _readLength = bytesAvaliable;
        //finished
        _finish = YES;
    }
    //and reset max len
    _maxLength = _readLength;
    //add offset
    _offset += _readLength;
    return (uint8_t *)malloc(_readLength);
}

- (size_t)readBuffer:(uint8_t *)buffer len:(size_t)len{
    NSMutableData *temp = [NSMutableData dataWithBytes:buffer length:len];
    [_data appendData:temp];
    if (buffer) {
        free(buffer);
    }
    return len;
}

@end

@implementation CoreSocketWritePacket
- (instancetype)initWithData:(NSData *)data{
    self = [super initWithData:data];
    if (self) {
        if (MAX(65335, CoreSocketWritePacketTag) == CoreSocketWritePacketTag) {
            CoreSocketWritePacketTag = 0;
        }
        _tag = ++CoreSocketReadPacketTag;
    }
    return self;
}
@end

#define kQueueLabelPre @"SocketHandleQueue_"
#define kQueueLabelSuf @"FD"

@implementation CoreSocketConnection

- (void)destoryHandle{
    
    if (_readSource) {
        dispatch_source_cancel(_readSource);
    }
    if (_writeSource) {
        dispatch_source_cancel(_writeSource);
    }
    if (_handleQueue) {
        _handleQueue = nil;
    }
}

- (instancetype)initWithSocketFD:(int)socketFD address:(NSData *)address delegate:(id<CoreSocketConnectionDelegate>)delegate{
    if (self = [super init]) {
        _socketFD = socketFD;
        _remoteAddress = address;
        _delegate = delegate;
        [self initHandleQueueAndSource];
    }
    return self;
}

- (void)initHandleQueueAndSource{
    NSString *queueName = [NSString stringWithFormat:@"%@%@%@",
                           kQueueLabelPre, @(_socketFD), kQueueLabelSuf];
    _handleQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    
    
    _readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, _socketFD, 0, _handleQueue);
    _writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, _socketFD, 0, _handleQueue);
    
    __weak __typeof (self) ws = self;
    dispatch_source_set_event_handler(_readSource, ^{ @autoreleasepool {
        [ws.delegate onSocketConnection:ws readSourceDidHandle:ws.socketFD];
    } });
    dispatch_source_set_event_handler(_writeSource, ^{ @autoreleasepool {
        [ws.delegate onSocketConnection:ws writeSourceDidHandle:ws.socketFD];
    } });
    
    __block int socketConnectCount = 2;
    dispatch_source_set_cancel_handler(_readSource, ^{ @autoreleasepool {
        _readSource = nil;
        if (--socketConnectCount == 0) {
        }
    } });
    dispatch_source_set_cancel_handler(_writeSource, ^{ @autoreleasepool {
        _writeSource = nil;
        if (--socketConnectCount == 0) {
        }
    } });
}

@end













