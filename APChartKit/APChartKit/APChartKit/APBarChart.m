//
//  APBarChart.m
//  ChartDemo
//
//  Created by ChenYim on 16/7/22.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "APBarChart.h"
#import "APChartTools.h"

#define APBarChartDotMarkMargin (self.dotMarkBottomMargin)
#define APBarChartContentMargin (self.contentMargin)
#define APBarChartAnimationDuration (self.barAnimationDuration)
#define APBarChartDefaultColor [UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0]

#pragma mark - APSingleChartBar -

@interface APSingleChartBar : UIView

@property (nonatomic, assign) CGFloat barOffsetX;
@property (nonatomic, assign) CGFloat contentMargin;
@property (nonatomic, assign) CGFloat barAnimationDuration;
@property (nonatomic, assign) CGFloat barValue;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, strong) id barColor;
@property (nonatomic, strong) UIColor *barShadowColor;

@property (nonatomic, copy  ) NSString *dotMarkStr;
@property (nonatomic, strong) id       dotMarkColor;
@property (nonatomic, strong) UIFont   *dotMarkFont;
@property (nonatomic, assign) CGFloat  dotMarkBottomMargin;

@property (nonatomic, strong) UIBezierPath *barPath;
@property (nonatomic, strong) UIBezierPath *barOutlinePath;
// gradientLayer
@property (nonatomic, strong) CAGradientLayer *barTintLayer;
@property (nonatomic, strong) CAGradientLayer *barShadowLayer;
// shapeLayer
@property (nonatomic, strong) CAShapeLayer *barTintLayerMask;
@property (nonatomic, strong) CAShapeLayer *barShadowLayerMask;
@end

@implementation APSingleChartBar

// Public Method =======================================
- (void)setup
{
    [self setupbarTintLayer];
    [self setupBarSharpLayer];
}

- (void)startBarAnimation
{
    self.barTintLayerMask.lineWidth = _barWidth;
    
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = APBarChartAnimationDuration;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.delegate = self;
    [self.barTintLayerMask addAnimation:pathAnimation forKey:@"strokeEnd"];
}

// Private Method =======================================

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES) {
        [self drawDotMarkStr];
    }
}

- (void)setupbarTintLayer
{
    self.barShadowLayer = [CAGradientLayer layer];
    self.barShadowLayer.frame = self.bounds;
    self.barShadowLayer.startPoint = CGPointMake(0, 0.0);
    self.barShadowLayer.endPoint = CGPointMake(1.0, 0.0);
    self.barShadowLayer.colors = [self getGradientLayerColorFromDataSource:_barShadowColor];
    [self.layer addSublayer:self.barShadowLayer];
    
    // barTintLayer
    self.barTintLayer = [CAGradientLayer layer];
    self.barTintLayer.frame = self.bounds;
    self.barTintLayer.startPoint = CGPointMake(0, 0.0);
    self.barTintLayer.endPoint = CGPointMake(1.0, 0.0);
    self.barTintLayer.colors = [self getGradientLayerColorFromDataSource:_barColor];
    [self.layer addSublayer:self.barTintLayer];
}

