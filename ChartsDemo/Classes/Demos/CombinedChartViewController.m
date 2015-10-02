//
//  CombinedChartViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

#import "CombinedChartViewController.h"
#import "ChartsDemo-Swift.h"

#define ITEM_COUNT 7 //28 //12

@interface CombinedChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet CombinedChartView *chartView;

// added
//@property (nonatomic, strong) NSString *chartData1;



@end

@implementation CombinedChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Combined Chart";
    
    self.options = @[
                     @{@"key": @"toggleLineValues", @"label": @"Toggle Line Values"},
                     @{@"key": @"toggleBarValues", @"label": @"Toggle Bar Values"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBarShadowEnabled = NO;
    
    _chartView.drawOrder = @[
                             @(CombinedChartDrawOrderBar),
                             @(CombinedChartDrawOrderCandle),
                             @(CombinedChartDrawOrderBubble),
                             @(CombinedChartDrawOrderLine),
                             @(CombinedChartDrawOrderScatter)
                             ];
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = YES;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBothSided;
    
    CombinedChartData *data = [[CombinedChartData alloc] initWithXVals:weekdays]; // months];//days];
    data.lineData = [self generateLineData];
    data.barData = [self generateBarData];
    data.bubbleData = [self generateBubbleData];
    data.scatterData = [self generateScatterData];
    //data.candleData = [self generateCandleData];
    
    _chartView.data = data;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleLineValues"])
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            if ([set isKindOfClass:LineChartDataSet.class])
            {
                set.drawValuesEnabled = !set.isDrawValuesEnabled;
            }
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleBarValues"])
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            if ([set isKindOfClass:BarChartDataSet.class])
            {
                set.drawValuesEnabled = !set.isDrawValuesEnabled;
            }
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"saveToGallery"])
    {
        [_chartView saveToCameraRoll];
    }
}


#pragma mark - [Weight] LineChartData
- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {

//        // Do any additional setup after loading the view.
//        AAPLEnergyViewController *svc = [self.tabBarController.viewControllers objectAtIndex:2];
//
//        svc.delegate = self;
//
//
//







        //NSString *stringWithBackslash = svc.chartData1; //

        NSString *stringWithBackslash = @"273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,267,273,273,273,273,400";


        NSMutableArray *BarChartDataAsStrings = [NSMutableArray arrayWithArray:[ stringWithBackslash componentsSeparatedByString:@","]];


        NSString *tempSt = BarChartDataAsStrings[index];
        // self.title = tempSt;  CONVERT STRING TO DOUBLE THEN ADD TO VAL.
        double val = [tempSt doubleValue];//(double) 3.0;






        [entries addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:index]];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:entries label:@"Line DataSet"];
    [set setColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.lineWidth = 2.5;
    [set setCircleColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.fillColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.drawCubicEnabled = YES;
    set.drawValuesEnabled = YES;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    set.valueTextColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1.f];
    
    set.axisDependency = AxisDependencyRight;
    
    [d addDataSet:set];
    
    return d;
}


#pragma mark - [Cal Burnt] BarChartData
- (BarChartData *)generateBarData
{
    BarChartData *d = [[BarChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
       NSString *stringWithBackslash = @"3887,3298,3524,3022,4556,3755,4634,5146,4864,4863,5208,3992,5481,4446,3967,4675,4322,4449,4928,3900,3608,4290,4673,3201,3604,4449,3634,3339,2414,3201,3604,4449,3634,3339,2414";
        NSMutableArray *BarChartDataAsStrings = [NSMutableArray arrayWithArray:[ stringWithBackslash componentsSeparatedByString:@","]];


        NSString *tempSt = BarChartDataAsStrings[index];
        // self.title = tempSt;  CONVERT STRING TO DOUBLE THEN ADD TO VAL.
        double val = [tempSt doubleValue];//(double) 3.0;

        [entries addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:index]];
    }
    
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithYVals:entries label:@"Bar DataSet"];
    [set setColor:[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f]];
    set.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set.valueFont = [UIFont systemFontOfSize:10.f];
    
    set.axisDependency = AxisDependencyLeft;
    
    [d addDataSet:set];
    
    return d;
}

