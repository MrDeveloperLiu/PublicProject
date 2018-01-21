//
//  CSSocketAddress.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSSocketAddress.h"

@implementation CSSocketAddress

- (id)copyWithZone:(NSZone *)zone{
    CSSocketAddress *address = [[CSSocketAddress allocWithZone:zone] init];
    address -> _socket = self.socket;
    address -> _addrData = [self.addrData copy];
    address -> _host = [self.host copy];
    address -> _port = [self.port copy];
    address -> _address = [self.address copy];
    return address;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@> : %@", NSStringFromClass([self class]), _address];
}

- (instancetype)initWithAddress:(NSData *)address socket:(int)socket{
    self = [super init];
    if (self) {
        _socket = socket;
        _addrData = address;
        _host = [[self class] hostFromIPv4:address];
        _port = [@([[self class] portFromIPv4:address]) stringValue];
        _address = [NSString stringWithFormat:@"%@:%@", _host, _port];
    }
    return self;
}

+ (NSUInteger)portFromIPv4:(NSData *)ipv4{
    struct sockaddr_in *addr = (struct sockaddr_in *)ipv4.bytes;
    return ntohs(addr -> sin_port);
}

+ (NSString *)hostFromIPv4:(NSData *)ipv4{
    struct sockaddr_in *addr = (struct sockaddr_in *)ipv4.bytes;
    const char *host = inet_ntoa(addr -> sin_addr);
    if (!host) {
        return nil;
    }
    return [NSString stringWithUTF8String:host];
}

+ (NSString *)ipv4ToString:(NSData *)ipv4{
    struct sockaddr_in *addr = (struct sockaddr_in *)ipv4.bytes;
    const char *host = inet_ntoa(addr -> sin_addr);
    if (!host) {
        return nil;
    }
    NSString *hostFormat = [NSString stringWithUTF8String:host];
    NSUInteger portFormat = ntohs(addr -> sin_port);
    return [NSString stringWithFormat:@"%@:%@", hostFormat, @(portFormat)];
}

+ (NSData *)ipv4WithHost:(NSString *)host port:(NSUInteger)port{
    const char *hostChar = host.UTF8String;
    if (!hostChar) {
        return nil;
    }
    struct sockaddr_in          addr;
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_family             = AF_INET;
    addr.sin_port               = htons(port);
    addr.sin_addr.s_addr        = inet_addr(hostChar);
    addr.sin_len                = sizeof(addr);
    return [NSData dataWithBytes:&addr length:sizeof(addr)];
}

+ (NSData *)anyIPv4AddressWithPort:(NSUInteger)port{
    struct sockaddr_in          addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family             = AF_INET;
    addr.sin_port               = htons(port);
    addr.sin_addr.s_addr        = htonl(INADDR_ANY);
    addr.sin_len                = sizeof(addr);
    return [NSData dataWithBytes:&addr length:sizeof(addr)];
}

+ (NSData *)localAddressWithSocket:(int)socketFD{
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    socklen_t len;
    int ret = getsockname(socketFD, (struct sockaddr *)&addr, &len);
    if (0 == ret) {
        
    }else{
        
    }
    return [NSData dataWithBytes:&addr length:len];
}
@end
