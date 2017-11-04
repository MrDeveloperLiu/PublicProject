//
//  CSBaseOperation.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSBaseOperation.h"

@implementation CSBaseOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start{
    if (self.isCancelled) {
        return;
    }
    [super start];
}

- (void)main{
    [super main];
}

- (void)cancel{
    if (self.isFinished) {
        return;
    }
    [super cancel];
}

- (void)setExecuting:(BOOL)executing{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}
@end






