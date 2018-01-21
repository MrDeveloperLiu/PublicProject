//
//  CSRegistAccountViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/21.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSRegistAccountViewController.h"
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)acountBtnAction:(UIButton *)sender {
    NSString *account = self.accountTF.text;
    
    ChatMessageRequest *request = [[ChatMessageRequest alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"ConfirmAccount" forKey:@"Method"];
    [request addHeader:account forKey:@"Account"];
    CSTcpRequest *req = [[ChatiPhoneClient iPhone] tcpRequestWithChatMessageRequest:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessageResponse *resp) {
        CSLogI(@"%@", resp);
    }];
    [req setFailedBlock:^(CSTcpRequestOperation *operation, NSError *error) {
        CSLogI(@"%@", error);
    }];
    [req resume];
}
- (IBAction)registerBtnAction:(UIButton *)sender {
    NSString *account = self.accountTF.text;
    NSString *password = self.passwordTF.text;
    NSString *passwordAgain = self.confirmPwdTF.text;
    NSString *phone = self.phoneTF.text;
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
    
    ChatMessageRequest *request = [[ChatMessageRequest alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"RegistAccount" forKey:@"Method"];
    [request addHeader:account forKey:@"Account"];
    [request addHeader:password forKey:@"Password"];
    [request addHeader:phone forKey:@"Phone"];
    CSTcpRequest *req = [[ChatiPhoneClient iPhone] tcpRequestWithChatMessageRequest:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessageResponse *resp) {
        CSLogI(@"%@", resp);
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
