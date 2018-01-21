//
//  CSServerConnectedCell.h
//  ChatServer
//
//  Created by 刘杨 on 2018/1/20.
//  Copyright © 2018年 Married. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSServerConnectedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;

+ (NSString *)name;
+ (NSString *)identifier;
@end
