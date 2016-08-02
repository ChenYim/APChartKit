//
//  APPieChart.h
//  ChartDemo
//
//  Created by ChenYim on 16/7/25.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APPieChartDataSource;

@interface APPieChart : UIView

@property (nonatomic, assign) CGFloat pieWidth;                     // default: MIN(frameW, frameH)/3
@property (nonatomic, assign) CGFloat pieAnimarionDuration;         // default: 3.0
@property (nonatomic, assign) BOOL isTapGestureInteractionEnabled;  // default:false

- (id)initWithFrame:(CGRect)frame andDataSource:(id<APPieChartDataSource>)dataSource;
- (void)updatePieChartDatas;
- (void)startPieAnimations;

@end

@protocol APPieChartDataSource <NSObject>

@required
- (NSArray <NSNumber*>*)dataModelsForPieChart:(APPieChart *)pieChart; // Number : 0.0 ~ 1.0

@optional

/** @return UIColor |  NSArray<UIColor*>* */
- (id)pieChart:(APPieChart *)pieChart colorForPieAtIndex:(NSInteger)pieIndex;

- (NSString *)pieChart:(APPieChart *)pieChart titleForPieMarkAtIndex:(NSInteger)pieIndex;

/** @return UIColor |  NSArray<UIColor*>* */
- (id)pieChart:(APPieChart *)pieChart colorForPieMarkAtIndex:(NSInteger)pieIndex;

- (UIFont *)pieChart:(APPieChart *)pieChart fontForPieMarkAtIndex:(NSInteger)pieIndex;
@end