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
@property (nonatomic, strong) ChatConnection *connection;
@end

@implementation CSTcpRequestOperation

- (instancetype)initWithRequest:(ChatMessageRequest *)request{
    if (self = [super init]) {
        _request = request;
        
        _connection = [[ChatConnection alloc] init];
        _connection.delegate = self;
    }
    return self;
}

- (void)start{
    [super start];
    
    NSString *host = [CSUserDefaultStore host];
    NSInteger port = [CSUserDefaultStore port];
    if (host && port) {
        [_connection connectToHost:host port:port timeout:10];
    }else{
        [self callError:[NSError errorWithDomain:@"host and port nil" code:0 userInfo:nil]];
    }
}

- (void)callError:(NSError *)error{
    if (self.failedBlock) {
        self.failedBlock(self, error);
        self.failedBlock = nil;
    }
}

- (void)chatConnection:(ChatConnection *)connection didConnectToHost:(NSString *)host{
    [connection sendRequest:_request];
}
- (void)chatConnection:(ChatConnection *)connection didDisconnectToHost:(NSString *)host error:(NSError *)error{
    self.progressBlock = nil;
    if (error) {
        [self callError:error];
    }
    self.finished = YES;
}
- (void)chatConnection:(ChatConnection *)connection didReceiveData:(NSData *)data progress:(double)progress{
    if (self.progressBlock) {
        self.progressBlock(self, progress);
    }
}
- (void)chatConnection:(ChatConnection *)connection didReceiveDone:(NSData *)response{
    ChatMessageResponse *resp = [[ChatMessageResponse alloc] initWithData:response];
    [connection disconnect];
    if (self.finshedBlock) {
        self.finshedBlock(self, resp);
        self.finshedBlock = nil;
    }
}

@end
