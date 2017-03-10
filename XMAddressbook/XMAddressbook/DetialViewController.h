//
//  DetialViewController.h
//  XMAddressbook
//
//  Created by developer_liu on 17/1/13.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMAddressbookHelper.h"

@interface DetialViewController : UIViewController
@property (nonatomic, strong) XMABRecordModel *model;

@property (nonatomic, assign, getter=isPush) BOOL push;
@end
