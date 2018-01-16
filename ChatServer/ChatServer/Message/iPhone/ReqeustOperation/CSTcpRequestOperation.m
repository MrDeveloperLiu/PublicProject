//
//  CSTcpRequestOperation.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSTcpRequestOperation.h"

@interface CSTcpRequestOperation ()
@property (nonatomic, strong) ChatMessageRequest *request;
@property (nonatomic, strong) CSSocket *socket;
@end

@implementation CSTcpRequestOperation

- (instancetype)initWithRequest:(ChatMessageRequest *)request{
    if (self = [super init]) {
        _request = request;
        
        _socket = [[CSSocket alloc] initWithDelegate:self handleQueue:nil];
    }
    return self;
}

- (void)start{
    [super start];
    
    NSString *host = [CSUserDefaultStore host];
    NSInteger port = [CSUserDefaultStore port];
    if (host && port) {
        NSData *address = [CSSocketAddress ipv4WithHost:host port:port];
        [_socket connectToTheAddress:address timeOut:10 error:nil];
    }else{
        [self callError:[NSError errorWithDomain:@"host and port nil" code:0 userInfo:nil]];
    }
}
- (void)callError:(NSError *)error{
    if (self.failedBlock) {
        self.failedBlock(self, error);
        self.failedBlock = nil;
    }
    self.finished = YES;
}
- (void)onSocket:(CSSocket *)s didReadDone:(NSData *)data{
    ChatMessageResponse *resp = [[ChatMessageResponse alloc] initWithData:data];
    [s disconnect];
    if (self.finshedBlock) {
        self.finshedBlock(self, resp);
        self.finshedBlock = nil;
    }
}
- (void)onSocket:(CSSocket *)s didReadData:(NSData *)data progress:(double)progress{
    if (self.progressBlock) {
        self.progressBlock(self, progress);
    }
}
- (void)onSocket:(CSSocket *)s didConnectToTheHost:(NSString *)host port:(NSString *)port{
    [s writeData:_request.toMessage timeOut:10];
}
- (void)onSocket:(CSSocket *)s didDisConnectToTheHost:(NSString *)host port:(NSString *)port{
    self.progressBlock = nil;
    self.finished = YES;
}
@end
