//
//  CSGCDAccept.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/30.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSGCDSocketSource.h"

@interface CSGCDAccept : CSGCDSocketSource

- (instancetype)initWithSocket:(int)socket queue:(dispatch_queue_t)queue;

@end
