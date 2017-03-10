//  XMToastView.h
//  功能: 说话音量展示 (视图)
//  作者: 刘杨
//  创建日期: 2015-11-13
//  最近修改: 2016-11-2
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#import <AVFoundation/AVFoundation.h>

@class XMToastView, XMToastViewMananger;

@protocol XMToastViewManangerDelegate <NSObject>
@optional
- (void)toastViewManager:(XMToastViewMananger *)manager ButtonTouchDown:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager ButtonTouchUpInside:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager ButtonTouchUpOutside:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager ButtonTouchDragExit:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager ButtonTouchDragEnter:(UIButton *)button;

////////////////////////////////////////////////////上下两种都会走，看需求，用上面就别用下面了

- (void)toastViewManager:(XMToastViewMananger *)manager beginSpeakingWithButton:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager didFinishedSpeakingWithButton:(UIButton *)button;
- (void)toastViewManager:(XMToastViewMananger *)manager cancelSpeakingWithButton:(UIButton *)button;

//如果超时的话会走这个回调
- (void)toastViewManager:(XMToastViewMananger *)manager speakingTimeOutWithButton:(UIButton *)button;
//如果想使用这个，必须设置ifHaveTimeLessMode = YES
- (void)toastViewManager:(XMToastViewMananger *)manager speakingTimeLessThanOneSecondWithButton:(UIButton *)button;

@end

@interface XMToastViewMananger : NSObject

@property (nonatomic, weak) id<XMToastViewManangerDelegate> delegate;
//获取实例
+ (XMToastViewMananger *)shareManager;

//详细解释一下这个方法，你需要给我传要在哪个view上显示 ， 并且给我传你要用到的按钮， 并且传代理， 并且传你当前录音的录音器
//时时监听麦克风音量的方法里面有个图片数组，如果要更改的话，记得替换属性和替换所取得图片，不然肯定导致crash
- (void)showToastViewInView:(UIView *)view
                speakButton:(UIButton *)button
                   delegate:(id<XMToastViewManangerDelegate>)delegate;

- (void)refreshTheMACVoiceWithRate:(CGFloat)rate;
- (void)refreshTheMACVoiceDidStop;

//设置view的位置
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

//是否有少于1秒的提示
@property (nonatomic, assign) BOOL    ifHaveTimeLessMode;                       //default is NO
@end

@interface XMToastView : UIView

@property (readwrite, nonatomic, copy)   NSString   *text;                      //面板上的文字属性
@property (readwrite, nonatomic, strong) UIImage    *image;                     //面板上的图片属性
@property (readwrite, nonatomic, strong) UIColor    *labelColor;                //面板上文字框的背景颜色属性


+ (XMToastView *)defaultView;

+ (XMToastView *)viewWithImage:(UIImage *)image
                     labelText:(NSString *)text
                 timeUpHandler:(void(^)(XMToastView *toastView))handler;
@end




////////////////////////////////////////////////////////////////////////////////////////////////////
//新版




@class XMVoiceRecordView;
@protocol XMVoiceRecordManagerDelegate;
@interface XMVoiceRecordManager : NSObject

@property (nonatomic, strong, readonly) XMVoiceRecordView *recordView;
@property (nonatomic, weak) id <XMVoiceRecordManagerDelegate> delegate;
@property (nonatomic, assign) BOOL tooLess;

- (UIButton *)buttonSettingWithButton:(UIButton *)button;
- (void)addRecordViewToView:(UIView *)view frame:(CGRect)frame;
- (void)refreshTheMACVoiceWithRate:(CGFloat)rate;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@interface XMVoiceRecordView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *label;

@end

@protocol XMVoiceRecordManagerDelegate <NSObject>

- (void)recordManager:(XMVoiceRecordManager *)manager beginRecord:(UIButton *)btn;
- (void)recordManager:(XMVoiceRecordManager *)manager buttonComfirmSend:(UIButton *)btn;
- (void)recordManager:(XMVoiceRecordManager *)manager buttonCancelSend:(UIButton *)btn;
- (void)recordManager:(XMVoiceRecordManager *)manager overTimeAndSend:(UIButton *)btn;
- (void)recordManager:(XMVoiceRecordManager *)manager tooLessAndCancel:(UIButton *)btn;

@end
