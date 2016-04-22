//
//  Person.m
//  sqlite3-11
//
//  Created by 刘杨 on 15/9/20.
//  Copyright © 2015年 刘杨. All rights reserved.
//
#define k_coder_name @"name"

#import "Person.h"

@implementation Person
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:k_coder_name];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:k_coder_name];
    }
    return self;
}
@end


@implementation RunTest
- (void)method{
    NSLog(@"%@, %p", self, _cmd);
}
@end