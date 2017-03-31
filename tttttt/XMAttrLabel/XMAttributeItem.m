#import "XMAttributeItem.h"

CGFloat XMAttributeMargin = 2.0f;

CGFloat XMAttributeItemAscentCallback(void * ref){
    
    XMAttributeItem *item = (__bridge XMAttributeItem *)ref;
    
    return item.fontAscent;
}

CGFloat XMAttributeItemDescentCallback(void * ref){
    
    XMAttributeItem *item = (__bridge XMAttributeItem *)ref;
    
    return item.fontDescent;
}

CGFloat XMAttributeItemWidthCallback(void * ref){
    
    XMAttributeItem *item = (__bridge XMAttributeItem *)ref;
    if (item.type == XMAttachmentItemTypeImage) {
        return item.size.width + XMAttributeMargin * 2;
    }else if (item.type == XMAttachmentItemTypeUIView){
        return item.size.width + XMAttributeMargin;
    }
    return item.size.width;
}



@implementation XMAttributeItem

- (instancetype)init{
    if (self = [super init]) {
        _autoSize = YES;
        _linkUnderline = kCTUnderlineStyleSingle;
    }
    return self;
}

@end

#define kPatternLinks "((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)"

@implementation XMAutoLinkDetect

+ (NSArray <XMAttributeItem *> *)detectLink:(NSString *)string{
    NSMutableArray *retVal = nil;
    if (string.length){
        
        retVal = [NSMutableArray array];
        NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@kPatternLinks
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
        [urlRegex enumerateMatchesInString:string
                                   options:0
                                     range:NSMakeRange(0, string.length)
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    NSRange range = result.range;
                                    NSString *text = [string substringWithRange:range];
                                    XMAttributeItem *item = [[XMAttributeItem alloc] init];
                                    item.type = XMAttachmentItemTypeLink;
                                    item.content = text;
                                    item.linkRange = range;
                                    [retVal addObject:item];
                                }];
    }
    return retVal;
}

@end
