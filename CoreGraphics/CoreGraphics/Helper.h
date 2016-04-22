//
//  Helper.h
//  MeetingSDK
//
//  Created by 刘杨 on 16/1/6.
//  Copyright © 2016年 feinno. All rights reserved.
//

#ifndef Helper_h
#define Helper_h

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

#define UIColorFromHEX(hex) \
[UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0f]

#define UIColorFromRGBA(r, g, b, a) \
[UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a]

#define UIFontSize(size) \
[UIFont systemFontOfSize:size]

#define WeakClass(class) \
__weak __typeof(class) weak##class = class

#define ProtraitSize 44
#define SelectSize   16
#define Margin       10
#define LabelH       30

#endif /* Helper_h */
