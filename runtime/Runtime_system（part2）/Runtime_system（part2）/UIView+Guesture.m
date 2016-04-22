//
//  UIView+Guesture.m
//  Runtime_system（part2）
//
//  Created by 刘杨 on 15/9/30.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "UIView+Guesture.h"
#import <objc/runtime.h>

@implementation UIView (Guesture)
//假定我们想要动态地将一个Tap手势操作连接到任何UIView中，并且根据需要指定点击后的实际操作。这时候我们就可以将一个手势对象及操作的block对象关联到我们的UIView对象中。这项任务分两部分。首先，如果需要，我们要创建一个手势识别对象并将它及block做为关联对象。如下代码所示：
static char kTapGRKey;
static char kTapGRBlockKey;

- (void)setTapActionWithBlock:(void(^)())block{
    UITapGestureRecognizer *tapGR = objc_getAssociatedObject(self, &kTapGRKey);
    if (!tapGR) {
        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGR:)];
        [self addGestureRecognizer:tapGR];
        objc_setAssociatedObject(self, &kTapGRKey, tapGR, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kTapGRBlockKey, block, OBJC_ASSOCIATION_COPY);
}


//实现action
- (void)handleActionForTapGR:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        void(^action)() = objc_getAssociatedObject(self, &kTapGRBlockKey);
        if (action) {
            action();//如果block被实现，那么调用block
        }
    }
}
//关联对象使用起来并不复杂。它让我们可以动态地增强类现有的功能。我们可以在实际编码中灵活地运用这一特性

@end
