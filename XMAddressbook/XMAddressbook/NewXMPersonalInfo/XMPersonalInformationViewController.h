#import <UIKit/UIKit.h>
#import "XMPersonalInfoViewModel.h"

@interface XMPersonalInformationViewController : UIViewController <XMPerosnalInfoBaseCellDelegate>

@property (nonatomic, strong, readonly) XMPersonalInfoViewModel *viewModel;

+ (XMPersonalInformationViewController *)personVCWithViewModel:(XMPersonalInfoViewModel *)model;

@end
