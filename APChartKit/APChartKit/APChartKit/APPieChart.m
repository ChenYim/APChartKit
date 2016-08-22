//
//  APPieChart.m
//  ChartDemo
//
//  Created by ChenYim on 16/7/25.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "APPieChart.h"
#import "APChartTools.h"

#define APSinglePieChart_OuterRadius (MIN(self.frame.size.width, self.frame.size.height)/2)
#define APSinglePieChart_InnerRadius (MIN(self.frame.size.width, self.frame.size.height)/2 - _pieWidth)

#define APPieChartOriginStartAngle (M_PI_2 * -1)
#define APPieChartDefaultColor [UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0]
#define APPieChartDefaultMarkFont [UIFont systemFontOfSize:20.0]
#define APPieChartAnimationDuration (self.pieAnimationDuration)

@class APSinglePieChart;
@protocol APSinglePieChartAnimationDelegate <NSObject>

- (void)singlePieChartDidFinishAnimation:(APSinglePieChart *)pieChart;

@end

#pragma mark - APSinglePieChart

@interface APSinglePieChart : UIView

@property (nonatomic, weak) id<APSinglePieChartAnimationDelegate> animationDeleagte;
@property (nonatomic, strong) CAGradientLayer *gradientPieLayer;
@property (nonatomic, strong) CAShapeLayer *pieShapeLayer;
@property (nonatomic, strong) UILabel *markStrLabel;
@property (nonatomic, strong) CAGradientLayer *markStrGradientLayer;

@property (nonatomic, assign) CGFloat pieValue;
@property (nonatomic, assign) CGFloat piePercent;
@property (nonatomic, strong) id pieColor;
@property (nonatomic, copy)   NSString *pieMarkTitle;
@property (nonatomic, strong) id pieMarkColor;
@property (nonatomic, strong) id pieMarkFont;
@property (nonatomic, assign) CGFloat pieAnimationDuration;
@property (nonatomic, assign) CGFloat pieWidth;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

@property (nonatomic, strong) UIBezierPath *piePath;
@property (nonatomic, strong) UIBezierPath *pieOutlinePath;

@end

@implementation APSinglePieChart

// Public Method =======================================
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    [self setupGradientBarLayer];
    [self setupPieSharpLayer];
}

- (void)startPieAnimation
{
    self.pieShapeLayer.lineWidth = _pieWidth;
    self.gradientPieLayer.hidden = NO;
    self.markStrLabel.hidden = NO;
    
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = APPieChartAnimationDuration;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0];
    pathAnimation.delegate = self;
    [self.pieShapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

// Private Method =======================================

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES) {
        
        [self drawDotMarkStr];
        if (self.animationDeleagte && [self.animationDeleagte respondsToSelector:@selector(singlePieChartDidFinishAnimation:)]) {
            [self.animationDeleagte singlePieChartDidFinishAnimation:self];
        }
    }
}

- (void)setupGradientBarLayer
{
    // gradientLineLayer
    self.gradientPieLayer = [CAGradientLayer layer];
    self.gradientPieLayer.frame = self.bounds;
    self.gradientPieLayer.startPoint = CGPointMake(0, 0.0);
    self.gradientPieLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientPieLayer.colors = [self getGradientLayerColorFromDataSource:_pieColor];
    [self.layer addSublayer:self.gradientPieLayer];
}

