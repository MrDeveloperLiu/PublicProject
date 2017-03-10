#import "XMPerosnalInfoBaseCell.h"
#import "XMGradientView.h"
#import "XMPersonalInfoViewModel.h"

@implementation XMPerosnalInfoBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:kPixel3(72)];
}

+ (NSString *)registerCellWithTableView:(UITableView *)tableView{
    NSString *retVal = NSStringFromClass([self class]);
    [tableView registerClass:[self class] forCellReuseIdentifier:retVal];
    return retVal;
}

@end

//头像Cell
@interface XMPerosnalInfoProtraitCell()

@property (nonatomic, strong) XMGradientView *gradientView;
@property (nonatomic, strong) XMResizeableButton *iconBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation XMPerosnalInfoProtraitCell

- (void)setupViews{
    self.type = PersonalCellTypeInitial;
    
    [self.contentView addSubview:self.gradientView];
    [self.gradientView addSubview:self.nameLabel];
    [self.gradientView addSubview:self.iconBtn];
    [self.gradientView addSubview:self.infoLabel];
}

- (void)setModel:(XMPersonalInfoViewModel *)model{
    [self layoutIfNeeded];
    
    //model class is [XMData class] then this method works
    if ([model.data isKindOfClass:[NSDictionary class]]) {
        
    }
    
    [self.iconBtn setImage:[UIImage imageNamed:@"icon_placeholder"] forState:UIControlStateNormal];
    NSString *t = @"副总经理\n中国移动/人力资源部/总部人力资源\n\n副总经理\n中国移动/人力资源部/总部人力资源部门";
    NSString *name = @"欧阳娜娜";
    self.nameLabel.text = name;
    self.infoLabel.text = t;
    
    CGFloat x = VMaxX(self.iconBtn) + kPixel3(56);
    
    CGRect r = [t boundingRectWithSize:(CGSize){USSizeW - x, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.infoLabel.font} context:NULL];
    CGFloat h = r.size.height;
    self.infoLabel.frame = (CGRect){x, VMaxY(self.nameLabel) + kPixel3(52), USSizeW - x, h};
    model.protraitHeight = VMaxY(self.infoLabel) + kPixel3(112);
}

- (CGFloat)height{
    return VMaxY(self.infoLabel) + kPixel3(112);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.gradientView.frame = self.contentView.bounds;
    self.iconBtn.frame = (CGRect){kPixel3(40), kPixel3(360), kPixel3(210), kPixel3(210)};
    CGFloat x = VMaxX(self.iconBtn) + kPixel3(56);
    self.nameLabel.frame = (CGRect){x, kPixel3(368), USSizeW - x, kPixel3(52)};
}

- (XMGradientView *)gradientView{
    if (!_gradientView) {
        _gradientView = [[XMGradientView alloc] init];
        _gradientView.from = UIColorFromRGB(63, 145, 240);
        _gradientView.to = UIColorFromRGB(48, 173, 229);
    }
    return _gradientView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:kPixel3(54)];
    }
    return _nameLabel;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:kPixel3(40)];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (XMResizeableButton *)iconBtn{
    if (!_iconBtn) {
        _iconBtn = [XMResizeableButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn addTouchUpInSideTarget:self action:@selector(iconBtnAction:)];
        [_iconBtn resizeImageWithBlock:^CGRect(CGRect contectRect) {
            return contectRect;
        }];
    }
    return _iconBtn;
}

- (void)iconBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(protraitCell:clickAtProtrait:)]) {
        [self.delegate protraitCell:self clickAtProtrait:(UIButton *)sender];
    }
}
@end

//图片按钮Cell
@interface XMPerosnalInfoFunctionButtonCell()

@property (nonatomic, strong) XMResizeableButton *reszieBtn;

@end

@implementation XMPerosnalInfoFunctionButtonCell
- (void)setupViews{
    self.type = PersonalFunctionTypeInit;
    
    [self.contentView addSubview:self.reszieBtn];
}

