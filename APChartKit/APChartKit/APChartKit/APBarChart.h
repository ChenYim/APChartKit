//
//  APBarChart.h
//  ChartDemo
//
//  Created by ChenYim on 16/7/22.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APBarChartDataSource;

@interface APBarChart : UIView

@property (nonatomic, assign) CGFloat coordinateLineW;          // default:0.5
@property (nonatomic, strong) UIColor *coordinateColor;         // default:[UIColor grayColor]
@property (nonatomic, strong) UIFont *coordinateFont;           // default:[UIFont systemFontOfSize:5.0]
@property (nonatomic, assign) CGFloat coordinateMarkRightMargin;// default:3.0
@property (nonatomic, assign) CGFloat coordinateMarkTopMargin;  // default:3.0

@property (nonatomic, assign) CGFloat contentMargin;                // default:0.0 (if contentMargin is 0.0, there will be no coordinateSystem)
@property (nonatomic, assign) CGFloat markBottomMargin;             // default:0.0

// special effect
@property (nonatomic, strong) UIColor *barShadowColor;              // default:[UIColor clearColor]
@property (nonatomic, assign) CGFloat barAnimarionDuration;         // default:1.5
@property (nonatomic, assign) BOOL isDotMarkDrawingEnabled;         // default:false
@property (nonatomic, assign) BOOL isTapGestureInteractionEnabled;  // default:false




- (id)initWithFrame:(CGRect)frame andDataSource:(id<APBarChartDataSource>)dataSource;
- (void)updateBarChartDatas;
- (void)startBarAnimations;
@end

@protocol APBarChartDataSource <NSObject>

@required
- (NSArray <NSNumber*>*)dataModelsForBarChart:(APBarChart *)barChart; // Number : 0.0 ~ 1.0

@optional
// bar ==================
/** @return UIColor |  NSArray<UIColor*>* */
- (id)barChart:(APBarChart *)barChart colorForBarAtIndex:(NSInteger)barIndex;
- (CGFloat)barChart:(APBarChart *)barChart widthForBarAtIndex:(NSInteger)barIndex;
- (CGFloat)barChart:(APBarChart *)barChart intervalForBarSpaceAtIndex:(NSInteger)BarSpaceIndex;
- (NSString *)barChart:(APBarChart *)barChart titleForBarMarkAtIndex:(NSInteger)barIndex;

// barMark ==================
/** @return UIColor |  NSArray<UIColor*>* */
- (id)barChart:(APBarChart *)barChart colorForBarMarkAtIndex:(NSInteger)barIndex;
- (UIFont *)barChart:(APBarChart *)barChart fontForBarMarkAtIndex:(NSInteger)barIndex;

// coordinateSystem ==================
- (NSArray<NSString*>*)titlesForHorizontalAxisInBarChart:(APBarChart *)barChart;
- (NSArray<NSString*>*)titlesForVerticalAxisInBarChart:(APBarChart *)barChart;
@end