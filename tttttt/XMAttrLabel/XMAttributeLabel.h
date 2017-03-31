#import "XMAttributeLabelProtocol.h"
#import "XMAttributeItem.h"

@interface XMAttributeLabel : UIView

@property (nonatomic, assign, readonly) CGFloat fontAscent;
@property (nonatomic, assign, readonly) CGFloat fontDescent;

@property (nonatomic, weak) id<XMAttributeLabelProtocol> delegate;
/**
 *  the text font default is 16.0f
 */
@property (nonatomic, strong) UIFont *font;
/**
 *  the text color default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *textColor;
/**
 *  the link color (32 193 220) rgb
 */
@property (nonatomic, strong) UIColor *linkColor;
/**
 *  the link background color [UIColor lightGrayColor]
 */
@property (nonatomic, strong) UIColor *linkBackgroundColor;
//**!@ There We extending only two feature's
/**
 *  setting the line break mode ;   kCTLineBreakByTruncatingTail by default
 */
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;
/**
 *  setting the line break mode ;   kCTTextAlignmentLeft by default
 */
@property (nonatomic, assign) CTTextAlignment textAlignment;

/**
 * some attribute store the item
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *attributeDict;

/**
 *  the text -> attributedString
 */
@property (nonatomic, copy) NSString *text;
/**
 *  the link color (32 193 220) rgb
 */
@property (nonatomic, copy) NSAttributedString *attributeText;

- (CGSize)intrinsicContentSize;
- (CGSize)sizeThatFits:(CGSize)size;

- (void)appendText:(NSString *)text;
- (void)appendAttributeText:(NSAttributedString *)attributeText;
- (void)appendItem:(XMAttributeItem *)item;

//for emoji remember that if you will auto detect links and also auto detect emoji, you use this before
//or it will cause some problem
- (void)resetEmojiWithItem:(XMAttributeItem *)item;
- (void)resetLinkWithItem:(XMAttributeItem *)item;

@end


FOUNDATION_EXTERN NSString *const XMLinksAttributeName;

FOUNDATION_EXTERN NSString *const XMImagesAttributeName;

FOUNDATION_EXTERN NSString *const XMUIViewsAttributeName;


//Char is 0xfffc
FOUNDATION_EXTERN unichar const XMAttributedReplaceChar;
