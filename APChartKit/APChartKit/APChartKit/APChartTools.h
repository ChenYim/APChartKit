//
//  APChartCoordinateTool.h
//  ChartDemo
//
//  Created by ChenYim on 16/7/28.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APChartColorDefine.h"

@interface APChartTools : NSObject

+ (void)drawPoint:(CGContextRef)context point:(CGPoint)point color:(UIColor *)color;
+ (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth;
+ (void)drawText:(CGContextRef)context text:(NSString*)text point:(CGPoint)point color:(UIColor *)color font:(UIFont*)font textAlignment:(NSTextAlignment)textAlignment;
+ (void)drawDot:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius color:(UIColor *)color lineWidth:(CGFloat)lineWidth;

@end

@interface CALayer(APChartTools)

- (CABasicAnimation *)addTwinkleAnimationWithDuration:(double)duration repeatCount:(NSInteger)repeatCount;

@end
