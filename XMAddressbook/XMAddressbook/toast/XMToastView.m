#import "XMToastView.h"

#define kTimerSetZero  0
#define kTimerLeftTen  10
#define kBtnTitleColor UIColorFromRGB(112, 112, 112)

@interface XMToastViewMananger()<UIAlertViewDelegate, AVAudioRecorderDelegate>{
    float _recorderTime;
    BOOL  _isSend;
    BOOL  _isTooLess;
}

/**下面是有用的*/
@property (nonatomic, strong) XMToastView                   *toast;
@property (nonatomic, strong) NSArray                       *img_array;
@property (nonatomic, strong) UIView                        *view;
@property (nonatomic, strong) UIView                        *back;

@property (nonatomic, weak) UIButton                        *button;

@end

@implementation XMToastViewMananger

+ (XMToastViewMananger *)shareManager{
    static XMToastViewMananger *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (void)showToastViewInView:(UIView *)view
                speakButton:(UIButton *)button
                   delegate:(id<XMToastViewManangerDelegate>)delegate{
    
    self.delegate = delegate;
    self.view = view;
    self.button = button;
    
    self.button.tintColor = [UIColor clearColor];
//    [self.button setBackgroundImage:[UIImage imageNamed:ICON_chat_btn_voice_nor]
//                           forState:UIControlStateNormal];
//    [self.button setBackgroundImage:[UIImage imageNamed:ICON_chat_btn_voice_sel]
//                           forState:UIControlStateHighlighted];
    
    self.button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.button.layer.cornerRadius = 3;
    
    [self.button setTitle:@"按住  说话" forState:UIControlStateNormal];
    [self.button setTitle:@"松开  结束" forState:UIControlStateHighlighted];
    [self.button setTitle:@"按住  说话" forState:UIControlStateSelected];
    
    [self.button setTitleColor:kBtnTitleColor forState:UIControlStateNormal];
    [self.button setTitleColor:kBtnTitleColor forState:UIControlStateHighlighted];
    [self.button setTitleColor:kBtnTitleColor forState:UIControlStateSelected];
    
    [self.button addTarget:self action:@selector(buttonTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.button addTarget:self action:@selector(buttonTouchUpOutside:)
          forControlEvents:UIControlEventTouchUpOutside];
    [self.button addTarget:self action:@selector(buttonTouchDown:)
          forControlEvents:UIControlEventTouchDown];
    [self.button addTarget:self action:@selector(buttonTouchDragEnter:)
          forControlEvents:UIControlEventTouchDragEnter];
    [self.button addTarget:self action:@selector(buttonTouchDragExit:)
          forControlEvents:UIControlEventTouchDragExit];
}

//button点击事件
- (void)buttonTouchUpInside:(UIButton *)sender{
    
    sender.selected = NO;
    if (_recorderTime < 1 && NO != _ifHaveTimeLessMode) {
        ///给他用户交互关了
        sender.userInteractionEnabled = NO;
        [self setRecoderTimeZero];
        if ([self.delegate respondsToSelector:@selector(toastViewManager:speakingTimeLessThanOneSecondWithButton:)]) {
            [self.delegate toastViewManager:self speakingTimeLessThanOneSecondWithButton:self.button];
        }
        
        self.toast.image = nil;//替换为一个叹号
        _isTooLess = YES;
        self.toast.text = @"录音时间太短";

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.toast removeFromSuperview];
            [self.back removeFromSuperview];
            sender.userInteractionEnabled = YES;//给丫打开用户交互
            _isTooLess = NO;
        });
        
    }else if(!_isSend){
        
        [self setRecoderTimeZero];
        if ([self.delegate respondsToSelector:@selector(toastViewManager:didFinishedSpeakingWithButton:)]) {
            [self.delegate toastViewManager:self didFinishedSpeakingWithButton:self.button];
        }
        if ([self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchUpInside:)]) {
            [self.delegate toastViewManager:self ButtonTouchUpInside:self.button];
        }
        [self.toast removeFromSuperview];
        [self.back removeFromSuperview];
    }
    _recorderTime = kTimerSetZero;
    _isSend = NO;
}

