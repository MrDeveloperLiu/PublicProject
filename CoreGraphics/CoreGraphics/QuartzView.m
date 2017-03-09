//
//  QuartzView.m
//  CoreGraphics
//
//  Created by 刘杨 on 16/2/4.
//  Copyright © 2016年 刘杨. All rights reserved.
//

#import "QuartzView.h"
#import "Helper.h"

CGFloat radius(CGFloat r){
    return (M_PI / 180) * r;
}
CGFloat color(int c){
    return c / 255.0;
}
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
@implementation QuartzView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawCommonShapesInRect:(CGRect)rect context:(CGContextRef)context{
    //弧线段
    CGFloat margin = 20;
    CGPoint center = (CGPoint){rect.size.width * 0.5, rect.size.height * 0.5};
    CGFloat r = 60;
    
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextAddArc(context, center.x, center.y, r, radius(0 + margin), radius(180 - margin), 0);
    CGContextStrokePath(context);
    
    CGContextAddArc(context, center.x, center.y, r, radius(180 + margin), radius(360 - margin), 0);
    CGContextStrokePath(context);
    
    //贝塞尔曲线
    CGFloat offset = 30;
    CGPoint p1 = (CGPoint){center.x, center.y - offset};
    CGPoint p2 = (CGPoint){center.x, center.y + offset};
    CGPoint porigin = (CGPoint){center.x - r + margin, center.y};
    CGPoint pdest = (CGPoint){center.x + r - margin, center.y};
    CGContextMoveToPoint(context, porigin.x, porigin.y);
    CGContextAddCurveToPoint(context, p1.x, p1.y, p2.x, p2.y, pdest.x, pdest.y);
    //    CGContextAddQuadCurveToPoint(context, p1.x, p1.y, pdest.x, pdest.y);
    CGContextStrokePath(context);
    
    //椭圆 当 w = h 时, 即为圆形
    CGContextAddEllipseInRect(context, (CGRect){center.x - margin, center.y - margin, 2 * margin, 2 * margin});
    CGContextStrokePath(context);
    
    //虚线段 线类型
    CGFloat length[] = {10.0f, 20.0f, 5.0f};
    size_t count = sizeof(length) / sizeof(length[0]);
    CGContextSetLineDash(context, 0, length, count);
    
    //矩形
    CGContextAddRect(context, (CGRect){center.x - r, center.y - r, 2 * r, 2 * r});
    CGContextStrokePath(context);
}

