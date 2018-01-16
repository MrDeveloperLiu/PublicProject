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

#import "CSSocket.h"

@interface CSReisgterViewController () <ChatiPhoneCallbackProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic) CSSocket *socket;

@end

@implementation CSReisgterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.hostTextField.text = [CSUserDefaultStore host];
    self.portTextField.text = @([CSUserDefaultStore port]).stringValue;
    // Do any additional setup after loading the view from its nib.
    
    self.accountTextField.text = [CSUserDefaultStore username];
    self.passwordTextField.text = [CSUserDefaultStore password];
    
//    self.socket = [[CSSocket alloc] initWithDelegate:self handleQueue:dispatch_get_main_queue()];
    
}
- (IBAction)loginBtnAction:(id)sender {

    NSString *host = self.hostTextField.text;
    NSInteger port = [self.portTextField.text integerValue];
    [CSUserDefaultStore setHost:host];
    [CSUserDefaultStore setPort:port];
    
//    NSError *error = nil;
//    [self.socket connectToTheAddress:[CSSocketAddress ipv4WithHost:host port:port] timeOut:10 error:&error];
    
    
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    ChatMessageRequest *request = [[ChatMessageRequest alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Login" forKey:@"Event"];
    [request addHeader:account forKey:@"Account"];
    [request addHeader:password forKey:@"Password"];
    [[AppDelegate applicationDelegate].phoneClient doLoginWithRequest:request completion:self];
    
}

- (void)onResponse:(ChatMessageResponse *)resp userInfo:(NSDictionary *)userInfo{

    if ([[resp headerForKey:@"Event"] isEqualToString:@"Login"]) {
        if (resp.responseCode == ChatResponseOK) {
            
            //login success
            NSString *account = self.accountTextField.text;
            NSString *password = self.passwordTextField.text;
            [CSUserDefaultStore setUsername:account];
            [CSUserDefaultStore setPassword:password];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *delegate = [AppDelegate applicationDelegate];
                delegate.window.rootViewController = [[CSTabBarController alloc] init];
            });
            
        }else{
            //login failed
            [CSAlertView showAlert:resp.chatHeader[@"Reason"] delay:3];
        }
    }
}

- (IBAction)registerBtnAction:(id)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    

    ChatMessageRequest *request = [[ChatMessageRequest alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"Register" forKey:@"Event"];
    [request addHeader:account forKey:@"Account"];
    [request addHeader:password forKey:@"Password"];
    CSTcpRequest *req = [[AppDelegate applicationDelegate].phoneClient tcpRequestWithChatMessageRequest:request];
    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessageResponse *resp) {
        if (resp.responseCode == ChatResponseOK) {
            [CSAlertView showAlert:resp.description delay:3];
        }else{
            [CSAlertView showAlert:resp.chatHeader[@"Reason"] delay:3];
        }
    }];
    [req setFailedBlock:^(CSTcpRequestOperation *operation, NSError *error) {
        [CSAlertView showAlert:error.localizedDescription delay:3];
    }];
    [req resume];
    
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
