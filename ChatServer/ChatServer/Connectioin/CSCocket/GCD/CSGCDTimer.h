//
//  CSGCDTimer.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSGCDSource.h"

@interface CSGCDTimer : CSGCDSource

@property (nonatomic, assign, readonly) NSTimeInterval interval;
@property (nonatomic, assign, readonly) NSTimeInterval startInterval;
@property (nonatomic, assign, getter=isRuning) BOOL runing;

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                               start:(NSTimeInterval)start
                               queue:(dispatch_queue_t)queue;
- (void)setInterval:(NSTimeInterval)interval;
- (void)setStartInterval:(NSTimeInterval)startInterval;
- (void)setTimer;

@end
