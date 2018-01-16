//
//  CSImageUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSImageUntil.h"

@implementation CSImageUntil

+ (UIImage *)imageFromICON:(NSString *)icon{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ICON" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *imagePath = [bundle.resourcePath stringByAppendingPathComponent:icon];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
