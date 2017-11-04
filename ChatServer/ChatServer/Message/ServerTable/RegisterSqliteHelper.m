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

+ (NSString *)tableName{
    return @"Register";
}

- (BOOL)initTable{
    __block BOOL ret = NO;
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ \
                         (userid integer primary key autoincrement,\
                         account text,\
                         password text,\
                         state integer);", [self.class tableName]];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (BOOL)deleteWithUserid:(uint64_t)userid{
    __block BOOL ret = NO;
    
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where userid = '%lld';", [self.class tableName], userid];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}


- (NSArray *)quaryWithAccount:(NSString *)account{
    NSMutableArray *temp = [NSMutableArray array];
    
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where account = '%@';", [self.class tableName], account];
        FMResultSet *set = [db executeQuery:sql];
        
        while ([set next]) {
            NSDictionary *dict = [self _tansferDictWithSet:set];
            RegisterModel *registerM = [[RegisterModel alloc] init];
            [registerM setValuesForKeysWithDictionary:dict];
            [temp addObject:registerM];
        }
        [set close];
    }];
    return temp;
}

- (NSArray *)quaryWithUserid:(uint64_t)userid{
    NSMutableArray *temp = [NSMutableArray array];
    
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where userid = '%lld';", [self.class tableName], userid];
        FMResultSet *set = [db executeQuery:sql];
        
        while ([set next]) {
            NSDictionary *dict = [self _tansferDictWithSet:set];
            RegisterModel *registerM = [[RegisterModel alloc] init];
            [registerM setValuesForKeysWithDictionary:dict];
            [temp addObject:registerM];
        }
        [set close];
    }];
    return temp;
}

- (NSDictionary *)_tansferDictWithSet:(FMResultSet *)set{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"account"] = [set stringForColumn:@"account"];
    dict[@"password"] = [set stringForColumn:@"password"];
    dict[@"state"] = @([set intForColumn:@"state"]);
    dict[@"userid"] = @([set longLongIntForColumn:@"userid"]);
    return dict;
}

- (BOOL)insertIntoTableWithAccount:(NSString *)account password:(NSString *)password state:(int)state{
    __block BOOL ret = NO;
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (account, password, state) values ('%@', '%@', '%d');", [self.class tableName], account, password, state];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (BOOL)updateTableWithAccount:(NSString *)account password:(NSString *)password state:(int)state{
    __block BOOL ret = NO;
    NSString *chanegePassword = @"";
    NSString *changeState = @"";
    NSString *and = @"";
    if (password) {
        chanegePassword = [NSString stringWithFormat:@" password = '%@'", password];
    }
    if (state) {
        if (password.length) and = @" and";
        changeState = [NSString stringWithFormat:@" state = '%d'", state];
    }
    [[[ChatServerClient server].dbHelper databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set%@%@%@ where account = '%@';", [self.class tableName], chanegePassword, and, changeState, account];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}
@end

@implementation RegisterModel

- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
