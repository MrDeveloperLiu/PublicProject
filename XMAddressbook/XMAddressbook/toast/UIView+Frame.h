//
//  UIView+Frame.h
//  Test
//
//  Created by 刘杨 on 15/9/15.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

// 设置控件的位置为另一个控件的水平位置平移
- (void)alignView:(UIView*)toView Space:(int)space Right:(BOOL)right;
/**
 *  给一个View切成圆形的方法
 *
 *  @param view        view
 *  @param fillColor   填充颜色
 *  @param strokeColor 描边颜色
 *
 *  @return view
 */
- (UIView *)roundRectForView:(UIView *)view fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor;
- (UIView *)roundRectForView:(UIView *)view fillColor:(UIColor *)fillColor radius:(float)radius;

@end
