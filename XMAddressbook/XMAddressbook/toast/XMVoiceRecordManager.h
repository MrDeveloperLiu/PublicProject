#import <UIKit/UIKit.h>
#import "UIView+Frame.h"

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
