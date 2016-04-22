//
//  Person.m
//  XML_JSON_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}
- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"number"]) {
        self.number = [value stringValue];
    }
}
+ (Person *)personWithDict:(NSDictionary *)dict{
    return [[[self class] alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
