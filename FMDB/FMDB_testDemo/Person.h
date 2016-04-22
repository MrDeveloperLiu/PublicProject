//
//  Person.h
//  FMDB_testDemo
//
//  Created by 刘杨 on 15/9/5.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject<NSCoding>


@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger age;


@end
