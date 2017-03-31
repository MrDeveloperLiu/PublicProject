#import "XMPersonalInfoViewModel.h"
#import "XMPersonalInformationViewController.h"

@interface XMPersonalInfoViewModel()
@property (nonatomic, assign, readwrite) BOOL havePhone;
@property (nonatomic, assign, readwrite) BOOL haveEmail;
@property (nonatomic, assign, readwrite) BOOL haveAuthor;
@property (nonatomic, assign, readwrite) BOOL inAddressbook;
@property (nonatomic, assign, readwrite) BOOL inCommon;

@end
@implementation XMPersonalInfoViewModel

- (BOOL)haveEmail{
    return YES;
}
- (BOOL)haveAuthor{
    return YES;
}
- (BOOL)inAddressbook{
    return NO;
}
- (BOOL)inCommon{
    return YES;
}
- (BOOL)havePhone{
    return YES;
}
@end

#define kIdentifierFromClass(cls) NSStringFromClass([cls class])

@interface XMPersonalInfoShowSource()
@property (nonatomic, weak) XMPersonalInformationViewController *vc;
@end

@implementation XMPersonalInfoShowSource

- (instancetype)initWithViewController:(XMPersonalInformationViewController <XMPerosnalInfoBaseCellDelegate> *)vc{
    if (self = [super init]) {
        _vc = vc;
    }
    return self;
}

+ (NSInteger)numberOfType:(PersonalType)type enterprise:(NSInteger (^)())enterprise
           enterpriseSelf:(NSInteger (^)())enterpriseSelf phone:(NSInteger (^)())phone{
    
    NSParameterAssert((enterprise && enterpriseSelf && phone));
    
    if (type == PersonalTypeEnterprise) {
        return enterprise();
    }else if (type == PersonalTypeEnterPriseSelf) {
        return enterpriseSelf();
    }else if (type == PersonalTypePhone) {
        return phone();
    }
    
    return 0;
}

+ (UITableViewCell *)cellOfType:(PersonalType)type tableView:(UITableView *)tableView
                     enterprise:(UITableViewCell * (^)())enterprise
                 enterpriseSelf:(UITableViewCell * (^)())enterpriseSelf
                          phone:(UITableViewCell * (^)())phone{
    
    NSParameterAssert((enterprise && enterpriseSelf && phone));
    
    if (type == PersonalTypeEnterprise) {
        return enterprise();
    }else if (type == PersonalTypeEnterPriseSelf) {
        return enterpriseSelf();
    }else if (type == PersonalTypePhone) {
        return phone();
    }
    
    NSAssert(nil, @"+ [cellOfType:tableView:enterprise:enterpriseSelf:phone:] cell can not be nil [type : %lu]", type);
    return nil;
}

- (void)registerTableViewCellsInTableView:(UITableView *)tableView{
    //protrait //normal btn //image btn //phone
    NSArray *class = @[[XMPerosnalInfoProtraitCell class], [XMPerosnalInfoPhoneCell class], [XMPerosnalInfoFunctionButtonCell class], [XMPerosnalInfoNormalButtonCell class], [UITableViewCell class]];
    for (Class cls in class) [tableView registerClass:cls forCellReuseIdentifier:NSStringFromClass(cls)];
}

//data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [[self class] numberOfType:self.vc.viewModel.type enterprise:^NSInteger{
        //For Enterprise
        
        return (self.vc.viewModel.haveAuthor) ? 3 : 1;
    } enterpriseSelf:^NSInteger{
        //For Enterprise self
        
        return 2;
    } phone:^NSInteger{
        //For Phone
        
        return 2;
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self class] numberOfType:self.vc.viewModel.type enterprise:^NSInteger{
        //For Enterprise
        if (0 == section) {
            if (!self.vc.viewModel.haveAuthor) {
                return (self.vc.viewModel.haveEmail) ? 2 : 1;
            }else if (self.vc.viewModel.haveEmail){
                return 3;
            } else {
                return 2;
            }
        }else if (1 == section){
            return 4;
        }else if (2 == section){
            return (self.vc.viewModel.inAddressbook) ? 1 : 2;
        }
        
        return 0;
    } enterpriseSelf:^NSInteger{
        //For Enterprise self
        if (0 == section) {
            return self.vc.viewModel.haveEmail ? 3 : 2;
        }else if (1 == section){
            return 2;
        }
        
        return 0;
    } phone:^NSInteger{
        //For Phone
        if (0 == section) {
            NSInteger retVal = 1;//at least there has name
            if (self.vc.viewModel.haveEmail) retVal += 1;
            if (self.vc.viewModel.havePhone) retVal += 1;
            return retVal;
        }else if (1 == section){
            return 2;
        }

        return 0;
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *indentifer = kIdentifierFromClass(XMPerosnalInfoProtraitCell);
    
    
    XMPerosnalInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifer];
    return cell;
}

//delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath.row && !indexPath.section) return kPixel2(676);
    return kPixel2(160);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

@end
