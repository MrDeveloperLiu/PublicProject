//
//  LYSQLite3_db.h
//  ---test--sqlite3
//
//  Created by 刘杨 on 15/9/20.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Person;
@interface LYSQLite3_db : NSObject

+ (LYSQLite3_db *)defaultDB;

- (void)open;

- (void)close;

- (void)createTableWithName:(NSString *)name;

- (void)insertIntoTableName:(NSString *)tableName name:(NSString *)name person:(Person *)person;

- (void)updateDataSourceWithTableName:(NSString *)tableName name:(NSString *)name person:(Person *)person;

- (void)selectDataSourceWithTableName:(NSString *)tableName;

- (void)deleteDataSourceWithTableName:(NSString *)tableName name:(NSString *)name;

- (void)deleteDataSourceWithTableName:(NSString *)tableName;
@end
