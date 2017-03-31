#import "ChatTableViewCell.h"

#define kMaxW  ScreenW - 120 //最大的cell宽度

@interface ChatTableViewCell()<XMAttributeLabelProtocol>
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) XMAttributeLabel *label;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation ChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:NSStringFromClass([self class])];
    if (self) {
        _label = [[XMAttributeLabel alloc] init];
        _label.lineBreakMode = kCTLineBreakByWordWrapping;
        _label.delegate = self;
        _label.layer.borderWidth = 0.5f;
        [self.contentView addSubview:_label];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
        _nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_nameLabel];
        
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setBackgroundImage:[UIImage imageNamed:@"icon_mail_doc"] forState:UIControlStateNormal];
        [self.contentView addSubview:_iconBtn];
    }
    return self;
}

- (void)label:(XMAttributeLabel *)label performActionWithItem:(XMAttributeItem *)item{
    
    if ([self.delegate respondsToSelector:@selector(chatCell:itemDidClicked:)]) {
        [self.delegate chatCell:self itemDidClicked:item];
    }
    
}

- (void)setModel:(ChatModel *)model{


    if (_model.messageID != model.messageID) {
        _model = model;
        _label.text = model.content;
        _nameLabel.text = model.dest ?: @"陌生人";
        
            //you need parser your emoji before your links, or it have problem
        for (XMAttributeItem *it in [ChatAutoMojiParser parserEmoji:model.content])
            [_label resetEmojiWithItem:it];
        
        for (XMAttributeItem *it in [XMAutoLinkDetect detectLink:model.content])
            [_label resetLinkWithItem:it];
        
        CGFloat a = 36;
        CGSize s = [_label.text boundingRectWithSize:(CGSize){kMaxW, MAXFLOAT}
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: _label.font}
                                             context:NULL].size;
        CGFloat max = MIN(kMaxW, s.width);
        s = [_label sizeThatFits:(CGSize){max, MAXFLOAT}];
        
        if (_model.object == ChatObjectMe) {
            _iconBtn.frame = (CGRect){ScreenW - 10 - a, 10, a, a};
            CGFloat x = CGRectGetMinX(_iconBtn.frame);
            CGFloat y = CGRectGetMinY(_iconBtn.frame);
            _label.frame = (CGRect){x - 10 - s.width, y, s.width, s.height};
            _nameLabel.frame = CGRectZero;
            _nameLabel.text = @"";
        }else if (_model.object == ChatObjectGroup){
            _iconBtn.frame = (CGRect){10, 10, a, a};
            
            CGFloat x = CGRectGetMaxX(_iconBtn.frame);
            CGFloat y = CGRectGetMinY(_iconBtn.frame);
            
            _nameLabel.frame = (CGRect){x + 10, y, s.width, 20};
            CGFloat nmy = CGRectGetMaxY(_nameLabel.frame) + 2;
            _label.frame = (CGRect){x + 10, nmy, s.width, s.height};
            
        }else if (_model.object == ChatObjectOthers){
            _iconBtn.frame = (CGRect){10, 10, a, a};
            
            CGFloat x = CGRectGetMaxX(_iconBtn.frame);
            CGFloat y = CGRectGetMinY(_iconBtn.frame);
            _label.frame = (CGRect){x + 10, y, s.width, s.height};
            
            _nameLabel.frame = CGRectZero;
            _nameLabel.text = @"";
        }


        CGFloat ly = _label.frame.origin.y;
        CGFloat h = s.height;
        CGFloat imy = CGRectGetMaxY(_iconBtn.frame);
        
        model.rowHeight = MAX(ly + h + 10, imy + 10);
    }
        

}


@end




@implementation ChatModel

@end

@implementation ChatAutoMojiParser

+ (NSArray<XMAttributeItem *> *)parserEmoji:(NSString *)text{
    NSMutableArray *temp = nil;
    if (text.length){
        
        temp = [NSMutableArray array];
    
    
        NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@key
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
        [urlRegex enumerateMatchesInString:text
                                   options:0
                                     range:NSMakeRange(0, text.length)
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    
                                    NSRange range = result.range;
                                    
                                    XMAttributeItem *item = [[XMAttributeItem alloc] init];
                                    item.type = XMAttachmentItemTypeImage;
                                    
                                    NSString *is = [text substringWithRange:range];
                                    is = [is stringByReplacingOccurrencesOfString:@"[" withString:@""];
                                    is = [is stringByReplacingOccurrencesOfString:@"]" withString:@""];

                                    item.content = [UIImage imageNamed:is];
                                    item.size = (CGSize){20, 20};
                                    item.linkRange = range;
                                    
                                    [temp addObject:item];
                                }];
    }
   
    return temp;
}

@end

