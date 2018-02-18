//
//  SqliteHelper.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "SqliteHelper.h"

@interface SqliteHelper ()
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) FMDatabaseQueue *staticsDatabaseQueue;

@property (nonatomic, strong) RegisterSqliteHelper *registerHelper;
@end

@implementation SqliteHelper

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createStaticsDatabase];
    }
    return self;
}

+ (NSString *)databasePath{
    NSString *chatDatabase = @"chatDatabase.db";
    NSString *home = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [home stringByAppendingPathComponent:chatDatabase];
}

- (RegisterSqliteHelper *)registerHelper{
    if (!_registerHelper) {
        _registerHelper = [RegisterSqliteHelper new];
    }
    return _registerHelper;
}

- (FMDatabaseQueue *)databaseQueue{
    if (!_databaseQueue) {
        NSString *path = [[self class] databasePath];
        NSLog(@"<Database Path: %@>", path);
        _databaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return _databaseQueue;
}

+ (NSString *)staticsDatabasePath{
    NSString *chatDatabase = @"staticsDatabase.db";
    NSString *home = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [home stringByAppendingPathComponent:chatDatabase];
}
- (FMDatabaseQueue *)staticsDatabaseQueue{
    if (!_staticsDatabaseQueue) {
        NSString *path = [[self class] staticsDatabasePath];
        NSLog(@"<staticsDatabaseQueue Path: %@>", path);
        _staticsDatabaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return _staticsDatabaseQueue;
}

- (void)createStaticsDatabase{
    [self.staticsDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists statics (key text primary key, value blob);";
        if ([db executeUpdate:sql]) {//
            NSLog(@"创建成功statics");
        }else{//
            NSLog(@"已经创建statics");
        }
    }];
}

- (BOOL)setStaticsValue:(id<NSCoding>)value ForKey:(NSString *)key{
    __block BOOL ret = NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (!data) {
        return NO;
    }
    [self.staticsDatabaseQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"insert or replace into statics (key, value) values (?, ?);", key, data];
    }];
    return ret;
}
- (id<NSCoding>)staticsValueForKey:(NSString *)key{
    __block NSData *data = nil;
    [self.staticsDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"select * from statics where key = ?;", key];
        if ([set next]) {
            data = [set objectForColumnName:@"value"];
        }
    }];
    if (!data) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
