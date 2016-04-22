//
//  UIViewController+Tracking.m
//  Runtime_system（part5）
//
//  Created by 刘杨 on 15/10/5.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "UIViewController+Tracking.h"
#import <objc/runtime.h>

@implementation UIViewController (Tracking)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        //当方法是类方法时，用下面获取object的class的方法
//        Class class = objc_getClass((id)self);//但是在ARC状态下不可用
        
        SEL originalSelector = @selector(viewWillAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        SEL swizzilingSelector = @selector(ly_viewWillAppear:);
        Method swizzilingMethod = class_getInstanceMethod(class, swizzilingSelector);
        
        BOOL didAddMethod = class_addMethod(class, @selector(ly_viewWillAppear:), method_getImplementation(swizzilingMethod), method_getTypeEncoding(swizzilingMethod));
        
        if (didAddMethod) {//如果类class添加了这个方法的话,那么我就将original的方法的选择器替换成swizzling的
            class_replaceMethod(class, swizzilingSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else{//如果没有添加这个方法的话，那么就交换两个方法的实现
            method_exchangeImplementations(originalMethod, swizzilingMethod);
        }
        
        
    });
}

- (void)ly_viewWillAppear:(BOOL)animated{
    [self ly_viewWillAppear:animated];
    NSLog(@"viewWillAppear : %@", self);
}
//咋看上去是会导致无限循环的。但令人惊奇的是，并没有出现这种情况。在swizzling的过程中，方法中的[self xxx_viewWillAppear:animated]已经被重新指定到UIViewController类的-viewWillAppear:中。在这种情况下，不会产生无限循环。不过如果我们调用的是[self viewWillAppear:animated]，则会产生无限循环，因为这个方法的实现在运行时已经被重新指定为xxx_viewWillAppear:了。
@end
