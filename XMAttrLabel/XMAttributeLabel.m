#import "XMAttributeLabel.h"

#define XMAttributeLabelSafeRelease(__v) \
if ((__v) != NULL) { CFRelease(__v); __v = NULL; }
#define kColorVal(f) (f) / 255.0

NSString *const XMLinksAttributeName = @"XMLinksAttributeName";
NSString *const XMImagesAttributeName = @"XMLinksAttributeName";
NSString *const XMUIViewsAttributeName = @"XMLinksAttributeName";
unichar const XMAttributedReplaceChar = 0xFFFC;

@interface XMAttributeLabel()

@property (nonatomic, strong) XMAttributeItem *acticeItem;
@property (nonatomic, assign) CGFloat fontAscent;
@property (nonatomic, assign) CGFloat fontDescent;
@property (nonatomic, assign) CGFloat fontHeight;

@property (nonatomic) CTFrameRef frameRef;

@property (nonatomic, strong, readwrite) NSMutableDictionary *attributeDict;

@end

@implementation XMAttributeLabel

- (void)dealloc{
    XMAttributeLabelSafeRelease(_frameRef);
}

- (instancetype)init{
    if (self = [super init]) {
        [self customInitAllIvars];
    }
    return self;
}

- (void)customInitAllIvars{
    // Init the ivars
    self.backgroundColor = [UIColor whiteColor];
    //default display the text is line break tail and the alignment from left
    _lineBreakMode = kCTLineBreakByTruncatingTail;
    _textAlignment = kCTTextAlignmentLeft;
    
    self.font = [UIFont systemFontOfSize:20.0f];
    _textColor = [UIColor blackColor];
    _linkBackgroundColor = [UIColor lightGrayColor];
    _linkColor = [UIColor colorWithRed:kColorVal(32) green:kColorVal(193) blue:kColorVal(220) alpha:1];
}

- (CGSize)intrinsicContentSize{
    return [self sizeThatFits:(CGSize){self.bounds.size.width, CGFLOAT_MAX}];
}

- (CGSize)sizeThatFits:(CGSize)size{
    if (!_attributeText.length) {
        return CGSizeZero;
    }
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributeText);
    CFRange fitRange = CFRangeMake(0, 0);
    CGSize s = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), NULL, size, &fitRange);
    XMAttributeLabelSafeRelease(frameSetterRef);
    if (s.height < _fontHeight * 0.5) {
        return CGSizeMake(ceilf(s.width) + 2.0, ceilf(s.height) + 4.0);
    }else{
        return CGSizeMake(size.width, ceilf(s.height) + 4.0);
    }
}

#pragma mark - Append Rich Text such as.. link, image or UIVIew

- (void)appendItem:(XMAttributeItem *)item{
    if (item.type == XMAttachmentItemTypeUnkown) {
        NSLog(@"Unspport type of Item <%@>", item);
    }else{
        [self appendAttachment:item];
    }
}

- (void)appendText:(NSString *)text{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = (NSRange){0, string.length};
    [self setTheCoreTextFont:self.font range:range text:string];
    [self setTextColor:self.textColor.CGColor range:range text:string];
    [self appendAttributeText:string];
}