- (void)setModel:(XMPersonalInfoViewModel *)model{
    if (self.type == PersonalFunctionTypeMessage) {
        [self setShowTitle:@"即时消息"];
    }else if (self.type == PersonalFunctionTypeNetPhone) {
        [self setShowTitle:@"网络电话"];
    }else if (self.type == PersonalFunctionTypeVOIP) {
        [self setShowTitle:@"视频通话"];
    }else if (self.type == PersonalFunctionTypeFreeSMS){
        [self setShowTitle:@"免费短信"];
    }
    [self setIcon:[UIImage imageNamed:@"icon_mail_doc"]];
}

- (void)setShowTitle:(NSString *)title{
    [self.reszieBtn setTitle:title forState:UIControlStateNormal];
}

- (void)setIcon:(UIImage *)icon{
    [self.reszieBtn setImage:icon forState:UIControlStateNormal];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.reszieBtn.frame = self.contentView.bounds;
}

- (void)resizeBtnAction:(XMResizeableButton *)sender{
    if ([self.delegate respondsToSelector:@selector(functionButtonCell:clickAtBtn:)]) {
        [self.delegate functionButtonCell:self clickAtBtn:sender];
    }
}

- (XMResizeableButton *)reszieBtn{
    if (!_reszieBtn) {
        _reszieBtn = [XMResizeableButton buttonWithType:UIButtonTypeCustom];
        [_reszieBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _reszieBtn.titleLabel.font = [UIFont systemFontOfSize:kPixel3(54)];
        [_reszieBtn resizeImageWithBlock:^CGRect(CGRect contectRect) {
            CGFloat w = kPixel3(100) + kPixel3(80) + 100;
            CGFloat x = (contectRect.size.width - w) / 2;
            return (CGRect){x, kPixel3(30) , kPixel3(100), kPixel3(100)};
        }];
        [_reszieBtn resizeTitleWithBlock:^CGRect(CGRect contectRect, CGRect imageRect) {
            CGFloat x = imageRect.origin.x + imageRect.size.width + kPixel3(80);
            return (CGRect){x, kPixel3(30), kPixel3(300), kPixel3(100)};
        }];
        [_reszieBtn addTouchUpInSideTarget:self action:@selector(resizeBtnAction:)];
    }
    return _reszieBtn;
}
@end

//普通按钮Cell
@interface XMPerosnalInfoNormalButtonCell()

@property (nonatomic, strong) UIButton *btn;

@end

@implementation XMPerosnalInfoNormalButtonCell

- (void)setupViews{
    self.type = PersonalNormalTypeInit;;

    [self.contentView addSubview:self.btn];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.btn.frame = self.contentView.bounds;
}

- (void)setModel:(XMPersonalInfoViewModel *)model{
    if (self.type == PersonalNormalTypeCommon) {
        if (model.inCommon) {
            [_btn setTitle:@"删除常用联系人" forState:UIControlStateNormal];
            [_btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [_btn setTitle:@"添加到常用联系人" forState:UIControlStateNormal];
            [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }else if (self.type == PersonalNormalTypeAddressbook){
        if (!model.inAddressbook) {
            [_btn setTitle:@"添加到本地通讯录" forState:UIControlStateNormal];
            [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)btnAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(normalButtonCell:clickAtBtn:)]) {
        [self.delegate normalButtonCell:self clickAtBtn:sender];
    }
}

- (UIButton *)btn{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.titleLabel.font = [UIFont systemFontOfSize:kPixel3(54)];
        [_btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}
@end


//电话, 邮箱Cell
@interface XMPerosnalInfoPhoneCell()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *infoBtn;
@property (nonatomic, strong) XMResizeableButton *actionBtn;

@end

@implementation XMPerosnalInfoPhoneCell

- (void)setupViews{
    self.type = PersonalPhoneTypeInit;
    
    [self.contentView addSubview:self.typeLabel];
    [self.contentView addSubview:self.infoBtn];
    [self.contentView addSubview:self.actionBtn];
    
}

- (void)setModel:(XMPersonalInfoViewModel *)model{
    
    //
    if ([model isKindOfClass:[NSDictionary class]]) {
        
    }
    
    if (self.type == PersonalPhoneTypePhone) {
        [self setTypeTitle: @"手机号码 :"];
        [self setInfoTitle:@"13800138000"];
        [self setActionImage:[UIImage imageNamed:@"icon_mail_doc"]];

    }else if (self.type == PersonalPhoneTypeEmail){
        [self setTypeTitle: @"电子邮箱 :"];
        [self setInfoTitle:@"nuagfksakod@sina.com"];
        [self setActionImage:[UIImage imageNamed:@"icon_mail_doc"]];

    }
    
}

- (void)setInfoTitle:(NSString *)title{
    [self.infoBtn setTitle:title forState:UIControlStateNormal];
}

- (void)setTypeTitle:(NSString *)title{
    self.typeLabel.text = title;
}

- (void)setActionImage:(UIImage *)image{
    [self.actionBtn setImage:image forState:UIControlStateNormal];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect r = self.contentView.frame;
    self.typeLabel.frame = (CGRect){kPixel3(40), 0, kPixel3(210), r.size.height};
    self.actionBtn.frame = (CGRect){USSizeW - kPixel3(160), 0, kPixel3(160), r.size.height};
    self.infoBtn.frame = (CGRect){VMaxX(self.typeLabel), 0, USSizeW - kPixel3(160) - VMaxX(self.typeLabel), r.size.height};
}

- (UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = [UIColor grayColor];
        _typeLabel.font = [UIFont systemFontOfSize:kPixel3(44)];
    }
    return _typeLabel;
}

- (void)infoLongGRAction:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItem:)];
        [[UIMenuController sharedMenuController] setMenuItems:@[item]];
        [[UIMenuController sharedMenuController] setTargetRect:self.bounds inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

- (void)infoBtnAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(phoneCell:clickAtInfoBtn:)]) {
        [self.delegate phoneCell:self clickAtInfoBtn:sender];
    }
}

