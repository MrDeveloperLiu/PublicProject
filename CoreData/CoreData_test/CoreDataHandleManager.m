//
//  CoreDataHandleManager.m
//  CoreData_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//
#define kDefaultTableName @"table.sqlite"
#define kName @"name"
#define kPhone @"phoneNumber"

#import "CoreDataHandleManager.h"
#import <CoreData/CoreData.h>

@interface CoreDataHandleManager(){
    NSString *_fileName;//coredata文件的名字
    NSString *_entityName;//实体描述的类名
}
@property (nonatomic, strong) NSManagedObjectContext *managerObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managerObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CoreDataHandleManager

+ (CoreDataHandleManager *)managerWithFileName:(NSString *)fileName EntityName:(NSString *)entityName{
    return [[self alloc] initWithFileName:fileName EntityName:entityName];
}

- (instancetype)initWithFileName:(NSString *)fileName EntityName:(NSString *)entityName{
    if (self = [super init]) {
        _fileName = fileName;
        _entityName = entityName;
    }
    return self;
}

- (NSManagedObjectContext *)managerObjectContext{
    if (_managerObjectContext) {
        return _managerObjectContext;
    }//如果存在的话，直接返回
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator) {
        _managerObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];//在一个私有的线程创建管理
        [_managerObjectContext setPersistentStoreCoordinator:coordinator];//给管理上下文设置协调者
    }
    return _managerObjectContext;
}

- (NSString *)tableName{
    return _tableName ?: kDefaultTableName;
}

- (NSManagedObjectModel *)managerObjectModel{
    if (!_managerObjectModel && _fileName) {
        NSURL *pathURL = [[NSBundle mainBundle] URLForResource:_fileName withExtension:@"momd"];
        _managerObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:pathURL];//创建一个模型
    }
    return _managerObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (!_persistentStoreCoordinator) {
        NSError *error = nil;
        NSURL *path = [self pathForDocumentDirectory];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managerObjectModel];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:path
                                                        options:nil
                                                          error:&error];//储存为sqlite的类型的具体资源路径
        NSLog(@"path: %@ \n error:%@", path, error);
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)pathForDocumentDirectory{//路径
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:self.tableName];
}

- (void)contextSave{
    NSError *error = nil;
    [self.managerObjectContext save:&error];
    if (error) {
        NSLog(@"储存错误");
    }
}

- (void)insertPerson:(Person *)person{
    Person *temp = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:self.managerObjectContext];
    temp.name = person.name;
    temp.phoneNumber = person.phoneNumber;
    [self contextSave];
}

- (void)insertObject:(id)object parameter:(NSDictionary *)parameter{
    object = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:self.managerObjectContext];
    if (parameter) {
        [object setValuesForKeysWithDictionary:parameter];
    }
    [self contextSave];
}

- (void)insertObject:(id)object parameters:(void(^)(id object))parameters{
    object = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:self.managerObjectContext];
    if (parameters) {
        parameters(object);
    }
    [self contextSave];
}

//私有方法    //谓词模糊查询(contains  like)
- (NSArray *)arrayWithObjectForKeyPath:(NSString *)keyPath value:(id)value{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:_entityName];
    NSPredicate *predicate = nil;
    if ([keyPath isEqualToString:kName]) {
        predicate = [NSPredicate predicateWithFormat:@"name = %@", value];
    }else if([keyPath isEqualToString:kPhone]){
        predicate = [NSPredicate predicateWithFormat:@"phoneNumber = %@", value];
    }
    request.predicate = predicate;
    NSArray *array = [self.managerObjectContext executeFetchRequest:request error:nil];
    return array;
}

- (void)removeObjectForKeyPath:(NSString *)keyPath value:(id)value{
    NSArray *array = [self arrayWithObjectForKeyPath:keyPath value:value];
    for (Person *person in array) {
        if ([keyPath isEqualToString:kName]) {
            if ([value isEqualToString:person.name]) {
                [self.managerObjectContext deleteObject:person];
            }
        }else if([keyPath isEqualToString:kPhone]){
            if ([value isEqualToString:person.phoneNumber]) {
                [self.managerObjectContext deleteObject:person];
            }
        }
    }
    [self contextSave];
}

- (void)removeAllObjects{
    NSArray *array = [self selectAllObjects];
    for (id obj in array) {
        if ([obj isKindOfClass:NSClassFromString(_entityName)]) {
            [self.managerObjectContext deleteObject:obj];
        }
    }
    [self contextSave];
}

- (void)updateObjectForKeyPath:(NSString *)keyPath value:(id)value newValue:(id)newValue{
    NSArray *array = [self arrayWithObjectForKeyPath:keyPath value:value];
    for (Person *person in array) {
        if ([keyPath isEqualToString:kName]) {
            if ([value isEqualToString:person.name]) {
                person.name = newValue;
            }
        }else if([keyPath isEqualToString:kPhone]){
            if ([value isEqualToString:person.phoneNumber]) {
                person.phoneNumber = newValue;
            }
        }
    }
    [self contextSave];
}

- (NSArray *)selectAllObjects{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:_entityName];
    NSArray *array = [self.managerObjectContext executeFetchRequest:request error:nil];
    [self contextSave];
    return array;
}

- (NSArray *)selectObjectForKeyPath:(NSString *)keyPath value:(id)value{
    NSArray *array = [self arrayWithObjectForKeyPath:keyPath value:value];
    [self contextSave];
    return array;
}

@end
