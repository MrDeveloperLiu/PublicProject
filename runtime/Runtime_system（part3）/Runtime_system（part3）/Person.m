//
//  Person.m
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

//但是这种方案 往往是为了实现@dynamic property属性

@implementation Person
//未知消息处理函数
void funMethod(id self, IMP _cmd){
    NSLog(@"%@, %p", self, _cmd);
}


+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString isEqualToString:@"method"]) {
        class_addMethod(self.class, @selector(method), (IMP)funMethod, "@:");
    }
    return [super resolveInstanceMethod:sel];
}



- (void)handleUnkownMessage{
    NSLog(@"%@ : 来处理这个消息了", self);
}
@end

