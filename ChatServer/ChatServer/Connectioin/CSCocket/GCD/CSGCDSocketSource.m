//
//  CSGCDSocketSource.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/15.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSGCDSocketSource.h"

@implementation CSGCDSocketSource

- (void)dealloc{
    self.handleQueue = nil;
    self.socket = 0;
    self.open = NO;
}

- (instancetype)initWithSocket:(int)socket queue:(dispatch_queue_t)queue source:(dispatch_source_t)source{
    self = [super initWithSource:source];
    if (self) {
        self.socket = socket;
        self.handleQueue = queue;
    }
    return self;
}

- (BOOL)resume{
    if (!self.internal) {
        [self resetInternalSource];
    }
    BOOL ret = [super resume];
    self.runing = ret;
    self.open = ret;
    return ret;
}

- (BOOL)cancel{
    BOOL ret = [super cancel];
    self.runing = NO;
    self.open = NO;
    if (self.internal) {
        [self setInternal:nil];
    }
    return ret;
}

- (BOOL)suspend{
    BOOL ret = [super suspend];
    self.runing = NO;
    return ret;
}


@end
