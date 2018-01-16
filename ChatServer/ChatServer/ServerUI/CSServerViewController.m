//
//  CSServerViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSServerViewController.h"
#import "AppDelegate.h"
#import "CSUserDefaultStore.h"
#import "CSSocket.h"

@interface CSServerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (nonatomic, strong) CSSocket *socket;
@end

@implementation CSServerViewController
- (void)dealloc{
    [ChatClient removeObserver:self];
}

- (IBAction)connectionBtnAction:(id)sender {
    
    /*
    if (self.connectBtn.isSelected) {
        
        if ([[AppDelegate applicationDelegate].serverClient endListen]) {
            self.connectBtn.selected = NO;
        }
        
    }else{
        NSInteger port = [self.portTextField.text integerValue];
        [CSUserDefaultStore setPort:port];
        
        if ([[AppDelegate applicationDelegate].serverClient beginListenToThePort:port]) {
            self.connectBtn.selected = YES;
        }
    
    }
     */
    
    NSInteger port = [self.portTextField.text integerValue];
    [CSUserDefaultStore setPort:port];
    [self.socket acceptOnPort:port error:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.portTextField.text = @([CSUserDefaultStore port]).stringValue;

    [ChatClient addObserver:self
                         selector:@selector(connectDidConnect:)
              forNotificationName:NotificationConnectionDidConnect];
    [ChatClient addObserver:self
                   selector:@selector(connectDisconnect:)
        forNotificationName:NotificationConnectionDisconnect];
    
//    [ChatClient addObserver:self
//                   selector:@selector(setImage:)
//        forNotificationName:@"IMAGE"];
    
    
    self.socket = [[CSSocket alloc] initWithDelegate:self handleQueue:nil];
}

- (void)setImage:(NSNotification *)notif{
    UIImage *image = [UIImage imageWithData:notif.object];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

- (void)connectDidConnect:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *address = notif.userInfo[@"address"];
        self.infoTextView.text = [NSString stringWithFormat:@"%@%@", @"Connect To the: ", address];
    });
}
- (void)connectDisconnect:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *address = notif.userInfo[@"address"];
        self.infoTextView.text = [NSString stringWithFormat:@"%@%@", address, @" Disconnect"];
    });
}

@end