- (void)buttonTouchUpOutside:(UIButton *)sender{
    
    sender.selected = NO;
    [self setRecoderTimeZero];
    [self.toast removeFromSuperview];
    [self.back removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(toastViewManager:cancelSpeakingWithButton:)]) {
        [self.delegate toastViewManager:self cancelSpeakingWithButton:self.button];
    }
    
    if ([self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchUpOutside:)]) {
        [self.delegate toastViewManager:self ButtonTouchUpOutside:self.button];
    }
    _recorderTime = kTimerSetZero;
    _isSend = NO;
}

// 开启录音和加载视图
- (void)buttonTouchDown:(UIButton *)sender {

    // 判断当前是否在线,不在线弹出提示询问是否调用系统短信功能
//    if ([Reachability networkUnreach]) {
//        [UIAlertView simpleAlert:@"您当前处于离线状态，不能使用该功能。"];
//        return;
//    }
    
    sender.selected = NO;
    [self addVoiceViewToView:self.view];
    
    if ([self.delegate respondsToSelector:@selector(toastViewManager:beginSpeakingWithButton:)]) {
        [self.delegate toastViewManager:self beginSpeakingWithButton:self.button];
    }
    if ([self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDown:)]) {
        [self.delegate toastViewManager:self ButtonTouchDown:self.button];
    }
    if (self.img_array) self.toast.image = self.img_array.firstObject;
}

- (void)buttonTouchDragEnter:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDragEnter:)]) {
        [self.delegate toastViewManager:self ButtonTouchDragEnter:self.button];
    }
    
    sender.selected = NO;
    self.toast.labelColor = [UIColor clearColor];
    self.toast.text = @"手指上滑, 取消发送";
}

- (void)buttonTouchDragExit:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDragExit:)]) {
        [self.delegate toastViewManager:self ButtonTouchDragExit:self.button];
    }
    sender.selected = YES;
    self.toast.text = @"松开手指, 取消发送";
}

- (void)addVoiceViewToView:(UIView *)view{
    
    self.toast = [XMToastView viewWithImage:self.img_array.firstObject
                                  labelText:@"手指上滑, 取消发送"
                              timeUpHandler:^(XMToastView *toastView) {
                                  [self setRecoderTimeZero];
                                  if ([self.delegate respondsToSelector:@selector(toastViewManager:speakingTimeOutWithButton:)]) {
                                      [self.delegate toastViewManager:self
                                            speakingTimeOutWithButton:self.button];
                                      _isSend = YES;
                                  }
                              }];
    
//    self.toast.width = self.width ?: 155;
//    self.toast.height = self.height ?: 155;
//    self.toast.centerX = self.centerX ?: view.centerX;
//    self.toast.centerY = self.centerY ?: view.centerY;
    
    self.back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, USSizeW, USSizeH)];
    self.back.backgroundColor = [UIColor clearColor];
    [self.back addSubview:self.toast];
    [view addSubview:self.back];
}

//- (NSArray *)img_array{
//    
//    if (!_img_array) {
//        _img_array = @[
//                      UICachedImage(ICON_message_voice_viewImage_1),
//                      UICachedImage(ICON_message_voice_viewImage_2),
//                      UICachedImage(ICON_message_voice_viewImage_3),
//                      UICachedImage(ICON_message_voice_viewImage_4),
//                      UICachedImage(ICON_message_voice_viewImage_5),
//                      UICachedImage(ICON_message_voice_viewImage_6),
//                      UICachedImage(ICON_message_voice_viewImage_7),
//                      UICachedImage(ICON_message_voice_viewImage_8)
//                      ];
//    }
//    return _img_array;
//}

