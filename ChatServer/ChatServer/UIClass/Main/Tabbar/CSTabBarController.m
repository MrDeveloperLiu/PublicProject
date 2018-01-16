//
//  CSTabBarController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSTabBarController.h"
#import "CSBaseViewController.h"
#import "CSNavigationController.h"
#import "ChatiPhoneClient.h"
#import "CSImageUntil.h"

@interface CSTabBarController ()

@end

@implementation CSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAllSubViewControllers];
    // Do any additional setup after loading the view.
}

- (void)configureAllSubViewControllers{
    
    NSMutableArray *temp = [NSMutableArray array];
    CSNavigationController *messageVC = [self vcWithTitle:CSIPhoneString(@"CSTabbarMessage")];
    CSNavigationController *contactVC = [self vcWithTitle:CSIPhoneString(@"CSTabbarContacts")];
    CSNavigationController *meVC = [self vcWithTitle:CSIPhoneString(@"CSTabbarMe")];

    [self setAttributes:messageVC title:CSIPhoneString(@"CSTabbarMessage")
                  image:[CSImageUntil imageFromICON:@"icon_tabbar_message.png"]
            selectImage:nil];
    
    [self setAttributes:contactVC title:CSIPhoneString(@"CSTabbarContacts")
                  image:[CSImageUntil imageFromICON:@"icon_tabbar_addressbook.png"]
            selectImage:nil];
    
    [self setAttributes:meVC title:CSIPhoneString(@"CSTabbarMe")
                  image:[CSImageUntil imageFromICON:@"icon_tabbar_me.png"]
            selectImage:nil];
    
    [temp addObject:messageVC];
    [temp addObject:contactVC];
    [temp addObject:meVC];
    [self setViewControllers:temp animated:YES];
    
}

- (CSNavigationController *)vcWithTitle:(NSString *)title{
    CSBaseViewController *vc = [[CSBaseViewController alloc] init];
    CSNavigationController *nav = [[CSNavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.title = title;
    return nav;
}

- (void)setAttributes:(CSNavigationController *)vc title:(NSString *)title image:(UIImage *)image selectImage:(UIImage *)selectImage{
    
    UITabBarItem *tabbarItem = [[UITabBarItem alloc] initWithTitle:title
                                                         image:image
                                                 selectedImage:selectImage];
    /*
    [tabbarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                                   forState:UIControlStateNormal];
    [tabbarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                                              NSForegroundColorAttributeName : [UIColor orangeColor]
                                                              }
                                                   forState:UIControlStateSelected];
    */
    vc.topViewController.tabBarItem = tabbarItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
