#import "XMVoiceRecordManager.h"
////////////////////////////////////////////////////////////////////////////////////////////////////
//新版


#import "UIViewMacro.h"

#define kLoopTime           1.0
#define kLeftRemindTime     10.0
#define kMaxRecordTime      60.0

#define STR_BtnUp           "按住  说话"
#define STR_BtnDown         "松开  结束"
#define STR_TimeTooLess     "录音时间太短"

#define STR_CancelDragUp    "手指上滑, 取消发送"
#define STR_CancelFreeUp    "松开手指, 取消发送"
#define STR_FormatTime(t)   [NSString stringWithFormat:@"倒计时%d秒", (t)]//int

@interface XMVoiceRecordManager()
@property (nonatomic, strong, readwrite) XMVoiceRecordView *recordView;
@property (nonatomic, strong) NSArray *imageArray;
@property (atomic, assign) BOOL finish;
@property (nonatomic, assign) NSTimeInterval recordTime;

@end

@implementation XMVoiceRecordManager

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _recordTime = 0.0;
    _finish = YES;
    [_recordView removeFromSuperview];
}

- (instancetype)init{
    if (self = [super init]) {
        _recordView = [[XMVoiceRecordView alloc] init];
        _recordView.hidden = YES;
        _recordTime = 0.0;
        
        _tooLess = YES;
    }
    return self;
}

- (void)setCenterX:(CGFloat)centerX{
    _centerX = centerX;
    _recordView.centerX = centerX;
}

- (void)setCenterY:(CGFloat)centerY{
    _centerY = centerY;
    _recordView.centerY = centerY;
}

- (void)setWidth:(CGFloat)width{
    _width = width;
    _recordView.width = width;
}

- (void)setHeight:(CGFloat)height{
    _height = height;
    _recordView.height = height;
}


- (UIButton *)buttonSettingWithButton:(UIButton *)button{
    //first title and color
    [button setTitle:@STR_BtnUp forState:UIControlStateNormal];
    [button setTitle:@STR_BtnDown forState:UIControlStateHighlighted];

//    [button setBackgroundImage:[UIImage imageNamed:ICON_chat_btn_voice_nor]
//                           forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:ICON_chat_btn_voice_sel]
//                           forState:UIControlStateHighlighted];
    //then target action
    [button addTarget:self action:@selector(buttonTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchUpOutside:)
          forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(buttonTouchDown:)
          forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchDragEnter:)
          forControlEvents:UIControlEventTouchDragEnter];
    [button addTarget:self action:@selector(buttonTouchDragExit:)
          forControlEvents:UIControlEventTouchDragExit];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor orangeColor]];
    
    return button;
}

- (void)buttonTouchUpInside:(UIButton *)sender{
    //confirm send
    //first of all detect if too less
    
    if (_tooLess && _recordTime < 1) {
        self.recordView.label.text = @STR_TimeTooLess;
        self.recordView.imageView.image = nil; //this
        
        if ([self.delegate respondsToSelector:@selector(recordManager:tooLessAndCancel:)]) {
            [self.delegate recordManager:self tooLessAndCancel:sender];
        }
        
        [self remove:YES];
        //remove it
        return;
    }
    
    if (_recordTime < 1) {
        //remove it
        if ([self.delegate respondsToSelector:@selector(recordManager:tooLessAndCancel:)]) {
            [self.delegate recordManager:self tooLessAndCancel:sender];
        }
        
        [self remove:NO];
        return;
    }
    
    // else you can send it
    if ([self.delegate respondsToSelector:@selector(recordManager:buttonComfirmSend:)]) {
        [self.delegate recordManager:self buttonComfirmSend:sender];
    }
    //remove it
    [self remove:NO];
}

- (void)buttonTouchUpOutside:(UIButton *)sender{
    // cancel send and remind user
    
    if ([self.delegate respondsToSelector:@selector(recordManager:buttonCancelSend:)]) {
        [self.delegate recordManager:self buttonCancelSend:sender];
    }
    
    [self remove:NO];
    //remove it
}

- (void)buttonTouchDown:(UIButton *)sender{
    [self changeLabelOnButton:YES];
    //show it
    [self show];
    
    if ([self.delegate respondsToSelector:@selector(recordManager:beginRecord:)]) {
        [self.delegate recordManager:self beginRecord:sender];
    }
    //begin calculate time, and observe
    [self performSelector:@selector(calculateTimeOfBeginRecord:) withObject:sender afterDelay:kLoopTime];
}

- (void)buttonTouchDragEnter:(UIButton *)sender{
    //change title for label
    [self changeLabelOnButton:YES];
}

- (void)buttonTouchDragExit:(UIButton *)sender{
    //change title for label
    [self changeLabelOnButton:NO];
}

