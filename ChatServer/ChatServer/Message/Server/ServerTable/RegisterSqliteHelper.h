//
//  RegisterSqliteHelper.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RegisterModel;
@interface RegisterSqliteHelper : NSObject

- (BOOL)initTable;
- (BOOL)insertIntoTableWithAccount:(NSString *)account password:(NSString *)password state:(int)state userId:(uint64_t)userId;
- (BOOL)updateTableWithAccount:(NSString *)account password:(NSString *)password state:(int)state;
- (NSArray <RegisterModel *> *)quaryWithAccount:(NSString *)account;
- (NSArray <RegisterModel *> *)quaryWithUserid:(uint64_t)userid;
- (BOOL)deleteWithUserid:(uint64_t)userid;

@end

@interface RegisterModel : NSObject
@property (nonatomic, assign) int64_t userid;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) int state;
@end