- (void)setupBarSharpLayer
{
    CGFloat frameH = self.frame.size.height;
    CGFloat contentH = frameH - APBarChartContentMargin * 2;
    
    // BarTintPath
    self.barPath = [UIBezierPath bezierPath];
    [_barPath moveToPoint:CGPointMake(_barOffsetX + _barWidth*0.5, frameH - _contentMargin)];
    [_barPath addLineToPoint:CGPointMake(_barOffsetX + _barWidth*0.5, APBarChartContentMargin + contentH*(1-_barValue))];
    if (_barValue == 0.0) {
        _barPath = nil;
    }
    
    self.barTintLayerMask = [CAShapeLayer layer];
    self.barTintLayerMask.path = _barPath.CGPath;
    self.barTintLayerMask.strokeColor = APBarChartDefaultColor.CGColor;
    self.barTintLayerMask.fillColor = [[UIColor clearColor] CGColor];
    self.barTintLayerMask.lineWidth = 0.0;
    self.barTintLayerMask.shouldRasterize = YES;
    self.barTintLayer.mask = self.barTintLayerMask;
    
    // BarShadowPath
    UIBezierPath *barPath2 = [UIBezierPath bezierPath];
    [barPath2 moveToPoint:CGPointMake(_barOffsetX + _barWidth*0.5, frameH - _contentMargin)];
    [barPath2 addLineToPoint:CGPointMake(_barOffsetX + _barWidth*0.5, APBarChartContentMargin)];
    if (_barValue == 0.0) {
        barPath2 = nil;
    }
    
    self.barShadowLayerMask = [CAShapeLayer layer];
    self.barShadowLayerMask.lineWidth = _barWidth;
    self.barShadowLayerMask.path = barPath2.CGPath;
    self.barShadowLayerMask.strokeColor = APBarChartDefaultColor.CGColor;
    self.barShadowLayerMask.fillColor = [[UIColor clearColor] CGColor];
//    self.barShadowLayerMask.lineWidth = 0.0;
    self.barShadowLayerMask.shouldRasterize = YES;
    self.barShadowLayer.mask = self.barShadowLayerMask;
    
    // BarTintOutlinePath
    self.barOutlinePath = [UIBezierPath bezierPath];
    CGPoint ptBottomLeft, ptBottomRight, ptTopLeft, ptTopRight;
    ptBottomLeft  = CGPointMake(_barOffsetX, frameH - _contentMargin);
    ptBottomRight = CGPointMake(_barOffsetX + _barWidth, frameH - _contentMargin);
    ptTopLeft     = CGPointMake(_barOffsetX, APBarChartContentMargin + contentH*(1-_barValue));
    ptTopRight    = CGPointMake(_barOffsetX + _barWidth, APBarChartContentMargin + contentH*(1-_barValue));
    if (_barValue == 0.0) {
        _barOutlinePath = nil;
    }
    [_barOutlinePath moveToPoint:ptBottomLeft];
    [_barOutlinePath addLineToPoint:ptBottomRight];
    [_barOutlinePath addLineToPoint:ptTopRight];
    [_barOutlinePath addLineToPoint:ptTopLeft];
    [_barOutlinePath addLineToPoint:ptBottomLeft];
    [_barOutlinePath closePath];

}

- (void)drawDotMarkStr
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = _dotMarkFont ? _dotMarkFont : [UIFont systemFontOfSize:10.0];
    label.text = _dotMarkStr;
    [label sizeToFit];
    
    CGFloat contentH = self.frame.size.height - APBarChartContentMargin*2;
    CGFloat barTopY = APBarChartContentMargin + contentH*(1-_barValue);
    label.center = CGPointMake(_barOffsetX + _barWidth/2, barTopY - CGRectGetHeight(label.frame)/2 - APBarChartDotMarkMargin);
    [self addSubview:label];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    gradientLayer.colors = [self getGradientLayerColorFromDataSource:_dotMarkColor];

    [self.layer addSublayer:gradientLayer];
    gradientLayer.mask = label.layer;
    //    label.frame = gradientLayer.bounds
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
        return @[(__bridge id)APBarChartDefaultColor.CGColor,
                 (__bridge id)APBarChartDefaultColor.CGColor];
    }
}

@end

#pragma mark - APBarChart -

@interface APBarChart()
@property (nonatomic, strong) NSArray <NSNumber*> *      dataModels;
@property (nonatomic, strong) NSMutableArray             *barColors;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *barWidths;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *spaceIntervals;

@property (nonatomic, strong) NSMutableArray *barMarkTitles;
@property (nonatomic, strong) NSMutableArray *barMarkColors;
@property (nonatomic, strong) NSMutableArray *barMarkFonts;

@property (nonatomic, strong) NSArray<NSString*> *horizontalTitles;
@property (nonatomic, strong) NSArray<NSString*> *verticalTitles;

@property (nonatomic, strong) NSMutableArray<NSNumber*> *barOffsetXs;

@property (nonatomic, strong) NSMutableArray *barViews;

