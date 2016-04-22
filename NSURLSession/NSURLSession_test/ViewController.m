//
//  ViewController.m
//  NSURLSession_test
//
//  Created by 刘杨 on 15/10/3.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import "LYURLSession.h"



#define K_GET_URL @"http://mapi.mafengwo.cn/travelguide/ad/ads/statics/home_banner?oauth_version=1.0&oauth_nonce=656e9fcf-1080-4d39-bc59-5d406ae5c259&oauth_consumer_key=5&screen_scale=2.0&device_type=android&mfwsdk_ver=20140507&screen_width=720&device_id=1C%3A99%3A4C%3AAC%3A79%3A3E&sys_ver=4.3&channel_id=PPCPD&oauth_signature=Zwx%2Fcr3D9M%2FVn3kQE7Yjh2KdLuc%3D&x_auth_mode=client_auth&oauth_signature_method=HMAC-SHA1&oauth_token=0_0969044fd4edf59957f4a39bce9200c6&open_udid=1C%3A99%3A4C%3AAC%3A79%3A3E&app_ver=6.0.1&app_code=com.mfw.roadbook&oauth_timestamp=1441887324&screen_height=1280"
#define K_DOWNLOAD_URL @"http://help.adobe.com/archive/en/photoshop/cs6/photoshop_reference.pdf"


@interface ViewController ()
- (IBAction)downloadTask:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)resume:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downloadTask:(id)sender {
//    [[LYURLSession session] downloadWithURLString:K_DOWNLOAD_URL completion:^(NSString *locationStr) {
//        NSLog(@"%@", locationStr);
//    } failed:^(NSError *error) {
//        NSLog(@"%@", error);
//    }];
//    [[LYURLSession session] requestWithURLString:K_GET_URL completion:^(id backData, NSURLResponse *response) {
//        NSLog(@"%@", backData);
//    } failed:^(NSError *error) {
//        NSLog(@"%@", error);
//    }];
    [[LYURLSession session] downloadInBackgroundWithURLString:K_DOWNLOAD_URL identifier:@"hehe"];
}

- (IBAction)cancel:(id)sender {
    [[LYURLSession session] cancelTaskWithType:CancelDownloadTask];
}

- (IBAction)resume:(id)sender {
    [[LYURLSession session] resumeDataTask];
}
@end
