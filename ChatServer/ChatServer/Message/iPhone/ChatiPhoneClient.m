//
//  ChatiPhoneClient.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatiPhoneClient.h"
#import "ChatiPhoneTask.h"

@interface ChatiPhoneClient ()
@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@end

@implementation ChatiPhoneClient

+ (ChatiPhoneClient *)iPhone{
    static ChatiPhoneClient *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ChatiPhoneClient alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _socketQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String],
                                             DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSOperationQueue *)requestQueue{
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
    }
    return _requestQueue;
}

- (CSTcpRequest *)tcpRequestWithChatMessageRequest:(ChatMessageRequest *)request{
    CSTcpRequestOperation *ope = [[CSTcpRequestOperation alloc] initWithRequest:request];
    CSTcpRequest *tcpReq = [[CSTcpRequest alloc] initWithCSTcpRequestOperation:ope];
    return tcpReq;
}

@end
