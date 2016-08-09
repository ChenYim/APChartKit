//
//  APLineChart.m
//  ChartDemo
//
//  Created by ChenYim on 16/7/20.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "APLineChart.h"
#import "APChartTools.h"

@interface APLineChartDataModel()
@property (nonatomic, readwrite, assign) CGFloat xValuePercent;
@property (nonatomic, readwrite, assign) CGFloat yValuePercent;
@property (nonatomic, readwrite, copy) NSString *dotMarkStr;
@end

@implementation APLineChartDataModel

+ (instancetype)modelWithxValuePercent:(CGFloat)xValuePercent yValuePercent:(CGFloat)yValuePercent dotMarkStr:(NSString *)dotMarkStr
{
    APLineChartDataModel *chartlineModel = [[APLineChartDataModel alloc] init];
    
    if (chartlineModel) {
        chartlineModel.xValuePercent = xValuePercent;
        chartlineModel.yValuePercent = yValuePercent;
        chartlineModel.dotMarkStr = dotMarkStr;
    }
    return chartlineModel;
}
@end

#pragma mark - APSingleChartLine -

#define APLineChartDotRadius (self.lineDotRadius) //2.5
#define APLineChartDotMark_TopMargin (self.dotMarkTopMargin)  //1.0
#define APLineChartDotMark_BottomMargin (self.dotMarkBottomMargin) //1.0
#define APLineChartContentMargin (self.contentMargin)
#define APLineChartCoordinateMargin_x (self.segmentLength_x)
#define APLineChartCoordinateMargin_y (self.segmentLength_y)

#define APLineChartAnimationDuration (self.AnimationDuration)

@interface APSingleChartLine : UIView
@property (nonatomic, strong) UIBezierPath *linePath;
@property (nonatomic, strong) UIBezierPath *dotPath;

@property (nonatomic, assign) CGFloat contentMargin;
@property (nonatomic, strong) NSArray <APLineChartDataModel *> * lineModels;
@property (nonatomic, assign) CGFloat segmentLength_x;
@property (nonatomic, assign) CGFloat segmentLength_y;
@property (nonatomic, assign) BOOL isDotMarkDrawingEnabled;

@property (nonatomic, strong) id lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineDotRadius;
@property (nonatomic, assign) CGFloat lineAnimarionDuration;

@property (nonatomic, strong) id dotMarkColor;
@property (nonatomic, strong) UIFont *dotMarkFont;
@property (nonatomic, assign) CGFloat dotMarkTopMargin;
@property (nonatomic, assign) CGFloat dotMarkBottomMargin;

// gradientLayer
@property (nonatomic, strong) CAGradientLayer *gradientLineLayer;
@property (nonatomic, strong) CAGradientLayer *gradientDotLayer;

// shapeLayer
@property (nonatomic, strong) CAShapeLayer *lineShapeLayer;
@property (nonatomic, strong) CAShapeLayer *dotShapeLayer;
@end

@implementation APSingleChartLine

- (void)setup
{
    [self setupGradientLayers];
}

#pragma mark - Public Method

