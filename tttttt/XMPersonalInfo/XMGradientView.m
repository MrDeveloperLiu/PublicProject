#import "XMGradientView.h"

@implementation XMGradientView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat components[] = {
        self.from.red, self.from.green, self.from.blue, self.from.alpha,
        self.to.red, self.to.green, self.to.blue, self.to.alpha
    };
    
    //from bottom to top
    CGPoint start = self.fromPoint;
    CGPoint end = self.toPoint;
    
    if (CGPointEqualToPoint(CGPointZero, start)) {
        start = (CGPoint){0, self.bounds.size.height};
    }
    
    if (CGPointEqualToPoint(CGPointZero, end)) {
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
