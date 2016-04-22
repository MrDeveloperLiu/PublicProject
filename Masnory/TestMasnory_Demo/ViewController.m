//
//  ViewController.m
//  TestMasnory_Demo
//
//  Created by 刘杨 on 15/8/15.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "LYHeader.h"

@interface ViewController ()<LYHeaderDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) LYHeader *header;

@end

@implementation ViewController
//- (void)headerIndexPage:(NSInteger)indexPage{
//    NSLog(@"%ld", indexPage);
//}


- (void)viewDidLoad {
    [super viewDidLoad];

    
        UIView *view1 = [[UIView alloc] init];
        view1.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view1];
        
        
        
        //弱引用 避免循环引用
        __weak __typeof(self) weakSelf = self;
        
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(weakSelf.view);
            make.center.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 200));
            
        }];
    
    
        NSArray *urlArray = @[
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20130529085311649.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20130529110700596.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20141206143019627.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20150609140904328.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20150609091345991.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20150402162544105.jpg",
                              @"http://121.41.88.127:8080/zhangchu/HandheldKitchen/ipad/20150512200730127.jpg"
                              ];

        _header = [LYHeader headerWithArray:urlArray];
//        _header.delegate = self;
        [self.header getIndexPageWithBlock:^(NSInteger indexPage) {
            NSLog(@"index page = %ld", indexPage);
        }];
        [view1 addSubview:_header];
        [_header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view1);
        }];
    
    
#pragma mark - three views in a line
    
//        UIView *v1 = [[UIView alloc] init];
//        UIView *v2 = [[UIView alloc] init];
//        UIView *v3 = [[UIView alloc] init];
//        v1.backgroundColor = [UIColor redColor];
//        v2.backgroundColor = [UIColor redColor];
//        v3.backgroundColor = [UIColor redColor];
//        [view1 addSubview:v1];
//        [view1 addSubview:v2];
//        [view1 addSubview:v3];
//        
//        [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(view1);
//            make.left.mas_equalTo(view1.mas_left).with.offset(10);
//            make.right.mas_equalTo(v2.mas_left).with.offset(-10);
//            make.width.equalTo(@[v2, v3]);
//            make.height.mas_equalTo(@150);
//        }];
//        [v2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(view1);
//            make.width.equalTo(@[v1, v3]);
//            make.height.equalTo(v1);
//        }];
//        [v3 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(view1);
//            make.left.mas_equalTo(v2.mas_right).with.offset(10);
//            make.right.mas_equalTo(view1.mas_right).with.offset(-10);
//            make.width.equalTo(@[v1, v2]);
//            make.height.equalTo(v1);
//        }];
    
#pragma mark - can scolled views
//            UIScrollView *scollView = [[UIScrollView alloc] init];
//            scollView.backgroundColor = [UIColor whiteColor];
//            [view1 addSubview:scollView];
//            [scollView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(view1).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
//            }];
//
//            UIView *containerView = [[UIView alloc] init];
//            containerView.backgroundColor = [UIColor redColor];
//            [scollView addSubview:containerView];
//            [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(scollView);
//                make.width.equalTo(scollView);
//            }];
//
//            int count = 10;
//            UIView *lastView = nil;
//            for (int i = 1; i <= count; i++) {
//                UIView *subView = [[UIView alloc] init];
//                [containerView addSubview:subView];
//                subView.backgroundColor = [UIColor colorWithRed:(arc4random() % 256)/255.0 green:(arc4random() % 256)/255.0 blue:(arc4random() % 256)/255.0 alpha:1.0f];
//                [subView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.and.right.equalTo(containerView);
//                    make.height.mas_equalTo(@(20 * i));
//                    if (lastView) {
//                        make.top.mas_equalTo(lastView.mas_bottom);
//                    }else{
//                        make.top.mas_equalTo(containerView.mas_top);
//                    }
//                }];
//                lastView = subView;
//            }
//            [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(lastView.mas_bottom);
//            }];
    
    
    
#pragma mark - two views in a line

        //    UIView *view2 = [[UIView alloc] init];
        //    view2.backgroundColor = [UIColor redColor];
        //    [view1 addSubview:view2];
        //
        //    UIView *view3 = [[UIView alloc] init];
        //    view3.backgroundColor = [UIColor redColor];
        //    [view1 addSubview:view3];
        //    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(view1.mas_centerY);
        //        make.left.equalTo(view1.mas_left).with.offset(20);
        //        //            make.right.equalTo(view3.mas_left).with.offset(-20);
        //        make.height.mas_equalTo(@100);
        //        //            make.width.equalTo(view3);
        //    }];
        //    
        //    
        //    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(view1.mas_centerY);
        //        make.left.equalTo(view2.mas_right).with.offset(20);
        //        make.right.equalTo(view1.mas_right).with.offset(-20);
        //        make.height.equalTo(view2);
        //        make.width.equalTo(view2);
        //    }];
        
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
