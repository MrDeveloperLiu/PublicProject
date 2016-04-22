//
//  Person.h
//  sqlite3-11
//
//  Created by 刘杨 on 15/9/20.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject<NSCoding>
@property (nonatomic, copy) NSString *name;
@end



@interface RunTest : NSObject
- (void)method;
@end