- (void)setupPieSharpLayer
{
    // PiePath
    self.piePath = [UIBezierPath bezierPath];
    [_piePath addArcWithCenter:self.center radius:APSinglePieChart_OuterRadius - _pieWidth/2 startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    
    self.pieShapeLayer = [CAShapeLayer layer];
    self.pieShapeLayer.path = _piePath.CGPath;
    self.pieShapeLayer.strokeColor = APPieChartDefaultColor.CGColor;
    self.pieShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.pieShapeLayer.lineWidth = 0.0;
    self.pieShapeLayer.shouldRasterize = YES;
    self.gradientPieLayer.mask = self.pieShapeLayer;
    
    // PieOutlinePath
    self.pieOutlinePath = [UIBezierPath bezierPath];
    [_pieOutlinePath addArcWithCenter:self.center radius:APSinglePieChart_OuterRadius startAngle:_endAngle endAngle:_startAngle clockwise:NO];
    CGPoint pt1 = CGPointMake(self.center.x + APSinglePieChart_InnerRadius*cos(_startAngle), self.center.y + APSinglePieChart_InnerRadius*sin(_startAngle));
    [_pieOutlinePath addLineToPoint:pt1];
    [_pieOutlinePath addArcWithCenter:self.center radius:APSinglePieChart_InnerRadius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    CGPoint pt2 = CGPointMake(self.center.x + APSinglePieChart_OuterRadius*cos(_endAngle), self.center.y + APSinglePieChart_OuterRadius*sin(_endAngle));
    [_pieOutlinePath addLineToPoint:pt2];
    [_pieOutlinePath closePath];
}

- (void)drawDotMarkStr
{
    if (self.markStrLabel) {
        [self.markStrLabel removeFromSuperview];
        [self.markStrGradientLayer removeFromSuperlayer];
    }
    self.markStrLabel               = [[UILabel alloc] initWithFrame:CGRectZero];
    self.markStrLabel.numberOfLines = 0;
    self.markStrLabel.shadowColor   = [UIColor clearColor];
    self.markStrLabel.textAlignment = NSTextAlignmentCenter;
    self.markStrLabel.font          = _pieMarkFont;;
    self.markStrLabel.text          = _pieMarkTitle;
    [self.markStrLabel sizeToFit];
    
    CGFloat frameW = self.frame.size.width;
    CGFloat frameH = self.frame.size.height;
    CGFloat midRadius = APSinglePieChart_OuterRadius - _pieWidth/2;

    CGPoint center = CGPointMake(self.center.x + midRadius*cos((_startAngle+_endAngle)/2), self.center.y + midRadius*sin((_startAngle+_endAngle)/2));
    self.markStrLabel.center = center;
    [self addSubview:self.markStrLabel];
    
    self.markStrGradientLayer = [CAGradientLayer layer];
    self.markStrGradientLayer.startPoint = CGPointMake(0, 0.0);
    self.markStrGradientLayer.endPoint = CGPointMake(1.0, 0.0);
    self.markStrGradientLayer.frame = CGRectMake(0, 0, frameW, frameH);
    self.markStrGradientLayer.colors = [self getGradientLayerColorFromDataSource:_pieMarkColor];
    
    [self.layer addSublayer:self.markStrGradientLayer];
    self.markStrGradientLayer.mask = self.markStrLabel.layer;
    //    self.markStrLabel.frame = gradientLayer.bounds
}

- (NSArray *)getGradientLayerColorFromDataSource:(id)color
{
    if ([color isKindOfClass:[UIColor class]])
    {
        if (!color) return @[];
        NSArray *colors = [NSArray arrayWithObjects:(__bridge id)((UIColor *)color).CGColor, (__bridge id)((UIColor *)color).CGColor, nil];
        return colors;
    }
    else if ([color isKindOfClass:[NSArray class]])
    {
        if (!color || ((NSArray *)color).count == 0) return @[];
        NSMutableArray *gradientColors = [NSMutableArray new];
        [color enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [gradientColors addObject:(__bridge id)obj.CGColor];
        }];
        return [gradientColors copy];
    }
    else{
        return @[(__bridge id)APPieChartDefaultColor.CGColor,
                 (__bridge id)APPieChartDefaultColor.CGColor];
    }
}

@end

#pragma mark - APPieChart

@interface APPieChart()<APSinglePieChartAnimationDelegate>

@property (nonatomic, strong) NSArray <NSNumber*> * dataModels;

@property (nonatomic, strong) NSMutableArray *pieViews;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *pieColors;
@property (nonatomic, strong) NSMutableArray *pieMarkTitles;
@property (nonatomic, strong) NSMutableArray *pieMarkColors;
@property (nonatomic, strong) NSMutableArray *pieMarkFonts;

@property (nonatomic, weak) id<APPieChartDataSource> dataSource;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation APPieChart

#pragma mark - Public Method
- (id)initWithFrame:(CGRect)frame andDataSource:(id<APPieChartDataSource>)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataSource = dataSource;
        _pieAnimarionDuration = 3.0;
        _isTapGestureInteractionEnabled = NO;
    }
    
    return self;
}

