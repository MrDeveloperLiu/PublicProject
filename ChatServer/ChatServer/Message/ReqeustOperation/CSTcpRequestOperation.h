//
//  CSTcpRequestOperation.h
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSBaseOperation.h"
#import "ChatMessage.h"
#import "ChatConnection.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CSUserDefaultStore.h"

@class CSTcpRequestOperation;
typedef void(^CSTcpRequestOperationProgressBlock)(CSTcpRequestOperation *operation, CGFloat progress);
typedef void(^CSTcpRequestOperationCompletionBlock)(CSTcpRequestOperation *operation, ChatMessageResponse *resp);
typedef void(^CSTcpRequestOperationFailedBlock)(CSTcpRequestOperation *operation, NSError *error);

@interface CSTcpRequestOperation : CSBaseOperation <ChatConnectionDelegate>

@property (nonatomic, strong, readonly) ChatMessageRequest *request;

- (instancetype)initWithRequest:(ChatMessageRequest *)request;

@property (nonatomic, copy) CSTcpRequestOperationProgressBlock progressBlock;
@property (nonatomic, copy) CSTcpRequestOperationCompletionBlock finshedBlock;
@property (nonatomic, copy) CSTcpRequestOperationFailedBlock failedBlock;

@end
