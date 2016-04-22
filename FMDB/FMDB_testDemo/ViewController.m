//
//  ViewController.m
//  FMDB_testDemo
//
//  Created by 刘杨 on 15/9/5.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <FMDB.h>
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) Person *person1;

@property (nonatomic, strong) Person *person2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"PersonalDB.sqlite"];
    NSLog(@"%@", path);
    _db = [FMDatabase databaseWithPath:path];
    //init
    _person1 = [[Person alloc] init];
    _person1.name = @"小米";
    _person1.age = 20;
    
    _person2 = [[Person alloc] init];
    _person2.name = @"大米";
    _person2.age = 24;

}

- (void)openDB{
    if (![_db open]) {
        NSLog(@"db is not open");
        return;
    }
}

- (IBAction)createBtnAction:(UIButton *)sender {
    [self openDB];
    //create a table
    [_db executeUpdate:@"CREATE TABLE PersonalList (Page text, Identifier text, Person blob)"];//如果你存blob数据，不遵从NSCoding协议并且实现coding方法就会crash
    [_db close];
}

- (IBAction)insertBtnAction:(UIButton *)sender {
    [self openDB];

    //blob其实是一个二进制数据，只要是NSData类型就可以往里塞
    
    static int a = 0;
    if (!a) {
        [_db executeUpdate:@"INSERT INTO PersonalList (Page, Identifier, Person) VALUES (?, ?, ?)", @"11", @"第一个", _person1];
        a++;
    }else{
        [_db executeUpdate:@"INSERT INTO PersonalList (Page, Identifier, Person) VALUES (?, ?, ?)", @"22", @"第二个", _person2];
        a--;
    }
    
    [_db close];
}
- (IBAction)updateBtnAction:(UIButton *)sender {
    [self openDB];

    [_db executeUpdate:@"UPDATE PersonalList SET Identifier = ? WHERE Page = ?", @"嗯嗯我改了", @"11"];
    
    [_db close];
}
- (IBAction)deleteBtnAction:(UIButton *)sender {
    [self openDB];

    //移除单个-->根据某个条件
//    [_db executeUpdate:@"DELETE FROM PersonalList WHERE Page = 11"];
    [_db executeUpdate:@"DELETE FROM PersonalList"];

    [_db close];
}
- (IBAction)showBtnAction:(UIButton *)sender {
    [self openDB];
    //FMDB查询用的结果集
    FMResultSet *rs = [_db executeQuery:@"SELECT Page, Identifier, Person FROM PersonalList"];
    
    while ([rs next]) {
        NSString *page = [rs stringForColumn:@"Page"];
        NSString *identifier = [rs stringForColumn:@"Identifier"];
        Person *person = [rs objectForColumnName:@"Person"];
        NSLog(@"%@ --- %@ --- %@", page, identifier, person);
    }
    
    [rs close];
    [_db close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
}

@end
