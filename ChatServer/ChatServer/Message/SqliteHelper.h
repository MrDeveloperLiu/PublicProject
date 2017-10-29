//
//  SqliteHelper.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "RegisterSqliteHelper.h"

@interface SqliteHelper : NSObject

+ (SqliteHelper *)defaultHelper;

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

@property (nonatomic, strong, readonly) RegisterSqliteHelper *registerHelper;

@end
