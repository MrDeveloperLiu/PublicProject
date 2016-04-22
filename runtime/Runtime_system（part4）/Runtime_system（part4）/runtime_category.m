//
//  runtime_category.m
//  Runtime_system（part4）
//
//  Created by 刘杨 on 15/10/5.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "runtime_category.h"

@implementation runtime_category
- (void)method1{
    NSLog(@"%s", __func__);
}
@end

@implementation runtime_category (category)

- (void)method2{
    NSLog(@"%s", __func__);
}

@end