- (void)actionBtnAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(phoneCell:clickAtActionBtn:)]) {
        [self.delegate phoneCell:self clickAtActionBtn:sender];
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)copyItem:(UIMenuItem *)sender{
    if ([self.delegate respondsToSelector:@selector(phoneCell:copyAtInfoBtn:)]) {
        [self.delegate phoneCell:self copyAtInfoBtn:self.infoBtn];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copyItem:)) return YES;
    return NO;
}

- (UIButton *)infoBtn{
    if (!_infoBtn) {
        _infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_infoBtn addTarget:self action:@selector(infoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_infoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _infoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UILongPressGestureRecognizer *longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(infoLongGRAction:)];
        longGR.minimumPressDuration = 1.0f;
        [_infoBtn addGestureRecognizer:longGR];
    }
    return _infoBtn;
}

- (XMResizeableButton *)actionBtn{
    if (!_actionBtn) {
        _actionBtn = [XMResizeableButton buttonWithType:UIButtonTypeCustom];
        [_actionBtn resizeImageWithBlock:^CGRect(CGRect contectRect) {
            CGSize s = (CGSize){contectRect.size.height * 0.5, contectRect.size.height * 0.5};
            return VCenterRect(contectRect, s);
        }];
        [_actionBtn addTouchUpInSideTarget:self action:@selector(actionBtnAction:)];
    }
    return _actionBtn;
}
@end

@interface XMPerosnalInfoPhoneNameCell ()

@property (nonatomic, strong) XMGradientView *gradientView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation XMPerosnalInfoPhoneNameCell

- (void)setupViews{
    self.type = PersonalCellTypeInitial;
    
    [self.contentView addSubview:self.gradientView];
    [self.gradientView addSubview:self.nameLabel];
}

- (void)setModel:(XMPersonalInfoViewModel *)model{

    self.nameLabel.text = @"欧阳娜娜";
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect r = self.contentView.bounds;
    self.gradientView.frame = r;
    self.nameLabel.frame = (CGRect){kPixel3(40), r.size.height - kPixel3(240), r.size.width - kPixel3(40), kPixel3(240)};
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:kPixel3(69)];
    }
    return _nameLabel;
}

- (XMGradientView *)gradientView{
    if (!_gradientView) {
        _gradientView = [[XMGradientView alloc] init];
        _gradientView.from = UIColorFromRGB(63, 145, 240);
        _gradientView.to = UIColorFromRGB(48, 173, 229);
    }
    return _gradientView;
}

@end