@property (nonatomic, assign) id<APBarChartDataSource> dataSource;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation APBarChart

- (id)initWithFrame:(CGRect)frame andDataSource:(id<APBarChartDataSource>)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = dataSource;

        _coordinateLineW = 0.5;
        _coordinateColor = [UIColor grayColor];
        _coordinateFont = [UIFont systemFontOfSize:5.0];
        _coordinateMarkRightMargin = 1.5;
        _coordinateMarkTopMargin = 3.0;
        
        _contentMargin = 0.0;
        _markBottomMargin = 0.0;
        
        _barShadowColor = [UIColor clearColor];
        _barAnimarionDuration = 1.5;
        _isDotMarkDrawingEnabled = NO;
        _isTapGestureInteractionEnabled = NO;
    }
    
    return self;
}

- (void)updateBarChartDatas
{
    [self setup];
}

- (void)startBarAnimations
{
    for (APSingleChartBar *bar in _barViews) {
        [bar startBarAnimation];
    }
}

-(void)drawRect:(CGRect)rect
{
    if (_verticalTitles.count == 0 || _horizontalTitles.count == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat frameW = self.frame.size.width;
    CGFloat frameH = self.frame.size.height;
    
    CGPoint ptOrigin = CGPointMake(_contentMargin, frameH - _contentMargin);
    CGPoint ptXmax = CGPointMake(frameW, frameH - _contentMargin);
    CGPoint ptYmax = CGPointMake(_contentMargin, 0.0);
    
    // X/Y Axis
    [APChartTools drawLine:context startPoint:ptOrigin endPoint:ptXmax lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptOrigin endPoint:ptYmax lineColor:_coordinateColor lineWidth:_coordinateLineW];
    
    CGFloat offsetXLength = (frameW - _contentMargin*2) / (_horizontalTitles.count);
    CGFloat offsetY = frameH - _contentMargin;
    CGFloat offsetYLength = (frameH - _contentMargin*2) / (_verticalTitles.count);
    CGFloat markLength = 3.0;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{  NSFontAttributeName: _coordinateFont,
                                   NSForegroundColorAttributeName: _coordinateColor,
                                   NSParagraphStyleAttributeName: paragraphStyle};
    // mark in X axis
    for (NSInteger i = 0 ; i < _horizontalTitles.count ;i++) {
        CGFloat markY = frameH - _contentMargin;
        NSString *text = [NSString stringWithFormat:@"%@",_horizontalTitles[i]];
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:_coordinateFont}];
        CGRect rect = CGRectMake([_barOffsetXs[i] floatValue] + [_barWidths[i] floatValue]/2 - 0.5*textSize.width, markY+_coordinateMarkTopMargin, textSize.width, textSize.height);
        [text drawInRect:rect withAttributes:attributes];
    }
    
    // mark in Y axis
    for (NSInteger i = 0 ; i < _verticalTitles.count ;i++) {
        CGFloat markX = _contentMargin;
        CGFloat markY = offsetY-offsetYLength*(i+1);
        [APChartTools drawLine:context startPoint:CGPointMake(markX, markY) endPoint:CGPointMake(markX + markLength, markY) lineColor:_coordinateColor lineWidth:_coordinateLineW];
        
        NSString *text = [NSString stringWithFormat:@"%@",_verticalTitles[i]];
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:_coordinateFont}];
        CGRect rect = CGRectMake(markX - textSize.width - _coordinateMarkRightMargin, markY - textSize.height/2, textSize.width, textSize.height);
        [text drawInRect:rect withAttributes:attributes];
    }
    
    // Arrow
    CGPoint ptMaxXUp =  CGPointMake(frameW - offsetYLength/2, frameH - _contentMargin - offsetYLength/4);
    CGPoint ptMaxXDown =  CGPointMake(frameW - offsetYLength/2, frameH - _contentMargin + offsetYLength/4);
    CGPoint ptMaxYUp =  CGPointMake(_contentMargin - offsetXLength/4, offsetXLength/2);
    CGPoint ptMaxYDown =  CGPointMake(_contentMargin + offsetXLength/4, offsetXLength/2);
    [APChartTools drawLine:context startPoint:ptXmax endPoint:ptMaxXUp lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptXmax endPoint:ptMaxXDown lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptYmax endPoint:ptMaxYUp lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptYmax endPoint:ptMaxYDown lineColor:_coordinateColor lineWidth:_coordinateLineW];
}

