//
//  LYSQLite3_db.m
//  ---test--sqlite3
//
//  Created by 刘杨 on 15/9/20.
//  Copyright © 2015年 刘杨. All rights reserved.
//
#define DB_Path NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

#import "LYSQLite3_db.h"
#import "Person.h"

@implementation LYSQLite3_db
static sqlite3 *db = nil;

+ (LYSQLite3_db *)defaultDB{
    static LYSQLite3_db *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LYSQLite3_db alloc] init];
    });
    return _instance;
}

- (void)open{
    if (!db) {
        return;
    }
    NSLog(@"%@", DB_Path);
    NSString *path = [DB_Path stringByAppendingPathComponent:@"db.sqlite"];
    int result = sqlite3_open([path UTF8String], &db);
    if (result == SQLITE_OK) {
        NSLog(@"db open success");
    }else{
        NSLog(@"db open failed");
    }
}

- (void)close{
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        NSLog(@"close db success");
    }else{
        NSLog(@"close db failed");
    }
}

//autoincrement 自动自增
- (void)createTableWithName:(NSString *)name{
    NSString *string = [NSString stringWithFormat:@"create table if not exists %@ (id int primary key autoincrement, name text, book blob)", name];
    int result = sqlite3_exec(db, [string UTF8String], NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"create %@ success", name);
    }else{
        NSLog(@"create %@ failed", name);
    }
}

- (void)insertIntoTableName:(NSString *)tableName name:(NSString *)name person:(Person *)person{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:person forKey:@"k"];
    [archiver finishEncoding];
    NSString *string = [NSString stringWithFormat:@"insert into %@ (name, book) values (?, ?)", tableName];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare(db, [string UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
        sqlite3_bind_blob(stmt, 2, [data bytes], (int)[data length], NULL);
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

- (void)updateDataSourceWithTableName:(NSString *)tableName name:(NSString *)name person:(Person *)person{
    NSString *string = [NSString stringWithFormat:@"update %@ set person = %@ where name = %@", tableName, person, name];
    int result = sqlite3_exec(db, [string UTF8String], NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"update success");
    }else{
        NSLog(@"update failed");
    }
}

- (void)deleteDataSourceWithTableName:(NSString *)tableName name:(NSString *)name{
    NSString *string = [NSString stringWithFormat:@"delete from %@ where name = %@", tableName, name];
    int result = sqlite3_exec(db, [string UTF8String], NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"delete %@ success", name);
    }else{
        NSLog(@"delete %@ failed", name);
    }
}

- (void)deleteDataSourceWithTableName:(NSString *)tableName{
    NSString *string = [NSString stringWithFormat:@"delete from %@", tableName];
    int result = sqlite3_exec(db, [string UTF8String], NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"delete table success");
    }else{
        NSLog(@"delete table failed");
    }
}

- (void)selectDataSourceWithTableName:(NSString *)tableName{
    NSString *string = [NSString stringWithFormat:@"select * from %@", tableName];
    sqlite3_stmt *stmt = nil;//结果集
    int result = sqlite3_prepare(db, [string UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            //取数据
            int noID = sqlite3_column_int(stmt, 0);
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            NSString *nameStr = [NSString stringWithUTF8String:(const char *)name];
            const void *bytes = sqlite3_column_blob(stmt, 2);
            int length = sqlite3_column_bytes(stmt, 2);
            NSData *data = [NSData dataWithBytes:bytes length:length];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            Person *person = [unarchiver decodeObjectForKey:@"k"];
            [unarchiver finishDecoding];
            NSLog(@"id = %d name = %@ person.name = %@", noID, nameStr, person.name);
        }
        sqlite3_finalize(stmt);
    }
}




@end
