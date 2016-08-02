//
//  APLineChart.h
//  ChartDemo
//
//  Created by ChenYim on 16/7/20.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APLineChartDataModel : NSObject
@property (nonatomic, readonly, assign) CGFloat xValuePercent;
@property (nonatomic, readonly, assign) CGFloat yValuePercent;
@property (nonatomic, readonly, copy) NSString *dotMarkStr;
+ (instancetype)modelWithxValuePercent:(CGFloat)xValuePercent yValuePercent:(CGFloat)yValuePercent dotMarkStr:(NSString *)dotMarkStr;
@end

@protocol APLineChartDataSource;
@interface APLineChart : UIView

@property (nonatomic, assign) CGFloat coordinateLineW;          // default:0.5
@property (nonatomic, strong) UIColor *coordinateColor;         // default:[UIColor grayColor]
@property (nonatomic, strong) UIFont *coordinateFont;           // default:[UIFont systemFontOfSize:5.0]
@property (nonatomic, assign) CGFloat coordinateMarkRightMargin;// default:3.0
@property (nonatomic, assign) CGFloat coordinateMarkTopMargin;  // default:3.0

@property (nonatomic, assign) CGFloat lineChartWidth;           // default:0.5;
@property (nonatomic, assign) CGFloat lineDotRadius;            // default:2.5;
@property (nonatomic, assign) CGFloat lineDotMarkTopMargin;     // default:1.0;
@property (nonatomic, assign) CGFloat lineDotMarkBottomMargin;  // default:1.0;

@property (nonatomic, assign) CGFloat contentMargin;                // default:0.0
@property (nonatomic, assign) CGFloat lineChartAnimarionDuration;   // default:2.0
@property (nonatomic, assign) BOOL isDotMarkDrawingEnabled;         // default:false
@property (nonatomic, assign) BOOL isTapGestureInteractionEnabled;  // default:false

- (id)initWithFrame:(CGRect)frame andDataSource:(id <APLineChartDataSource>)dataSource;
- (void)updateLineChartDatas;
- (void)startLineAnimations;

@end


@protocol APLineChartDataSource <NSObject>

@required
- (NSArray <NSArray <APLineChartDataModel *> *> *)dataModelsForLineChart:(APLineChart *)lineChart;

@optional

/** @return UIColor |  NSArray<UIColor*>* */
- (id)lineChart:(APLineChart *)lineChart colorForLineAtIndex:(NSInteger)lineIndex;

/** @return UIColor |  NSArray<UIColor*>* */
- (id)lineChart:(APLineChart *)lineChart colorForLineMarkAtIndex:(NSInteger)lineIndex;


- (UIFont *)lineChart:(APLineChart *)lineChart fontForLineMarkAtIndex:(NSInteger)lineIndex;

- (NSArray<NSString*>*)titlesForHorizontalAxisInLineChart:(APLineChart *)lineChart;
- (NSArray<NSString*>*)titlesForVerticalAxisInLineChart:(APLineChart *)lineChart;
@end