#pragma mark - Private Method

- (void)setup
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    self.dataModels = [self requestDataModelsForBarChart];
    self.horizontalTitles = [self requestTitlesForHorizontalAxis];
    self.verticalTitles = [self requestTitlesForVerticalAxis];
    
    self.barColors      = [NSMutableArray new];
    self.barWidths      = [NSMutableArray new];
    self.spaceIntervals = [NSMutableArray new];
    self.barMarkTitles  = [NSMutableArray new];
    self.barMarkColors  = [NSMutableArray new];
    self.barMarkFonts   = [NSMutableArray new];
    self.barOffsetXs    = [NSMutableArray new];
    
    CGFloat frameW = self.frame.size.width;
    CGFloat frameH = self.frame.size.height;
    CGFloat contentW = frameW - _contentMargin * 2;
    
    for (NSInteger i = 0 ; i < _dataModels.count ;i++) {
        
        id barColor            = [self requestColorForBarAtIndex:i];
        CGFloat barWidth       = [self requesWidthForBarAtIndex:i];
        CGFloat spaceInterval  = [self requestIntervalForBarSpaceAtIndex:i];
        NSString *barMarkTitle = [self requestTitleForBarMarkAtIndex:i];
        id barMarkColor        = [self requestColorForBarMarkAtIndex:i];
        id barMarkFont         = [self requestFontForBarMarkAtIndex:i];
        
        barColor = barColor ? barColor:APBarChartDefaultColor;
        barWidth = (barWidth == 0.0) ? (contentW/(_dataModels.count*2 + 1)) : barWidth;
        spaceInterval = (spaceInterval == 0.0) ? (contentW/(_dataModels.count*2 + 1)) : spaceInterval;
        barMarkTitle = barMarkTitle? barMarkTitle : @"";
        barMarkColor = barMarkColor? barMarkColor: APBarChartDefaultColor;
        barMarkFont = barMarkFont? barMarkFont: [UIFont systemFontOfSize:(frameW/(_dataModels.count*2 + 1))];
        
        [_barColors addObject:barColor];
        [_barWidths addObject:@(barWidth)];
        [_spaceIntervals addObject:@(spaceInterval)];
        [_barMarkTitles addObject:barMarkTitle];
        [_barMarkColors addObject:barMarkColor];
        [_barMarkFonts addObject:barMarkFont];
        
        if (_barOffsetXs.count == 0) {
            [_barOffsetXs addObject:@(_contentMargin + spaceInterval)];
        }
        else{
            CGFloat lastValue = [[_barOffsetXs lastObject] floatValue];
            [_barOffsetXs addObject:@(lastValue + [_barWidths[i-1] floatValue] + spaceInterval)];
        }
    }
    
    self.barViews = [NSMutableArray new];
    for (NSInteger i = 0 ; i < _dataModels.count ;i++) {
        
        CGRect barFrame = CGRectMake(0, 0, frameW, frameH);
        APSingleChartBar *singleBar = [[APSingleChartBar alloc] initWithFrame:barFrame];
        singleBar.contentMargin = _contentMargin;
        singleBar.barAnimationDuration = _barAnimarionDuration;
        
        singleBar.barOffsetX = [_barOffsetXs[i] floatValue];
        singleBar.barValue   = [_dataModels[i] floatValue];
        singleBar.barWidth   = [_barWidths[i] floatValue];
        singleBar.barColor   = _barColors[i];
        singleBar.barShadowColor = _barShadowColor;
        
        singleBar.dotMarkStr = _barMarkTitles[i];
        singleBar.dotMarkColor = _barMarkColors[i];
        singleBar.dotMarkFont = _barMarkFonts[i];
        singleBar.dotMarkBottomMargin = _markBottomMargin;
        
        [singleBar setup];
        [self addSubview:singleBar];
        [self.barViews addObject:singleBar];
    }
    
    [self setNeedsDisplay];
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
    for (APSingleChartBar *barView in _barViews) {
        
        CGPoint touchPoint = [tapGesture locationInView:barView];
        
        if ([barView.barOutlinePath containsPoint:touchPoint]) {
            
            [barView.barTintLayer addTwinkleAnimationWithDuration:0.3 repeatCount:3];
        }
    }
}

