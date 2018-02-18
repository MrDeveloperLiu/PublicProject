//
//  CSRegistAccountViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/21.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSRegistAccountViewController.h"
#import "CSTabBarController.h"

//24A632
@interface CSRegistAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *accountBtn;
@property (weak, nonatomic) IBOutlet UIButton *regiterBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation CSRegistAccountViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.accountTF addTarget:self action:@selector(accountTFAction:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view from its nib.
}
- (void)accountTFAction:(id)sender{
    if (self.accountBtn.isSelected){
        self.accountBtn.selected = NO;
    }
}

- (IBAction)acountBtnAction:(UIButton *)sender {
    NSString *account = self.accountTF.text;
    if (!account.length) {
        [CSAlertView showAlert:@"请输入一个账号" delay:1];
        return;
    }
    ChatMessage *request = [[ChatMessage alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Register" forKey:@"Method"];
    [request addHeader:@"ConfirmAccount" forKey:@"Event"];
    [request addHeader:account forKey:@"Account"];
    CSTcpRequest *req = [[ChatiPhoneClient iPhone] tcpRequestWithChatMessage:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessage *resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resp.responseCode == ChatResponseOK) {
                self.accountBtn.selected = YES;
            }else{
                self.accountBtn.enabled = NO;
            }
        });
    }];
    [req setFailedBlock:^(CSTcpRequestOperation *operation, NSError *error) {
        CSLogI(@"%@", error);
    }];
    [req resume];
}

- (IBAction)inputAccount:(UITextField *)sender {
    if (!self.accountBtn.isEnabled) {
        self.accountBtn.enabled = YES;
    }
}

- (IBAction)registerBtnAction:(UIButton *)sender {
    NSString *account = self.accountTF.text;
    NSString *password = self.passwordTF.text;
    NSString *passwordAgain = self.confirmPwdTF.text;
    NSString *phone = self.phoneTF.text;
    if (!self.accountBtn.isSelected) {
        [CSAlertView showAlert:@"请先核对账号是否可用" delay:1];
        return;
    }
    if (!account.length) {
        [CSAlertView showAlert:@"请输入账号" delay:1];
        return;
    }
    if (!password.length) {
        [CSAlertView showAlert:@"请输入密码" delay:1];
        return;
    }
    if (!passwordAgain.length) {
        [CSAlertView showAlert:@"请再次确认密码" delay:1];
        return;
    }
    if (![password isEqualToString:passwordAgain]) {
        [CSAlertView showAlert:@"两次密码输入不一致" delay:1];
        return;
    }
    if (!phone.length) {
        [CSAlertView showAlert:@"请输入手机号码" delay:1];
        return;
    }
    
    ChatMessage *request = [[ChatMessage alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Register" forKey:@"Method"];
    [request addHeader:@"RegistAccount" forKey:@"Event"];
    [request addHeader:account forKey:@"Account"];
    [request addHeader:password forKey:@"Password"];
    [request addHeader:phone forKey:@"Phone"];
    CSTcpRequest *req = [[ChatiPhoneClient iPhone] tcpRequestWithChatMessage:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessage *resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resp.responseCode == ChatResponseOK) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [AppDelegate applicationDelegate].window.rootViewController =
                    [[CSTabBarController alloc] init];
                }];
            }else{
                [CSAlertView showAlert:[resp headerForKey:@"Reason"] delay:2];
            }
        });
    }];
    [req setFailedBlock:^(CSTcpRequestOperation *operation, NSError *error) {
        CSLogI(@"%@", error);
    }];
    [req resume];

}
- (IBAction)cancelBtnAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