- (void)refreshTheMACVoiceWithRate:(CGFloat)rate{
    
    if (self.img_array.count > 0 && !_isTooLess) {
        if (rate >= - 40 && rate < - 35) {
            self.toast.image = self.img_array[0];
        }else if (rate >= - 35 && rate < - 30){
            self.toast.image = self.img_array[0];
        }else if (rate >= - 30 && rate < - 25){
            self.toast.image = self.img_array[1];
        }else if (rate >= - 25 && rate < - 20){
            self.toast.image = self.img_array[2];
        }else if (rate >= - 20 && rate < - 15){
            self.toast.image = self.img_array[3];
        }else if (rate >= - 15 && rate < - 10){
            self.toast.image = self.img_array[4];
        }else if (rate >= - 10 && rate < - 5){
            self.toast.image = self.img_array[5];
        }else if (rate >= - 5 && rate < -2){
            self.toast.image = self.img_array[6];
        }else if (rate >= - 2){
            self.toast.image = self.img_array[7];
        }
    }
    if (self.ifHaveTimeLessMode) {
        _recorderTime += 0.1;
    }
}

- (void)refreshTheMACVoiceDidStop{
    self.toast.image = nil;
}

//完成定时器并播放
- (void)setRecoderTimeZero{
    _recorderTime = kTimerSetZero;
}

@end

@interface XMToastView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *text_label;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation XMToastView{
    int _time;
    int _left_time;
    void(^_handler)(XMToastView *);
}

+ (XMToastView *)defaultView{
    static XMToastView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

+ (XMToastView *)viewWithImage:(UIImage *)image
                     labelText:(NSString *)text
                 timeUpHandler:(void (^)(XMToastView *))handler{
    
    XMToastView *view = [XMToastView defaultView];
    [view setTimeUpHandler:handler];
    [view beginTimer];//开启定时器
    [view setValuesWithImage:image text:text];
    return view;
}

- (void)setTimeUpHandler:(void(^)(XMToastView *))handler{
    _handler = [handler copy];
}

- (void)beginTimer{
    //开启定时器
    _time = kTimerSetZero;
    _left_time = kTimerLeftTen;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        [self initialized];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    
    _image = image;
    self.imageView.image = image;
}

- (void)setText:(NSString *)text{
    
    _text = text;
    self.text_label.text = text;
}

- (void)setLabelColor:(UIColor *)labelColor{
    
    _labelColor = labelColor;
    self.text_label.backgroundColor = labelColor;
}

- (void)setValuesWithImage:(UIImage *)image text:(NSString *)text{
    
    self.image = image;
    self.text = text;
    
    self.imageView.image = self.image;
    self.text_label.text = self.text;
}

- (void)initialized{
    
    [self addSubview:self.containerView];
    [self addSubview:self.imageView];
    [self addSubview:self.text_label];
}

- (NSTimer *)timer{
    
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.0
                                         target:self selector:@selector(calculateTime:)
                                       userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)calculateTime:(NSTimer *)sender{

    if (49 <= _time) {
        self.text_label.text = [NSString stringWithFormat:@"倒计时%d秒", _left_time--];
        if (60 < _time || -1 > _left_time) {
            [self removeFromSuperview];
            if (_handler) {
                _handler(self);
            }
        }
    }
    _time ++;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    CGFloat margin = 12;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
//    self.imageView.x = margin;
//    self.imageView.y = margin;
//    self.imageView.width = width - margin * 2;
//    self.imageView.height = height - margin * 6;
//    
//    self.text_label.x = margin;
//    self.text_label.y = self.imageView.height + margin * 2;
//    self.text_label.width = self.imageView.width;
//    self.text_label.height = margin * 3;
}

- (UIView *)containerView{
    
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
//        _containerView.backgroundColor = UIColorFromRGBAlpha(24, 24, 24, 0.6f);
    }
    return _containerView;
}

- (UIImageView *)imageView{
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)text_label{
    
    if (!_text_label) {
        _text_label = [[UILabel alloc] init];
        _text_label.backgroundColor = [UIColor clearColor];
        _text_label.textAlignment = NSTextAlignmentCenter;
        _text_label.font = [UIFont systemFontOfSize:14.0f];
//        _text_label.textColor = UIColorFromHEX(0xd6d6d6);
        _text_label.layer.cornerRadius = 5;
        _text_label.layer.masksToBounds = YES;
    }
    return _text_label;
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    
    self.text = nil;
    self.labelColor = [UIColor clearColor];
    
    [self.timer invalidate];
    self.timer = nil;
    _time = kTimerSetZero;
    _left_time = kTimerSetZero;
    self.text_label.text = nil;
}

@end

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
