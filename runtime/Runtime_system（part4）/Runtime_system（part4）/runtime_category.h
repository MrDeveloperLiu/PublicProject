//
//  runtime_category.h
//  Runtime_system（part4）
//
//  Created by 刘杨 on 15/10/5.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface runtime_category : NSObject
- (void)method1;
@end


@interface runtime_category (category)
- (void)method2;
@end