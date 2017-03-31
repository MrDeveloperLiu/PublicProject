#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSUInteger, XMAttachmentItemType) {
    XMAttachmentItemTypeUnkown = -1,
    XMAttachmentItemTypeImage = 0,
    XMAttachmentItemTypeUIView,
    XMAttachmentItemTypeLink
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

FOUNDATION_EXTERN CGFloat XMAttributeItemAscentCallback(void * ref);
FOUNDATION_EXTERN CGFloat XMAttributeItemDescentCallback(void * ref);
FOUNDATION_EXTERN CGFloat XMAttributeItemWidthCallback(void * ref);
FOUNDATION_EXTERN CGFloat XMAttributeMargin;

@interface XMAttributeItem : NSObject

@property (nonatomic, strong, nullable) id content;

@property (nonatomic, assign) CGFloat fontAscent;
@property (nonatomic, assign) CGFloat fontDescent;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) NSRange linkRange;
//default iskCTUnderlineStyleSingle
@property (nonatomic, assign) CTUnderlineStyle linkUnderline;
//default is YES
@property (nonatomic, assign) BOOL  autoSize;
@property (nonatomic, assign) BOOL  phone;

@property (nonatomic, assign) XMAttachmentItemType type;

@end

@interface XMAutoLinkDetect : NSObject
/**
 * This method provide a founction that can detect links of url
 * @r if no return nil
 * @r if have return a array of <XMAttributeItem *>
 */
+ (NSArray <XMAttributeItem *> *)detectLink:(NSString *)string;
@end

#pragma clang diagnostic pop
