//
//  ViewController.m
//  CoreData_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataHandleManager.h"

@interface ViewController ()
@property (nonatomic, strong) Person *person;

@end
NSString *fileName = @"ALL";
NSString *name = @"Person";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CoreDataHandleManager *manager = [CoreDataHandleManager managerWithFileName:fileName EntityName:name];
    
    self.person = [[Person alloc] init];
    
//    [manager insertObject:self.person parameter:@{@"name":@"hehe5" ,
//                                                  @"phoneNumber": @"120"
//                                                  }];
//    
//    [manager insertObject:self.person parameters:^(id object) {
//        [object setValue:@"hehe6" forKey:@"name"];
//        [object setValue:@"111" forKey:@"phoneNumber"];
//    }];
//    
    
//    [manager removeObjectForKeyPath:@"name" value:@"hehe3"];
//    [manager removeAllObjects];
    
    

    [manager updateObjectForKeyPath:@"name" value:@"hehe5" newValue:@"woaini"];
    
    
//    NSArray *array = [manager selectAllObjects];
    NSArray *array = [manager selectObjectForKeyPath:@"name" value:@"woaini"];
    for (Person *person in array) {
        NSLog(@"%@  %@", person.name, person.phoneNumber);
    }



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
