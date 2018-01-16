//
//  CSTcpRequest.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSTcpRequestOperation.h"

@interface CSTcpRequest : NSObject

@property (nonatomic, strong, readonly) ChatMessageRequest *request;

- (instancetype)initWithCSTcpRequestOperation:(CSTcpRequestOperation *)operation;

@property (nonatomic, copy) CSTcpRequestOperationProgressBlock progressBlock;
@property (nonatomic, copy) CSTcpRequestOperationCompletionBlock finshedBlock;
@property (nonatomic, copy) CSTcpRequestOperationFailedBlock failedBlock;

- (void)resume;
- (void)cancel;
@end