- (void)calculateTimeOfBeginRecord:(UIButton *)sender{
    
    @autoreleasepool {
        
        if (_recordTime >= kMaxRecordTime - kLeftRemindTime) {
            //begin
            int left = kMaxRecordTime - _recordTime;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.recordView.label.text = STR_FormatTime(left);
                
                if (0 >= left) {
                    
                    if ([self.delegate respondsToSelector:@selector(recordManager:overTimeAndSend:)]) {
                        [self.delegate recordManager:self overTimeAndSend:sender];
                    }
                    
                    [self remove:NO];
                    
                }
            });
            
        }
        
        _recordTime ++;
        
    }
    
    [self performSelector:@selector(calculateTimeOfBeginRecord:) withObject:sender afterDelay:kLoopTime];
}

- (void)show{ //if you show then init
    _finish = NO;
    _recordTime = 0.0;
    self.recordView.hidden = NO;
}

- (void)remove:(BOOL)delay{
    _finish = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (delay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.38 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.recordView.hidden = YES;
        });
    }else{
        self.recordView.hidden = YES;
    }
}

- (void)changeLabelOnButton:(BOOL)on{
    if (on) {
        self.recordView.label.text = @STR_CancelDragUp;
        self.recordView.label.backgroundColor = [UIColor clearColor];
    }else{
        self.recordView.label.text = @STR_CancelFreeUp;
        self.recordView.label.backgroundColor = [UIColor redColor];
    }
}

- (void)addRecordViewToView:(UIView *)view frame:(CGRect)frame{
    [view addSubview:self.recordView];
    self.recordView.frame = frame;
}

- (void)refreshTheMACVoiceWithRate:(CGFloat)rate{
    
    if (rate < - 30){
        [self changeImageWithObjectIndex:0];
    }else if (rate >= - 30 && rate < - 25){
        [self changeImageWithObjectIndex:1];
    }else if (rate >= - 25 && rate < - 20){
        [self changeImageWithObjectIndex:2];
    }else if (rate >= - 20 && rate < - 15){
        [self changeImageWithObjectIndex:3];
    }else if (rate >= - 15 && rate < - 10){
        [self changeImageWithObjectIndex:4];
    }else if (rate >= - 10 && rate < - 5){
        [self changeImageWithObjectIndex:5];
    }else if (rate >= - 5 && rate < -2){
        [self changeImageWithObjectIndex:6];
    }else if (rate >= - 2){
        [self changeImageWithObjectIndex:7];
    }
    
}

- (void)changeImageWithObjectIndex:(int)index{
    self.recordView.imageView.image = self.imageArray[index];
}

- (NSArray *)imageArray{
    
    if (!_imageArray) {
//        _imageArray = @[
//                       UICachedImage(ICON_message_voice_viewImage_1),
//                       UICachedImage(ICON_message_voice_viewImage_2),
//                       UICachedImage(ICON_message_voice_viewImage_3),
//                       UICachedImage(ICON_message_voice_viewImage_4),
//                       UICachedImage(ICON_message_voice_viewImage_5),
//                       UICachedImage(ICON_message_voice_viewImage_6),
//                       UICachedImage(ICON_message_voice_viewImage_7),
//                       UICachedImage(ICON_message_voice_viewImage_8)
//                       ];
    }
    return _imageArray;
}

@end

@interface XMVoiceRecordView()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) UILabel *label;

@end

@implementation XMVoiceRecordView

UIViewPropertyLazyload(UILabel, label, _label, NSObjectPropertySetter(^{
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:14.0f];
    _label.textColor = UIColorFromHex(0xd6d6d6);
    _label.layer.cornerRadius = 3;
    _label.layer.masksToBounds = YES;
    _label.backgroundColor = [UIColor orangeColor];
    
    _label.text = @"倒计时3秒";
}))

UIViewPropertyLazyload(UIImageView, imageView, _imageView, NSObjectPropertySetter(^{
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
//    _imageView.image = [UIImage imageNamed:ICON_message_voice_viewImage_8];
}))

UIViewPropertyLazyload(UIView, containerView, _containerView, NSObjectPropertySetter(^{
    _containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    _containerView.layer.cornerRadius = 3;
}))

- (instancetype)init{
    if (self = [super init]) {
        [self addSubview:self.containerView];
        [self addSubview:self.imageView];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    CGFloat margin = 12;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.imageView.x = margin;
    self.imageView.y = margin;
    self.imageView.width = width - margin * 2;
    self.imageView.height = height - margin * 6;
    
    self.label.x = margin;
    self.label.y = self.imageView.height + margin * 3;
    self.label.width = self.imageView.width;
    self.label.height = margin * 2;
    
}

@end