- (void)updatePieChartDatas
{
    [self setup];
}

- (void)startPieAnimations
{
    [_pieViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        APSinglePieChart *singlePieChart = obj;
        singlePieChart.gradientPieLayer.hidden = YES;
        singlePieChart.markStrLabel.hidden = YES;
        [singlePieChart.pieShapeLayer removeAllAnimations];
    }];
    
    APSinglePieChart *firstPieChart = [_pieViews firstObject];
    [firstPieChart startPieAnimation];
}

#pragma mark - Private Method
- (void)setup
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    self.dataModels = [self requestDataModelsForPieChartView];
    self.pieViews = [NSMutableArray new];
    self.pieColors = [NSMutableArray new];
    self.pieMarkTitles = [NSMutableArray new];
    self.pieMarkColors = [NSMutableArray new];
    self.pieMarkFonts = [NSMutableArray new];
    
    CGFloat frameW = self.frame.size.width;
    CGFloat frameH = self.frame.size.height;
    
    CGFloat summation = 0.0;
    for (NSInteger i = 0 ; i < _dataModels.count ;i++) {
        
        id pieColor            = [self requestColorForPieAtIndex:i];
        NSString *pieMarkTitle = [self requestTitleForPieMarkAtIndex:i];
        id pieMarkColor        = [self requestColorForPieMarkAtIndex:i];
        id pieMarkFont         = [self requestFontForPieMarkAtIndex:i];
        
        pieColor = pieColor == nil ? APPieChartDefaultColor : pieColor;
        pieMarkTitle = pieMarkTitle == nil ? @"" : pieMarkTitle;
        pieMarkColor = pieMarkColor == nil ? APPieChartDefaultColor : pieMarkColor;
        pieMarkFont = pieMarkFont == nil ? APPieChartDefaultMarkFont : pieMarkFont;
        
        [_pieColors addObject:pieColor];
        [_pieMarkTitles addObject:pieMarkTitle];
        [_pieMarkColors addObject:pieMarkColor];
        [_pieMarkFonts addObject:pieMarkFont];
        
        summation += [_dataModels[i] floatValue];
    }
    
    NSMutableArray *temp = [NSMutableArray new];
    CGFloat lastAngle = 0.0;
    CGFloat startAngle = 0.0, endAngle = 0.0;
    for (NSInteger i = 0 ; i < _dataModels.count ;i++)
    {
        [temp addObject:@([_dataModels[i] floatValue]/summation)];
        
        if (i == 0){
            startAngle = 0.0;
            endAngle   = 2 * M_PI * [temp[i] floatValue];
            lastAngle  = endAngle;
        }
        else{
            startAngle = lastAngle;
            endAngle   = (2 * M_PI * [temp[i] floatValue]) + lastAngle;
            lastAngle = endAngle;
        }
        
        startAngle += APPieChartOriginStartAngle;
        endAngle += APPieChartOriginStartAngle;
        
        APSinglePieChart *singlePie = [[APSinglePieChart alloc] initWithFrame:CGRectMake(0, 0, frameW, frameH)];
        singlePie.animationDeleagte = self;
        singlePie.pieValue = [_dataModels[i] floatValue];
        singlePie.piePercent = [_dataModels[i] floatValue]/summation;
        singlePie.pieColor = _pieColors[i];
        singlePie.pieMarkTitle = _pieMarkTitles[i];
        singlePie.pieMarkColor = _pieMarkColors[i];
        singlePie.pieMarkFont = _pieMarkFonts[i];
        singlePie.pieAnimationDuration = _pieAnimarionDuration * [_dataModels[i] floatValue]/summation;
        
        CGFloat pieWidth = MIN(frameW, frameH)/3;
        if (_pieWidth > 0.0 && _pieWidth <= MIN(frameW, frameH)/2) {
            pieWidth = _pieWidth;
        }
        singlePie.pieWidth = pieWidth;
        singlePie.startAngle = startAngle;
        singlePie.endAngle = endAngle;
        
        [singlePie setup];
        [self addSubview:singlePie];
        [self.pieViews addObject:singlePie];
    }
    NSLog(@"%@",_pieViews);
}

