//
//  AppDelegate.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/12.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "XMAddressbookHelper.h"
#import "ViewController.h"
#import "RootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [XMAddressbookHelper requestAddressbookAuthor:^(BOOL grand, CFErrorRef error) {
        if (grand) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddressbookGrand object:nil userInfo:nil];
        }
    }];
    [XMAddressbookHelper createAddressbook];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *root = [[UINavigationController alloc] initWithRootViewController:[RootViewController new]];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    
    
    if (![XMAddressbookHelper quaryPersonFromLocalWithPhone:@"125339"]) {
        [self addChinamobile];
    }
    if (![XMAddressbookHelper quaryPersonFromLocalWithPhone:@"4001100868"]) {
        [self addChinamobileUser];
    }
    
    return YES;
}

NSString *transferString(CFStringRef ref){
    return (__bridge NSString *)ref;
}

- (BOOL)addChinamobileUser{
    ABRecordRef personRef = [XMAddressbookHelper createPerson];
    [XMAddressbookHelper personRef:personRef property:kABPersonLastNameProperty string:@"中国移动企业融合通信客服"];
    [XMAddressbookHelper personRef:personRef MulitValuelabel:kABPersonPhoneMobileLabel property:kABPersonPhoneProperty string:@"4001100868"];
    [XMAddressbookHelper personRef:personRef setImage:[UIImage imageNamed:@"icon_mail_doc"]];
    return [XMAddressbookHelper saveIntoAddressbook:personRef];
}

- (BOOL)addChinamobile{
    ABRecordRef personRef = [XMAddressbookHelper createPerson];
    NSArray *vals = @[@"125339", @"+86125339", @"0125339"];
    NSArray *labs = @[transferString(kABPersonPhoneMobileLabel),
                      transferString(kABPersonPhoneIPhoneLabel),
                      transferString(kABPersonPhoneIPhoneLabel)];
    [XMAddressbookHelper personRef:personRef property:kABPersonLastNameProperty string:@"中国移动电话会议"];
    [XMAddressbookHelper personRef:personRef property:kABPersonPhoneProperty strings:vals labels:labs];
    [XMAddressbookHelper personRef:personRef setImage:[UIImage imageNamed:@"icon_mail_doc"]];
    return [XMAddressbookHelper saveIntoAddressbook:personRef];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
