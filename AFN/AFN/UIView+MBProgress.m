//
//  UIView+MBProgress.m
//  AFN
//
//  Created by 刘杨 on 15/10/2.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "UIView+MBProgress.h"
#import <objc/runtime.h>

@implementation UIView (MBProgress)
static char kMBPKey;

- (void)setMBProgressShow:(MBProgressShow)show percent:(void(^)(MBProgressHUD *progress))percent{
    
    self.mbp = [[MBProgressHUD alloc] init];
        switch (show) {
            case showDownloadMBProgressHUD:
                self.mbp.mode = MBProgressHUDModeDeterminateHorizontalBar;
                self.mbp.square = YES;
                self.mbp.labelText = @"Downloading...";
                break;
            case showUploadMBPProgressHUD:
                self.mbp.mode = MBProgressHUDModeDeterminateHorizontalBar;
                self.mbp.square = YES;
                self.mbp.labelText = @"Uploading...";
                break;
            case showRequestMBPProgressHUD:
                self.mbp.labelText = @"Loading...";
                break;
        }
    [self addSubview:self.mbp];
    if (percent) {
        percent(self.mbp);
    }
    [self.mbp show:YES];
}

- (void)MBPHide{
    [self.mbp hide:YES];
}
- (MBProgressHUD *)mbp{
    return objc_getAssociatedObject(self, &kMBPKey);
}
- (void)setMbp:(MBProgressHUD *)mbp{
    objc_setAssociatedObject(self, &kMBPKey, mbp, OBJC_ASSOCIATION_RETAIN);
}
@end
