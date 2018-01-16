//
//  CSSocketPack.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/1.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSSocketPack.h"

@implementation CSSocketPack
- (instancetype)initWithTag:(unsigned long)tag bytesAvaliable:(unsigned long)bytesAvaliable totalBytes:(unsigned long)totalBytes{
    self = [super init];
    if (self) {
        _tag = tag;
        _bytesAvaliable = bytesAvaliable;
        _totalBytes = totalBytes;
    }
    return self;
}

@end

@implementation CSSocketWritePack

- (instancetype)initWithTag:(unsigned long)tag data:(NSData *)sendData{
    unsigned long bytesAvaliable = sendData.length;
    unsigned long totalBytes = sendData.length;
    self = [super initWithTag:tag bytesAvaliable:bytesAvaliable totalBytes:totalBytes];
    if (self) {
        _sendData = sendData;
    }
    return self;
}

@end

@implementation CSSocketReadPack

- (instancetype)initWithTag:(unsigned long)tag bytesAvaliable:(unsigned long)bytesAvaliable totalBytes:(unsigned long)totalBytes{
    self = [super initWithTag:tag bytesAvaliable:bytesAvaliable totalBytes:totalBytes];
    if (self) {
        _receiveData = [NSMutableData dataWithCapacity:totalBytes];
    }
    return self;
}

- (unsigned long)readLengthWithMaxReadLength:(unsigned long)maxLength{
    if (MIN(self.bytesAvaliable, maxLength) == self.bytesAvaliable) {
        return self.bytesAvaliable;
    }else{
        return maxLength;
    }
}

- (void)appendData:(NSData *)data{
    [self modifyBytesAvaliable:data.length];
    [self.receiveData appendData:data];
}

- (BOOL)appendReadPack:(CSSocketReadPack *)pack{
    if (!pack.receiveData.length  || !self.receiveData) {
        return NO;
    }
    if (pack.tag != self.tag) {
        return NO;
    }

    [self.receiveData appendData:pack.receiveData];
    return YES;
}

- (void)modifyBytesAvaliable:(unsigned long)dataLen{
    _offset += dataLen;
    _hasBytesAvaliable = ( ABS(self.totalBytes - _offset) != 0 );
}
@end
