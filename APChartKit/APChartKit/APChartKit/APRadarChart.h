//
//  APRadarChart.h
//  APChartKit
//
//  Created by ChenYim on 16/8/3.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    APRadarChartTitleStyle_Hidden,
    APRadarChartTitleStyle_NormalSurrounded,
    APRadarChartTitleStyle_RotateSurrounded
} APRadarChartTitleStyle;

@protocol APRadarChartDataSource;

@interface APRadarChart : UIView

@property (nonatomic, assign) BOOL isTapGestureInteractionEnabled;      // default: false
@property (nonatomic, assign) CGFloat radarAnimarionDuration;           // default: 3.0f
@property (nonatomic, assign) CGFloat radarPolygonOpacity;              // default: 0.5f
@property (nonatomic, assign) APRadarChartTitleStyle titleStyle;        // default: APRadarChartTitleType_NormalSurrounded
@property (nonatomic, assign) CGFloat titleCircleRadiusPlus;            // default: 0.0f
@property (nonatomic, assign) CGFloat originStartAngle;                 // default: (M_PI_2 * -1)
@property (nonatomic, strong) UIColor *mapColor;                        // default: [UIColor colorWithWhite:0.7 alpha:1.0]

- (id)initWithFrame:(CGRect)frame andDataSource:(id<APRadarChartDataSource>)dataSource;
- (void)updateRadarChartDatas;
- (void)startRadarAnimation;
@end

@protocol APRadarChartDataSource <NSObject>

@required
- (NSArray<NSNumber*>*)dataModelsForRadarChart:(APRadarChart *)radarChart;
- (NSInteger)numberOfDirectionMarkForRadarChart:(APRadarChart *)radarChart;
- (CGFloat)radiusOfDirectionForRadarChart:(APRadarChart *)radarChart;
@optional
- (NSString *)radarChart:(APRadarChart *)radarChart titleAtDirectionIndex:(NSInteger)directionIndex;
- (UIColor *)radarChart:(APRadarChart *)radarChart titleColorAtDirectionIndex:(NSInteger)directionIndex;    // default: [UIColor blackColor]
- (UIFont *)radarChart:(APRadarChart *)radarChart titleFontAtDirectionIndex:(NSInteger)directionIndex;      // default: [UIFont systemFontOfSize:15.0]
@end
