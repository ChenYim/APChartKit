//
//  APRadarChart.m
//  APChartKit
//
//  Created by ChenYim on 16/8/3.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "APRadarChart.h"
#import "APChartTools.h"

#define APRadarChartOriginStartAngle (self.originStartAngle)
#define APRadarChartDefaultColor [UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0]

#pragma mark - APRadarPolygon -
@interface APRadarPolygon : UIView

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *shapeLayerPath;
@property (nonatomic, assign) CGFloat radarAnimarionDuration;
@property (nonatomic, assign) CGFloat radarPolygonOpacity;
@end

@implementation APRadarPolygon

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupPolygonLayer
{
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = _shapeLayerPath.CGPath;
    self.shapeLayer.strokeColor = APRadarChartDefaultColor.CGColor;
    self.shapeLayer.fillColor = [APRadarChartDefaultColor CGColor];
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.shouldRasterize = YES;
    self.shapeLayer.opacity = _radarPolygonOpacity;
    [self.layer addSublayer:_shapeLayer];
}

- (void)startAnimation
{
    CGFloat centerX = self.frame.size.width/2;
    CGFloat centerY = self.frame.size.height/2;
    
    CABasicAnimation *animateScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animateScale.fromValue = [NSNumber numberWithFloat:0.f];
    animateScale.toValue = [NSNumber numberWithFloat:1.0f];
    
    CABasicAnimation *animateMove = [CABasicAnimation animationWithKeyPath:@"position"];
    animateMove.fromValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
    animateMove.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    
    CABasicAnimation *animateAlpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animateAlpha.fromValue = [NSNumber numberWithFloat:0.f];
    animateAlpha.toValue = [NSNumber numberWithFloat:_radarPolygonOpacity];
    
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = _radarAnimarionDuration;
    aniGroup.repeatCount = 1;
    aniGroup.animations = [NSArray arrayWithObjects:animateScale,animateMove,animateAlpha, nil];
    aniGroup.removedOnCompletion = YES;
    
    [_shapeLayer addAnimation:aniGroup forKey:nil];
}


@end

#pragma mark - APRadarChart -
@interface APRadarChart()

@property (nonatomic, strong) NSArray<NSNumber*> *dataModels;
@property (nonatomic, assign) NSInteger numOfDirection;
@property (nonatomic, assign) NSInteger numOfDirectionMark;
@property (nonatomic, assign) CGFloat directionRangeLength;         // default: MIN(frameW, frameH)/2;

@property (nonatomic, strong) NSArray<NSString*>* titlesAtEachDirection;
@property (nonatomic, strong) NSArray *titleFontAtEachDirection;
@property (nonatomic, strong) NSArray *titleColorAtEachDirection;
@property (nonatomic, strong) NSArray<NSNumber*>* anglesAtEachDirection;
@property (nonatomic, weak) id<APRadarChartDataSource> dataSource;

@property (nonatomic, strong) NSMutableArray<APRadarPolygon*> *radarPolygonViews;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation APRadarChart

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

    }
    return self;
}

#pragma mark - Public Method
- (id)initWithFrame:(CGRect)frame andDataSource:(id<APRadarChartDataSource>)dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataSource = dataSource;
        self.backgroundColor = [UIColor clearColor];
        self.radarPolygonViews = [NSMutableArray new];
        _isTapGestureInteractionEnabled = false;
        _radarAnimarionDuration = 3.0;
        _radarPolygonOpacity = 0.5;
        _titleStyle = APRadarChartTitleStyle_NormalSurrounded;
        _titleCircleRadiusPlus = 0.0;
        _originStartAngle = (M_PI_2 * -1);
        _mapColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
    
    return self;
}

- (void)updateRadarChartDatas
{
    [self setup];
}

- (void)startRadarAnimation
{
    for (APRadarPolygon *radarPolygon in _radarPolygonViews) {
        [radarPolygon removeFromSuperview];
    }
    
    // radarPolygonView
    UIBezierPath *bezierPathOfRadarPolygon = [UIBezierPath bezierPath];
    bezierPathOfRadarPolygon.lineWidth = 0.0;
    for (NSInteger i = 0 ; i < _numOfDirection ;i++)
    {
        CGFloat directionLengthPercent = [[_dataModels objectAtIndex:i] floatValue];
        
        CGPoint extremePt = [[self getPointByDirectionIndex:i andDirectionLengthPercent:directionLengthPercent] CGPointValue];
        if (i == 0){
            [bezierPathOfRadarPolygon moveToPoint:extremePt];
        }
        else if (i == (_numOfDirection-1)){
            [bezierPathOfRadarPolygon addLineToPoint:extremePt];
            directionLengthPercent = [[_dataModels objectAtIndex:0] floatValue];
            CGPoint firstExtremePt = [[self getPointByDirectionIndex:0 andDirectionLengthPercent:directionLengthPercent] CGPointValue];
            [bezierPathOfRadarPolygon addLineToPoint:firstExtremePt];
        }
        else{
            [bezierPathOfRadarPolygon addLineToPoint:extremePt];
        }
    }
    [bezierPathOfRadarPolygon closePath];
    
    APRadarPolygon *radarPolygonView = [[APRadarPolygon alloc] initWithFrame:self.bounds];
    radarPolygonView.radarAnimarionDuration = _radarAnimarionDuration;
    radarPolygonView.radarPolygonOpacity = _radarPolygonOpacity;
    radarPolygonView.shapeLayerPath = bezierPathOfRadarPolygon;
    [radarPolygonView setupPolygonLayer];
    [self addSubview:radarPolygonView];
    [self.radarPolygonViews addObject:radarPolygonView];
    
    for (APRadarPolygon *radarPolygon in _radarPolygonViews) {
        [radarPolygon startAnimation];
    }
}

