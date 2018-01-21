//
//  CSGCDTimer.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSGCDTimer.h"

@interface CSGCDTimer ()
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSTimeInterval startInterval;
@property (nonatomic, strong) dispatch_queue_t handleQueue;
@end

@implementation CSGCDTimer

- (void)dealloc{
    self.handleQueue = nil;
    self.runing = NO;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval start:(NSTimeInterval)start queue:(dispatch_queue_t)queue{
    self = [super initWithSource:nil];
    if (self) {
        self.handleQueue = queue;
        self.startInterval = start;
        self.interval = interval;
        [self setTimer];
    }
    return self;
}

+ (dispatch_source_t)createSourceWithQueue:(dispatch_queue_t)queue{
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0,
                                                     0,
                                                     queue);
    return timer;
}

- (void)setInterval:(NSTimeInterval)interval{
    _interval = interval;
}

- (void)setTimer{
    [self resetInternalSource];
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * self.startInterval);
    __block dispatch_source_t timer = [[self class] createSourceWithQueue:self.handleQueue];
    dispatch_source_set_timer(timer,
                              when,
                              NSEC_PER_SEC * self.interval,
                              0);
    
    __weak __typeof(self) ws = self;
    dispatch_source_set_event_handler(timer, ^{ CSAutoReleasePoolBegin
        [ws callEventCallback];
    CSAutoReleasePoolEnd });
    dispatch_source_set_cancel_handler(timer, ^{ CSAutoReleasePoolBegin
        [ws callCancelCallback];
        timer = nil;
    CSAutoReleasePoolEnd });
    [self setInternal:timer];
}

- (void)callEventCallback{
    [super callEventCallback];
    if (self.interval <= 0) {
        [self cancel];//never repeat
    }
}

- (BOOL)resume{
    if (!self.internal) {
        [self setTimer];
    }
    BOOL ret = [super resume];
    self.runing = YES;
    return ret;
}

- (BOOL)cancel{
    BOOL ret = [super cancel];
    if (self.internal) {
        [self setInternal:nil];
    }
    self.runing = NO;
    return ret;
}

- (BOOL)suspend{
    BOOL ret = [super suspend];
    self.runing = NO;
    return ret;
}

- (CSGCDSourceType)sourceType{
    return CSGCDSourceTypeTimer;
}
@end
