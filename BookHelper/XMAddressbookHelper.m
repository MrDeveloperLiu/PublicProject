#import "XMAddressbookHelper.h"


@implementation XMABRecordModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.rid) forKey:NSStringFromSelector(@selector(rid))];
    [aCoder encodeObject:self.name forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
    [aCoder encodeObject:self.pinyin forKey:NSStringFromSelector(@selector(pinyin))];
    [aCoder encodeObject:self.mobilephone forKey:NSStringFromSelector(@selector(mobilephone))];
    [aCoder encodeObject:self.emails forKey:NSStringFromSelector(@selector(emails))];
    [aCoder encodeObject:self.mobiles forKey:NSStringFromSelector(@selector(mobiles))];
    [aCoder encodeObject:self.icon forKey:NSStringFromSelector(@selector(icon))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.rid = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(rid))] intValue];
        self.name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
        self.email = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
        self.mobilephone = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mobilephone))];
        self.pinyin = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(pinyin))];
        self.emails = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(emails))];
        self.mobiles = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mobiles))];
        self.icon = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(icon))];
    }
    return self;
}

- (instancetype)initWithRid:(ABRecordID)rid Icon:(UIImage *)icon name:(NSString *)name pinyin:(NSString *)pinyin mobilephone:(NSString *)mobilephone email:(NSString *)email mobiles:(NSArray *)mobiles emails:(NSArray *)emails{
    if (self = [super init]) {
        self.rid = rid;
        self.icon = icon;
        self.name = name;
        self.pinyin = pinyin;
        self.mobilephone = mobilephone;
        self.email = email;
        self.mobiles = mobiles;
        self.emails = emails;
    }
    return self;
}

+ (XMABRecordModel *)modelWithRid:(ABRecordID)rid Icon:(UIImage *)icon name:(NSString *)name pinyin:(NSString *)pinyin mobilephone:(NSString *)mobilephone email:(NSString *)email mobiles:(NSArray *)mobiles emails:(NSArray *)emails{
    return [[self alloc] initWithRid:rid Icon:icon name:name pinyin:pinyin mobilephone:mobilephone email:email mobiles:mobiles emails:emails];
}

@end

NSString *const XMAddressbookBeginLoad = @"XMAddressbookBeginLoad";
NSString *const XMAddressbookFinishLoad = @"XMAddressbookFinishLoad";

#define KEY_Specical @"#"
#define CFSafeRelease(obj) if (obj != NULL) { CFRelease(obj); }

#define ABLogErr(ret, error) \
if (error != NULL && !ret) {\
id reason = (__bridge id)error;\
NSLog(@"%s FAILD! <%@>", __func__, reason);\
}\

static ABAddressBookRef Singleton_addressbookRef = nil;

@implementation XMAddressbookHelper

+ (void)requestAddressbookAuthor:(void (^)(BOOL, CFErrorRef))author{
    
    ABAddressBookRef abRef = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(abRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSLog(@"用户允许通讯录");
        }else{
            NSLog(@"用户禁止通讯录");
        }
        if(author) author(granted, error);
    });
    CFSafeRelease(abRef);
}

+ (ABAddressBookRef)createAddressbook{ //not re create this
    if (Singleton_addressbookRef != NULL) { return Singleton_addressbookRef; }
    
    CFErrorRef error = NULL;
    ABAddressBookRef abRef = ABAddressBookCreateWithOptions(NULL, &error);
    if (error != NULL) {
        CFStringRef reason = CFErrorCopyFailureReason(error);
        
        ABLogErr(NO, error);
        CFSafeRelease(reason);
    }
    if ([self haveAuthor]) {
        Singleton_addressbookRef = abRef;
    } else {
        CFSafeRelease(abRef);
    }
    return abRef;
}

+ (BOOL)haveAuthor{
    return (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized );
}

+ (ABAddressBookRef)addressbook{
    return Singleton_addressbookRef;
}

+ (NSArray<XMABRecordModel *> *)loadAddressbookToModel:(ABPersonSortOrdering)order{
    return [self loadAddressbookToModel:order notification:YES];
}

