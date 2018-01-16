//
//  ChatMessage.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessageProtocol.h"
#import "CSUUIDUntil.h"

//message Type Key
#define ChatMessageType             @"CM:MessageType"
#define ChatMessageId               @"CM:MessageID"
//message transport data
#define ChatMessageBody             @"CM:MessageBody"
#define ChatMessageBodyData         @"CM:MessageBodyData"
#define ChatMessageBodyDataLength   @"CM:MessageBodyDataLength"
//message Type
#define ChatNoramlMessage           @"CM:NormalMessage"
#define ChatResponseMessage         @"CM:ResponseMessage"
#define ChatRequestMessage          @"CM:RequestMessage"

@interface ChatMessage : NSObject <ChatMessageProtocol>

@property (nonatomic, strong, readonly) NSMutableDictionary *chatHeader;

@property (nonatomic, strong, readonly) NSMutableDictionary *chatBody;

- (void)addHeader:(id)value forKey:(id)key;
- (id)headerForKey:(id)key;

- (void)addBody:(id)value forKey:(id)key;
- (id)bodyForKey:(id)key;

- (void)setBodyData:(NSData *)data;
- (NSData *)bodyData;

- (instancetype)init;
- (instancetype)initWithData:(NSData *)data;
- (NSData *)toMessage;

- (NSString *)chatMessageType;
@end


#define ChatResponseCodeKey   @"CM:ResponseCode"

typedef NS_ENUM(NSUInteger, ChatResponseCode) {
    ChatResponseUnAvaiable,
    ChatResponseError       = 100,
    ChatResponseOK          = 200,
    ChatResponseNotFound    = 404
};

@interface ChatMessageResponse : ChatMessage
@property (nonatomic, assign) ChatResponseCode responseCode;
@end


#define ChatRequestMethodKey    @"CM:RequestMethod"
#define ChatRequestMethodGET    @"CM:GET"
#define ChatRequestMethodPOST   @"CM:POST"

@interface ChatMessageRequest : ChatMessage
- (void)setMethod:(NSString *)method;
- (NSString *)method;
@end