#pragma mark - Private Method
- (void)setup
{
    self.dataModels           = [self requestDataModelsForRadarChart];
    self.numOfDirection       = [_dataModels count];
    self.numOfDirectionMark   = [self requestNumberOfDirectionMarkForRadarChart];
    self.directionRangeLength = [self requestradiusOfDirectionForRadarChart];
    
    NSMutableArray *temp_Titles = [NSMutableArray new];
    NSMutableArray *temp_TitleColors = [NSMutableArray new];
    NSMutableArray *temp_TitleFonts = [NSMutableArray new];
    for (NSInteger i = 0 ; i < _numOfDirection ;i++) {
        [temp_Titles addObject:[self requestTitleAtDirectionIndex:i]];
        [temp_TitleColors addObject:[self requestTitleColorAtDirectionIndex:i]];
        [temp_TitleFonts addObject:[self requestTitleFontAtDirectionIndex:i]];
    }
    self.titlesAtEachDirection = [temp_Titles copy];
    self.titleColorAtEachDirection = [temp_TitleColors copy];
    self.titleFontAtEachDirection = [temp_TitleFonts copy];
    
    CGFloat angleOffset = M_PI*2/_numOfDirection;
    NSMutableArray *temp_Angles = [NSMutableArray new];
    for (NSInteger i = 0 ; i < _numOfDirection ;i++) {
        [temp_Angles addObject:@(APRadarChartOriginStartAngle + angleOffset * i)];
    }
    self.anglesAtEachDirection = [temp_Angles copy];
    
    [self setupDirectionTitles];
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
    for (APRadarPolygon *radarPolygon in _radarPolygonViews) {
        
        CGPoint touchPoint = [tapGesture locationInView:radarPolygon];
        
        if ([radarPolygon.shapeLayerPath containsPoint:touchPoint]) {
            
            [radarPolygon.shapeLayer addTwinkleAnimationWithDuration:0.5 repeatCount:3];
        }
    }
}

- (NSValue *)getPointByDirectionIndex:(NSInteger)directionIdx andDirectionLengthPercent:(CGFloat)directionLengthPercent
{
    CGFloat centerX = self.frame.size.width/2;
    CGFloat centerY = self.frame.size.height/2;
    
    CGFloat angleValue = [[_anglesAtEachDirection objectAtIndex:directionIdx] floatValue];
    CGFloat directionLength = _directionRangeLength * directionLengthPercent;
    CGPoint thePoint = CGPointMake(centerX + directionLength*cos(angleValue), centerY + directionLength*sin(angleValue));
    return [NSValue valueWithCGPoint:thePoint];
}

- (void)setupDirectionTitles
{
    for (NSInteger i = 0 ; i < _numOfDirection ;i++)
    {
        UILabel *label      = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
        label.shadowColor   = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font          = _titleFontAtEachDirection[i];;
        label.text          = _titlesAtEachDirection[i];
        [label sizeToFit];
        [self addSubview:label];
        
        CGFloat titleCircleRadius = 0.0;
        switch (_titleStyle) {
            case APRadarChartTitleStyle_Hidden:{
                titleCircleRadius = _directionRangeLength + _titleCircleRadiusPlus;
            }break;
            case APRadarChartTitleStyle_NormalSurrounded:{
                titleCircleRadius = _directionRangeLength + CGRectGetHeight(label.frame)/2 + _titleCircleRadiusPlus;
            }break;
            case APRadarChartTitleStyle_RotateSurrounded:{
                titleCircleRadius = _directionRangeLength + CGRectGetHeight(label.frame)/2 + _titleCircleRadiusPlus;
            }break;
        }
        
        CGFloat theAngle = [_anglesAtEachDirection[i] floatValue];
        CGFloat centerX = self.frame.size.width/2;
        CGFloat centerY = self.frame.size.height/2;
        CGFloat x = centerX + titleCircleRadius *cos(theAngle);
        CGFloat y = centerY + titleCircleRadius *sin(theAngle);
        CGSize detailSize = label.frame.size;
        
        switch (_titleStyle) {
            case APRadarChartTitleStyle_Hidden:{
                label.center = CGPointMake(x, y);
                label.transform = CGAffineTransformMakeRotation(theAngle+M_PI_2);
                label.hidden = YES;
            }
                break;
            case APRadarChartTitleStyle_NormalSurrounded:{
                if (x < centerX) {
                    label.frame = CGRectMake(x-detailSize.width, y-detailSize.height/2, detailSize.width, detailSize.height);
                    label.textAlignment = NSTextAlignmentRight;
                }else{
                    label.frame = CGRectMake(x, y-detailSize.height/2, detailSize.width , detailSize.height);
                    label.textAlignment = NSTextAlignmentLeft;
                }
            }
                break;
            case APRadarChartTitleStyle_RotateSurrounded:{
                label.center = CGPointMake(x, y);
                label.transform = CGAffineTransformMakeRotation(theAngle+M_PI_2);
            }
                break;
        }
    }
}

