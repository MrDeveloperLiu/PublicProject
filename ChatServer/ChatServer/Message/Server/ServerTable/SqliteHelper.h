//
//  SqliteHelper.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "SqliteHelperProtocol.h"
#import "RegisterSqliteHelper.h"

#define CSSetObjectProperty(instance, property, value) \
(instance).(property) = (value);
#define CSWeakObject(object, name) \
__weak __typeof(object) weak##name = object;

@interface SqliteHelper : NSObject
@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong, readonly) FMDatabaseQueue *staticsDatabaseQueue;

@property (nonatomic, strong, readonly) RegisterSqliteHelper *registerHelper;

//statics
- (id <NSCoding>)staticsValueForKey:(NSString *)key;
- (BOOL)setStaticsValue:(id <NSCoding>)value ForKey:(NSString *)key;
@end
