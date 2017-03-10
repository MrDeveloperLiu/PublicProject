//
//  RootViewController.m
//  XMAddressbook
//
//  Created by developer_liu on 17/2/10.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "RootViewController.h"
#import "XMPersonalInformationViewController.h"
#import "XMVoiceRecordManager.h"

@interface RootViewController ()
{
    XMVoiceRecordManager *_manager;
}
@end

@implementation RootViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor] , NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor redColor];
    
    self.title = @"名片样式";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Enterprise" forState:UIControlStateNormal];
    btn.tag = 100;
    
//    UIButton *btn_1 = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn_1 setTitle:@"Enterprise self" forState:UIControlStateNormal];
//    btn_1.tag = 101;
//    
//    UIButton *btn_2 = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn_2 setTitle:@"Phone" forState:UIControlStateNormal];
//    btn_2.tag = 102;
    
//    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [btn_1 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [btn_2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
//    [self.view addSubview:btn_1];
//    [self.view addSubview:btn_2];
    
    btn.frame = VRect(40, USSizeH - 130, USSizeW - 80, 40);
//    btn_1.frame = VRect(0, VMaxY(btn) + 20, USSizeW, 40);
//    btn_2.frame = VRect(0, VMaxY(btn_1) + 20, USSizeW, 40);
    // Do any additional setup after loading the view.
    
    _manager = [[XMVoiceRecordManager alloc] init];
    [_manager addRecordViewToView:self.view frame:VCenterRect(self.view.frame, CGSizeMake(200, 200))];
    [_manager buttonSettingWithButton:btn];
}

- (void)btnAction:(UIButton *)sender{
    
    XMPersonalInfoViewModel *m = [XMPersonalInfoViewModel modelWithData:nil];
    if (sender.tag == 100) {
        m.type = PersonalTypeEnterprise;
    }else if (sender.tag == 101){
        m.type = PersonalTypeEnterPriseSelf;
    }else if (sender.tag == 102){
        m.type = PersonalTypePhone;
    }
    XMPersonalInformationViewController *vc = [XMPersonalInformationViewController personVCWithViewModel:m];
    [self.navigationController pushViewController:vc animated:YES];
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