- (void)drawClipInRect:(CGRect)rect context:(CGContextRef)context{
    //剪裁路径
    CGFloat w = ScreenW, h = ScreenH;
    UIImage *image = [UIImage imageNamed:@"1.png"];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat m = MIN(w, h);
    
//    CGPathAddEllipseInRect(path, NULL, (CGRect){0, 0, m, m});
    CGPathAddArc(path, NULL, w * 0.5, h * 0.5, m * 0.5, 0, radius(180), 0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawImage(context, rect, image.CGImage);
}

- (void)drawColorspaceInRect:(CGRect)rect context:(CGContextRef)context{
    
    /* 创建设备依赖颜色空间
    CGFloat white[] = {};
    CGFloat black[] = {};
    CGFloat range[] = {};
    //L * a * b
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateLab(white, black, range);
    //icc
    CGDataProviderSequentialCallbacks callback;
    
    CGDataProviderRef providerRef = CGDataProviderCreateSequential(NULL, &callback);
    CGColorSpaceRef iccSpaceRef = CGColorSpaceCreateICCBased(0, range, providerRef, NULL);
    CGDataProviderRelease(providerRef);
    
    //rgb
    CGFloat gamma[] = {};
    CGFloat matrix[] = {};
    CGColorSpaceRef rgbSpaceRef = CGColorSpaceCreateCalibratedRGB(white, black, gamma, matrix);
    
    //rgb ray
    CGFloat gGamma = 0;
    CGColorSpaceRef graySpaceRef =  CGColorSpaceCreateCalibratedGray(white, black, gGamma);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGColorSpaceRelease(iccSpaceRef);
    CGColorSpaceRelease(rgbSpaceRef);
    CGColorSpaceRelease(graySpaceRef);
     */
    
    /*创建通用颜色空间
    //kCGColorSpaceGenericGray kCGColorSpaceGenericRGB kCGColorSpaceGenericCMYK
    CGColorSpaceRef spaceRef = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    CGColorSpaceRelease(spaceRef);
     */
    
    /*创建索引颜色空间和模式颜色空间
    unsigned char colorTable[] = {};
    size_t lastIndex = 0;
    CGColorSpaceRef indexSpaceRef = CGColorSpaceCreateIndexed(NULL, lastIndex, colorTable);
    CGColorSpaceRelease(indexSpaceRef);
    
    CGColorSpaceRef patternSpaceRef = CGColorSpaceCreatePattern(NULL);
    CGColorSpaceRelease(patternSpaceRef);
     */
    
    //设置和创建颜色
    CGColorSpaceRef baseRef = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceRef spaceRef = CGColorSpaceCreatePattern(baseRef);
    CGColorSpaceRelease(baseRef);
    
    CGContextSetFillColorSpace(context, spaceRef);
    CGContextSetStrokeColorSpace(context, spaceRef);
    
    CGPatternCallbacks callback = {0, &drawSpaceCallBack, NULL};
    
    
    CGFloat area = 10;
    CGRect r = (CGRect){50, 50, 250, 250};
    CGRect each = (CGRect){0, 0, area, area};
    
    //模式(Pattern)是绘制操作的一个序列，这些绘制操作可以重复地绘制到一个图形上下文
    CGPatternRef patternRef = CGPatternCreate(&each, each, CGAffineTransformIdentity, each.size.width, each.size.height, kCGPatternTilingConstantSpacing, false, &callback);
    
    //三个平铺选项 CGPatternTiling
    //1没有失真(no distortion): 以细微调整模式单元格之间的间距为代价，但通常不超过一个设备像素。
    //2最小的失真的恒定间距：设定单元格之间的间距，以细微调整单元大小为代价，但通常不超过一个设备像素。
    //3恒定间距：设定单元格之间间距，以调整单元格大小为代价，以求尽快的平铺
    
    CGFloat components[] = {1, 0, 0, 1};
    
    CGContextSetStrokePattern(context, patternRef, components);
    CGContextSetFillPattern(context, patternRef, components);
    
    CGContextFillRect(context, r);
    
    CGPatternRelease(patternRef);
    CGColorSpaceRelease(spaceRef);
}

//着色骨架绘制回调
void drawSpaceCallBack(void *info, CGContextRef context){
    CGRect *r = (CGRect *)info;
    CGContextTranslateCTM(context, r -> size.width / 2, r -> size.height / 2);
    CGContextFillRect(context, *r);
}

- (void)drawCTMInRect:(CGRect)rect context:(CGContextRef)context{
    CGFloat w = ScreenW, h = ScreenH;
    CGFloat a = 100;
    CGRect r = (CGRect){w * 0.5 - a, h * 0.5 - a, a * 2, a * 2};
    
//    CGContextTranslateCTM(context, w + a, h - a * 2);
//    CGContextScaleCTM(context, 1.0, - 1.0);
//    CGContextRotateCTM(context, radius(90));
    
    //例如 翻转图片显示
//    CGContextTranslateCTM(context, 0, h);
//    CGContextScaleCTM(context, 1.0, - 1.0);
    
    //why  刚刚好是3倍的关系, so this is the t's  a & d 的值
//    CGAffineTransform t = CGContextGetUserSpaceToDeviceSpaceTransform(context);
    CGContextScaleCTM(context, 1.0, - 1.0);
    r = CGContextConvertRectToUserSpace(context, CGRectMake(ScreenW, ScreenH, ScreenW, ScreenH));
    
    UIImage *image = [UIImage imageNamed:@"1.png"];
    CGContextDrawImage(context, r, image.CGImage);
    
}

- (void)drawShadowInRect:(CGRect)rect context:(CGContextRef)context{
    
    CGFloat components[] = {1, 0, 0, 1};
    CGContextSetFillColor(context, components);
    
    CGFloat dx = rect.size.width * 0.25;
    CGFloat dy = rect.size.height * 0.25;
    CGRect r = CGRectInset(rect, dx, dy);
    CGFloat offset = (r.size.height - r.size.width) * 0.5;
    r = CGRectOffset(r, 0, offset);
    r.size.height = r.size.width;
    
    CGSize off = (CGSize){-10, 20};//阴影的偏移位置
    CGFloat sComponents[] = {0, 0, 0, 0.5};//阴影的颜色
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(spaceRef, sComponents);
    CGColorSpaceRelease(spaceRef);
    
    CGFloat blur = 5;//模糊值
    CGContextSetShadowWithColor(context, off, blur, colorRef);
    CGColorRelease(colorRef);
    
    CGContextFillEllipseInRect(context, r);
}

void functionCallBack(void * __nullable info, const CGFloat *inf, CGFloat *outf){

    static const CGFloat c[] = {1, 1, 0.5, 0};
    size_t range = (size_t)info;
    
    CGFloat v = *inf;
    for (size_t k = 0; k < range - 1; k++){
        CGFloat val =
         *outf++ = c[k] * v;
        printf("\n val %f", val);
        if (k == range - 2) {
            printf("\n ==== \n");
        }
    }
    
    *outf++ = 1;
}

void funtionRadialCallback(void * __nullable info, const CGFloat *inf, CGFloat *outf){
    size_t k, components;
    double frequency[4] = { 55, 220, 110, 0 };
    components = (size_t)info;
    for (k = 0; k < components - 1; k++)
    *outf++ = (1 + sin(*inf * frequency[k])) / 2;
    *outf++ = 1; // alpha
}

- (void)drawShadingInRect:(CGRect)rect context:(CGContextRef)context{

    CGFloat area = 150;
    CGColorSpaceRef spaceRef = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);//CGColorSpaceCreateDeviceRGB();
    CGPoint start = (CGPoint){rect.size.width, 0};
    CGPoint end = (CGPoint){rect.size.width - area, area};
    
    //指向回调所需要的数据的指针
    //回调的输入值的个数。Quartz要求回调携带一个输入值。
    //一个浮点数的数组。Quartz只会提供数组中的一个元素给回调函数。一个转入值的范围是0(渐变的开始点的颜色)到1(渐变的结束点的颜色)。
    //回调提供的输出值的数目。对于每一个输入值，我们的回调必须为每个颜色组件提供一个值，以及一个alpha值来指定透明度。颜色组件值由Quartz提供的颜色空间来解释，并会提供给CGShading创建函数。例如，如果我们使用RGB颜色空间，则我们提供值4作为输出值(R,G,B,A)的数目。
    //一个浮点数的数组，用于指定每个颜色组件的值及alpha值。
    //一个回调数据结构，包含结构体的版本(设置为0)、生成颜色组件值的回调、一个可选的用于释放回调中info参数表示的数据。该回调类似于以下格式：
    
    //from 0 - 1 的渐变
    CGFloat domain[] = {0, 1};
    size_t range = 1 + CGColorSpaceGetNumberOfComponents(spaceRef);
    //rgba 从 颜色 -> 颜色的渐变
    CGFloat rangef[] = {1, 0, 0, 1, 0, 0, 1, 1};
    
    CGFunctionCallbacks callback = {0 , &functionCallBack, NULL};
    CGFunctionRef functionRef = CGFunctionCreate((void *)range, 1, domain, range, rangef, &callback);
    
    //轴向渐变
    CGShadingRef axialShadingRef = CGShadingCreateAxial(spaceRef, start, end, functionRef, false, false);
    
    CGFloat startRadius = 5;
    CGFloat endRadius = 50;
    CGFunctionCallbacks rCallback = {0 , &funtionRadialCallback, NULL};
    CGFunctionRef rFunctionRef = CGFunctionCreate((void *)range, 1, domain, range, rangef, &rCallback);
    //径向渐变
    CGShadingRef radialShadingRef = CGShadingCreateRadial(spaceRef, start, startRadius, end, endRadius, rFunctionRef, false, false);
    
    CGColorSpaceRelease(spaceRef);
    CGFunctionRelease(functionRef);
    CGFunctionRelease(rFunctionRef);
    
    CGContextDrawShading(context, axialShadingRef);
    CGContextDrawShading(context, radialShadingRef);
    
    
    CGShadingRelease(axialShadingRef);
    CGShadingRelease(radialShadingRef);
}

