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

+ (instancetype)new{
    return nil;
}

+ (XMPersonalInfoViewModel *)modelWithData:(id)data{
    XMPersonalInfoViewModel *model = [[self alloc] init];
    model.data = data;
    return model;
}

- (instancetype)init{
    if (self = [super init]) {
        self.type = PersonalTypeInit;
    }
    return self;
}

- (void)setData:(id)data{
    _data = data;
    
    //handle data
    
}

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
    NSArray *class = @[[XMPerosnalInfoProtraitCell class], [XMPerosnalInfoPhoneCell class], [XMPerosnalInfoFunctionButtonCell class], [XMPerosnalInfoNormalButtonCell class], [XMPerosnalInfoPhoneNameCell class]];
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
            return 1;
        }
        
        return 0;
    } phone:^NSInteger{
        //For Phone
        if (0 == section) {
            NSInteger retVal = 1;//at least there has name
            if (self.vc.viewModel.havePhone) retVal += 1;
            if (self.vc.viewModel.haveEmail) retVal += 1;
            return retVal;
        }else if (1 == section){
            return 2;
        }

        return 0;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self class] cellOfType:self.vc.viewModel.type tableView:tableView enterprise:^UITableViewCell *{
        //For Enterprise
        
        NSString *identifer = nil;
        PersonalCellType type = PersonalCellTypeInitial;
        NSInteger section = indexPath.section, row = indexPath.row;
        
        if (0 == section) {
            if (0 == row) {
                type = PersonalPhoneTypeProtrait;
                identifer = kIdentifierFromClass(XMPerosnalInfoProtraitCell);
            }else if (1 == row && self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypeEmail;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (1 == row && !self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (2 == row){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }
        }else if (1 == section){
            if (0 == row) {
                type = PersonalFunctionTypeMessage;
            }else if (1 == row){
                type = PersonalFunctionTypeNetPhone;
            }else if (2 == row){
                type = PersonalFunctionTypeVOIP;
            }else if (3 == row){
                type = PersonalFunctionTypeFreeSMS;
            }
            identifer = kIdentifierFromClass(XMPerosnalInfoFunctionButtonCell);
        }else if (2 == section){
            if (0 == row) {
                type = PersonalNormalTypeCommon;
            }else if (1 == row){
                type = PersonalNormalTypeAddressbook;
            }
            identifer = kIdentifierFromClass(XMPerosnalInfoNormalButtonCell);
        }
        
        XMPerosnalInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        cell.type = type;
        cell.model = self.vc.viewModel;
        cell.delegate = self.vc;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, kPixel3(40), 0, kPixel3(40));
        
        return cell;

    } enterpriseSelf:^UITableViewCell *{
        //For Enterprise self
        NSString *identifer = nil;
        PersonalCellType type = PersonalCellTypeInitial;
        NSInteger section = indexPath.section, row = indexPath.row;

        if (0 == section) {
            if (0 == row) {
                identifer = kIdentifierFromClass(XMPerosnalInfoProtraitCell);
            }else if (1 == row && self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypeEmail;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (1 == row && !self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (2 == row){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }
        }else if (1 == section){
            type = PersonalFunctionTypeFreeSMS;
            identifer = kIdentifierFromClass(XMPerosnalInfoFunctionButtonCell);
        }
        
        XMPerosnalInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        cell.type = type;
        cell.model = self.vc.viewModel;
        cell.delegate = self.vc;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, kPixel3(40), 0, kPixel3(40));

        return cell;
    } phone:^UITableViewCell *{
        //For Phone
        NSString *identifer = nil;
        PersonalCellType type = PersonalCellTypeInitial;
        NSInteger section = indexPath.section, row = indexPath.row;

        if (0 == section) {
            if (0 == row) {
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneNameCell);
            }else if (1 == row && self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypeEmail;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (1 == row && !self.vc.viewModel.haveEmail){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }else if (2 == row){
                type = PersonalPhoneTypePhone;
                identifer = kIdentifierFromClass(XMPerosnalInfoPhoneCell);
            }
        }else if (1 == section){
            if (0 == row) {
                type = PersonalFunctionTypeNetPhone;
            }else if (1 == row){
                type = PersonalFunctionTypeFreeSMS;
            }
            identifer = kIdentifierFromClass(XMPerosnalInfoFunctionButtonCell);
        }
        
        XMPerosnalInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        cell.type = type;
        cell.model = self.vc.viewModel;
        cell.delegate = self.vc;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsMake(0, kPixel3(40), 0, kPixel3(40));

        return cell;
    }];
}

//delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath.row && !indexPath.section){
        if (self.vc.viewModel.type == PersonalTypePhone) {
            return kPixel3(160) + 64;
        }else{
            return self.vc.viewModel.protraitHeight;
        }
    }
    return kPixel3(160);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section) return 0.01;
    return kPixel3(120);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
@end
