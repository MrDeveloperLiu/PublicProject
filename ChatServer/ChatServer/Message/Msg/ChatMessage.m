//
//  ChatMessage.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatMessage.h"


@interface ChatMessage () {
@protected
    
    NSData *_internalData;
    NSData *_bodyData;
    NSData *_jsonLenData;
    NSData *_jsonData;
    
    NSMutableDictionary *_chatHeader;
    NSMutableDictionary *_chatBody;
}
@end
@implementation ChatMessage
//RES
- (instancetype)initWithResponseCode:(ChatResponseCode)code{
    self = [super init];
    if (self) {
        _messageType = ChatMessageTypeResponse;
        self.responseCode = code;
    }
    return self;
}
//REQ
- (instancetype)init{
    if (self = [super init]) {
        _messageType = ChatMessageTypeRequest;
        _chatHeader = [NSMutableDictionary dictionary];
        _chatBody = [NSMutableDictionary dictionary];
    }
    return self;
}
//RES
- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        _messageType = ChatMessageTypeUnkown;
        _internalData = data;
        if ([data length]) {
            [self parseData];
        }
    }
    return self;
}

- (void)addHeader:(id)value forKey:(id)key{
    if ([key isEqualToString:ChatMessageBodyKey]) {
        return;
    }
    if (key) {
        _chatHeader[key] = value;
    }
}
- (id)headerForKey:(id)key{
    return _chatHeader[key];
}

- (void)addBody:(id)value forKey:(id)key{
    if (key) {
        _chatBody[key] = value;
    }
}
- (id)bodyForKey:(id)key{
    return _chatBody[key];
}

- (void)setBodyData:(NSData *)data{
    _bodyData = data;
}
- (NSData *)bodyData{
    return _bodyData;
}

- (void)setResponseCode:(ChatResponseCode)responseCode{
    _responseCode = responseCode;
    [self addHeader:@(responseCode) forKey:ChatResponseCodeKey];
}
- (void)setMethod:(NSString *)method{
    [_chatHeader setObject:method forKey:ChatRequestMethodKey];
}

- (NSString *)method{
    return [_chatHeader objectForKey:ChatRequestMethodKey];
}

- (NSData *)toMessage{
    NSInteger jsonDataLength = 2;
    NSError *error = nil;
    _chatHeader[ChatMessageTypeKey] = [self __chatMessageTypeWithKey:_messageType];
    if (_chatBody.allValues.count) {//addBodyIntoIt
        _chatHeader[ChatMessageBodyKey] = _chatBody;
    }
    _jsonData = [CSJsonUntil toJsonWithObject:_chatHeader error:&error];
    if (error) {
        NSLog(@"Fail with - toMessage func, error = %@", error.localizedDescription);
        return nil;
    }
    
    NSInteger jsonLen = [_jsonData length];
    _jsonLenData = [NSData dataWithBytes:&jsonLen length:jsonDataLength];
    NSMutableData *retVal = [NSMutableData data];
    //jsonlen
    [retVal appendData:_jsonLenData];
    //json
    [retVal appendData:_jsonData];
    //body
    if ([self bodyData]) {
        [retVal appendData:[self bodyData]];
    }
    return retVal;
}

- (BOOL)parseData{
    NSInteger jsonDataLength = 2;
    _jsonLenData = [_internalData subdataWithRange:(NSRange){0, jsonDataLength}];
    NSInteger jsonLen = *((NSInteger *)_jsonLenData.bytes);
    
    //json
    _jsonData = [_internalData subdataWithRange:(NSRange){jsonDataLength, jsonLen}];
    NSInteger bodyLen = _internalData.length - (jsonLen + jsonDataLength);
    //body
    if (bodyLen > 0) {
        [self setBodyData:[_internalData subdataWithRange:(NSRange){(jsonLen + jsonDataLength), bodyLen}]];
    }
    NSError *error = nil;
    id object = [CSJsonUntil jsonWithData:_jsonData error:&error];
    if (error) {
        NSLog(@"Fail with - parseData func, error = %@", error.localizedDescription);
        return NO;
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        _chatHeader = object;
        _chatBody = _chatHeader[ChatMessageBodyKey];
        _messageType = [self __typeWithChatMessageTypeKey:[self chatMessageType]];
        _responseCode = [_chatHeader[ChatResponseCodeKey] unsignedIntegerValue];
        return YES;
    }
    NSLog(@"Fail with - parseData func, is not a NSDictionary class");
    return NO;
}


- (NSString *)chatMessageType{
    return _chatHeader[ChatMessageTypeKey];
}

- (NSString *)description{
    return _chatHeader.description;
}


- (ChatMessageType)__typeWithChatMessageTypeKey:(NSString *)key{
    if ([key isEqualToString:ChatRequestMessage]) {
        return ChatMessageTypeRequest;
    }else if ([key isEqualToString:ChatResponseMessage]){
        return ChatMessageTypeResponse;
    }
    return ChatMessageTypeUnkown;
}
- (NSString *)__chatMessageTypeWithKey:(ChatMessageType)type{
    switch (type) {
        case ChatMessageTypeRequest: return ChatRequestMessage;
        case ChatMessageTypeResponse: return ChatResponseMessage;
        default: break;
    }
    return ChatUnkownMessage;
}
@end