- (void)appendAttributeText:(NSAttributedString *)attributeText{
    if (![attributeText isKindOfClass:[NSMutableAttributedString class]]) {
        attributeText = [[NSMutableAttributedString alloc] initWithAttributedString:attributeText];
    }
    [self setGraphStyleOfAttributedString:attributeText];
    NSRange range = (NSRange){0, attributeText.length};
    [self setTheCoreTextFont:self.font range:range text:(NSMutableAttributedString *)attributeText];
    [(NSMutableAttributedString *)_attributeText appendAttributedString:attributeText];
    [self resetTextFrameAndRefreshScreen];
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    if (!self.attributeText.length) return;
    //for ctx
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, rect.size.height);
    CGContextScaleCTM(contextRef, 1.0, - 1.0);
    //text frameRef
    if (_frameRef == NULL) {
        CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributeText);
        CFRange stringRange = CFRangeMake(0, self.attributeText.length);
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathAddRect(pathRef, NULL, rect);
        _frameRef = CTFramesetterCreateFrame(framesetterRef, stringRange, pathRef, NULL);
        XMAttributeLabelSafeRelease(framesetterRef);
        XMAttributeLabelSafeRelease(pathRef);
    }
    
    //for draw attachments with out links
    CFArrayRef ctLines = CTFrameGetLines(_frameRef);
    CFIndex ctLinesCount = CFArrayGetCount(ctLines);
    
    CGPoint lineOrigins[ctLinesCount];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
    
    //draw link
    [self drawLinkBackground:contextRef inRect:rect lines:ctLines lineOrigins:lineOrigins];
    
    for (CFIndex i = 0; i < ctLinesCount; i++) {
        
        //coretext line ref
        CTLineRef eachLine = CFArrayGetValueAtIndex(ctLines, i);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent, lineDescent, lineHeight, lineBottomY;
        CTLineGetTypographicBounds(eachLine, &lineAscent, &lineDescent, NULL);
        lineHeight = lineAscent + lineDescent; //for this if you're not understand @see https://yq.aliyun.com/articles/30654
        lineBottomY = lineOrigin.y - lineDescent;
        
        CFArrayRef ctRuns = CTLineGetGlyphRuns(eachLine);
        CFIndex ctRunsCount = CFArrayGetCount(ctRuns);
        for (CFIndex k = 0; k < ctRunsCount; k++) {
            
            //coretext run ref
            CTRunRef eachRun = CFArrayGetValueAtIndex(ctRuns, k);
            CFDictionaryRef eachRunAttr = CTRunGetAttributes(eachRun);
            CTRunDelegateRef delegate = CFDictionaryGetValue(eachRunAttr, kCTRunDelegateAttributeName);
            if (delegate == NULL) {
                continue;   //if null that's text
            }
            
            XMAttributeItem *item = CTRunDelegateGetRefCon(delegate);
            CGFloat runAscent, runDescent, offsetX;
            CGFloat runWidth = CTRunGetTypographicBounds(eachRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            CFRange runRange = CTRunGetStringRange(eachRun);
            offsetX = CTLineGetOffsetForStringIndex(eachLine, runRange.location, NULL);
            
            ///***there can calculate more details***///
            
            CGFloat height = MIN(item.size.height, lineHeight);
            CGFloat width = runWidth;
            if (item.autoSize) {//at least can't less than it's ascent + descent
                height = lineHeight;
                if (!width) width = item.fontAscent + item.fontDescent;
            }
            
            CGRect finialRect = (CGRect){lineOrigin.x + offsetX + XMAttributeMargin,
                                        lineBottomY,
                                        width - XMAttributeMargin * 2,
                                        height};
            
            if (item.type == XMAttachmentItemTypeImage) {
                finialRect.origin.y = finialRect.origin.y + (lineHeight - height) * 0.5;
                CGContextDrawImage(contextRef, finialRect, [(UIImage *)item.content CGImage]);
            }else if (item.type == XMAttachmentItemTypeUIView){
                [self addSubview:(UIView *)item.content];
                CGRect viewRect = finialRect;
                viewRect.origin.x = viewRect.origin.x - XMAttributeMargin * 0.5;
                viewRect.origin.y = rect.size.height - viewRect.origin.y - viewRect.size.height;
                viewRect.size.width = viewRect.size.width - XMAttributeMargin * 0.5;
                [(UIView *)item.content setFrame:viewRect];
            }
            item.origin = finialRect.origin;
            item.size = finialRect.size;
        }
        
    }
    
    //at last draw the text
    CTFrameDraw(_frameRef, contextRef);
}

