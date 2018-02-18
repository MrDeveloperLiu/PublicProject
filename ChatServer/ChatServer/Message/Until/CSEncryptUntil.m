//
//  CSEncryptUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2018/2/10.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSEncryptUntil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation CSEncryptUntil
+ (NSData *)md5Data:(NSData *)data{
    unsigned char md5Chars[CC_MD5_DIGEST_LENGTH];
    CC_MD5((const void *)data.bytes, (CC_LONG)data.length, md5Chars);
    if (md5Chars[0] == '\0') {//是否是结束符
        return nil;
    }
    return [NSData dataWithBytes:md5Chars length:sizeof(md5Chars)/sizeof(md5Chars[0])];
}
+ (NSString *)md5String:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *md5Data = [self md5Data:data];
    if (!md5Data) {
        return nil;
    }
    unsigned char *md5Chars = (unsigned char *)md5Data.bytes;
    NSMutableString *ret = [NSMutableString string];
    for (NSInteger i = 0; i < md5Data.length; i++) {
        [ret appendFormat:@"%02x", md5Chars[i]];
    }
    return [ret lowercaseString];
}
+ (NSData *)base64DataWithString:(NSString *)string{
    if (!string.length) {
        return nil;
    }
    NSData *d = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [d base64EncodedDataWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
}
+ (NSString *)base64StringWithData:(NSData *)data{
    if (!data.length) {
        return nil;
    }
    NSData *d = [[NSData alloc] initWithBase64EncodedData:data options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
    return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}
@end
