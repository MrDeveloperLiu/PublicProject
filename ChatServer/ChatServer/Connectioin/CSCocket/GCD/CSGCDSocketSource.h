//
//  CSGCDSocketSource.h
//  ChatServer
//
//  Created by 刘杨 on 2018/1/15.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSGCDSource.h"

@interface CSGCDSocketSource : CSGCDSource
@property (nonatomic, assign) int socket;
@property (nonatomic, strong) dispatch_queue_t handleQueue;
@property (nonatomic, assign, getter=isOpen) BOOL open;
@property (nonatomic, assign, getter=isRuning) BOOL runing;

- (instancetype)initWithSocket:(int)socket queue:(dispatch_queue_t)queue source:(dispatch_source_t)source;
@end
