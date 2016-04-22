//
//  ViewController.m
//  AFN
//
//  Created by 刘杨 on 15/9/22.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "UIView+MBProgress.h"
#import "ImgViewController.h"
#import <UIImageView+AFNetworking.h>

#define K_GET_URL @"http://mapi.mafengwo.cn/travelguide/ad/ads/statics/home_banner?oauth_version=1.0&oauth_nonce=656e9fcf-1080-4d39-bc59-5d406ae5c259&oauth_consumer_key=5&screen_scale=2.0&device_type=android&mfwsdk_ver=20140507&screen_width=720&device_id=1C%3A99%3A4C%3AAC%3A79%3A3E&sys_ver=4.3&channel_id=PPCPD&oauth_signature=Zwx%2Fcr3D9M%2FVn3kQE7Yjh2KdLuc%3D&x_auth_mode=client_auth&oauth_signature_method=HMAC-SHA1&oauth_token=0_0969044fd4edf59957f4a39bce9200c6&open_udid=1C%3A99%3A4C%3AAC%3A79%3A3E&app_ver=6.0.1&app_code=com.mfw.roadbook&oauth_timestamp=1441887324&screen_height=1280"


#define K_POST_URL @"http://mapi.mafengwo.cn/travelguide/ad/ads/statics/home_banner?"

@interface ViewController (){
    NSOperationQueue *_queue;
    AFHTTPRequestOperation *_operation;
}

@end

/**
 *  首先介绍一下AFN网络组件是对NSURLConnection做了一层封装
 1.基本使用方式（创建一个网络请求）
 AFHTTPRequestOperationManager网络请求管理者类、字典管理参数、block块返回结果成功/失败
 */

@implementation ViewController
//下载
- (IBAction)download:(id)sender {
    //AFN本身就是断点下载，而断点下载的原理就是从网络请求中获得的数据以流的方式传输
    _queue = [[NSOperationQueue alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://help.adobe.com/archive/en/photoshop/cs6/photoshop_reference.pdf"];
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"download.pdf"];
    _operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    _operation.outputStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    //在任务块AFHTTPRequestOperation中，outputStream就是任务快流，需要创建一个NSOutputStream的对象
    __weak __typeof(self) weak = self;
    //然后通过这个block块方法，获取当前的进度
    [_operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //bytesRead每次下载的bytes 字节
        //totalBytesRead 一共下载了多少字节
        //totalBytesExpectedToRead 文件的总共字节数
        CGFloat percent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        NSLog(@"%f， %ld", percent, bytesRead);
    }];
    
    
    [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {//下载成功会会走的block块
        NSLog(@"success=====>>>>>>%@", filePath);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        //当你把这个任务取消后会走这个block块
        NSLog(@"failed=====>>>>>>");
    }];
    //将任务添加到队列中，则任务就会进行
    [_queue addOperation:_operation];
//    [_queue cancelAllOperations]; 可通过这个方法暂时取消正在进行的任务
}
//简单的使用，get post发送网络请求
- (IBAction)getRequestAndPost:(UIButton *)sender {
//    演示GET请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    ImgViewController *imgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
    [self addChildViewController:imgVC];
    [self.view addSubview:imgVC.view];
    
    
    AFHTTPRequestOperation *operation = [manager GET:K_GET_URL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in responseObject[@"data"][@"list"]) {
            [array addObject:dict[@"img_url"]];
        }
        [imgVC.imageView setImageWithURL:[NSURL URLWithString:array.firstObject]];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
    [operation start];
//    这几个方法是开始，暂停，恢复
//    [operation cancel]
//    [operation resume]

    
    /*假设，上面的请求是POST那么传入一个baseURL 而参数用字典传入  由于没有接口，无法验证
    NSDictionary *parameters = @{
                                 @"oauth_version" : @"1.0",
                                 @"oauth_nonce" : @"656e9fcf-1080-4d39-bc59-5d406ae5c259",
                                 @"oauth_consumer_key" : @"5",
                                 @"screen_scale" : @"2.0",
                                 @"device_type" : @"android",
                                 @"mfwsdk_ver" : @"20140507",
                                 @"screen_width" : @"720",
                                 @"device_id" : @"1C%3A99%3A4C%3AAC%3A79%3A3E",
                                 @"sys_ver" : @"4.3",
                                 @"channel_id" : @"PPCPD",
                                 @"oauth_signature" : @"Zwx%2Fcr3D9M%2FVn3kQE7Yjh2KdLuc%3D",
                                 @"x_auth_mode" : @"client_auth",
                                 @"oauth_signature_method" : @"HMAC-SHA1",
                                 @"oauth_token" : @"0_0969044fd4edf59957f4a39bce9200c6",
                                 @"open_udid" : @"1C%3A99%3A4C%3AAC%3A79%3A3E&app_ver=6.0.1",
                                 @"app_code" : @"com.mfw.roadbook",
                                 @"oauth_timestamp" : @"1441887324",
                                 @"screen_height" : @"1280"
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    ImgViewController *imgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
    [self addChildViewController:imgVC];
    [self.view addSubview:imgVC.view];
    
    
    AFHTTPRequestOperation *operation = [manager POST:K_POST_URL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in responseObject[@"data"][@"list"]) {
            [array addObject:dict[@"img_url"]];
        }
        [imgVC.imageView setImageWithURL:[NSURL URLWithString:array.firstObject]];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
    [operation start];
    */
}

//上传
- (IBAction)uploadRequest:(UIButton *)sender {
    //上传其实就是post请求 由于没有接口，简单演示下
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //如果有要求拼接参数的话，第一种方法
    NSDictionary *parameters = @{
                                 @"password" : @"123"
                                 };
    /*还可以
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
     parameters[@"password"] = @"123";
     */
    //设置上传文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hehe" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    /*还可以利用    NSFileManager 这个单例来寻找文件路径
     */
    __weak __typeof(fileData) file = fileData;
    AFHTTPRequestOperation *operation = [manager POST:@"www.baidu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:file name:@"heheFile" fileName:@"hehe.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"upload success");
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"upload failed");
    }];
    [operation start];
    
}
//检测网络状态
- (IBAction)examNetworkStatus:(id)sender {
    //此方法是被动检测，当网络转换的时候，监测者manager会自动调用下面block块
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
        }
    }];
    [manager startMonitoring];
}


- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
