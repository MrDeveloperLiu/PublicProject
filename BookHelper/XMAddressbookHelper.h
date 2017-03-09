#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface XMABRecordModel : NSObject<NSCoding>

@property (nonatomic, assign) ABRecordID rid;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic, strong) NSString *mobilephone;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSArray *mobiles;
@property (nonatomic, strong) NSArray *emails;

+ (XMABRecordModel *)modelWithRid:(ABRecordID)rid Icon:(UIImage *)icon
                              name:(NSString *)name
                            pinyin:(NSString *)pinyin
                       mobilephone:(NSString *)mobilephone
                             email:(NSString *)email
                           mobiles:(NSArray *)mobiles
                            emails:(NSArray *)emails;
@end

FOUNDATION_EXTERN NSString *const XMAddressbookBeginLoad;
FOUNDATION_EXTERN NSString *const XMAddressbookFinishLoad;

@interface XMAddressbookHelper : NSObject

//request author
+ (void)requestAddressbookAuthor:(void(^)(BOOL grand, CFErrorRef error))author;
//instance
+ (ABAddressBookRef)createAddressbook;
//access author
+ (BOOL)haveAuthor;
//load the Addressbook from iPhone OS system
+ (NSArray <XMABRecordModel *> *)loadAddressbookToModel:(ABPersonSortOrdering)order;

//use for replace " " wih "" and zn_Ch -> latin
+ (NSString *)getPinYinWithName:(NSString *)name;
//according ABRecordID access ABRecordRef
+ (ABRecordRef)personRefGetWithID:(ABRecordID)rid;
//use for mulit val's
+ (NSArray <NSString *> *)mulitStringWithABRecordRef:(ABRecordRef)ref property:(ABPropertyID)property;
//use for string val's
+ (NSString *)stringWithABRecordRef:(ABRecordRef)ref property:(ABPropertyID)property;
//user image data
+ (UIImage *)iconWithABRecordRef:(ABRecordRef)ref;
//user name
+ (NSString *)nameStringWithABRecordRef:(ABRecordRef)ref;
//delete contact with ABRecordID
+ (BOOL)deletePersonWithID:(ABRecordID)rid;

//if you call this you must call '+ releasePersonRef:(ABRecordRef)personRef' at last Unless you call '+saveIntoAddressbook:(ABRecordRef)personRef'
+ (ABRecordRef)createPerson;
+ (void)releasePersonRef:(ABRecordRef)personRef;

//add a string as mulit label
+ (BOOL)personRef:(ABRecordRef)personRef MulitValuelabel:(CFStringRef)label
         property:(ABPropertyID)property string:(NSString *)string;
//add some string as multi
+ (BOOL)personRef:(ABRecordRef)personRef property:(ABPropertyID)property
          strings:(NSArray *)strings labels:(NSArray *)labels;
//add a string for property
+ (BOOL)personRef:(ABRecordRef)personRef property:(ABPropertyID)property string:(NSString *)string;
//set icon for personRef
+ (BOOL)personRef:(ABRecordRef)personRef setImage:(UIImage *)image;
//save into local addressbook and release the 'personRef' if have
+ (BOOL)saveIntoAddressbook:(ABRecordRef)personRef;

//according to phone quary person from local
+ (XMABRecordModel *)quaryPersonFromLocalWithPhone:(NSString *)phone;
//search Person from mobile . name . pinyin with key
+ (NSArray <XMABRecordModel *> *)searchPersonByKey:(NSString *)key;

+ (void)registChangeWithCallBack:(ABExternalChangeCallback)callback context:(void *)context;
+ (void)unRegistChangeWithCallBack:(ABExternalChangeCallback)callback context:(void *)context;

//show ABNewPersonViewController with display personRef
+ (UINavigationController *)addNewPersonViewControllerWithPerson:(ABRecordRef)personRef delegate:(id<ABNewPersonViewControllerDelegate>)delegate;
//transfer array to dictionary
+ (NSDictionary *)transferDictWithArray:(NSArray *)array;
//get dictionary keys [copy]
+ (NSArray *)keyArraySort:(NSDictionary *)dict;
@end