- (void)setIsTapGestureInteractionEnabled:(BOOL)isTapGestureInteractionEnabled
{
    _isTapGestureInteractionEnabled = isTapGestureInteractionEnabled;
    
    if (_isTapGestureInteractionEnabled) {
        [self setupTapGesture];
    }
}

- (void)setupTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrestureClick:)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)tapGrestureClick:(UITapGestureRecognizer *)tapGesture
{
    for (APSinglePieChart *pieChart in _pieViews) {
        
        CGPoint touchPoint = [tapGesture locationInView:pieChart];
        
        if ([pieChart.pieOutlinePath containsPoint:touchPoint]) {
            
            [pieChart.gradientPieLayer addTwinkleAnimationWithDuration:0.3 repeatCount:3];
        }
    }
}

#pragma mark - Request data

// pieDataModels
- (NSArray <NSNumber*> *)requestDataModelsForPieChartView
{
    NSArray *dataModels = nil;
    if ([self.dataSource respondsToSelector:@selector(dataModelsForPieChart:)])
    {
        dataModels = [self.dataSource dataModelsForPieChart:self];
    }
    return dataModels;
}

// pieColor
- (id)requestColorForPieAtIndex:(NSInteger)pieIndex
{
    id pieColor = nil;
    if ([self.dataSource respondsToSelector:@selector(pieChart:colorForPieAtIndex:)])
    {
        pieColor = [self.dataSource pieChart:self colorForPieAtIndex:pieIndex];
    }
    return pieColor;
}

// pieTitle
- (NSString *)requestTitleForPieMarkAtIndex:(NSInteger)pieIndex
{
    NSString *pieTitle = nil;
    if ([self.dataSource respondsToSelector:@selector(pieChart:titleForPieMarkAtIndex:)])
    {
        pieTitle = [self.dataSource pieChart:self titleForPieMarkAtIndex:pieIndex];
    }
    return pieTitle;
}

// pieTitleColor
- (id)requestColorForPieMarkAtIndex:(NSInteger)pieIndex
{
    id pieTitleColor = nil;
    if ([self.dataSource respondsToSelector:@selector(pieChart:colorForPieMarkAtIndex:)])
    {
        pieTitleColor = [self.dataSource pieChart:self colorForPieMarkAtIndex:pieIndex];
    }
    return pieTitleColor;
}

// pieTitleFont
- (UIFont *)requestFontForPieMarkAtIndex:(NSInteger)pieIndex
{
    UIFont *pieTitleFont = nil;
    if ([self.dataSource respondsToSelector:@selector(pieChart:fontForPieMarkAtIndex:)])
    {
        pieTitleFont = [self.dataSource pieChart:self fontForPieMarkAtIndex:pieIndex];
    }
    return pieTitleFont;
}

#pragma mark - APSinglePieChartAnimationDelegate

- (void)singlePieChartDidFinishAnimation:(APSinglePieChart *)pieChart
{
    NSUInteger pieChartIndex = [_pieViews indexOfObject:pieChart];
    
    if (pieChartIndex == NSNotFound) {
        return;
    }
    else if (pieChartIndex == (_pieViews.count - 1)){
        return;
    }
    else{
        APSinglePieChart *nextPieChart = [_pieViews objectAtIndex:(pieChartIndex + 1)];
        [nextPieChart startPieAnimation];
    }
}
@end
