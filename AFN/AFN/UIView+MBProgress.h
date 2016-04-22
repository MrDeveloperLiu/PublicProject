//
//  UIView+MBProgress.h
//  AFN
//
//  Created by 刘杨 on 15/10/2.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
//需要依赖cocopods安装MBProgressHUD第三方

typedef NS_ENUM(NSUInteger, MBProgressShow) {
    showDownloadMBProgressHUD,
    showUploadMBPProgressHUD,
    showRequestMBPProgressHUD,
};

@interface UIView (MBProgress)
@property (nonatomic, strong) MBProgressHUD *mbp;


- (void)setMBProgressShow:(MBProgressShow)show percent:(void(^)(MBProgressHUD *progress))percent;
- (void)MBPHide;
@end