+ (NSArray<XMABRecordModel *> *)loadAddressbookToModel:(ABPersonSortOrdering)order notification:(BOOL)notification{
    if (![self haveAuthor]) { return nil; }
    NSMutableArray *temp = [NSMutableArray array];
    
    //async notifi UI
    if (notification) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:XMAddressbookBeginLoad object:nil];
        });
    }
    
    [self personsArrayRefOfAddressbook:[self addressbook] sort:order compltion:^(CFArrayRef personsRef) {
    
        [self enumerateObjects:personsRef usingBlock:^(ABRecordRef personRef, CFIndex idx, BOOL *stop) {
           //mobile
           NSArray *mobiles = [self mulitStringWithABRecordRef:personRef property:kABPersonPhoneProperty];
           //email
           NSArray *emails = [self mulitStringWithABRecordRef:personRef property:kABPersonEmailProperty];
           //name
           NSString *name = [self nameStringWithABRecordRef:personRef];
           if (!name) { name = mobiles.firstObject; }
           
            if (mobiles.count) {
                
                [mobiles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    XMABRecordModel *model = [XMABRecordModel modelWithRid:ABRecordGetRecordID(personRef)
                                                                      Icon:[self iconWithABRecordRef:personRef]
                                                                      name:name
                                                                    pinyin:[self getPinYinWithName:name]
                                                               mobilephone:obj
                                                                     email:emails.firstObject
                                                                   mobiles:mobiles
                                                                    emails:emails];
                    [temp addObject:model];
                }];
                
            }else{//there is no phone's label
                
                XMABRecordModel *model = [XMABRecordModel modelWithRid:ABRecordGetRecordID(personRef)
                                                                  Icon:[self iconWithABRecordRef:personRef]
                                                                  name:name
                                                                pinyin:[self getPinYinWithName:name]
                                                           mobilephone:nil
                                                                 email:emails.firstObject
                                                               mobiles:mobiles
                                                                emails:emails];
                [temp addObject:model];
            }
            
          
        }];
    
    }];
    
    //async notifi UI
    if (notification) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:XMAddressbookFinishLoad object:nil];
        });
    }
   
    return temp;
}


+ (void)personsArrayRefOfAddressbook:(ABAddressBookRef)ref sort:(ABPersonSortOrdering)sort
                           compltion:(void (^)(CFArrayRef personsRef) )compltion{
    if (!compltion) { return; }
    
    ABRecordRef sourceRef = ABAddressBookCopyDefaultSource([self addressbook]);
    CFArrayRef personsRef = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering([self addressbook],
                                                                                      sourceRef,
                                                                                      sort);
    CFSafeRelease(sourceRef);
    compltion(personsRef);
    CFSafeRelease(personsRef);
}

+ (void)enumerateObjects:(CFArrayRef)arrayRef usingBlock:(void (^) (ABRecordRef personRef, CFIndex idx, BOOL *stop) )block{
    if (!block || arrayRef == NULL) { return; }
    
    @autoreleasepool {
        BOOL stop = NO;
        for (CFIndex i = 0; i < CFArrayGetCount(arrayRef); i++) {
            if (stop) { break; }
            ABRecordRef object = CFArrayGetValueAtIndex(arrayRef, i);
            block(object, i, &stop);
        }
    }
}

+ (UIImage *)iconWithABRecordRef:(ABRecordRef)ref{
    if (![self haveAuthor]) { return nil; }
    
    CFDataRef dataRef = ABPersonCopyImageData(ref);
    if (!dataRef) { return nil; }
    
    NSData *data = (__bridge NSData *)dataRef;
    UIImage *image = [UIImage imageWithData:data];
    CFSafeRelease(dataRef);
    return image;
}

+ (NSString *)nameStringWithABRecordRef:(ABRecordRef)ref{
    CFStringRef nameRef = ABRecordCopyCompositeName(ref);
    NSString *name = (__bridge NSString *)nameRef;
    if (!name.length) {
        CFSafeRelease(nameRef);
        return nil;
    };
    CFSafeRelease(nameRef);
    return name;
}

//use for mulit val's
+ (NSArray <NSString *> *)mulitStringWithABRecordRef:(ABRecordRef)ref property:(ABPropertyID)property{
    if (![self haveAuthor]) { return nil; }
    
    NSMutableArray *temp = [NSMutableArray array];
    
    ABMultiValueRef multi = ABRecordCopyValue(ref, property);
    CFArrayRef arrayRef = ABMultiValueCopyArrayOfAllValues(multi);
    CFSafeRelease(multi);
    if (!arrayRef) { return nil; }
    
    for (CFIndex i = 0; i < CFArrayGetCount(arrayRef); i++) {
        
        CFStringRef string = CFArrayGetValueAtIndex(arrayRef, i);
        NSString *value = (__bridge NSString *)string;
        if (value.length || ![value isEqual:[NSNull null]]) {
            [temp addObject:value];
        }
        
    }
    
    CFSafeRelease(arrayRef);
    if (!temp.count) { return nil; }
    return temp;
}

