#import <UIKit/UIKit.h>
#import "XMResizeableButton.h"

@protocol XMPerosnalInfoBaseCellDelegate;
@interface XMPerosnalInfoBaseCell : UITableViewCell

@property (nonatomic, weak) id<XMPerosnalInfoBaseCellDelegate> delegate;

+ (NSString *)registerCellWithTableView:(UITableView *)tableView;

@end

@protocol XMPerosnalInfoBaseCellDelegate <NSObject>
//头像Button点击事件
//长按复制 粘贴板 功能
//点击拨打电话, 发送邮件
//
@end

//头像Cell
@interface XMPerosnalInfoProtraitCell : XMPerosnalInfoBaseCell

@end

//图片按钮Cell
@interface XMPerosnalInfoFunctionButtonCell : XMPerosnalInfoBaseCell

@end

//普通按钮Cell
@interface XMPerosnalInfoNormalButtonCell : XMPerosnalInfoBaseCell

@end

//电话, 邮箱Cell
@interface XMPerosnalInfoPhoneCell : XMPerosnalInfoBaseCell

@end
