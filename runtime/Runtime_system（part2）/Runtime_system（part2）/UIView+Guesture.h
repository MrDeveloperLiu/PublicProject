//
//  UIView+Guesture.h
//  Runtime_system（part2）
//
//  Created by 刘杨 on 15/9/30.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Guesture)
- (void)setTapActionWithBlock:(void(^)())block;
@end
