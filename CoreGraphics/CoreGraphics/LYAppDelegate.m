//
//  LYAppDelegate.m
//  CoreGraphics
//
//  Created by 刘杨 on 16/2/6.
//  Copyright © 2016年 刘杨. All rights reserved.
//

#import "LYAppDelegate.h"
#import "LYRootViewController.h"

@implementation LYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[LYRootViewController alloc] init];
    return YES;
}

@end
