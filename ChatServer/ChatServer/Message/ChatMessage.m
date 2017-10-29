//
//  ChatMessage.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ChatMessage.h"


@interface ChatMessage () {
    NSData *_internalData;
}
@end

NSString *const ChatMessageBody = @"CM:MessageBody";

@implementation ChatMessage

- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        _internalData = data;
        [self parseData];
    }
    return self;
}

- (BOOL)parseData{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:_internalData
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
    if ([key isKindOfClass:[NSString class]] &&
        [key isEqualToString:ChatMessageBody]) {
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

- (NSData *)toMessage{
    NSError *error = nil;
    //addBodyIntoIt
    _chatHeader[ChatMessageBody] = _chatBody;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_chatHeader
                                    options:NSJSONWritingPrettyPrinted
                                      error:&error];
    if (error) {
        NSLog(@"Fail with - toMessage func, error = %@", error.localizedDescription);
        return nil;
    }
    return jsonData;
}


@end













