//
//  CSGCDRead.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/30.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSGCDRead.h"

@interface CSGCDRead ()
@end

@implementation CSGCDRead

- (instancetype)initWithSocket:(int)socket{
    NSString *queueName = [NSStringFromClass([self class]) stringByAppendingPathExtension:@(socket).stringValue];
    dispatch_queue_t queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    dispatch_source_t s = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, socket, 0, queue);
    self = [super initWithSocket:socket queue:queue source:s];
    if (self) {
        
    }
    return self;
}


- (void)resetInternalSource{
    [super resetInternalSource];
    
    __block dispatch_source_t s = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                                         self.socket, 0, self.handleQueue);
    dispatch_source_set_event_handler(s, ^{ CSAutoReleasePoolBegin
        [self callEventCallback];
    CSAutoReleasePoolEnd });
    dispatch_source_set_cancel_handler(s, ^{ CSAutoReleasePoolBegin
        [self callCancelCallback];
        s = nil;
    CSAutoReleasePoolEnd });
    
    [self setInternal:s];
}

- (CSGCDSourceType)sourceType{
    return CSGCDSourceTypeRead;
}
@end
