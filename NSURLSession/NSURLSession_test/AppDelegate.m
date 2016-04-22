//
//  AppDelegate.m
//  NSURLSession_test
//
//  Created by 刘杨 on 15/10/3.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

//添加这句话
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    self.completionHandler = completionHandler;
    
    
    
   
    
}





@end