- (void)drawGradientInRect:(CGRect)rect context:(CGContextRef)context{
    
    //CGShadingRef 的子集
    
    CGFloat area = 150;
    CGColorSpaceRef spaceRef = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGPoint start = (CGPoint){rect.size.width, 0};
    CGPoint end = (CGPoint){rect.size.width - area, area};

    CGPoint lstart = (CGPoint){rect.size.width, rect.size.height};
    CGPoint lend = (CGPoint){rect.size.width, 200};
    
    CGFloat locations[] = {0, 1};
    CGFloat components[] = {1, 0, 0, 1, 0, 1, 0, 1};
    CGFloat lcomponents[] = {color(63), color(145), color(240), 1, color(48), color(173), color(229), 1};
    
    size_t count = sizeof(locations) / sizeof(locations[0]);
    
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(spaceRef, lcomponents, locations, count);
    
    CGColorSpaceRelease(spaceRef);
    
    CGFloat startRadius = 5;
    CGFloat endRadius = 50;
    
    //轴向渐变
    CGContextDrawLinearGradient(context, gradientRef, lstart, lend, kCGGradientDrawsBeforeStartLocation);
    
    //径向渐变
    CGContextDrawRadialGradient(context, gradientRef, start, startRadius, end, endRadius,kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(gradientRef);
}

- (void)drawTransquarencyLayerInRect:(CGRect)rect context:(CGContextRef)context{
    
    CGSize offset = (CGSize){- 10, 20};
    CGFloat blur = 10;
    CGContextSetShadow(context, offset, blur);
    
    //开始在透明层中绘制阴影效果
    CGContextBeginTransparencyLayer(context, NULL);
    
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    CGFloat colors[][4] = {{1, 0, 0, 1}, {0, 1, 0, 1}, {0, 0, 1, 1}};
    CGRect rects[] = {{w / 3 + 50, h / 2, w / 4, h / 4},
                      {w / 3 - 50, h / 2 - 100, w / 4, h / 4},
                      {w / 3, h / 2 - 50, w / 4, h / 4}};
    
    //draw
    size_t count = sizeof(rects) / sizeof(rects[0]);
    for (int i = 0; i < count; i++) {
        CGContextSetRGBFillColor(context, colors[i][0], colors[i][1], colors[i][2], colors[i][3]);
        CGContextFillRect(context, rects[i]);
    }
    
    //结束在透明层中绘制阴影
    CGContextEndTransparencyLayer(context);
}

- (void)drawSourceImageInRect:(CGRect)rect context:(CGContextRef)context{
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    UIImage *image = [UIImage imageWithData:data];
    
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, - 1.0);
    
    CGImageRef cImage = image.CGImage;
    size_t w = CGImageGetWidth(cImage);
    size_t h = CGImageGetHeight(cImage);
    size_t c = CGImageGetBitsPerComponent(cImage);
    size_t p = CGImageGetBitsPerPixel(cImage);
    size_t r = CGImageGetBytesPerRow(cImage);
    CGBitmapInfo info = CGImageGetBitmapInfo(cImage);
    CGColorSpaceRef spaceRef = CGImageGetColorSpace(cImage);
    const CGFloat *decode = CGImageGetDecode(cImage);
    
    //方式一: 重绘到bitmap的上下文中, 从中读取位图信息
    CGContextRef ctx = CGBitmapContextCreate(NULL, w, h, c, r, spaceRef, info);
    CGContextDrawImage(ctx, (CGRect){0, 0, w, h}, cImage);
    CGImageRef cImageRef = CGBitmapContextCreateImage(ctx);
//    CGContextDrawImage(context, rect, cImageRef);
    if (cImageRef != NULL) CFRelease(cImageRef);
    CFRelease(ctx);
    
    //方式二: 知道是PNG 直接创建
    //r = (p / c) * w;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, data.bytes, data.length, NULL);
    
    CGImageRef pngImageRef = CGImageCreateWithPNGDataProvider(providerRef, NULL, false, kCGRenderingIntentDefault);
    CFRelease(providerRef);
//    CGContextDrawImage(context, rect, pngImageRef);
    if (pngImageRef != NULL) CFRelease(pngImageRef);

    //方式三: 直接读取提供者
    CGDataProviderRef directProviderRef = CGImageGetDataProvider(cImage);
    //但不知为何 这个不成, 估计是bytes 有问题
    //按理来说 按照RGBA 取色的话 每个像素32字节 每个组件8字节 意思就是 包含了rgba的信息
    CGImageRef imageRef = CGImageCreate(w, h, c, p, r, spaceRef, info, directProviderRef, decode, false, kCGRenderingIntentDefault);
//    CGContextDrawImage(context, rect, imageRef);
    if (imageRef != NULL) CFRelease(imageRef);

    
    //位图遮罩
    CGImageRef maskImageRef = CGImageMaskCreate(w, h, c, p, r, directProviderRef, decode, false);
    CGImageRef cMImageRef = CGImageCreateWithMask(cImage, maskImageRef);

    //按理来说可以呀, 为什么不行 疑问 疑问...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    CGFloat components[] = { 124, 255,  68, 222, 0, 165 };
#pragma clang diagnostic pop
//    CGImageRef maskColorImageRef = CGImageCreateWithMaskingColors(cImage, components);
  
    CGContextDrawImage(context, rect, cMImageRef);
    
//    if (maskColorImageRef != NULL) CFRelease(maskColorImageRef);    
    if (cMImageRef != NULL) CFRelease(cMImageRef);
    if (maskImageRef != NULL) CFRelease(maskImageRef);
    
}

