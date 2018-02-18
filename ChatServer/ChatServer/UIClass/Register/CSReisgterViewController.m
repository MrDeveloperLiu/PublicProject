//
//  CSReisgterViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/10/30.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSReisgterViewController.h"
#import "AppDelegate.h"
#import "CSUserDefaultStore.h"
#import "CSTabBarController.h"
#import "CSRegistAccountViewController.h"


@interface CSReisgterViewController () 
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation CSReisgterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hostTextField.text = [CSUserDefaultStore host];
    self.portTextField.text = @([CSUserDefaultStore port]).stringValue;
    // Do any additional setup after loading the view from its nib.
    
    self.accountTextField.text = [CSUserDefaultStore username];
    self.passwordTextField.text = [CSUserDefaultStore password];
}
- (IBAction)loginBtnAction:(id)sender {
    NSString *host = self.hostTextField.text;
    NSInteger port = [self.portTextField.text integerValue];
    [CSUserDefaultStore setHost:host];
    [CSUserDefaultStore setPort:port];
 
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (!account.length) {
        [CSAlertView showAlert:@"请输入用户名" delay:2];
        return;
    }
    if (!password.length) {
        [CSAlertView showAlert:@"请输入密码" delay:2];
        return;
    }
    
    ChatMessage *request = [[ChatMessage alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Login" forKey:@"Method"];
    
    [request addHeader:@"Reconnect" forKey:@"Event"];
    [request addHeader:@"100000001" forKey:@"UserId"];
    [request addHeader:@"Code" forKey:@"EncryptCode"];
    /*
     NSString *userId = [request headerForKey:@"UserId"];
     NSString *encryptCode = [request headerForKey:@"EncryptCode"];

    [request addHeader:account forKey:@"Account"];
    [request addHeader:password forKey:@"Password"];
    */
    CSTcpRequest *req = [[ChatiPhoneClient iPhone] tcpRequestWithChatMessage:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessage *resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resp.responseCode == ChatResponseOK) {
                [AppDelegate applicationDelegate].window.rootViewController =
                [[CSTabBarController alloc] init];
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

- (IBAction)registerBtnAction:(id)sender {
    CSRegistAccountViewController *vc = [[CSRegistAccountViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
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
