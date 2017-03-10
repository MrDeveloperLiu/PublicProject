#import "XMGradientView.h"

@implementation XMGradientView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint start = self.fromPoint;
    CGPoint end = self.toPoint;
    UIColor *from = self.from;
    UIColor *to = self.to;
    
    CGFloat fr, fg, fb, fa;
    CGFloat tr, tg, tb, ta;
    [from getRed:&fr green:&fg blue:&fb alpha:&fa];
    [to getRed:&tr green:&tg blue:&tb alpha:&ta];
    
    CGFloat components[] = {
        fr, fg, fb, fa,
        tr, tg, tb, ta
    };
    
    
    if (CGPointEqualToPoint(CGPointZero, start) &&
        CGPointEqualToPoint(CGPointZero, end)) {
    //from bottom to top by default    
        start = (CGPoint){0, self.bounds.size.height};
        end = (CGPoint){0, 0};
    }
    
    CGFloat locations[] = {0, 1};
    
    size_t count = sizeof(locations) / sizeof(locations[0]);
    
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();

    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(spaceRef, components, locations, count);
    CGColorSpaceRelease(spaceRef);
    
    CGContextDrawLinearGradient(context, gradientRef, start, end, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradientRef);
    
}


@end