- (void)drawLayerInRect:(CGRect)rect context:(CGContextRef)context{
    //层的概念

    int          i, j,
    num_six_star_rows = 5,
    num_five_star_rows = 4;
    CGFloat      start_x = 5.0,
    start_y = 108.0,
    red_stripe_spacing = 34.0,
    h_spacing = 26.0,
    v_spacing = 22.0;
    CGContextRef myLayerContext1,
    myLayerContext2;
    CGLayerRef   stripeLayer,
    starLayer;
    CGRect       myBoundingBox,
    stripeRect,
    starField;
    // ***** Setting up the primitives *****
    CGPoint point1 = {5, 5}, point2 = {10, 15}, point3 = {10, 15}, point4 = {15, 5};
    CGPoint point5 = {15, 5}, point6 = {2.5, 11}, point7 = {2.5, 11}, point8 = {16.5, 11};
    CGPoint point9 = {16.5, 11}, point10 = {5, 5};
    const CGPoint myStarPoints[] = {point1, point2,
        point3, point4,
        point5, point6,
        point7, point8,
        point9, point10};
    
    stripeRect  = CGRectMake (0, 0, 400, 17); // stripe
    starField  =  CGRectMake (0, 102, 160, 119); // star field
    
    myBoundingBox = CGRectMake (0, 0, rect.size.width, rect.size.height);
    
    // ***** Creating layers and drawing to them *****
    stripeLayer = CGLayerCreateWithContext (context, stripeRect.size, NULL);
    myLayerContext1 = CGLayerGetContext (stripeLayer);
    
    CGContextSetRGBFillColor (myLayerContext1, 1, 0 , 0, 1);
    CGContextFillRect (myLayerContext1, stripeRect);
    
    starLayer = CGLayerCreateWithContext (context, starField.size, NULL);
    myLayerContext2 = CGLayerGetContext (starLayer);
    CGContextSetRGBFillColor (myLayerContext2, 1.0, 1.0, 1.0, 1);
    CGContextAddLines (myLayerContext2, myStarPoints, 10);
    CGContextFillPath (myLayerContext2);
    
    // ***** Drawing to the window graphics context *****
    CGContextSaveGState(context);
    for (i = 0; i < 7;  i++) {
        CGContextDrawLayerAtPoint (context, CGPointZero, stripeLayer);
        CGContextTranslateCTM (context, 0.0, red_stripe_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSetRGBFillColor (context, 0, 0, 0.329, 1.0);
    CGContextFillRect (context, starField);
    
    CGContextSaveGState (context);
    CGContextTranslateCTM (context, start_x, start_y);
    for (j=0; j< num_six_star_rows;  j++) {
        for (i = 0; i < 6; i++) {
            CGContextDrawLayerAtPoint (context,CGPointZero, starLayer);
            CGContextTranslateCTM (context, h_spacing, 0);
        }
        CGContextTranslateCTM (context, (-i*h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, start_x + h_spacing / 2, start_y + v_spacing / 2);
    for (j = 0; j < num_five_star_rows; j++) {
        for (i = 0; i < 5;  i++) {
            CGContextDrawLayerAtPoint (context, CGPointZero, starLayer);
            CGContextTranslateCTM (context, h_spacing, 0);
        }
        CGContextTranslateCTM (context, (-i*h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGLayerRelease(stripeLayer);
    CGLayerRelease(starLayer);        
    
}

- (void)drawRect:(CGRect)rect {
    //giant the current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    [self drawCommonShapesInRect:rect context:context];
//    [self drawClipInRect:rect context:context];
//    [self drawColorspaceInRect:rect context:context];
//    [self drawCTMInRect:rect context:context];
//    [self drawShadowInRect:rect context:context];
//    [self drawShadingInRect:rect context:context];
//    [self drawGradientInRect:rect context:context];
//    [self drawTransquarencyLayerInRect:rect context:context];
//    [self drawSourceImageInRect:rect context:context];
    [self drawLayerInRect:rect context:context];
}

@end