//use for string val's
+ (NSString *)stringWithABRecordRef:(ABRecordRef)ref property:(ABPropertyID)property{
    if (![self haveAuthor]) { return nil; }
    
    CFStringRef temp = ABRecordCopyValue(ref, property);
    NSString *retVal = (__bridge NSString *)temp;
    
    if (!retVal.length || [retVal isEqual:[NSNull null]]) {
        CFSafeRelease(temp);
        return nil;
    }
    CFSafeRelease(temp);
    return retVal;
}

+ (ABRecordRef)personRefGetWithID:(ABRecordID)rid{
    if (![self haveAuthor]) { return 0; }
    
    return ABAddressBookGetPersonWithRecordID([self addressbook], rid);
}

+ (NSString *)getPinYinWithName:(NSString *)name{
    if (!name.length) { return name; }
    
    NSMutableString *result = [NSMutableString stringWithString:name];
    CFStringTransform((CFMutableStringRef)result, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)result, NULL, kCFStringTransformStripDiacritics, NO);
    return [result stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (BOOL)deletePersonWithID:(ABRecordID)rid{
    if (![self haveAuthor]) { return NO; }
    ABRecordRef personRef = [self personRefGetWithID:rid];
    if (personRef == NULL) { return NO; }
    CFErrorRef error = NULL;
    bool retVal = ABAddressBookRemoveRecord([self addressbook], personRef, &error);
    retVal = [self addressbookSaveChangeWithError:&error];
    
    ABLogErr(retVal, error);
    return retVal;
}

+ (BOOL)addressbookSaveChangeWithError:(CFErrorRef *)error{
    bool retVal = NO;
    if (ABAddressBookHasUnsavedChanges([self addressbook])) {
        retVal = ABAddressBookSave([self addressbook], error);
    }
    return retVal;
}

+ (ABRecordRef)createPerson{
    if (![self haveAuthor]) { return 0; }
    
    return ABPersonCreate();
}

+ (void)releasePersonRef:(ABRecordRef)personRef{
    CFSafeRelease(personRef);
}

+ (BOOL)personRef:(ABRecordRef)personRef MulitValuelabel:(CFStringRef)label
         property:(ABPropertyID)property string:(NSString *)string{
    if (!string.length || ![self haveAuthor]) { return NO; }
    
    ABMultiValueRef temp = ABMultiValueCreateMutable(kABStringPropertyType);
    CFStringRef tempValue = (__bridge CFStringRef)(string);
    ABMultiValueAddValueAndLabel(temp, tempValue, label, NULL);
    bool retVal = ABRecordSetValue(personRef, property, temp, NULL);
    CFRelease(temp);
    
    return retVal;
}

+ (BOOL)personRef:(ABRecordRef)personRef property:(ABPropertyID)property
          strings:(NSArray *)strings labels:(NSArray *)labels{
    if (!strings.count || !(strings.count == labels.count) || ![self haveAuthor]) { return NO; }
    
    ABMultiValueRef temp = ABMultiValueCreateMutable(kABStringPropertyType);
    [strings enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *label = [labels objectAtIndex:idx];
        CFStringRef tempValue = (__bridge CFStringRef)(obj);
        CFStringRef tempLabel = (__bridge CFStringRef)(label);
        ABMultiValueAddValueAndLabel(temp, tempValue, tempLabel, NULL);
        
    }];
    bool retVal = ABRecordSetValue(personRef, property, temp, NULL);
    CFRelease(temp);
    
    return retVal;
}

+ (BOOL)personRef:(ABRecordRef)personRef property:(ABPropertyID)property string:(NSString *)string{
    if (!string.length || ![self haveAuthor]) { return NO; }
    
    CFStringRef tempValue = (__bridge CFStringRef)(string);
    bool retVal = ABRecordSetValue(personRef, property, tempValue, NULL);
    
    return retVal;
}

+ (BOOL)personRef:(ABRecordRef)personRef setImage:(UIImage *)image{
    if (![self haveAuthor]) { return NO; }
    
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) { return NO; }
    CFErrorRef error = NULL;
    CFDataRef dataRef = (__bridge CFDataRef)data;
    bool retVal = ABPersonSetImageData(personRef, dataRef, &error);
    
    ABLogErr(retVal, error);
    return retVal;
}

+ (BOOL)saveIntoAddressbook:(ABRecordRef)personRef{
    if (![self haveAuthor]) { return 0; }
    
    CFErrorRef error = NULL;
    
    bool retVal = ABAddressBookAddRecord([self addressbook], personRef, &error);
    retVal = [self addressbookSaveChangeWithError:&error];
    
    CFSafeRelease(personRef);
    ABLogErr(retVal, error);
    return retVal;
}

