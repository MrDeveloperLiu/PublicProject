//
//  CSTcpRequest.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSTcpRequest.h"
#import "AppDelegate.h"

@interface CSTcpRequest ()
@property (nonatomic, strong) CSTcpRequestOperation *operation;
@end

@implementation CSTcpRequest

- (instancetype)initWithCSTcpRequestOperation:(CSTcpRequestOperation *)operation{
    if (self = [super init]) {
        _operation = operation;
    }
    return self;
}

- (ChatMessageRequest *)request{
    return _operation.request;
}

- (void)setFinshedBlock:(CSTcpRequestOperationCompletionBlock)finshedBlock{
    _operation.finshedBlock = finshedBlock;
}
- (void)setFailedBlock:(CSTcpRequestOperationFailedBlock)failedBlock{
    _operation.failedBlock = failedBlock;
}
- (void)setProgressBlock:(CSTcpRequestOperationProgressBlock)progressBlock{
    _operation.progressBlock = progressBlock;
}

- (void)resume{
    [[[AppDelegate applicationDelegate].phoneClient requestQueue] addOperation:_operation];
}

- (void)cancel{
    [_operation cancel];
}

@end
