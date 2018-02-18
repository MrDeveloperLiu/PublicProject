//
//  RegisterSqliteHelper.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "SqliteHelperProtocol.h"

typedef enum {
    RegisterStateInit = 0,
    RegisterStateUnregister = 1,
    RegisterStateRegister,
} RegisterState;

@class RegisterModel;
@interface RegisterSqliteHelper : NSObject <SqliteHelperProtocol>

- (BOOL)insertIntoTableWithModel:(RegisterModel *)model;

- (BOOL)updateTableWithModel:(RegisterModel *)model;
- (BOOL)updatePhone:(NSString *)phone withUserid:(uint64_t)userid;
- (BOOL)updateState:(RegisterState)state withUserid:(uint64_t)userid;
- (BOOL)updatePassword:(NSString *)password withUserid:(uint64_t)userid;
- (BOOL)updateSocketKey:(NSUInteger)socketKey address:(NSString *)address withUserid:(uint64_t)userid;

- (RegisterModel *)quaryWithAccount:(NSString *)account;
- (RegisterModel *)quaryWithUserid:(uint64_t)userid;
- (BOOL)deleteWithUserid:(uint64_t)userid;
- (NSInteger)quaryCount;

@end
@interface RegisterModel : NSObject
@property (nonatomic, assign) uint64_t userid;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) RegisterState state;
@property (nonatomic, assign) NSUInteger socket;
@property (nonatomic, copy) NSString *address;

- (instancetype)initWithUserId:(uint64_t)userId account:(NSString *)account
                      password:(NSString *)password phone:(NSString *)phone
                         state:(RegisterState)state;
@end