+ (XMABRecordModel *)quaryPersonFromLocalWithPhone:(NSString *)phone{
    if (![self haveAuthor]) { return nil; }
    
    __block XMABRecordModel *retVal = nil;
    
    [self personsArrayRefOfAddressbook:[self addressbook] sort:kABPersonSortByLastName compltion:^(CFArrayRef personsRef) {
        
        [self enumerateObjects:personsRef usingBlock:^(ABRecordRef personRef, CFIndex idx, BOOL *stop) {
            //mobile
            NSArray *mobiles = [self mulitStringWithABRecordRef:personRef property:kABPersonPhoneProperty];
            
            for (NSString *mobile in mobiles) {
                if ([mobile isEqualToString:phone]) {
                    
                    //mobile
                    NSArray *mobiles = [self mulitStringWithABRecordRef:personRef property:kABPersonPhoneProperty];
                    //email
                    NSArray *emails = [self mulitStringWithABRecordRef:personRef property:kABPersonEmailProperty];
                    //name
                    NSString *name = [self nameStringWithABRecordRef:personRef];
                    if (!name) { name = mobiles.firstObject; }
                    
                    retVal = [XMABRecordModel modelWithRid:ABRecordGetRecordID(personRef)
                                                      Icon:[self iconWithABRecordRef:personRef]
                                                      name:name
                                                    pinyin:[self getPinYinWithName:name]
                                               mobilephone:mobile
                                                     email:emails.firstObject
                                                   mobiles:mobiles
                                                    emails:emails];
                    *stop = YES;
                }
            }
            
        }];
        
    }];
        
    return retVal;
}

+ (NSArray<XMABRecordModel *> *)searchPersonByKey:(NSString *)key{
    if (![self haveAuthor]) { return nil; }
    
    NSMutableArray *array = (NSMutableArray *)[self loadAddressbookToModel:kABPersonSortByLastName notification:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mobilephone contains [cd] %@ || name contains [cd] %@ || pinyin contains [cd] %@", key, key, key];
    [array filterUsingPredicate:predicate];
    return array;
}

+ (void)registChangeWithCallBack:(ABExternalChangeCallback)callback context:(void *)context{
    if (![self haveAuthor]) { return ; }
    
    ABAddressBookRegisterExternalChangeCallback([self addressbook], callback, context);
}

+ (void)unRegistChangeWithCallBack:(ABExternalChangeCallback)callback context:(void *)context{
    if (![self haveAuthor]) { return ; }
    
    ABAddressBookUnregisterExternalChangeCallback([self addressbook], callback, context);
}

+ (UINavigationController *)addNewPersonViewControllerWithPerson:(ABRecordRef)personRef delegate:(id<ABNewPersonViewControllerDelegate>)delegate{
    if (![self haveAuthor]) { return nil; }
    
    ABNewPersonViewController *newVC = [[ABNewPersonViewController alloc] init];
    newVC.newPersonViewDelegate = delegate;
    newVC.displayedPerson = personRef;
    
    UINavigationController *contoller = [[UINavigationController alloc] initWithRootViewController:newVC];
    return contoller;
}

+ (NSDictionary *)transferDictWithArray:(NSArray *)array{
    if (!array.count) { return nil; }
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
    [array enumerateObjectsUsingBlock:^(XMABRecordModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self matches %@", @"^[A-Z]$"];
        NSString *upper = [[obj.pinyin substringToIndex:1] uppercaseString];
        BOOL is = [predicate evaluateWithObject:upper];
        if (is) {
            
            NSMutableArray *array = temp[upper];
            if (!array) { temp[upper] = [NSMutableArray arrayWithObject:obj]; }
            [array addObject:obj];
            
        }else{
            
            NSMutableArray *array = temp[KEY_Specical];
            if (!array) { temp[KEY_Specical] = [NSMutableArray arrayWithObject:obj]; }
            [array addObject:obj];
            
        }
        
    }];
    
    return temp;
}

+ (NSArray *)keyArraySort:(NSDictionary *)dict{
    NSMutableArray *retVal = dict.allKeys.mutableCopy;
    if (retVal.count > 1) {
        [retVal sortUsingSelector:@selector(compare:)];
        id obj = retVal.firstObject;
        if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:KEY_Specical]) {
            [retVal removeObject:obj];
            [retVal addObject:obj];
        }
    }
    return retVal;
}
@end





