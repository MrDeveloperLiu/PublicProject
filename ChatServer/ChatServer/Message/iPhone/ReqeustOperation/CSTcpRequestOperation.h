//
//  CSTcpRequestOperation.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSBaseOperation.h"
#import "ChatMessage.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CSUserDefaultStore.h"
#import "ChatConnection.h"

@class CSTcpRequestOperation;
typedef void(^CSTcpRequestOperationProgressBlock)(CSTcpRequestOperation *operation, NSData *data, CGFloat progress);
typedef void(^CSTcpRequestOperationCompletionBlock)(CSTcpRequestOperation *operation, ChatMessage *resp);
typedef void(^CSTcpRequestOperationFailedBlock)(CSTcpRequestOperation *operation, NSError *error);

@interface CSTcpRequestOperation : CSBaseOperation

@property (nonatomic, strong, readonly) ChatMessage *request;

- (instancetype)initWithRequest:(ChatMessage *)request;

@property (nonatomic, copy) CSTcpRequestOperationProgressBlock progressBlock;
@property (nonatomic, copy) CSTcpRequestOperationCompletionBlock finshedBlock;
@property (nonatomic, copy) CSTcpRequestOperationFailedBlock failedBlock;

@end
