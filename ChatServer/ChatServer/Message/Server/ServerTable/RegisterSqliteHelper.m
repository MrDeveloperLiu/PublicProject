//
//  RegisterSqliteHelper.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "RegisterSqliteHelper.h"
#import "ChatServerClient.h"

@implementation RegisterSqliteHelper

- (NSString *)tableName{
    return @"Register";
}
- (BOOL)createTable{
    __block BOOL ret = NO;
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ \
                         (account text primary key,\
                         userid integer,\
                         password text,\
                         phone text,\
                         state integer,\
                         socket integer,\
                         address text,\
                         reserved0 text,\
                         reserved1 text,\
                         reserved2 text,\
                         reserved3 text,\
                         reserved4 text);", [self tableName]];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}
- (BOOL)updateTable:(NSInteger)version{
    return YES;
}

- (BOOL)deleteWithUserid:(uint64_t)userid{
    __block BOOL ret = NO;
    
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where userid = '%lld';", [self tableName], userid];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (BOOL)updateTableWithModel:(RegisterModel *)model{
    if (model.userid <= 0) {
        return NO;
    }
    __block BOOL ret = NO;
    NSMutableString *update = [NSMutableString string];
    if (model.phone) {
        [update appendFormat:@"phone = '%@'", model.phone];
    }
    if (model.password) {
        if (update.length) [update appendString:@" "];
        [update appendFormat:@"password = '%@'", model.password];
    }
    if (model.state) {
        if (update.length) [update appendString:@" "];
        [update appendFormat:@"state = '%d'", model.state];
    }
    if (model.socket) {
        if (update.length) [update appendString:@" "];
        [update appendFormat:@"state = '%d'", (int)model.socket];
    }
    if (model.address) {
        if (update.length) [update appendString:@" "];
        [update appendFormat:@"address = '%@'", model.address];
    }
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where userid = '%lld';", [self tableName], update, model.userid];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (BOOL)updatePhone:(NSString *)phone withUserid:(uint64_t)userid{
    RegisterModel *m = [[RegisterModel alloc] initWithUserId:userid account:nil password:nil phone:phone state:0];
    return [self updateTableWithModel:m];
}
- (BOOL)updateState:(RegisterState)state withUserid:(uint64_t)userid{
    RegisterModel *m = [[RegisterModel alloc] initWithUserId:userid account:nil password:nil phone:nil state:state];
    return [self updateTableWithModel:m];
}
- (BOOL)updatePassword:(NSString *)password withUserid:(uint64_t)userid{
    RegisterModel *m = [[RegisterModel alloc] initWithUserId:userid account:nil password:password phone:nil state:0];
    return [self updateTableWithModel:m];
}
- (BOOL)updateSocketKey:(NSUInteger)socketKey address:(NSString *)address withUserid:(uint64_t)userid{
    RegisterModel *m = [[RegisterModel alloc] init];
    m.userid = userid;
    m.socket = socketKey;
    m.address = address;
    return [self updateTableWithModel:m];
}
- (RegisterModel *)quaryWithAccount:(NSString *)account{
    __block RegisterModel *registerM = nil;
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where account = '%@';", [self tableName], account];
        FMResultSet *set = [db executeQuery:sql];
        if ([set next]) {
            NSDictionary *dict = [self _tansferDictWithSet:set];
            registerM = [[RegisterModel alloc] init];
            [registerM setValuesForKeysWithDictionary:dict];
        }
        [set close];
    }];
    return registerM;
}

- (RegisterModel *)quaryWithUserid:(uint64_t)userid{
    __block RegisterModel *registerM = nil;
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where userid = '%lld';", [self tableName], userid];
        FMResultSet *set = [db executeQuery:sql];
        
        if ([set next]) {
            NSDictionary *dict = [self _tansferDictWithSet:set];
            registerM = [[RegisterModel alloc] init];
            [registerM setValuesForKeysWithDictionary:dict];
        }
        [set close];
    }];
    return registerM;
}

- (NSDictionary *)_tansferDictWithSet:(FMResultSet *)set{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"account"] = [set stringForColumn:@"account"];
    dict[@"password"] = [set stringForColumn:@"password"];
    dict[@"phone"] = [set stringForColumn:@"phone"];
    dict[@"state"] = @([set intForColumn:@"state"]);
    dict[@"userid"] = @([set longLongIntForColumn:@"userid"]);
    return dict;
}

- (BOOL)insertIntoTableWithModel:(RegisterModel *)model{
    __block BOOL ret = NO;
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (account, password, state, userid, phone) values ('%@', '%@', '%d', '%lld', '%@');", [self tableName], model.account, model.password, model.state, model.userid, model.phone];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (NSInteger)quaryCount{
    __block NSInteger count = 0;
    [ChatServerClient inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where userid != 0;", [self tableName]];
        FMResultSet *set = [db executeQuery:sql];
        if ([set next]) {
            count = [set intForColumnIndex:0];
        }
        [set close];
    }];
    return count;

}
@end

@implementation RegisterModel

- (instancetype)initWithUserId:(uint64_t)userId account:(NSString *)account password:(NSString *)password phone:(NSString *)phone state:(RegisterState)state{
    self = [super init];
    if (self) {
        self.userid = userId; self.account = account; self.password = password;
        self.phone = phone; self.state = state;
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
