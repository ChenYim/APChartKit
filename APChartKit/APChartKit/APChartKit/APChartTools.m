//
//  APChartCoordinateTool.m
//  ChartDemo
//
//  Created by ChenYim on 16/7/28.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "APChartTools.h"

@implementation APChartTools

+ (void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor *)color{
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Pointcolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Pointcolorspace1);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, point.x,point.y);
    CGContextAddArc(context, point.x, point.y, 2, 0, 360, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    CGColorSpaceRelease(Pointcolorspace1);
}
+ (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth{
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);
}

+ (void)drawText:(CGContextRef)context text:(NSString*)text point:(CGPoint)point color:(UIColor *)color font:(UIFont*)font textAlignment:(NSTextAlignment)textAlignment
{
    [color set];
    
    CGSize title1Size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    CGRect titleRect1 = CGRectMake(point.x,
                                   point.y,
                                   title1Size.width,
                                   title1Size.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = textAlignment;
    NSMutableDictionary *attributes = [@{  NSFontAttributeName: font,
                                           NSForegroundColorAttributeName: color,
                                           NSParagraphStyleAttributeName: paragraphStyle
                                           } mutableCopy];
    
    [text drawInRect:titleRect1 withAttributes:attributes];
}

+ (void)drawDot:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius color:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    CGContextSetShouldAntialias(context, YES); //抗锯齿
    CGColorSpaceRef Pointcolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Pointcolorspace1);
    CGContextSetLineWidth(context, lineWidth);//线的宽度
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    CGColorSpaceRelease(Pointcolorspace1);
}

@end

@implementation CALayer(APChartTools)

- (void)addTwinkleAnimationWithDuration:(double)duration repeatCount:(NSInteger)repeatCount
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue   = [NSNumber numberWithFloat:0.0];
    animation.autoreverses        = YES;
    animation.repeatCount         = FLT_MAX;
    animation.removedOnCompletion = YES;
    animation.fillMode            = kCAFillModeForwards;
    animation.repeatCount = repeatCount <= -1 ? HUGE_VALF:repeatCount;
    animation.duration=duration;
    
    [self addAnimation:animation forKey:@"APTwinkleAnimation"];
}

@end