//
//  FriendSqliteHelper.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendModel;
@interface FriendSqliteHelper : NSObject

@end

@interface FriendModel : NSObject
@property (nonatomic, assign, readonly) uint64_t userid;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *markname;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *phone;

@property (nonatomic, assign) int state;
@property (nonatomic, assign) int black;
@end