- (void)drawLinkBackground:(CGContextRef)context inRect:(CGRect)rect lines:(CFArrayRef)lines lineOrigins:(CGPoint[])lineOrigins{
    if (!self.acticeItem || self.acticeItem.type != XMAttachmentItemTypeLink) return;
    
    [self.linkBackgroundColor setFill];
    CGRect finalRect = CGRectZero;
    
    
    CFIndex count = CFArrayGetCount(lines);
    for (CFIndex i = 0; i < count; i++) {
        
        CTLineRef eachLineRef = CFArrayGetValueAtIndex(lines, i);
        CGPoint lineOrigin = lineOrigins[i];
        
        CFRange stringRange = CTLineGetStringRange(eachLineRef);
        NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
        NSRange interRange = NSIntersectionRange(lineRange, self.acticeItem.linkRange);
        if (!interRange.length) {
            continue;
        }
        
        
        CFArrayRef runs = CTLineGetGlyphRuns(eachLineRef);
        CFIndex runCount = CFArrayGetCount(runs);
        for (CFIndex k = 0; k < runCount; k++) {
            
            CTRunRef eachRunRef = CFArrayGetValueAtIndex(runs, k);
            CFRange runStringRange = CTRunGetStringRange(eachRunRef);
            NSRange runRange = NSMakeRange(runStringRange.location, runStringRange.length);
            NSRange runInterRange = NSIntersectionRange(runRange, self.acticeItem.linkRange);
            if (!runInterRange.length) {
                continue;
            }
            
            CGFloat ascent, descent;
            CGFloat width = CTRunGetTypographicBounds(eachRunRef, CFRangeMake(0, 0), &ascent, &descent, NULL);
            CGFloat height = ascent + descent;
            CGFloat offsetX = CTLineGetOffsetForStringIndex(eachLineRef, runStringRange.location, NULL);
            finalRect = (CGRect){lineOrigin.x + offsetX, lineOrigin.y - descent, width, height};
            finalRect.origin.x = roundf(finalRect.origin.x);
            finalRect.origin.y = roundf(finalRect.origin.y);
            finalRect.size.width = roundf(finalRect.size.width);
            finalRect.size.height = roundf(finalRect.size.height);
            
        }
        
        //draw
        if (!CGRectIsEmpty(finalRect)) {
            CGContextFillRect(context, finalRect);
        }
        
    }
    
}

#pragma mark - The Setter and Getter

- (void)setTextColor:(UIColor *)textColor{
    if (textColor && textColor != _textColor) {
        _textColor = textColor;
        NSRange range = (NSRange){0, _attributeText.length};
        [self setTextColor:textColor.CGColor range:range text:(NSMutableAttributedString *)_attributeText];
        [self resetTextFrameAndRefreshScreen];
    }
}

- (void)setText:(NSString *)text{
    NSMutableAttributedString *string = nil;
    if (text.length) {
         string = [[NSMutableAttributedString alloc] initWithString:text];
    }else{
        string = [[NSMutableAttributedString alloc] init];
    }
    self.attributeText = string;
}

- (NSString *)text{
    return [_attributeText string];
}

- (void)setAttributeText:(NSAttributedString *)attributeText{
    //if has images clean it
    [self resetScreenImagesAndUIViews];
    //set the default attribute
    if (![attributeText isKindOfClass:[NSMutableAttributedString class]]) {
        attributeText = [[NSMutableAttributedString alloc] initWithAttributedString:attributeText];
    }
    [self setGraphStyleOfAttributedString:attributeText];
    NSRange range = (NSRange){0, attributeText.length};
    [self setTheCoreTextFont:self.font range:range text:(NSMutableAttributedString *)attributeText];
    _attributeText = attributeText;
    
    [self resetTextFrameAndRefreshScreen];
}

- (void)setFont:(UIFont *)font{
    if (font && font != _font) {
        _font = font;
        NSRange range = (NSRange){0, _attributeText.length};
        [self setTheCoreTextFont:font range:range text:(NSMutableAttributedString *)_attributeText];
        [self enumrateItemAndFixIt:_attributeDict[XMLinksAttributeName]];//for links
        [self enumrateItemAndFixIt:_attributeDict[XMImagesAttributeName]];//for images
        [self enumrateItemAndFixIt:_attributeDict[XMUIViewsAttributeName]];//for views
        //setNeedsDisplay
        [self resetTextFrameAndRefreshScreen];
    }
}

- (NSMutableDictionary *)attributeDict{
    if (!_attributeDict) {
        _attributeDict = [NSMutableDictionary dictionary];
        NSMutableArray *links = [NSMutableArray array];
        NSMutableArray *images = [NSMutableArray array];
        NSMutableArray *views = [NSMutableArray array];
        _attributeDict[XMLinksAttributeName] = links;
        _attributeDict[XMImagesAttributeName] = images;
        _attributeDict[XMUIViewsAttributeName] = views;
    }
    return _attributeDict;
}

#pragma mark - set The Attachment

