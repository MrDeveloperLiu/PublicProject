//
//  ViewController.m
//  sqlite3-11
//
//  Created by 刘杨 on 15/9/20.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "LYSQLite3_db.h"
#import <ASIHTTPRequest.h>
#import <objc/runtime.h>
#import <AFNetworking.h>

#define k_delete 10

@interface ViewController ()<ASIHTTPRequestDelegate>{
    ASIHTTPRequest *_request;
}
- (IBAction)create:(id)sender;
- (IBAction)insert:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)read:(id)sender;
- (IBAction)delete:(id)sender;

- (IBAction)download:(id)sender;
@end

NSString *const string = @"http://mapi.mafengwo.cn/travelguide/discovery/home?oauth_version=1.0&oauth_nonce=93acb789-f3bb-48e6-b660-5039a192cdeb&oauth_consumer_key=5&screen_scale=2.0&device_type=android&mfwsdk_ver=20140507&screen_width=720&device_id=1C%3A99%3A4C%3AAC%3A79%3A3E&sys_ver=4.3&channel_id=PPCPD&oauth_signature=%2FEmCJm5kFICaP4FHS6b7FxFn96I%3D&x_auth_mode=client_auth&oauth_signature_method=HMAC-SHA1&oauth_token=0_0969044fd4edf59957f4a39bce9200c6&open_udid=1C%3A99%3A4C%3AAC%3A79%3A3E&app_ver=6.0.1&app_code=com.mfw.roadbook&oauth_timestamp=1441887324&screen_height=1280";
NSString *list = @"Personlist";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)create:(id)sender {
    //使用block请求
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:string]];
    __weak __typeof(request) weakRequest = request;
    [request setCompletionBlock:^{
        //请求下来的数据
        NSString *response = [weakRequest responseString];
        NSLog(@"%@", response);
        
        NSData *data = [weakRequest responseData];
        id source = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@", source);
    }];
    [request setFailedBlock:^{
        NSError *error = [weakRequest error];
        NSLog(@"error == %@", error);
    }];
    [request startAsynchronous];
}

- (IBAction)insert:(id)sender {
    //代理请求方式
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:string]];
    [request setDelegate:self];
    [request startAsynchronous];
}
//代理方法
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *response = [request responseString];
    NSLog(@"%@", response);
    
    NSData *data = [request responseData];
    NSLog(@"%@", data);
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"%@", error);
}

- (IBAction)update:(id)sender {

}


- (IBAction)read:(id)sender {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //is online

    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"无网络连接");
        }else if(status == AFNetworkReachabilityStatusReachableViaWiFi){
            NSLog(@"当前是wifi网络");
        }else if(status == AFNetworkReachabilityStatusReachableViaWWAN){
            NSLog(@"当前是2g/3g网络");
        }else if(status == AFNetworkReachabilityStatusUnknown){
            NSLog(@"当前不知道是神马连接");
        }

    }];
    
    [manager startMonitoring];

    
}

- (void)dealloc{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (IBAction)delete:(id)sender {
    //取消，然后执行download方法 可以接着请求
    [_request clearDelegatesAndCancel];
}

- (IBAction)download:(id)sender {
    
//    /Users/liuyang/Desktop
    
    
//  实现的断点下载功能？
    NSURL *url = [NSURL URLWithString:@"http://res3.szy.com.cn/images/user/127631/1325571197728522699.jpg"];
    _request = [ASIHTTPRequest requestWithURL:url];
    //下面的路径是自己电脑download文件夹里的路径
    NSString *downPath = @"/Users/liuyang/Desktop/download/1.png";
    //设置下载完成时候会把文件路径放在哪
    [_request setDownloadDestinationPath:downPath];
    //是否允许断点下载
    [_request setAllowResumeForFileDownloads:YES];
    //设置二进制数据保存为临时文件的路径
    [_request setTemporaryFileDownloadPath:@"/Users/liuyang/Desktop/download/1.png.download"];
    //开始异步请求
    [_request startAsynchronous];
}













@end
