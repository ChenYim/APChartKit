//
//  ViewController.m
//  APChartKit
//
//  Created by ChenYim on 16/8/2.
//  Copyright © 2016年 ChenYim. All rights reserved.
//

#import "ViewController.h"

#import "APChartKit.h"

@interface ViewController ()<APLineChartDataSource,APBarChartDataSource,APPieChartDataSource,APRadarChartDataSource>

@property (nonatomic, strong) NSArray<NSArray<APLineChartDataModel*>*> * lineChartDatas;
@property (nonatomic, strong) APLineChart *lineChar;
@property (nonatomic, strong) APBarChart  *barChart;
@property (nonatomic, strong) APPieChart  *pieChart;
@property (nonatomic, strong) APRadarChart  *radarChart;
@property (nonatomic, strong) UIButton *updateAnimationBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    
    [self setupLineChartViewDatas];
    
    // lineChart
    self.lineChar = [[APLineChart alloc] initWithFrame:CGRectZero andDataSource:self];
    self.lineChar.contentMargin = 12.0;
    self.lineChar.lineChartAnimarionDuration = 3.0;
    self.lineChar.lineChartWidth = 1.0;
    self.lineChar.isDotMarkDrawingEnabled = YES;
    self.lineChar.isTapGestureInteractionEnabled = YES;
    [self.view addSubview:_lineChar];
    
    // barChart
    self.barChart = [[APBarChart alloc] initWithFrame:CGRectZero andDataSource:self];
    self.barChart.contentMargin = 12.0;
    self.barChart.markBottomMargin = 0.0;
    self.barChart.barAnimarionDuration = 3.0;
    self.barChart.isTapGestureInteractionEnabled = YES;
//    self.barChart.barShadowColor = [UIColor grayColor];
    [self.view addSubview:_barChart];
    
    // pieChart
    self.pieChart = [[APPieChart alloc] initWithFrame:CGRectZero andDataSource:self];
    self.pieChart.pieAnimarionDuration = 3.0;
    self.pieChart.pieWidth = 70;
    self.pieChart.isTapGestureInteractionEnabled = YES;
    [self.view addSubview:_pieChart];
    
    // radarChart
    self.radarChart = [[APRadarChart alloc] initWithFrame:CGRectZero andDataSource:self];
    self.radarChart.isTapGestureInteractionEnabled = YES;
    self.radarChart.originStartAngle = (M_PI_2/3*2 * -1);
    [self.view addSubview:_radarChart];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:APColor_DeepGreen forState:UIControlStateNormal];
    [button setTitle:@"updateCharts" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    self.updateAnimationBtn = button;
    [self.view addSubview:_updateAnimationBtn];
    
    //    _lineChar.layer.borderWidth = 1.0;
    //    _lineChar.layer.borderColor = [UIColor redColor].CGColor;
    //    _barChart.layer.borderWidth = 1.0;
    //    _barChart.layer.borderColor = [UIColor redColor].CGColor;
    //    _pieChart.layer.borderWidth = 1.0;
    //    _pieChart.layer.borderColor = [UIColor redColor].CGColor;
    //    _radarChart.layer.borderWidth = 1.0;
    //    _radarChart.layer.borderColor = [UIColor redColor].CGColor;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat frameW = self.view.frame.size.width;
    CGFloat separateMargin = 10.0;
    
    _lineChar.frame = CGRectMake(separateMargin, 150, (frameW - separateMargin * 3)*0.5, (frameW - separateMargin * 3)*0.5);
    _barChart.frame = CGRectMake(frameW*0.5 + separateMargin*0.5, 150, (frameW - separateMargin * 3)*0.5, (frameW - separateMargin * 3)*0.5);
    _pieChart.frame = CGRectMake(separateMargin, CGRectGetMaxY(_lineChar.frame) + separateMargin, (frameW - separateMargin * 3)*0.5, (frameW - separateMargin * 3)*0.5);
    _radarChart.frame = CGRectMake(frameW*0.5 + separateMargin*0.5, CGRectGetMaxY(_lineChar.frame) + separateMargin, (frameW - separateMargin * 3)*0.5, (frameW - separateMargin * 3)*0.5);
    _updateAnimationBtn.frame = CGRectMake(50, CGRectGetMaxY(_pieChart.frame)+separateMargin, CGRectGetWidth(_updateAnimationBtn.frame), CGRectGetHeight(_updateAnimationBtn.frame));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateAllChartDatas];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [_lineChar startLineAnimations];
            [_barChart startBarAnimations];
            [_pieChart startPieAnimations];
            [_radarChart startRadarAnimation];
        });
    });
}

#pragma mark - Private Method

- (void)updateAllChartDatas
{
    [_lineChar updateLineChartDatas];
    [_barChart updateBarChartDatas];
    [_pieChart updatePieChartDatas];
    [_radarChart updateRadarChartDatas];
}

