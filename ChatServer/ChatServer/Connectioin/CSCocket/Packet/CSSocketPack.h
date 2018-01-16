//
//  CSSocketPack.h
//  ChatServer
//
//  Created by 刘杨 on 2018/1/1.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSocketPack : NSObject

@property (nonatomic, assign) unsigned long totalBytes;
@property (nonatomic, assign) unsigned long bytesAvaliable;
@property (nonatomic, assign) unsigned long tag;

- (instancetype)initWithTag:(unsigned long)tag
             bytesAvaliable:(unsigned long)bytesAvaliable
                 totalBytes:(unsigned long)totalBytes;
@end

@interface CSSocketWritePack : CSSocketPack
@property (nonatomic, strong) NSData *sendData;
- (instancetype)initWithTag:(unsigned long)tag data:(NSData *)sendData;
@end

@interface CSSocketReadPack : CSSocketPack
@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, assign, readonly) BOOL hasBytesAvaliable;
@property (nonatomic, assign) unsigned long offset;

- (unsigned long)readLengthWithMaxReadLength:(unsigned long)maxLength;
- (void)appendData:(NSData *)data;
- (BOOL)appendReadPack:(CSSocketReadPack *)pack;
@end
