//
//  ChatMessage.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSUUIDUntil.h"
#import "CSJsonUntil.h"

//message Type Key
#define ChatMessageTypeKey             @"CM:MessageType"
#define ChatMessageIdKey               @"CM:MessageID"
//message transport data
#define ChatMessageBodyKey             @"CM:MessageBody"

//message Type
#define ChatUnkownMessage           @"CM:UnkownMessage"
#define ChatResponseMessage         @"CM:ResponseMessage"
#define ChatRequestMessage          @"CM:RequestMessage"
typedef NS_ENUM(NSUInteger, ChatMessageType) {
    ChatMessageTypeUnkown   = 0,
    ChatMessageTypeRequest  = 1,
    ChatMessageTypeResponse = 2
};
#define ChatResponseCodeKey         @"CM:ResponseCode"
typedef NS_ENUM(NSUInteger, ChatResponseCode) {
    ChatResponseUnAvaiable  = 0,
    ChatResponseError       = 100,
    ChatResponseOK          = 200,
    ChatResponseNotFound    = 404
};
#define ChatRequestMethodKey        @"CM:RequestMethod"
#define ChatRequestMethodGET        @"CM:GET"
#define ChatRequestMethodPOST       @"CM:POST"


@interface ChatMessage : NSObject

@property (nonatomic, assign) ChatResponseCode responseCode;
@property (nonatomic, assign, readonly) ChatMessageType messageType;
@property (nonatomic, strong, readonly) NSMutableDictionary *chatHeader;
@property (nonatomic, strong, readonly) NSMutableDictionary *chatBody;

- (void)setMethod:(NSString *)method;
- (NSString *)method;

- (void)addHeader:(id)value forKey:(id)key;
- (id)headerForKey:(id)key;

- (void)addBody:(id)value forKey:(id)key;
- (id)bodyForKey:(id)key;

- (void)setBodyData:(NSData *)data;
- (NSData *)bodyData;

- (instancetype)init;
- (instancetype)initWithResponseCode:(ChatResponseCode)code;
- (instancetype)initWithData:(NSData *)data;

- (NSData *)toMessage;
- (NSString *)chatMessageType;
@end