#pragma mark - Request data

// barDataModels
- (NSArray <NSNumber*> *)requestDataModelsForBarChart
{
    NSArray *dataModels = nil;
    if ([self.dataSource respondsToSelector:@selector(dataModelsForBarChart:)])
    {
        dataModels = [self.dataSource dataModelsForBarChart:self];
    }
    return dataModels;
}

// barColor
- (id)requestColorForBarAtIndex:(NSInteger)barIndex
{
    UIColor *barColor = nil;
    if ([self.dataSource respondsToSelector:@selector(barChart:colorForBarAtIndex:)])
    {
        barColor = [self.dataSource barChart:self colorForBarAtIndex:barIndex];
    }
    return barColor;
}

// barWidth
- (CGFloat)requesWidthForBarAtIndex:(NSInteger)barIndex
{
    CGFloat barWidth = 0.0;
    if ([self.dataSource respondsToSelector:@selector(barChart:widthForBarAtIndex:)])
    {
        barWidth = [self.dataSource barChart:self widthForBarAtIndex:barIndex];
    }
    return barWidth;
}

// spaceInterval
- (CGFloat)requestIntervalForBarSpaceAtIndex:(NSInteger)barIndex
{
    CGFloat spaceInterval = 0.0;
    if ([self.dataSource respondsToSelector:@selector(barChart:intervalForBarSpaceAtIndex:)])
    {
        spaceInterval = [self.dataSource barChart:self intervalForBarSpaceAtIndex:barIndex];
    }
    return spaceInterval;
}

// barMarkTitle
- (id)requestTitleForBarMarkAtIndex:(NSInteger)barIndex
{
    NSString *barMarkTitle;
    if ([self.dataSource respondsToSelector:@selector(barChart:titleForBarMarkAtIndex:)])
    {
        barMarkTitle = [self.dataSource barChart:self titleForBarMarkAtIndex:barIndex];
    }
    return barMarkTitle;
}

// barMarkColor
- (id)requestColorForBarMarkAtIndex:(NSInteger)barIndex
{
    id barMarkColor = nil;
    if ([self.dataSource respondsToSelector:@selector(barChart:colorForBarMarkAtIndex:)])
    {
        barMarkColor = [self.dataSource barChart:self colorForBarMarkAtIndex:barIndex];
    }
    return barMarkColor;
}

// barMarkFont
- (UIFont *)requestFontForBarMarkAtIndex:(NSInteger)barIndex
{
    UIFont *barMarkFont = nil;
    if ([self.dataSource respondsToSelector:@selector(barChart:fontForBarMarkAtIndex:)])
    {
        barMarkFont = [self.dataSource barChart:self fontForBarMarkAtIndex:barIndex];
    }
    return barMarkFont;
}

// titlesForHorizontalAxis
- (NSArray<NSString*> *)requestTitlesForHorizontalAxis
{
    NSArray<NSString*> *horizontalTitles = @[];
    if ([self.dataSource respondsToSelector:@selector(titlesForHorizontalAxisInBarChart:)])
    {
        horizontalTitles = [self.dataSource titlesForHorizontalAxisInBarChart:self];
    }
    return horizontalTitles;
}

// titlesForVerticalAxis
- (NSArray<NSString*> *)requestTitlesForVerticalAxis
{
    NSArray<NSString*> *verticalTitles = @[];
    if ([self.dataSource respondsToSelector:@selector(titlesForVerticalAxisInBarChart:)])
    {
        verticalTitles = [self.dataSource titlesForVerticalAxisInBarChart:self];
    }
    return verticalTitles;
}
@end
