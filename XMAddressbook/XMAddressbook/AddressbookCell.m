//
//  AddressbookCell.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/13.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "AddressbookCell.h"
#import "UIViewMacro.h"
#import "NSObject+RoundImage.h"

@interface AddressbookCell()
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation AddressbookCell

UIViewPropertyLazyload(UILabel, titleLabel, _titleLabel, NSObjectPropertySetter(^{
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor grayColor];
}))

NSObjectPropertyLazyloadAllocWithZone(UIButton, iconBtn, _iconBtn, NSObjectPropertySetter(^{
    _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _iconBtn.userInteractionEnabled = NO;//暂时不可点击
    [_iconBtn addTarget:self action:@selector(iconBtnAction:)
       forControlEvents:UIControlEventTouchUpInside];
}))

- (void)iconBtnAction:(UIButton *)sender{
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    [self.contentView addSubview:self.iconBtn];
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize s = self.contentView.bounds.size;
    self.iconBtn.frame = VRect(15, 5, s.height - 10, s.height - 10);
    CGFloat x = VMaxX(self.iconBtn) + 10;
    self.titleLabel.frame = VRect(x, 0, s.width - x, s.height);
}

- (void)setIcon:(UIImage *)icon{
    [self layoutIfNeeded];
    
    CGSize s = _iconBtn.frame.size;
    if (!icon) {
        icon = [UIImage imageNamed:@"icon_placeholder"];
    }
    
    UIImage *img = [self imageWithRoundCorner:icon cornerRadius:s.height * 0.5 size:s];
    [_iconBtn setImage:img forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
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
