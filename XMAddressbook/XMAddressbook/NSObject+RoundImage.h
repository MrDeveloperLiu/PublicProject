//
//  UIImage+Round.h
//  XMAddressbook
//
//  Created by developer_liu on 17/1/13.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSObject (RoundImage)

- (UIImage *)imageWithRoundCorner:(UIImage *)sourceImage
                     cornerRadius:(CGFloat)cornerRadius
                             size:(CGSize)size;



- (NSString *)phoneNumber:(NSString *)number;
@end
