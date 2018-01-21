//
//  CSServerConnectedCell.m
//  ChatServer
//
//  Created by 刘杨 on 2018/1/20.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSServerConnectedCell.h"

@interface CSServerConnectedCell ()
@end

@implementation CSServerConnectedCell

+ (NSString *)name{
    return NSStringFromClass([self class]);
}
+ (NSString *)identifier{
    return [self name];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