- (void)enumrateItemAndFixIt:(NSArray *)array{
    for (XMAttributeItem *item in array) {
        item.fontAscent = _fontAscent;
        item.fontDescent = _fontDescent;
    }
}

- (void)resetScreenImagesAndUIViews{
    //for UIView's you need remove it from superview so that is can released and clean the screen
    for (UIView *v in self.subviews) [v removeFromSuperview];
    self.attributeDict = nil;
}

- (void)resetTextFrameAndRefreshScreen{
    XMAttributeLabelSafeRelease(_frameRef);
    if ([NSThread isMainThread]) {
        [self setNeedsDisplay]; //will call the '- drawRect:' always draw code in main thread
    }
}

- (void)appendAttachment:(XMAttributeItem *)attach{
    
    //store them so that you can call delegate method's
    if (attach.type == XMAttachmentItemTypeImage) {
        // append attribute text
        NSMutableAttributedString *replaceAttrString = [self createStringWithAttachment:attach];
        [self appendAttributeText:replaceAttrString];

        [self.attributeDict[XMImagesAttributeName] addObject:attach];
    }else if (attach.type == XMAttachmentItemTypeUIView) {
        // append attribute text
        NSMutableAttributedString *replaceAttrString = [self createStringWithAttachment:attach];
        [self appendAttributeText:replaceAttrString];

        [self.attributeDict[XMUIViewsAttributeName] addObject:attach];
    }else if (attach.type == XMAttachmentItemTypeLink) {
        //change the text color with the link color
        [self setTextLinkStyleWithAttachment:attach];
        [self.attributeDict[XMLinksAttributeName] addObject:attach];
        [self resetTextFrameAndRefreshScreen];
    }
}

- (NSMutableAttributedString *)createStringWithAttachment:(XMAttributeItem *)attach{
    attach.fontAscent = _fontAscent;
    attach.fontDescent = _fontDescent;
    
    NSString *replaceString = [NSString stringWithCharacters:&XMAttributedReplaceChar length:1];
    NSMutableAttributedString *replaceAttrString = [[NSMutableAttributedString alloc] initWithString:replaceString];
    
    CTRunDelegateCallbacks callbacks = {kCTRunDelegateVersion1,
        NULL,
        XMAttributeItemAscentCallback,
        XMAttributeItemDescentCallback,
        XMAttributeItemWidthCallback};
    
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&callbacks, (__bridge void *)attach);
    NSInteger len = replaceAttrString.length;
    [replaceAttrString addAttribute:(__bridge NSString *)kCTRunDelegateAttributeName
                              value:(__bridge id)delegateRef
                              range:(NSRange){0, len}];
    XMAttributeLabelSafeRelease(delegateRef);
    return replaceAttrString;
}

#pragma mark - The settings of text

- (void)setTxetAttr:(NSMutableAttributedString *)text range:(NSRange)range value:(CFTypeRef)value key:(CFStringRef)key{
    [text removeAttribute:(__bridge NSString *)key range:range];
    [text addAttribute:(__bridge NSString *)key value:(__bridge id)value range:range];
}

- (void)setTextLinkStyleWithAttachment:(XMAttributeItem *)attach{
    
    [self setTextColor:_linkColor.CGColor
                 range:attach.linkRange
                  text:(NSMutableAttributedString *)_attributeText];
    [self setTxetAttr:(NSMutableAttributedString *)_attributeText
                range:attach.linkRange
                value:_linkColor.CGColor
                  key:kCTUnderlineColorAttributeName];
    [self setTxetAttr:(NSMutableAttributedString *)_attributeText
                range:attach.linkRange
                value:(__bridge CFTypeRef)(@(attach.linkUnderline))
                  key:kCTUnderlineStyleAttributeName];
}

- (void)setTheCoreTextFont:(UIFont *)font range:(NSRange)range text:(NSMutableAttributedString *)text{
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    _fontAscent = CTFontGetAscent(fontRef);
    _fontDescent = CTFontGetDescent(fontRef);
    _fontHeight = CTFontGetSize(fontRef);
    //reset the whole font of the attributed string
    [self setTxetAttr:text range:range value:fontRef key:kCTFontAttributeName];
    XMAttributeLabelSafeRelease(fontRef);
}

