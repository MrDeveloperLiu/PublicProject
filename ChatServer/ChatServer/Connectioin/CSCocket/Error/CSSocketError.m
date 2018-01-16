//
//  CSSocketError.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSSocketError.h"

@implementation CSSocketError

+ (CSSocketError *)createSocketError{
    NSString *desc = @"fail in socket() function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeSocket
                        userInfo:userInfo];
}

+ (CSSocketError *)nonBlockError{
    NSString *desc = @"fail in fcntl() - nonblock function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeNonBlock
                        userInfo:userInfo];

}
+ (CSSocketError *)reuseAddressError{
    NSString *desc = @"fail in setsockopt() - reuse addr function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeReuseAddress
                        userInfo:userInfo];

}
+ (CSSocketError *)bindError{
    NSString *desc = @"fail in bind() function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeBind
                        userInfo:userInfo];

}
+ (CSSocketError *)listenError{
    NSString *desc = @"fail in listen() function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeListen
                        userInfo:userInfo];

}
+ (CSSocketError *)nosigpipeError{
    NSString *desc = @"fail in setsockopt() - no sigpipe function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeNoSigpipe
                        userInfo:userInfo];
    
}
+ (CSSocketError *)acceptError{
    NSString *desc = @"fail in accept() function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeAccept
                        userInfo:userInfo];
    
}
+ (CSSocketError *)connectError{
    NSString *desc = @"fail in connect() function";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeConnect
                        userInfo:userInfo];
    
}
+ (CSSocketError *)disconnectError{
    NSString *desc = @"no error, disconnect socket by client";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeNone
                        userInfo:userInfo];
}

+ (CSSocketError *)remoteDisconnectError{
    NSString *desc = @"no error, socket maybe closed by remote client";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeNone
                        userInfo:userInfo];
}

+ (CSSocketError *)connectTimeoutError:(NSTimeInterval)timeout{
    NSString *desc = [NSString stringWithFormat:@"connect() timer timeout (%f)", timeout];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeConnectTimeout
                        userInfo:userInfo];

}
+ (CSSocketError *)readTimeoutError:(NSTimeInterval)timeout{
    NSString *desc = [NSString stringWithFormat:@"read() timer timeout (%f)", timeout];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeReadTimeout
                        userInfo:userInfo];
    
}
+ (CSSocketError *)writeTimeoutError:(NSTimeInterval)timeout{
    NSString *desc = [NSString stringWithFormat:@"write() timer timeout (%f)", timeout];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
    return [self errorWithDomain:NSStringFromClass([self class])
                            code:CSSocketErrorCodeWriteTimeout
                        userInfo:userInfo];

}

@end










