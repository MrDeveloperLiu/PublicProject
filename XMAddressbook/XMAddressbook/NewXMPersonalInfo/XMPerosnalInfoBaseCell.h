#import <UIKit/UIKit.h>
#import "XMResizeableButton.h"

typedef NS_ENUM(NSUInteger, PersonalCellType) {
    
    PersonalCellTypeInitial = -1,
    
    PersonalFunctionTypeInit = 0,
    PersonalFunctionTypeMessage = 1,
    PersonalFunctionTypeNetPhone,
    PersonalFunctionTypeVOIP,
    PersonalFunctionTypeFreeSMS,
    
    PersonalNormalTypeInit = 10,
    PersonalNormalTypeAddressbook = 11,
    PersonalNormalTypeCommon,
    
    PersonalPhoneTypeInit = 20,
    PersonalPhoneTypePhone = 21,
    PersonalPhoneTypeEmail,
    
    PersonalPhoneTypePhoneName = 30,
    
    PersonalPhoneTypeProtrait = 40
};

@protocol XMPerosnalInfoBaseCellDelegate;
@class XMPersonalInfoViewModel;
@interface XMPerosnalInfoBaseCell : UITableViewCell

@property (nonatomic, weak) id<XMPerosnalInfoBaseCellDelegate> delegate;
@property (nonatomic, assign) XMPersonalInfoViewModel *model;
@property (nonatomic, assign) PersonalCellType type;

+ (NSString *)registerCellWithTableView:(UITableView *)tableView;

@end

//use for subclass hooks
@interface XMPerosnalInfoBaseCell (SubClassHooks)
- (void)setupViews;
@end

//Protrait Cell
@interface XMPerosnalInfoProtraitCell : XMPerosnalInfoBaseCell
- (CGFloat)height;
@end

//FunctionButton Cell
@interface XMPerosnalInfoFunctionButtonCell : XMPerosnalInfoBaseCell

@end

//NormalButton Cell
@interface XMPerosnalInfoNormalButtonCell : XMPerosnalInfoBaseCell

@end


//Phone Cell
@interface XMPerosnalInfoPhoneCell : XMPerosnalInfoBaseCell
- (void)setTypeTitle:(NSString *)title;
- (void)setInfoTitle:(NSString *)title;
- (void)setActionImage:(UIImage *)image;
@end

//PhoneName Cell
@interface XMPerosnalInfoPhoneNameCell : XMPerosnalInfoBaseCell

@end

@protocol XMPerosnalInfoBaseCellDelegate <NSObject>

- (void)protraitCell:(XMPerosnalInfoProtraitCell *)cell clickAtProtrait:(UIButton *)btn;

- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell clickAtInfoBtn:(UIButton *)btn;
- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell clickAtActionBtn:(UIButton *)btn;
- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell copyAtInfoBtn:(UIButton *)btn;

- (void)functionButtonCell:(XMPerosnalInfoFunctionButtonCell *)cell clickAtBtn:(UIButton *)btn;

- (void)normalButtonCell:(XMPerosnalInfoNormalButtonCell *)cell clickAtBtn:(UIButton *)btn;
@end
