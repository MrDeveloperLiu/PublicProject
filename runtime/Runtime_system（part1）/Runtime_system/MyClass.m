//
//  MyClass.m
//  Runtime_system
//
//  Created by 刘杨 on 15/9/30.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "MyClass.h"

@interface MyClass(){
    NSInteger _instance1;
    
    NSString *_instance2;
}

@property (nonatomic, assign) NSInteger interger;

- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2;
@end

@implementation MyClass

- (void)method1{
    NSLog(@"call method method1");
}

- (void)method2{
    NSLog(@"假如我是一个新的类 == 覆盖了method1");
}

+ (void)class_method{

}

- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2{
    NSLog(@"arg1: %ld  arg2: %@", arg1, arg2);
}
@end
