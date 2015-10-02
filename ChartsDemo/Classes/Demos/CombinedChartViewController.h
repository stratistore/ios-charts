//
//  CombinedChartViewController.h
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

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"
#import <Charts/Charts.h>

@interface CombinedChartViewController : DemoBaseViewController

// added
//@property (nonatomic, strong) NSString *weightData;
#pragma mark - Data Received Variables
@property (nonatomic) NSString *weightData;
@property (nonatomic) NSString *activeCaloriesData;
@property (nonatomic) NSString *restingCaloriesData;
@property (nonatomic) NSString *totalCaloriesData;
@property (nonatomic) NSString *netCaloriesData;
@property (nonatomic) NSString *consumedCaloriesData;
@property (nonatomic) NSString *stepData;

@end
