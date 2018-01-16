//
//  CSSocketError.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSSocketErrorSuccess 0
#define CSSocketErrorError -1

typedef NS_ENUM(NSInteger, CSSocketErrorCode) {
    CSSocketErrorCodeNone,
    CSSocketErrorCodeSocket = 1,
    CSSocketErrorCodeNonBlock,
    CSSocketErrorCodeReuseAddress,
    CSSocketErrorCodeBind,
    CSSocketErrorCodeListen,
    CSSocketErrorCodeNoSigpipe,
    CSSocketErrorCodeAccept,
    CSSocketErrorCodeConnect,
    CSSocketErrorCodeConnectTimeout,
    CSSocketErrorCodeReadTimeout,
    CSSocketErrorCodeWriteTimeout,
};

@interface CSSocketError : NSError

+ (CSSocketError *)createSocketError;
+ (CSSocketError *)nonBlockError;
+ (CSSocketError *)reuseAddressError;
+ (CSSocketError *)bindError;
+ (CSSocketError *)listenError;
+ (CSSocketError *)nosigpipeError;
+ (CSSocketError *)acceptError;
+ (CSSocketError *)connectError;
+ (CSSocketError *)disconnectError;
+ (CSSocketError *)remoteDisconnectError;
+ (CSSocketError *)connectTimeoutError:(NSTimeInterval)timeout;
+ (CSSocketError *)readTimeoutError:(NSTimeInterval)timeout;
+ (CSSocketError *)writeTimeoutError:(NSTimeInterval)timeout;
@end
