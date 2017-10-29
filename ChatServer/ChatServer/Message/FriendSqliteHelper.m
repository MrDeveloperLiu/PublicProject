//
//  FriendSqliteHelper.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "FriendSqliteHelper.h"
#import "SqliteHelper.h"

@implementation FriendSqliteHelper

+ (NSString *)tableName{
    return @"Friend";
}

- (BOOL)initTable{
    __block BOOL ret = NO;
    [[[SqliteHelper defaultHelper] databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ \
                         (userid integer primary key,\
                         name text,\
                         phone text,\
                         mail text,\
                         markname text,\
                         state integer,\
                         black integer);", [self.class tableName]];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (BOOL)deleteWithUserid:(uint64_t)userid{
    __block BOOL ret = NO;
    
    [[[SqliteHelper defaultHelper] databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where userid = '%lld';", [self.class tableName], userid];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

- (NSArray *)quaryWithUserid:(uint64_t)userid{
    NSMutableArray *temp = [NSMutableArray array];
    
    [[[SqliteHelper defaultHelper] databaseQueue] inDatabase:^(FMDatabase *db) {
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
    [[[SqliteHelper defaultHelper] databaseQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (account, password, state) values ('%@', '%@', '%d');", [self.class tableName], account, password, state];
        ret = [db executeUpdate:sql];
    }];
    return ret;
}

@end

@implementation FriendModel

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:NSStringFromSelector(@selector(userid))]) {
        _userid = [(NSNumber *)value longLongValue];
    }
    if ([key isEqualToString:NSStringFromSelector(@selector(state))]) {
        self.state = [(NSNumber *)value intValue];
    }
    if ([key isEqualToString:NSStringFromSelector(@selector(black))]) {
        self.black = [(NSNumber *)value intValue];
    }
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{}

@end

