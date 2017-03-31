#import "XMPerosnalInfoBaseCell.h"
#import "XMGradientView.h"

@implementation XMPerosnalInfoBaseCell

+ (NSString *)registerCellWithTableView:(UITableView *)tableView{
    NSString *retVal = NSStringFromClass([self class]);
    [tableView registerClass:[self class] forCellReuseIdentifier:retVal];
    return retVal;
}

@end

//头像Cell
@interface XMPerosnalInfoProtraitCell()
@property (nonatomic, strong) XMGradientView *gradientView;
@end
@implementation XMPerosnalInfoProtraitCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.gradientView];
    }
    return self;
}

- (XMGradientView *)gradientView{
    if (!_gradientView) {
        _gradientView = [[XMGradientView alloc] init];
        _gradientView.from = XMColorMake(63, 145, 240, 1);
        _gradientView.to = XMColorMake(48, 173, 229, 1);
    }
    return _gradientView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.gradientView.frame = self.contentView.bounds;
}
@end

//图片按钮Cell
@interface XMPerosnalInfoFunctionButtonCell()

@end
@implementation XMPerosnalInfoFunctionButtonCell

@end

//普通按钮Cell
@interface XMPerosnalInfoNormalButtonCell()

@end
@implementation XMPerosnalInfoNormalButtonCell

@end


//电话, 邮箱Cell
@interface XMPerosnalInfoPhoneCell()

@end
@implementation XMPerosnalInfoPhoneCell

@end
