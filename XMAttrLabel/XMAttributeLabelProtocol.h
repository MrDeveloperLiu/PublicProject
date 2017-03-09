#import <Foundation/Foundation.h>
@class XMAttributeItem, XMAttributeLabel;

@protocol XMAttributeLabelProtocol <NSObject>

- (void)label:(XMAttributeLabel *)label performActionWithItem:(XMAttributeItem *)item;

@end
