//
//  ImgViewController.m
//  AFN
//
//  Created by 刘杨 on 15/10/2.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ImgViewController.h"

@interface ImgViewController ()
- (IBAction)backBtnAction:(UIButton *)sender;

@end

@implementation ImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)backBtnAction:(UIButton *)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
@end