- (void)setTextColor:(CGColorRef)textColor range:(NSRange)range text:(NSMutableAttributedString *)text{
    [self setTxetAttr:text range:range value:textColor key:kCTForegroundColorAttributeName];
}

- (void)setFont:(CTFontRef)fontRef range:(NSRange)range text:(NSMutableAttributedString *)text{
    [self setTxetAttr:text range:range value:fontRef key:kCTFontAttributeName];
}

- (void)setGraphStyleOfAttributedString:(NSAttributedString *)attributeText{
    NSRange textRange = (NSRange){0, attributeText.length};
    CTParagraphStyleRef styleRef = [self graphStyle];
    [self setTxetAttr:(NSMutableAttributedString *)attributeText range:textRange
                value:styleRef key:kCTParagraphStyleAttributeName];
    XMAttributeLabelSafeRelease(styleRef);
}

//when you call this remember that you need release it by using 'CFRelease()'
- (CTParagraphStyleRef)graphStyle{
    CTTextAlignment alignment = _textAlignment;
    CTLineBreakMode linebreak = _lineBreakMode;
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(linebreak), &linebreak},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
    };
    size_t settingCount = sizeof(settings) / sizeof(settings[0]);
    CTParagraphStyleRef styleRef = CTParagraphStyleCreate(settings, settingCount);
    return styleRef;
}

#pragma mark - for touch event

- (CGAffineTransform)transformForCoreText{
    CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.bounds.size.height);
    return CGAffineTransformScale(t, 1.0f, - 1.0f);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touches.anyObject locationInView:self];
    XMAttributeItem *item = [self itemWithPoint:touchPoint];

    if (item.type == XMAttachmentItemTypeLink){
        self.acticeItem = item;
        [self resetTextFrameAndRefreshScreen];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touches.anyObject locationInView:self];
    XMAttributeItem *item = [self itemWithPoint:touchPoint];
    
    if (self.acticeItem) {
        self.acticeItem = nil;
        [self resetTextFrameAndRefreshScreen];
    }
    
    if (item && [_delegate respondsToSelector:@selector(label:performActionWithItem:)]) {
        [_delegate label:self performActionWithItem:item];
    }
}

- (XMAttributeItem *)itemWithPoint:(CGPoint)touchPoint{
    if (_frameRef == NULL) return nil;
    
    CFArrayRef linesRef = CTFrameGetLines(_frameRef);
    CFIndex count = CFArrayGetCount(linesRef);
    CGPoint lineOrigins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
    CGFloat offsetVertical = 0;
    CGFloat kVMargin = 5;
    
    for (CFIndex i = 0; i < count; i++) {
        
        CTLineRef eachLineRef = CFArrayGetValueAtIndex(linesRef, i);
        CGFloat ascent, descent, leading;
        CGFloat width = CTLineGetTypographicBounds(eachLineRef, &ascent, &descent, &leading);
        CGFloat height = ascent + descent;
        CGPoint linePoint = lineOrigins[i];
        CGRect flipRect = (CGRect){linePoint.x, linePoint.y - descent, width, height};
        CGRect rect = CGRectApplyAffineTransform(flipRect, [self transformForCoreText]);
        rect = CGRectInset(rect, 0, -kVMargin);
        rect = CGRectOffset(rect, 0, offsetVertical);
        
        if (CGRectContainsPoint(rect, touchPoint)) {
            
            CGPoint relativePoint = (CGPoint){touchPoint.x - CGRectGetMinX(rect), touchPoint.y - CGRectGetMinY(rect)};
            CFIndex index = CTLineGetStringIndexForPosition(eachLineRef, relativePoint);
            //for links first
            for (XMAttributeItem *item in _attributeDict[XMLinksAttributeName]) {
                if (item.type == XMAttachmentItemTypeLink && NSLocationInRange(index, item.linkRange)) {
                    return item;
                }
            }
            //for images last
            for (XMAttributeItem *item in _attributeDict[XMImagesAttributeName]) {
                CGRect r = (CGRect){item.origin, item.size};
                r = CGRectApplyAffineTransform(r, [self transformForCoreText]);
                if (item.type == XMAttachmentItemTypeImage && CGRectContainsPoint(r, touchPoint)) {
                    return item;
                }
            }
            //ingored UIView's because its can add Target Action by themselves
        }
        
        
    }
    return nil;
}

@end
