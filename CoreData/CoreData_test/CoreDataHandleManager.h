//
//  CoreDataHandleManager.h
//  CoreData_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person+CoreDataProperties.h"

@interface CoreDataHandleManager : NSObject

//第一个参数文件名：就是coredata文件的前缀名  第二个参数实体描述
+ (CoreDataHandleManager *)managerWithFileName:(NSString *)fileName EntityName:(NSString *)entityName;

//表名，默认是table.sqlite
@property (nonatomic, copy) NSString *tableName;

//在表里添加某一个类  第一个参数，你要传的对象 第二个参数，类的属性字典（kvc赋值）、block体传出的这个parameters，你可以用kvc进行赋值操作
- (void)insertPerson:(Person *)person;//第一个方法是直接传一个所有属性都赋初始值的对象
- (void)insertObject:(id)object parameter:(NSDictionary *)parameter;
- (void)insertObject:(id)object parameters:(void(^)(id object))parameters;

//根据某个属性的key的value值来删除 第一个参数，keyPath 某个属性的名字, 第二个参数，这个属性key对应的值
- (void)removeObjectForKeyPath:(NSString *)keyPath value:(id)value;
- (void)removeAllObjects;//全部删除

//根据某个属性的key的value值来更新，参数同上， 第三个参数这个属性key对应的新值
- (void)updateObjectForKeyPath:(NSString *)keyPath value:(id)value newValue:(id)newValue;

//查询
- (NSArray *)selectAllObjects;//所有的表里的数据
- (NSArray *)selectObjectForKeyPath:(NSString *)keyPath value:(id)value;//根据某个key的value值去查询


@end