- (void)setupLineChartViewDatas
{
    _lineChartDatas = @[
                        @[
                            [APLineChartDataModel modelWithxValuePercent:0.1 yValuePercent:0.7 dotMarkStr:@"0.7"],
                            [APLineChartDataModel modelWithxValuePercent:0.2 yValuePercent:0.8 dotMarkStr:@"0.8"],
                            [APLineChartDataModel modelWithxValuePercent:0.3 yValuePercent:0.7 dotMarkStr:@"0.7"],
                            [APLineChartDataModel modelWithxValuePercent:0.4 yValuePercent:0.8 dotMarkStr:@"0.8"],
                            [APLineChartDataModel modelWithxValuePercent:0.5 yValuePercent:0.7 dotMarkStr:@"0.7"],
                            [APLineChartDataModel modelWithxValuePercent:0.6 yValuePercent:0.0 dotMarkStr:@"0.0"],
                            [APLineChartDataModel modelWithxValuePercent:0.7 yValuePercent:0.9 dotMarkStr:@"0.9"],
                            [APLineChartDataModel modelWithxValuePercent:0.8 yValuePercent:0.9 dotMarkStr:@"0.9"],
                            [APLineChartDataModel modelWithxValuePercent:0.9 yValuePercent:1.0 dotMarkStr:@"1.0"],
                            ],
                        @[
                            [APLineChartDataModel modelWithxValuePercent:0.1 yValuePercent:0.5 dotMarkStr:@"0.5"],
                            [APLineChartDataModel modelWithxValuePercent:0.2 yValuePercent:0.4 dotMarkStr:@"0.4"],
                            [APLineChartDataModel modelWithxValuePercent:0.3 yValuePercent:0.5 dotMarkStr:@"0.5"],
                            [APLineChartDataModel modelWithxValuePercent:0.4 yValuePercent:0.6 dotMarkStr:@"0.6"],
                            [APLineChartDataModel modelWithxValuePercent:0.5 yValuePercent:0.6 dotMarkStr:@"0.6"],
                            [APLineChartDataModel modelWithxValuePercent:0.6 yValuePercent:0.4 dotMarkStr:@"0.4"],
                            [APLineChartDataModel modelWithxValuePercent:0.7 yValuePercent:0.7 dotMarkStr:@"0.7"],
                            [APLineChartDataModel modelWithxValuePercent:0.8 yValuePercent:0.5 dotMarkStr:@"0.5"],
                            [APLineChartDataModel modelWithxValuePercent:0.9 yValuePercent:0.7 dotMarkStr:@"0.7"]
                            ],
                        @[
                            [APLineChartDataModel modelWithxValuePercent:0.1 yValuePercent:0.3 dotMarkStr:@"0.3"],
                            [APLineChartDataModel modelWithxValuePercent:0.2 yValuePercent:0.6 dotMarkStr:@"0.6"],
                            [APLineChartDataModel modelWithxValuePercent:0.3 yValuePercent:0.3 dotMarkStr:@"0.3"],
                            [APLineChartDataModel modelWithxValuePercent:0.4 yValuePercent:0.3 dotMarkStr:@"0.3"],
                            [APLineChartDataModel modelWithxValuePercent:0.5 yValuePercent:0.1 dotMarkStr:@"0.1"],
                            [APLineChartDataModel modelWithxValuePercent:0.6 yValuePercent:0.5 dotMarkStr:@"0.5"],
                            [APLineChartDataModel modelWithxValuePercent:0.7 yValuePercent:0.1 dotMarkStr:@"0.1"],
                            [APLineChartDataModel modelWithxValuePercent:0.8 yValuePercent:0.5 dotMarkStr:@"0.5"],
                            [APLineChartDataModel modelWithxValuePercent:0.9 yValuePercent:0.6 dotMarkStr:@"0.6"]
                            
                            ]
                        ];
}

#pragma mark - Event Response
- (void)btnClick:(id)sender
{
    [_lineChar updateLineChartDatas];
    [_lineChar startLineAnimations];
    
    [_barChart updateBarChartDatas];
    [_barChart startBarAnimations];
    
//    [_pieChart updatePieChartDatas];
    [_pieChart startPieAnimations];
    
//    [_radarChart updateRadarChartDatas];
    [_radarChart startRadarAnimation];
}

#pragma mark - APLineChartDataSource
-(NSArray<NSArray<APLineChartDataModel *> *> *)dataModelsForLineChart:(APLineChart *)lineChart
{
    return _lineChartDatas;
}

-(id)lineChart:(APLineChart *)lineChart colorForLineAtIndex:(NSInteger)lineIndex
{
    //    GradientColor
    //    return [@[
    //              @[APColor_Grey, APColor_Red],
    //              @[APColor_Grey, APColor_DeepGreen],
    //              @[APColor_Grey, APColor_Blue]] objectAtIndex:lineIndex];
    
    return [@[APColor_Red, APColor_DeepGreen, APColor_Blue] objectAtIndex:lineIndex];
}

-(id)lineChart:(APLineChart *)lineChart colorForLineMarkAtIndex:(NSInteger)lineIndex
{
    //    GradientColor
    //    return [@[
    //              @[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3], APDefaultChartRedColor],
    //              @[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3], APDefaultChartGreenColor],
    //              @[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3], APDefaultChartBlueColor]] objectAtIndex:chartLineIndex];
    
    return [@[APColor_Red, APColor_DeepGreen, APColor_Blue] objectAtIndex:lineIndex];
}

