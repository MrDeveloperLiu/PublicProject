//
//  Person.h
//  XML_JSON_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *hobby;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *number;

+ (Person *)personWithDict:(NSDictionary *)dict;
@end
