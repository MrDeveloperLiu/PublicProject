//
//  CSConnection.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/31.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSConnection.h"

@interface CSConnection ()
@property (nonatomic, strong) CSSocketReadPack *currentReadPack;
@property (nonatomic, strong) NSMutableArray *writeDatas;
@end

@implementation CSConnection

- (NSString *)description{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@> : { \r", NSStringFromClass([self class])];
    [desc appendFormat:@" socket:%d \r address:%@ \r readPackTag:%d \r writePackTag:%d \r",
     _socketFD, _address.address, _readPackTag, _writePackTag];
    [desc appendFormat:@"\r }"];
    return desc;
}

- (void)dealloc{
    [self readQueueUnSchedule];
    [self writeQueueUnSchedule];
    _currentReadPack = nil;
    _readQueue = nil;
    _writeQueue = nil;
}

- (instancetype)initWithAddress:(CSSocketAddress *)address delegate:(id<CSConnectionDelegate>)delegate{
    if (!address) {
        return nil;
    }
    self = [super init];
    if (self) {
        _address = address;
        _socketFD = address.socket;
        _delegate = delegate;
        _readTimeout = 10;
        _writeTimeout = 10;
        _readPackTag = 0;
        _writePackTag = 0;
        _readMaxLen = 1024;
        _writeDatas = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)readQueueSchedule{
    if (_readQueue) {
        return;
    }
    __weak __typeof (self) ws = self;
    _readQueue = [[CSGCDRead alloc] initWithSocket:_socketFD];
    [_readQueue setEventBlock:^{
        [ws readQueueDidHasEvent];
    }];
    [_readQueue resume];
    
    dispatch_queue_t queue = NULL;
    if ([self.delegate respondsToSelector:@selector(delegateQueue)]) {
        queue = [self.delegate delegateQueue];
    }
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    _readTimer = [[CSGCDTimer alloc] initWithTimeInterval:0 start:0 queue:queue];
    [_readTimer setEventBlock:^{
        [ws readQueueDidTimeout];
    }];
    
    //call read queue
    if ([self.delegate respondsToSelector:@selector(connection:readQueueDidSchedule:)]) {
        [self.delegate connection:self readQueueDidSchedule:_readQueue];
    }
    [self callReadQueueAndReadQueueDidOpen:YES];
}

//读取流的流程
- (void)readQueueDidHasEvent{
    unsigned long hasBytesAvaliable = [_readQueue getData];
    if (0 == hasBytesAvaliable) {
        //close by remote
        [self callRemoteShouldBeClosed];
        return;
    }
    
    if (!_currentReadPack) {
        //new one
        CSSocketReadPack *readPack = [[CSSocketReadPack alloc] initWithTag: ++_readPackTag
                                                            bytesAvaliable:hasBytesAvaliable
                                                                totalBytes:hasBytesAvaliable];
        _currentReadPack = readPack;
        
        //begin
        [self didBeginReceiveANewPack:_currentReadPack];
    }

    unsigned long readLen = [_currentReadPack readLengthWithMaxReadLength:_readMaxLen];
    
    uint8_t *buffer = malloc(readLen);
    ssize_t realLen = read(_socketFD, buffer, readLen);
    if (realLen == 0) {
        //read 0 how to handle this?
    }
    NSData *realData = [NSData dataWithBytes:buffer length:realLen];
    [_currentReadPack appendData:realData];
    free(buffer);
    
    //progress append
    double progress = _currentReadPack.offset / _currentReadPack.totalBytes;
    [self didReceivePack:_currentReadPack progress:progress];
    
    if (!_currentReadPack.hasBytesAvaliable) {
        [self didReceivePackDone:_currentReadPack];//done
        _currentReadPack = nil;
    }

}
- (void)readQueueUnSchedule{
    if (!_readQueue) {
        return;
    }
    [self cancelReadTimer];
    [_readQueue cancel];
    
    if ([self.delegate respondsToSelector:@selector(connection:readQueueDidUnSchedule:)]) {
        [self.delegate connection:self readQueueDidUnSchedule:_readQueue];
    }
    
    [self callReadQueueAndReadQueueDidOpen:NO];

}

// 读取到数据为0 , 可能是远程关闭了链接
- (void)callRemoteShouldBeClosed{
    //远程断开连接
    if ([self.delegate respondsToSelector:@selector(connection:remoteShoudBeClosed:)]) {
        [self.delegate connection:self remoteShoudBeClosed:self.address];
    }
}

- (void)closeReadAndWriteSource{
    //关闭读写queue
    [self readQueueUnSchedule];
    [self writeQueueUnSchedule];
    _writeTimer = nil;
    _readTimer = nil;
}
//收到一个新的包
- (void)didBeginReceiveANewPack:(CSSocketReadPack *)pack{
    //do nothing
}
//回调进度
- (void)didReceivePack:(CSSocketReadPack *)pack progress:(double)progress{
    if ([self.delegate respondsToSelector:@selector(connection:didReadData:progress:)]) {
        [self.delegate connection:self didReadData:pack.receiveData progress:progress];
    }
}
//新报接受完成
- (void)didReceivePackDone:(CSSocketReadPack *)pack{
    if ([self.delegate respondsToSelector:@selector(connection:didReadDone:)]) {
        [self.delegate connection:self didReadDone:pack.receiveData];
    }
}
//读取超时, 失败
- (void)readQueueDidTimeout{
    //cancel timer
    [self cancelReadTimer];
    //call back
    if ([self.delegate respondsToSelector:@selector(connection:readDidTimeout:timeout:)]) {
        [self.delegate connection:self readDidTimeout:_currentReadPack.tag timeout:_readTimeout];
    }
}

- (void)writeQueueSchedule{
    if (_writeQueue) {
        return;
    }
    __weak __typeof (self) ws = self;
    _writeQueue = [[CSGCDWrite alloc] initWithSocket:_socketFD];
    [_writeQueue setEventBlock:^{
        [ws writeQueueDidHasEvent];
    }];
    
    dispatch_queue_t queue = NULL;
    if ([self.delegate respondsToSelector:@selector(delegateQueue)]) {
        queue = [self.delegate delegateQueue];
    }
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    _writeTimer = [[CSGCDTimer alloc] initWithTimeInterval:0 start:0 queue:queue];
    [_writeTimer setEventBlock:^{
        [ws writeQueueDidTimeout];
    }];
    
    //call delegate
    if ([self.delegate respondsToSelector:@selector(connection:writeQueueDidSchedule:)]) {
        [self.delegate connection:self writeQueueDidSchedule:_writeQueue];
    }
    [self callReadQueueAndReadQueueDidOpen:YES];
}
- (void)writeQueueUnSchedule{
    if (!_writeQueue) {
        return;
    }
    [self cancelWriteTimer];
    [_writeQueue cancel];
    
    if ([self.delegate respondsToSelector:@selector(connection:writeQueueDidUnSchedule:)]) {
        [self.delegate connection:self writeQueueDidUnSchedule:_writeQueue];
    }
    
    [self callReadQueueAndReadQueueDidOpen:NO];
    
}


//写入流
- (void)writeQueueDidHasEvent{
    CSSocketWritePack *writePack = _writeDatas.firstObject;
    if (!writePack) {
        [_writeQueue suspend];
        return;
    }
    //send and begin write timer
    ssize_t sendBytes = write(_socketFD,
                              ( const void *)[writePack.sendData bytes],
                              (size_t)[writePack.sendData length]);
    //end timer
    if (sendBytes == 0) {
        //if send bytes 0 how to handle this?
    }
    [self cancelWriteTimer];
    [_writeDatas removeObject:writePack];
    CSLogS(@"send %ld bytes, tag %ld", sendBytes, writePack.tag);
    
    if (_writeDatas.count <= 0) {
        [_writeQueue suspend];
    }
}
//写入超时
- (void)writeQueueDidTimeout{
    //call back and disconnect
    [self cancelWriteTimer];
    
    CSSocketWritePack *writePack = _writeDatas.firstObject;
    if ([self.delegate respondsToSelector:@selector(connection:writeDidTimeout:timeout:)]) {
        [self.delegate connection:self writeDidTimeout:writePack.tag timeout:_writeTimeout];
    }    
    [_writeDatas removeAllObjects];
}


- (void)callReadQueueAndReadQueueDidOpen:(BOOL)open{
    if ( (_readQueue.isOpen == open && _writeQueue.isOpen == open) &&
        [self.delegate respondsToSelector:@selector(connection:readAndReadQueueDidOpened:)]) {
        [self.delegate connection:self readAndReadQueueDidOpened:open];
        
        if (!open) {
            _writeQueue = nil;
            _readQueue = nil;
        }
    }
}

//发送流
- (unsigned long)write:(NSData *)data timeout:(NSTimeInterval)timeout{
    //begin timer
    [self beginWriteTimer];
    //write into queue
    CSSocketWritePack *writePack = [[CSSocketWritePack alloc] initWithTag:++ _writePackTag data:data];
    [_writeDatas addObject:writePack];
    
    
    //begin write queue
    if (_writeDatas.count > 1) {
        [_writeQueue resume];
    }
    return [data length];
}

- (void)beginReadTimer{
    [_readTimer setStartInterval:_readTimeout];
    [_readTimer setTimer];
    [_readTimer resume];
}
- (void)cancelReadTimer{
    [_readTimer cancel];
}

- (void)beginWriteTimer{
    [_writeTimer setStartInterval:_writeTimeout];
    [_writeTimer setTimer];
    [_writeTimer resume];
}
- (void)cancelWriteTimer{
    [_writeTimer cancel];
}

+ (NSNumber *)connectionKey:(int)socketFD{
    return @(socketFD);
}

- (NSNumber *)socketKey{
    return [[self class] connectionKey:_socketFD];
    
}

@end
