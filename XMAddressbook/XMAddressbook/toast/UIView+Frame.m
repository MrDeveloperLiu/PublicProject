//
//  UIView+Frame.m
//  Test
//
//  Created by 刘杨 on 15/9/15.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size{
    return self.frame.size;
}

- (CGPoint)origin{
    return self.frame.origin;
}

// 设置控件的位置为另一个控件的水平位置平移
- (void)alignView:(UIView*)toView Space:(int)space Right:(BOOL)right
{
    CGRect rc_to = toView.frame;
    CGRect rc = self.frame;
    // 在右侧
    if (right) {
        rc.origin.x = CGRectGetMaxX(rc_to) + space;
    }
    // 在左侧
    else {
        rc.origin.x = rc_to.origin.x - space - rc.size.width;
    }
    [self setFrame:rc];
}


- (UIView *)roundRectForView:(UIView *)view fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor{
    view.backgroundColor = [UIColor clearColor];
    CGSize size = view.frame.size;
    CGPoint center = (CGPoint){size.width / 2, size.height / 2};
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:center.y startAngle:0
                                                      endAngle:M_PI * 2 clockwise:YES];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = fillColor.CGColor;
    layer.strokeColor = strokeColor.CGColor;
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    
    [view.layer addSublayer:layer];
    return view;
}

- (UIView *)roundRectForView:(UIView *)view fillColor:(UIColor *)fillColor radius:(float)radius{
    view.backgroundColor = [UIColor clearColor];
    CGRect rect = view.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:(CGSize){radius, radius}];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = fillColor.CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    
    [view.layer insertSublayer:layer below:view.layer];
    return view;
}


@end
