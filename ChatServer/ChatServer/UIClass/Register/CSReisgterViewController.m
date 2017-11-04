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
}
- (IBAction)loginBtnAction:(id)sender {
#if kClientTypeIPhone
    NSString *host = self.hostTextField.text;
    NSInteger port = [self.portTextField.text integerValue];
    [CSUserDefaultStore setHost:host];
    [CSUserDefaultStore setPort:port];
    [[AppDelegate applicationDelegate].phoneClient connectToTheHost:host port:port];
#endif
}
- (IBAction)registerBtnAction:(id)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    ChatMessageRequest *request = [[ChatMessageRequest alloc] init];
    [request setMethod:ChatRequestMethodPOST];
    [request addHeader:@"File" forKey:@"Event"];
//    [request addHeader:account forKey:@"Account"];
//    [request addHeader:password forKey:@"Password"];
    
    [request setBodyData:UIImagePNGRepresentation([UIImage imageNamed:@"HF_buymartail"])];
    
    CSTcpRequest *req = [[AppDelegate applicationDelegate].phoneClient tcpRequestWithChatMessageRequest:request];

    [req setFinshedBlock:^(CSTcpRequestOperation *operation, ChatMessageResponse *resp) {
        NSLog(@"%@", resp);
    }];
    [req setFailedBlock:^(CSTcpRequestOperation *operation, NSError *error) {
        NSLog(@"");
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
