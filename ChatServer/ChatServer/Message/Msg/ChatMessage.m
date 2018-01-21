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

- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        _internalData = data;
        if ([data length]) {
            [self parseData];
        }
    }
    return self;
}

- (BOOL)parseData{
    NSInteger jsonLenLocation = 1;
    _jsonLenData = [_internalData subdataWithRange:(NSRange){0, jsonLenLocation}];
    NSInteger jsonLen = *((NSInteger *)_jsonLenData.bytes);
    
    
    _jsonData = [_internalData subdataWithRange:(NSRange){jsonLenLocation, jsonLen}];
    NSInteger bodyLen = _internalData.length - (jsonLen + jsonLenLocation);
    
    if (bodyLen > 0) {
        [self setBodyData:[_internalData subdataWithRange:(NSRange){(jsonLen + jsonLenLocation), bodyLen}]];
    }
    @try {
        NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:_jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
        if (error) {
            NSLog(@"Fail with - parseData func, error = %@", error.localizedDescription);
            return NO;
        }
        if ([object isKindOfClass:[NSDictionary class]]) {
            _chatHeader = object;
            _chatBody = _chatHeader[ChatMessageBody];
            return YES;
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSLog(@"Fail with - parseData func, is not a NSDictionary class");
    return NO;
}

- (instancetype)init{
    if (self = [super init]) {
        _chatHeader = [NSMutableDictionary dictionary];
        _chatBody = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addHeader:(id)value forKey:(id)key{
    if ([key isEqualToString:ChatMessageBody]) {
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

- (NSData *)toMessage{
    NSError *error = nil;
    _chatHeader[ChatMessageType] = [(id <ChatMessageProtocol>)self messageType];
    if (_chatBody.allValues.count) {//addBodyIntoIt
        _chatHeader[ChatMessageBody] = _chatBody;
    }
    @try {
        _jsonData = [NSJSONSerialization dataWithJSONObject:_chatHeader
                                        options:NSJSONWritingPrettyPrinted
                                          error:&error];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    NSInteger jsonLen = [_jsonData length];
    _jsonLenData = [NSData dataWithBytes:&jsonLen length:1];
    
    NSMutableData *retVal = [NSMutableData data];
    [retVal appendData:_jsonLenData];
    if ([self bodyData]) {
        _chatHeader[ChatMessageBodyData] = @(YES);
        _chatHeader[ChatMessageBodyDataLength] = @([[self bodyData] length]);
    }else{
        _chatHeader[ChatMessageBodyData] = @(NO);
    }
    [retVal appendData:_jsonData];
    if ([self bodyData]) {
        [retVal appendData:[self bodyData]];
    }
    if (error) {
        NSLog(@"Fail with - toMessage func, error = %@", error.localizedDescription);
        return nil;
    }
    return retVal;
}

- (NSString *)messageType{
    return ChatNoramlMessage;
}

- (NSString *)chatMessageType{
    return _chatHeader[ChatMessageType];
}

- (NSString *)description{
    return _chatHeader.description;
}
@end


@implementation ChatMessageResponse

- (void)setResponseCode:(ChatResponseCode)responseCode{
    _responseCode = responseCode;
    [self addHeader:@(responseCode) forKey:ChatResponseCodeKey];
}

- (BOOL)parseData{
    BOOL retVal = [super parseData];
    _responseCode = [_chatHeader[ChatResponseCodeKey] unsignedIntegerValue];
    return retVal;
}

- (NSString *)messageType{
    return ChatResponseMessage;
}
@end

@implementation ChatMessageRequest

- (void)setMethod:(NSString *)method{
    [_chatHeader setObject:method forKey:ChatRequestMethodKey];
}

- (NSString *)method{
    return [_chatHeader objectForKey:ChatRequestMethodKey];
}

- (NSString *)messageType{
    return ChatRequestMessage;
}
@end










