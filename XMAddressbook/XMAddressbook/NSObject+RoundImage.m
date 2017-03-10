//
//  UIImage+Round.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/13.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "NSObject+RoundImage.h"

@implementation NSObject (RoundImage)

- (UIImage *)imageWithRoundCorner:(UIImage *)sourceImage
                     cornerRadius:(CGFloat)cornerRadius
                             size:(CGSize)size{
    
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:cornerRadius];
    [path addClip];
    [sourceImage drawInRect:bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (NSString *)phoneNumber:(NSString *)number{
    NSString *retVal = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"-" withString:@""];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return retVal;
}
@end
