//
//  AppDelegate.h
//  NSURLSession_test
//
//  Created by 刘杨 on 15/10/3.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void(^completionHandler)();


@end

