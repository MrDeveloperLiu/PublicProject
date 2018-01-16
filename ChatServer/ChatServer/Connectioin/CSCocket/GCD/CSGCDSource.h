//
//  CSGCDSource.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSAutoReleasePoolBegin  @autoreleasepool {
#define CSAutoReleasePoolEnd    }

typedef NS_ENUM(NSUInteger, CSGCDSourceType) {
    CSGCDSourceTypeNull = -1,
    CSGCDSourceTypeTimer = 0,
    CSGCDSourceTypeRead,
    CSGCDSourceTypeWrite,
    CSGCDSourceTypeAccept
};

@interface CSGCDSource : NSObject

@property (nonatomic, strong, readonly) dispatch_source_t internal;

- (instancetype)initWithSource:(dispatch_source_t)source;
- (void)setInternal:(dispatch_source_t)internal;

- (void)setEventBlock:(dispatch_block_t)eventBlock;
- (void)setCancelBlock:(dispatch_block_t)cancelBlock;

- (void)resetInternalSource;
- (void)callEventCallback;
- (void)callCancelCallback;

- (BOOL)resume;
- (BOOL)suspend;
- (BOOL)cancel;

- (unsigned long)getData;
- (CSGCDSourceType)sourceType;

@end