-(void)drawRect:(CGRect)rect
{
    [_mapColor setStroke];
    
    CGFloat centerX = rect.size.width/2;
    CGFloat centerY = rect.size.height/2;
    
    // polygonLoop
    for (NSInteger i = 0 ; i < _numOfDirectionMark ;i++) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineWidth = 1.0;
        CGFloat directionLengthPercent = (i + 1.f)/_numOfDirectionMark;
        for (NSInteger j = 0 ; j < _numOfDirection ;j++)
        {
            CGPoint extremePt = [[self getPointByDirectionIndex:j andDirectionLengthPercent:directionLengthPercent] CGPointValue];
            if (j == 0){
                [bezierPath moveToPoint:extremePt];
            }
            else if (j == (_numOfDirection-1)){
                [bezierPath addLineToPoint:extremePt];
                CGPoint firstExtremePt = [[self getPointByDirectionIndex:0 andDirectionLengthPercent:directionLengthPercent] CGPointValue];
                [bezierPath addLineToPoint:firstExtremePt];
            }
            else{
                [bezierPath addLineToPoint:extremePt];
            }
        }
        [bezierPath stroke];
    }
    
    // lines
    for (NSInteger i = 0 ; i < _anglesAtEachDirection.count ;i++) {
        CGPoint extremePt = [[self getPointByDirectionIndex:i andDirectionLengthPercent:1.0] CGPointValue];
        UIBezierPath *bezierPath2 = [UIBezierPath bezierPath];
        [bezierPath2 moveToPoint:CGPointMake(centerX, centerY)];
        [bezierPath2 addLineToPoint:extremePt];
        [bezierPath2 stroke];
    }
}

#pragma mark - RequestData
- (NSArray<NSNumber*> *)requestDataModelsForRadarChart
{
    NSArray<NSNumber*> *dataModels = 0;
    if ([self.dataSource respondsToSelector:@selector(dataModelsForRadarChart:)])
    {
        dataModels = [self.dataSource dataModelsForRadarChart:self];
    }
    return dataModels;
}

- (NSInteger)requestNumberOfDirectionMarkForRadarChart
{
    NSInteger numOfDirectionMark = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfDirectionMarkForRadarChart:)])
    {
        numOfDirectionMark = MAX([self.dataSource numberOfDirectionMarkForRadarChart:self], numOfDirectionMark);
    }
    return numOfDirectionMark;
}

- (CGFloat)requestradiusOfDirectionForRadarChart
{
    CGFloat directionRadius = MIN(self.frame.size.width, self.frame.size.height)/2;
    if ([self.dataSource respondsToSelector:@selector(radiusOfDirectionForRadarChart:)])
    {
        directionRadius = [self.dataSource radiusOfDirectionForRadarChart:self];
    }
    return directionRadius;
}

- (NSString *)requestTitleAtDirectionIndex:(NSInteger)directionIndex
{
    NSString *title = 0;
    if ([self.dataSource respondsToSelector:@selector(radarChart:titleAtDirectionIndex:)])
    {
        title = [self.dataSource radarChart:self titleAtDirectionIndex:directionIndex];
    }
    return title;
}

- (UIFont *)requestTitleFontAtDirectionIndex:(NSInteger)directionIndex
{
    UIFont *titleFont = [UIFont systemFontOfSize:15.0];
    if ([self.dataSource respondsToSelector:@selector(radarChart:titleFontAtDirectionIndex:)])
    {
        titleFont = [self.dataSource radarChart:self titleFontAtDirectionIndex:directionIndex];
    }
    return titleFont;
}

- (UIColor *)requestTitleColorAtDirectionIndex:(NSInteger)directionIndex
{
    UIColor *titleColor = [UIColor blackColor];
    if ([self.dataSource respondsToSelector:@selector(radarChart:titleColorAtDirectionIndex:)])
    {
        titleColor = [self.dataSource radarChart:self titleColorAtDirectionIndex:directionIndex];
    }
    return titleColor;
}
@end