#pragma mark - [Cal Delta] ScatterChartData
- (ScatterChartData *)generateScatterData
{
    ScatterChartData *d = [[ScatterChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        // [entries addObject:[[ChartDataEntry alloc] initWithValue:(arc4random_uniform(20) + 15) xIndex:index]];

        NSString *stringWithBackslash = @"598,746,730,-22,1802,1011,1483,2124,2472,2289,3080,-539,3392,1410,2094,2393,2178,2085,2459,727,1295,2098,2801,868,1460,579,1045,634,2414,1460,579,1045,634,2414";
        //@"3289,2552,2794,3044,2754,2744,3151,1234,2552,2794,3044,2754,2744,3151,1234";


        NSMutableArray *BarChartDataAsStrings = [NSMutableArray arrayWithArray:[ stringWithBackslash componentsSeparatedByString:@","]];


        NSString *tempSt = BarChartDataAsStrings[index];
        // self.title = tempSt;  CONVERT STRING TO DOUBLE THEN ADD TO VAL.
        double val = [tempSt doubleValue];//(double) 3.0;

        [entries addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:index]];

    }
    
    ScatterChartDataSet *set = [[ScatterChartDataSet alloc] initWithYVals:entries label:@"Scatter DataSet"];
    [set setColor:[UIColor greenColor]];
    set.scatterShapeSize = 17.5;
    [set setDrawValuesEnabled:YES];
    set.valueFont = [UIFont systemFontOfSize:10.f];
    
    [d addDataSet:set];
    
    return d;
}

#pragma mark - [      ] CandleChartData
- (CandleChartData *)generateCandleData
{
    CandleChartData *d = [[CandleChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        [entries addObject:[[CandleChartDataEntry alloc] initWithXIndex:index shadowH:170.0 shadowL:5.0 open:1963.3 close:4142.4]];

        

    }
    
    CandleChartDataSet *set = [[CandleChartDataSet alloc] initWithYVals:entries label:@"Candle DataSet"];
    [set setColor:[UIColor colorWithRed:80/255.f green:80/255.f blue:80/255.f alpha:1.f]];
    set.bodySpace = 0.3;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    set.valueTextColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:8/255.f alpha:1.f];
    [set setDrawValuesEnabled:NO]; //NO
    set.axisDependency = AxisDependencyLeft;
    [d addDataSet:set];
    
    return d;
}

#pragma mark - [Cal In] BubbleChartData
- (BubbleChartData *)generateBubbleData
{
    BubbleChartData *bd = [[BubbleChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        //NSString *stringWithBackslash = @"3887,3298,3524,3022,4556,3755,4634,5146,4864,4863,5208,3992,5481,4446,3967,4675,4322,4449,4928,3900,3608,4290,4673,3201,3604,4449,3634,3339,2414";
        NSString *stringWithBackslash = @"2552,2794,3044,2754,2744,3151,3234,2552,2794,3044,2754,2744,3151,2552,2794,3044,2754,2744,3151,3234,2552,2794,3044,2754,2744,3151,2552,2794,3044,2754,2744,3151";
        


        NSMutableArray *BarChartDataAsStrings = [NSMutableArray arrayWithArray:[ stringWithBackslash componentsSeparatedByString:@","]];


        NSString *tempSt = BarChartDataAsStrings[index];
        // self.title = tempSt;  CONVERT STRING TO DOUBLE THEN ADD TO VAL.
        double rnd = [tempSt doubleValue];//(double) 3.0;





        // double rnd = arc4random_uniform(20) + 30.f;
        [entries addObject:[[BubbleChartDataEntry alloc] initWithXIndex:index value:rnd size:30.0]];//rnd]];
    }
    
    BubbleChartDataSet *set = [[BubbleChartDataSet alloc] initWithYVals:entries label:@"Bubble DataSet"];
    //[set setColors:ChartColorTemplates.vordiplom];
    set.valueTextColor = UIColor.blackColor;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    [set setDrawValuesEnabled:NO];
    
    [bd addDataSet:set];
    
    return bd;
}

#pragma mark - [      ] ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
