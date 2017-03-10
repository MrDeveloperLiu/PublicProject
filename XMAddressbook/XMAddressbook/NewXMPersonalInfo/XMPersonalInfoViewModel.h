#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMPerosnalInfoBaseCell.h"

typedef NS_ENUM(NSUInteger, PersonalType) {
    PersonalTypeInit = -1,
    PersonalTypeEnterprise = 0,
    PersonalTypeEnterPriseSelf,
    PersonalTypePhone
};

@interface XMPersonalInfoViewModel : NSObject

/**
 *  Personal infor Type 
 *  include myself / enterprise others / addressbook, but default is Init
 */
@property (nonatomic, assign, readwrite) PersonalType type;

/**
 *  Personal Data 
 *  it can be XMData class or XMABRecordModel class ; you need to use '- isKindOfClass' to seperate enterprise
 * and addressbook
 */
@property (nonatomic, strong) id data;


/**
 *  Person is have email
 */
@property (nonatomic, assign, readonly) BOOL haveEmail;
/**
 *  Person is have phone use to addressbook nonull phone's
 */
@property (nonatomic, assign, readonly) BOOL havePhone;
/**
 *  Person is have author
 */
@property (nonatomic, assign, readonly) BOOL haveAuthor;
/**
 *  Person is in addressbook
 */
@property (nonatomic, assign, readonly) BOOL inAddressbook;
/**
 *  Person is in common
 */
@property (nonatomic, assign, readonly) BOOL inCommon;
/**
 *  The Protrait's cell height
 */
@property (nonatomic, assign, readwrite) CGFloat protraitHeight;

/**
 *  Only one kind to create this viewModel
 */
+ (XMPersonalInfoViewModel *)modelWithData:(id)data;


/**
 *  Don't use it
 */
+ (instancetype)new NS_DEPRECATED_IOS(2_0, 2_0);
- (instancetype)init NS_DEPRECATED_IOS(2_0, 2_0);
@end

@class XMPersonalInformationViewController;
@interface XMPersonalInfoShowSource : NSObject<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithViewController:(XMPersonalInformationViewController <XMPerosnalInfoBaseCellDelegate> *)vc;
- (void)registerTableViewCellsInTableView:(UITableView *)tableView;

@end
