//
//  CSNavigationController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSNavigationController.h"

@interface CSNavigationController ()

@end

@implementation CSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (![self.viewControllers containsObject:viewController]) {
        [super pushViewController:viewController animated:animated];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