- (void)startDrawlineChart {
    
    // set LineWidth = 0.0 before start drawing
    self.lineShapeLayer.lineWidth = _lineWidth;
    self.dotShapeLayer.lineWidth = _lineWidth;
    
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = _lineAnimarionDuration;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
//    pathAnimation.delegate = self;
    [self.lineShapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CABasicAnimation *pointAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pointAnimation.duration = _lineAnimarionDuration;
    pointAnimation.repeatCount = 1;
    pointAnimation.removedOnCompletion = NO;
    pointAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pointAnimation.toValue = [NSNumber numberWithFloat:0.8f];
    pointAnimation.delegate = self; // set to observe CABasicAnimation didStop event
    [self.dotShapeLayer addAnimation:pointAnimation forKey:@"strokeEnd"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES && _isDotMarkDrawingEnabled) {
        [self drawDotMarkStr];
    }
}

#pragma mark - Private Method

- (void)setupGradientLayers {
    
    // gradientLineLayer
    self.gradientLineLayer = [CAGradientLayer layer];
    self.gradientLineLayer.frame = self.bounds;
    self.gradientLineLayer.startPoint = CGPointMake(0, 0.0);
    self.gradientLineLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientLineLayer.colors = [NSMutableArray arrayWithArray:@[(__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor,
                                                                     (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor]];
    [self.layer addSublayer:self.gradientLineLayer];
    
    // gradientDotLayer
    self.gradientDotLayer = [CAGradientLayer layer];
    self.gradientDotLayer.frame = self.bounds;
    self.gradientDotLayer.startPoint = CGPointMake(0, 0.0);
    self.gradientDotLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientDotLayer.colors = [NSMutableArray arrayWithArray:@[(__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor,
                                                                    (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor]];
    [self.layer addSublayer:self.gradientDotLayer];
}

- (void)setupLineColor:(id)lineColor
{
    self.lineColor = lineColor;
    
    if ([lineColor isKindOfClass:[UIColor class]])
    {
        if (!_lineColor) return;
        self.gradientLineLayer.colors = [NSArray arrayWithObjects:(__bridge id)((UIColor *)lineColor).CGColor, (__bridge id)((UIColor *)lineColor).CGColor, nil];
        self.gradientDotLayer.colors = [NSArray arrayWithObjects:(__bridge id)((UIColor *)lineColor).CGColor, (__bridge id)((UIColor *)lineColor).CGColor, nil];
    }
    else if ([lineColor isKindOfClass:[NSArray class]])
    {
        if (!_lineColor || ((NSArray *)_lineColor).count == 0) return;
        NSMutableArray *lineGradientColorRef = [NSMutableArray new];
        [_lineColor enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [lineGradientColorRef addObject:(__bridge id)obj.CGColor];
        }];
        self.gradientLineLayer.colors = [lineGradientColorRef copy];
        self.gradientDotLayer.colors = [lineGradientColorRef copy];
    }
}

- (NSArray *)getDotMarkColorRef
{
    if ([_dotMarkColor isKindOfClass:[UIColor class]])
    {
        if (!_dotMarkColor) return @[];
        NSArray *colors = [NSArray arrayWithObjects:(__bridge id)((UIColor *)_dotMarkColor).CGColor, (__bridge id)((UIColor *)_dotMarkColor).CGColor, nil];
        return colors;
    }
    else if ([_dotMarkColor isKindOfClass:[NSArray class]])
    {
        if (!_dotMarkColor || ((NSArray *)_dotMarkColor).count == 0) return @[];
        NSMutableArray *mColors = [NSMutableArray new];
        [_dotMarkColor enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mColors addObject:(__bridge id)obj.CGColor];
        }];
        return [mColors copy];
    }
    else{
        return @[];
    }
}

- (void)setupLineModels:(NSArray <APLineChartDataModel *> *)lineModels{
    
    self.lineModels = lineModels;
    
    self.linePath = [self linePathByInfos:_lineModels];
    self.dotPath  = [self dotPathByInfos:_lineModels];
    
    self.lineShapeLayer = [CAShapeLayer layer];
    self.lineShapeLayer.path = _linePath.CGPath;
    self.lineShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.lineShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.lineShapeLayer.lineWidth = 0.0;
    self.lineShapeLayer.lineCap = kCALineCapRound;
    self.lineShapeLayer.lineJoin = kCALineJoinRound;
    self.lineShapeLayer.shouldRasterize = YES;
    
    self.dotShapeLayer = [CAShapeLayer layer];
    self.dotShapeLayer.path = _dotPath.CGPath;
    self.dotShapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.dotShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.dotShapeLayer.lineWidth = 0.0;
    self.dotShapeLayer.lineCap = kCALineCapRound;
    self.dotShapeLayer.lineJoin = kCALineJoinRound;
    self.dotShapeLayer.shouldRasterize = YES;
    
    self.gradientLineLayer.mask = self.lineShapeLayer;
    self.gradientDotLayer.mask = self.dotShapeLayer;
}

- (UIBezierPath *)linePathByInfos:(NSArray <APLineChartDataModel *> *)dotPositions
{
    if (dotPositions.count <= 1) {
        return nil;
    }
    
    CGFloat frameW = self.frame.size.width - APLineChartContentMargin * 2;
    CGFloat frameH = self.frame.size.height - APLineChartContentMargin * 2 - APLineChartCoordinateMargin_y;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [dotPositions enumerateObjectsUsingBlock:^(APLineChartDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isLastDot = idx == (dotPositions.count - 1) ? YES : NO;
        if (isLastDot) {
            return;
        }
        
        CGFloat last_x = obj.xValuePercent * frameW;
        CGFloat last_y = (1-obj.yValuePercent) * frameH;
        CGFloat x = [dotPositions[idx +1] xValuePercent] * frameW;
        CGFloat y = (1-[dotPositions[idx +1] yValuePercent]) * frameH;
        
        // calculate the point for line
        CGFloat distance = sqrt(pow(x - last_x, 2) + pow(y - last_y, 2));
        CGFloat last_x1 = last_x + APLineChartDotRadius / distance * (x - last_x);
        CGFloat last_y1 = last_y + APLineChartDotRadius / distance * (y - last_y);
        CGFloat x1 = x - APLineChartDotRadius / distance * (x - last_x);
        CGFloat y1 = y - APLineChartDotRadius / distance * (y - last_y);

        [linePath moveToPoint:CGPointMake(last_x1 + APLineChartContentMargin , last_y1 + APLineChartContentMargin)];
        [linePath addLineToPoint:CGPointMake(x1 + APLineChartContentMargin , y1 + APLineChartContentMargin)];
    }];
    
    return linePath;
}

- (UIBezierPath *)dotPathByInfos:(NSArray <APLineChartDataModel *> *)dotPositions
{
    if (dotPositions.count <= 0) {
        return nil;
    }
    
    CGFloat frameW = self.frame.size.width - APLineChartContentMargin * 2;
    CGFloat frameH = self.frame.size.height - APLineChartContentMargin * 2 - APLineChartCoordinateMargin_y;
    
    UIBezierPath *dotPath = [UIBezierPath bezierPath];
    [dotPositions enumerateObjectsUsingBlock:^(APLineChartDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat dotX = obj.xValuePercent * frameW;
        CGFloat dotY = (1-obj.yValuePercent) * frameH;
        [dotPath moveToPoint:CGPointMake(dotX+APLineChartDotRadius + APLineChartContentMargin, dotY + APLineChartContentMargin)];
        [dotPath addArcWithCenter:CGPointMake(dotX + APLineChartContentMargin , dotY + APLineChartContentMargin) radius:APLineChartDotRadius startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
    }];
    return dotPath;
}

- (void)drawDotMarkStr
{
    for (NSInteger i = 0 ; i < _lineModels.count ;i++) {
        
        APLineChartDataModel *lineModel = _lineModels[i];
        CGFloat value = lineModel.yValuePercent;
        NSString *dotMarkStr = lineModel.dotMarkStr;
        // 画值
        BOOL markOnTheTop = YES;
        if (i == 0) {
            APLineChartDataModel *secondLineModel = _lineModels[i+1];
            CGFloat nextValue = secondLineModel.yValuePercent;
            if (nextValue > value) {
                markOnTheTop = NO;
            }
        }
        else if (i == _lineModels.count - 1){
            APLineChartDataModel *lastLineModel = _lineModels[i-1];
            CGFloat lastValue = lastLineModel.yValuePercent;
            if (value < lastValue) {
                markOnTheTop = NO;
            }
        }
        else{
            CGFloat lastValue = ((APLineChartDataModel *)(_lineModels[i-1])).yValuePercent;
            CGFloat nextValue = ((APLineChartDataModel *)(_lineModels[i+1])).yValuePercent;
            if (lastValue > value && nextValue > value) {
                markOnTheTop = NO;
            }
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = _dotMarkFont ? _dotMarkFont : [UIFont systemFontOfSize:10.0];
        label.text = dotMarkStr;
        [label sizeToFit];
        
        CGFloat frameW = self.frame.size.width - APLineChartContentMargin * 2;
        CGFloat frameH = self.frame.size.height - APLineChartContentMargin * 2 - APLineChartCoordinateMargin_y;
        
        CGFloat dotX = lineModel.xValuePercent * frameW;
        CGFloat dotY = (1-lineModel.yValuePercent) * frameH;
        
        CGFloat labelCenterY;
        if (markOnTheTop) {
            labelCenterY = dotY - APLineChartDotRadius - APLineChartDotMark_BottomMargin - 0.5 * label.frame.size.height;
        }
        else{
            labelCenterY = dotY + APLineChartDotRadius + APLineChartDotMark_TopMargin + 0.5 * label.frame.size.height;
        }
        label.center = CGPointMake(dotX + APLineChartContentMargin, labelCenterY + APLineChartContentMargin);
        
        [self addSubview:label];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0.0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        gradientLayer.colors = [self getDotMarkColorRef];
        
        [self.layer addSublayer:gradientLayer];
        gradientLayer.mask = label.layer;
        //    label.frame = gradientLayer.bounds
    }
}
@end

#pragma mark - APLineChart -

@interface APLineChart()

@property (nonatomic, strong) NSArray <NSArray <APLineChartDataModel*> *> * chartLineDataModels;
@property (nonatomic, strong) NSMutableArray *lineColors;
@property (nonatomic, strong) NSMutableArray *lineDotMarkColors;
@property (nonatomic, strong) NSMutableArray <APSingleChartLine *> *singChartLines;
@property (nonatomic, weak) id<APLineChartDataSource> dataSource;
@property (nonatomic, strong) NSArray<NSString*> *horizontalTitles;
@property (nonatomic, strong) NSArray<NSString*> *verticalTitles;

@property (nonatomic, assign) CGFloat segmentLength_x;
@property (nonatomic, assign) CGFloat segmentLength_y;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation APLineChart

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame andDataSource:(id<APLineChartDataSource>)dataSource
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
        
        _lineChartWidth = 0.5;
        _lineDotRadius = 2.5;
        _lineDotMarkTopMargin = 1.0;
        _lineDotMarkBottomMargin = 1.0;
        
        _contentMargin = 0.0;
        _isDotMarkDrawingEnabled = NO;
        _lineChartAnimarionDuration = 2.0;
        _isTapGestureInteractionEnabled = NO;
    }
    
    return self;
}

- (void)updateLineChartDatas
{
    [self setup];
}

- (void)startLineAnimations
{
    for (APSingleChartLine *line in _singChartLines) {
        [line startDrawlineChart];
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
    
    CGFloat offsetX = _contentMargin;
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
        CGFloat markX = offsetX+offsetXLength*(i+1);
        CGFloat markY = frameH - _contentMargin;
        [APChartTools drawLine:context startPoint:CGPointMake(markX, markY) endPoint:CGPointMake(markX, markY - markLength) lineColor:_coordinateColor lineWidth:_coordinateLineW];
        
        NSString *text = [NSString stringWithFormat:@"%@",_horizontalTitles[i]];
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:_coordinateFont}];
        CGRect rect = CGRectMake(markX - textSize.width/2, markY + _coordinateMarkTopMargin, textSize.width, textSize.height);
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
    // CGFloat arrowW = MIN(offsetXLength, offsetYLength)/2;
    CGPoint ptMaxXUp =  CGPointMake(frameW - offsetYLength/2, frameH - _contentMargin - offsetYLength/4);
    CGPoint ptMaxXDown =  CGPointMake(frameW - offsetYLength/2, frameH - _contentMargin + offsetYLength/4);
    CGPoint ptMaxYLeft =  CGPointMake(_contentMargin - offsetXLength/4, offsetXLength/2);
    CGPoint ptMaxYRight =  CGPointMake(_contentMargin + offsetXLength/4, offsetXLength/2);
    // Arrorw (X axis)
    [APChartTools drawLine:context startPoint:ptXmax endPoint:ptMaxXUp lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptXmax endPoint:ptMaxXDown lineColor:_coordinateColor lineWidth:_coordinateLineW];
    // Arrorw (Y axis)
    [APChartTools drawLine:context startPoint:ptYmax endPoint:ptMaxYLeft lineColor:_coordinateColor lineWidth:_coordinateLineW];
    [APChartTools drawLine:context startPoint:ptYmax endPoint:ptMaxYRight lineColor:_coordinateColor lineWidth:_coordinateLineW];
}

#pragma mark - Private Method
- (void)setup
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    self.chartLineDataModels = [self requestDataModelsForLineChart];
    self.horizontalTitles    = [self requestTitlesForHorizontalAxis];
    self.verticalTitles      = [self requestTitlesForVerticalAxis];
    
    
    if (_verticalTitles.count > 0) {
        self.segmentLength_x = (self.frame.size.width - _contentMargin) / (_horizontalTitles.count + 1);
        self.segmentLength_y = (self.frame.size.height - _contentMargin) / (_verticalTitles.count + 1);
    }
    else{
        self.segmentLength_x = 0.0;
        self.segmentLength_y = 0.0;
    }
    
    self.lineColors = [NSMutableArray new];
    self.lineDotMarkColors = [NSMutableArray new];
    self.singChartLines = [NSMutableArray new];
    for (NSInteger i = 0 ; i < _chartLineDataModels.count ;i++) {
        
        id lineColor = [self requestColorForLineAtIndex:i];
        id dotMarkColor = [self requestColorForLineMarkAtIndex:i];
        UIFont *dotMarkFont = [self requestFontForLineMarkAtIndex:i];
        
        APSingleChartLine *singleLine = [[APSingleChartLine alloc] initWithFrame:self.bounds];
        [singleLine setup];
        [singleLine setupLineColor:lineColor];
        singleLine.dotMarkColor = dotMarkColor;
        singleLine.dotMarkFont = dotMarkFont;
        singleLine.contentMargin = _contentMargin;
        singleLine.lineWidth = _lineChartWidth;
        singleLine.lineDotRadius = _lineDotRadius;
        singleLine.dotMarkTopMargin = _lineDotMarkTopMargin;
        singleLine.dotMarkBottomMargin = _lineDotMarkBottomMargin;
        singleLine.isDotMarkDrawingEnabled = _isDotMarkDrawingEnabled;
        singleLine.lineAnimarionDuration = _lineChartAnimarionDuration;
        singleLine.segmentLength_x = _segmentLength_x;
        singleLine.segmentLength_y = _segmentLength_y;
        [singleLine setupLineModels:_chartLineDataModels[i]];
        [self addSubview:singleLine];
        [self.singChartLines addObject:singleLine];
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

- (void)tapGrestureClick:(UITapGestureRecognizer *)tapGesture {
    
    for (APSingleChartLine *lineView in _singChartLines) {
        
        CGPoint touchPoint = [tapGesture locationInView:lineView];
        //遍历当前视图上的子视图的presentationLayer 与点击的点是否有交集
        if ([lineView.linePath containsPoint:touchPoint]) {
            //            NSLog(@"linePath Clicked!!!");
        }
        if ([lineView.dotPath containsPoint:touchPoint]) {
            //            NSLog(@"dotPath Clicked!!!");
            [lineView.gradientLineLayer addTwinkleAnimationWithDuration:0.3 repeatCount:3];
            [lineView.gradientDotLayer addTwinkleAnimationWithDuration:0.3 repeatCount:3];
        }
    }
}

#pragma mark - Request data

- (NSArray <NSArray <APLineChartDataModel *> *> *)requestDataModelsForLineChart
{
    NSArray *dataModels;
    if ([self.dataSource respondsToSelector:@selector(dataModelsForLineChart:)])
    {
        dataModels = [self.dataSource dataModelsForLineChart:self];
    }
    return dataModels;
}

- (id)requestColorForLineAtIndex:(NSInteger)lineIndex
{
    UIColor *chartLineColor;
    if ([self.dataSource respondsToSelector:@selector(lineChart:colorForLineAtIndex:)])
    {
        chartLineColor = [self.dataSource lineChart:self colorForLineAtIndex:lineIndex];
    }
    return chartLineColor;
}

- (id)requestColorForLineMarkAtIndex:(NSInteger)lineIndex
{
    UIColor *chartLineMarkColor;
    if ([self.dataSource respondsToSelector:@selector(lineChart:colorForLineMarkAtIndex:)])
    {
        chartLineMarkColor = [self.dataSource lineChart:self colorForLineMarkAtIndex:lineIndex];
    }
    return chartLineMarkColor;
}

- (UIFont *)requestFontForLineMarkAtIndex:(NSInteger)lineIndex
{
    UIFont *chartLineMarkFont;
    if ([self.dataSource respondsToSelector:@selector(lineChart:fontForLineMarkAtIndex:)])
    {
        chartLineMarkFont = [self.dataSource lineChart:self fontForLineMarkAtIndex:lineIndex];
    }
    return chartLineMarkFont;
}

- (NSArray<NSString*> *)requestTitlesForHorizontalAxis
{
    NSArray<NSString*> *horizontalTitles = @[];
    if ([self.dataSource respondsToSelector:@selector(titlesForHorizontalAxisInLineChart:)])
    {
        horizontalTitles = [self.dataSource titlesForHorizontalAxisInLineChart:self];
    }
    return horizontalTitles;
}

- (NSArray<NSString*> *)requestTitlesForVerticalAxis
{
    NSArray<NSString*> *verticalTitles = @[];
    if ([self.dataSource respondsToSelector:@selector(titlesForVerticalAxisInLineChart:)])
    {
        verticalTitles = [self.dataSource titlesForVerticalAxisInLineChart:self];
    }
    return verticalTitles;
}

@end
