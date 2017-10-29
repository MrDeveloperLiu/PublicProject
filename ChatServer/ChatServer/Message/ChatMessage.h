//
//  ChatMessage.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *chatHeader;

@property (nonatomic, strong, readonly) NSMutableDictionary *chatBody;

- (void)addHeader:(id)value forKey:(id)key;
- (id)headerForKey:(id)key;

- (void)addBody:(id)value forKey:(id)key;
- (id)bodyForKey:(id)key;


- (instancetype)init;
- (instancetype)initWithData:(NSData *)data;
- (NSData *)toMessage;

@end
