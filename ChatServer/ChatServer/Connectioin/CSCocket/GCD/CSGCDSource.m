//
//  CSGCDSource.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSGCDSource.h"

@interface CSGCDSource ()
@property (nonatomic, strong) dispatch_source_t internal;
@property (nonatomic, copy) dispatch_block_t eventCallback;
@property (nonatomic, copy) dispatch_block_t cancelCallback;
@end

@implementation CSGCDSource

- (void)dealloc{
    [self cancel];
    self.internal = nil;
    self.eventCallback = nil;
    self.cancelCallback = nil;
}

- (instancetype)init{
    return [self initWithSource:nil];
}

- (instancetype)initWithSource:(dispatch_source_t)source{
    self = [super init];
    if (self) {
        [self maybeInitSource:source];
    }
    return self;
}

- (void)maybeInitSource:(dispatch_source_t)source{
    if (source == NULL) {
        return;
    }
    __block dispatch_source_t src = source;
    dispatch_source_set_event_handler(source, ^{
        [self callEventCallback];
    });
    dispatch_source_set_cancel_handler(source, ^{
        [self callCancelCallback];
        src = nil;
    });
    _internal = source;
}

- (void)setInternal:(dispatch_source_t)internal{
    _internal = internal;
}

- (void)setEventBlock:(dispatch_block_t)eventBlock{
    self.eventCallback = eventBlock;
}

- (void)setCancelBlock:(dispatch_block_t)cancelBlock{
    self.cancelCallback = cancelBlock;
}

- (void)resetInternalSource{
    if ([self cancel]) {
        _internal = nil;
    }
}

- (void)callEventCallback{
    if (self.eventCallback) { CSAutoReleasePoolBegin
        self.eventCallback();
    CSAutoReleasePoolEnd }
}
- (void)callCancelCallback{
    if (self.cancelCallback) { CSAutoReleasePoolBegin
        self.cancelCallback();
    CSAutoReleasePoolEnd }
}

- (BOOL)resume{
    if (_internal == NULL) {
        return NO;
    }
    dispatch_resume(self.internal);
    return YES;
}

- (BOOL)suspend{
    if (_internal == NULL) {
        return NO;
    }
    dispatch_suspend(self.internal);
    return YES;
}

- (BOOL)cancel{
    if (_internal == NULL) {
        return NO;
    }
    dispatch_source_cancel(self.internal);
    return YES;
}

- (unsigned long)getData{
    if (_internal == NULL) {
        return 0;
    }
    return dispatch_source_get_data(self.internal);
}

- (CSGCDSourceType)sourceType{
    return CSGCDSourceTypeNull;
}
@end
