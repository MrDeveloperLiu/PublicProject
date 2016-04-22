//
//  Person.m
//  FMDB_testDemo
//
//  Created by 刘杨 on 15/9/5.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//
#define K_CODE_NAME @"name"
#define K_CODE_AGE @"age"

#import "Person.h"

@implementation Person
- (NSString *)description{
    return [NSString stringWithFormat:@"姓名： %@  年龄： %ld", self.name, self.age];
}

//实现coding协议的方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:K_CODE_NAME];
        _age = [aDecoder decodeIntegerForKey:K_CODE_AGE];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:K_CODE_NAME];
    [aCoder encodeInteger:_age forKey:K_CODE_AGE];
}

@end