-(UIFont *)lineChart:(APLineChart *)lineChart fontForLineMarkAtIndex:(NSInteger)lineIndex
{
    return  [UIFont systemFontOfSize:5.0];
}

-(NSArray<NSString *> *)titlesForHorizontalAxisInLineChart:(APLineChart *)lineChart
{
    return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
}

-(NSArray<NSString *> *)titlesForVerticalAxisInLineChart:(APLineChart *)lineChart
{
    return @[@"0.0",@"0.1", @"0.2", @"0.3", @"0.4", @"0.5", @"0.6", @"0.7", @"0.8", @"0.9", @"1.0"];
}



#pragma mark - APBarChartDataSource

-(NSArray<NSNumber *> *)dataModelsForBarChart:(APBarChart *)barChart
{
    return @[@(0.1), @(0.2), @(0.3), @(0.4), @(0.5), @(0.6), @(0.7), @(0.8), @(0.9), @(1.0)];
    //    return @[@(0.0)];
}

-(CGFloat)contentTopMarginForBarChart:(APBarChart *)barChart
{
    //    return 0.0;
    return 20.0;
}

-(id)barChart:(APBarChart *)barChart colorForBarAtIndex:(NSInteger)barIndex
{
    //    GradientColor
    //    return [@[
    //              @[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3], APDefaultChartRedColor],
    //              @[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3], APDefaultChartGreenColor],
    //              @[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3], APDefaultChartBlueColor]] objectAtIndex:chartLineIndex];
    
    return APColor_FreshGreen;
}

-(id)barChart:(APBarChart *)barChart colorForBarMarkAtIndex:(NSInteger)barIndex
{
    return APColor_FreshGreen;
}

-(NSString *)barChart:(APBarChart *)barChart titleForBarMarkAtIndex:(NSInteger)barIndex
{
    NSArray *titles = @[@"0.1", @"0.2", @"0.3", @"0.4", @"0.5", @"0.6", @"0.7", @"0.8", @"0.9", @"1.0"];
    return titles[barIndex];
}

-(NSArray<NSString *> *)titlesForHorizontalAxisInBarChart:(APBarChart *)barChart
{
    return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
}

-(NSArray<NSString *> *)titlesForVerticalAxisInBarChart:(APBarChart *)barChart
{
    return @[@"0.1", @"0.2", @"0.3", @"0.4", @"0.5", @"0.6", @"0.7", @"0.8", @"0.9", @"1.0"];
}

#pragma mark - APPieChartDataSource

-(NSArray<NSNumber *> *)dataModelsForPieChart:(APPieChart *)pieChart
{
    return @[@(0.3), @(0.2), @(0.5)];
}

-(id)pieChart:(APPieChart *)pieChart colorForPieAtIndex:(NSInteger)pieIndex
{
    //    GradientColor
    //    return [@[
    //              @[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3], APDefaultChartRedColor],
    //              @[[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3], APDefaultChartGreenColor],
    //              @[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3], APDefaultChartBlueColor]] objectAtIndex:chartLineIndex];
    
    return [@[APColor_Red, APColor_DeepGreen, APColor_Blue] objectAtIndex:pieIndex];
}

-(NSString *)pieChart:(APPieChart *)pieChart titleForPieMarkAtIndex:(NSInteger)pieIndex
{
    return [@[@"30%\n(value:0.3)", @"20%\n(value:0.2)", @"50%\n(value:0.5)"] objectAtIndex:pieIndex];
}

-(UIFont *)pieChart:(APPieChart *)pieChart fontForPieMarkAtIndex:(NSInteger)pieIndex
{
    return [UIFont systemFontOfSize:9.0];
}

-(id)pieChart:(APPieChart *)pieChart colorForPieMarkAtIndex:(NSInteger)pieIndex
{
    return [UIColor whiteColor];
}

#pragma mark - APRadarChartDataSource

-(NSArray<NSNumber *> *)dataModelsForRadarChart:(APRadarChart *)radarChart
{
    return @[@(0.5), @(0.6), @(0.4), @(0.9), @(0.5)];
}

-(NSInteger)numberOfDirectionMarkForRadarChart:(APRadarChart *)radarChart
{
    return 8;
}

-(CGFloat)radiusOfDirectionForRadarChart:(APRadarChart *)radarChart
{
    return 80;
}

-(NSString *)radarChart:(APRadarChart *)radarChart titleAtDirectionIndex:(NSInteger)directionIndex
{
    return [@[@"Math", @"Math", @"Art", @"Sports", @"Chinese"] objectAtIndex:directionIndex];
}

-(UIColor *)radarChart:(APRadarChart *)radarChart titleColorAtDirectionIndex:(NSInteger)directionIndex
{
    return [UIColor lightGrayColor];
}

-(UIFont *)radarChart:(APRadarChart *)radarChart titleFontAtDirectionIndex:(NSInteger)directionIndex
{
    return [UIFont systemFontOfSize:10.0];
}
@end
