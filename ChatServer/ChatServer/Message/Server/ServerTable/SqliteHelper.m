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
@property (nonatomic, strong) RegisterSqliteHelper *registerHelper;
@end

@implementation SqliteHelper

+ (NSString *)databasePath{
    NSString *chatDatabase = @"chatDatabase.db";
    NSString *home = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [home stringByAppendingPathComponent:chatDatabase];
}

- (FMDatabaseQueue *)databaseQueue{
    if (!_databaseQueue) {
        NSString *path = [[self class] databasePath];
        NSLog(@"<Database Path: %@>", path);
        _databaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return _databaseQueue;
}

- (RegisterSqliteHelper *)registerHelper{
    if (!_registerHelper) {
        _registerHelper = [RegisterSqliteHelper new];
        [_registerHelper initTable];
    }
    return _registerHelper;
}
@end
