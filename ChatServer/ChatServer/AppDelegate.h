//
//  AppDelegate.h
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kClientTypeIPhone 1

#import "ChatiPhoneClient.h"
#import "ChatServerClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


+ (AppDelegate *)applicationDelegate;

@property (nonatomic, strong) ChatiPhoneClient *phoneClient;

@property (nonatomic, strong) ChatServerClient *serverClient;

@end

