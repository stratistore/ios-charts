/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

 Displays energy-related information retrieved from HealthKit.

 */

#import "AAPLEnergyViewController.h"
// @property *healthStore;

#pragma mark - AAPLExtensions
#import "HKHealthStore+AAPLExtensions.h"
// - (void)aapl_mostRecentQuantitySampleOfType:
// Fetches the single most recent quantity of the specified type.

#pragma mark - Combined Chart
#import "CombinedChartViewController.h"
// import the chart controller here
// then - define a STRING *(weightData) as a property of that object
// Create and Pass the weightData object and add each item to it with a ',' seperating to make CSV.

#pragma mark - Combined Chart - Data Received Variables Handled
// @property (nonatomic) NSString *weightData;
// @property (nonatomic) NSString *activeCaloriesData;
// @property (nonatomic) NSString *restingCaloriesData;
// @property (nonatomic) NSString *totalCaloriesData;
// @property (nonatomic) NSString *netCaloriesData;
// @property (nonatomic) NSString *consumedCaloriesData;
// @property (nonatomic) NSString *stepData;


#pragma mark - Interface Definition
@interface AAPLEnergyViewController()

#pragma mark - Labels to Display on First Screen
@property (nonatomic, weak) IBOutlet UILabel *activeEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *restingEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *consumedEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *netEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsCountedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsExplainedLabel;

#pragma mark - Energy
@property (nonatomic) double activeEnergyBurned;
@property (nonatomic) double restingEnergyBurned;
@property (nonatomic) double basalEnergyBurned;
@property (nonatomic) double energyConsumed;
@property (nonatomic) double netEnergy;

#pragma mark - Steps
@property (nonatomic) double stepsCounted;
@property (nonatomic) NSString *stepsExplained;

#pragma mark - Data Passed Variables
@property (nonatomic) NSString *weightData;
@property (nonatomic) NSString *weightDataMin;
@property (nonatomic) NSString *weightDataMax;


@property (nonatomic) NSString *activeCaloriesData;
@property (nonatomic) NSString *restingCaloriesData;
@property (nonatomic) NSString *totalCaloriesData;
@property (nonatomic) NSString *netCaloriesData;
@property (nonatomic) NSString *consumedCaloriesData;

@property (nonatomic) NSString *stepData;
@property (nonatomic) NSString *heartRateData;


@end

#pragma mark - Implementation
@implementation AAPLEnergyViewController

#pragma mark - View Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.refreshControl addTarget:self action:@selector(refreshStatistics) forControlEvents:UIControlEventValueChanged];

    [self refreshStatistics];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Deallocation
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


#pragma mark - Refresh Stats - Reading HealthKit Data
- (void)refreshStatistics {

    // used below to build CSV - nil if not set
    self.weightData             = @"weightData";
    self.weightDataMin          = @"weightDataMin";
    self.weightDataMax          = @"weightDataMax";

    self.consumedCaloriesData   = @"consumedCaloriesData";
    self.restingCaloriesData    = @"restingCaloriesData";
    // new
    self.activeCaloriesData     = @"activeCaloriesData";
    self.totalCaloriesData      = @"totalCaloriesData";
    self.netCaloriesData        = @"netCaloriesData";

    self.stepData               = @"stepData";
    self.heartRateData          = @"heartRateData";





    // order to fetch results
    [self.refreshControl beginRefreshing];
    [self getMostRecentSamples];
    [self getStepStats ];
}

#pragma mark - Most Recent Samples - Order Fetches
- (void)getMostRecentSamples
{
    HKQuantityType *energyConsumedType     = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType   = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *basalEnergyBurnType    = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    HKQuantityType *stepCountType          = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // First, fetch the sum of energy consumed samples from HealthKit. Populate this by creating your
    // own food logging app or using the food journal view controller.
    [self fetchSumOfSamplesTodayForType:energyConsumedType unit:[HKUnit jouleUnit] completion:^(double totalJoulesConsumed, NSError *error) {

        // Next, fetch the sum of active energy burned from HealthKit. Populate this by creating your
        // own calorie tracking app or the Health app.
        [self fetchSumOfSamplesTodayForType:activeEnergyBurnType unit:[HKUnit jouleUnit] completion:^(double activeEnergyBurned, NSError *error) {


            // Last replaced by this section to get basalEnergyBurn from Samples
            [self fetchSumOfSamplesTodayForType:stepCountType unit:[HKUnit countUnit] completion:^(double stepsCounted, NSError *error) {
                // Last replaced by this section to get basalEnergyBurn from Samples
                [self fetchSumOfSamplesTodayForType:basalEnergyBurnType unit:[HKUnit jouleUnit] completion:^(double basalEnergyBurned, NSError *error) {

                    //gpd former

                    NSLog (@"Completed all Fetches");

                    // Last, calculate the user's basal energy burn so far today.
                    //            [self fetchTotalBasalBurn:^(HKQuantity *basalEnergyBurn, NSError *error) {
                    //
                    //                if (!basalEnergyBurn) {
                    //                    NSLog(@"An error occurred trying to compute the basal energy burn. In your app, handle this gracefully. Error: %@", error);
                    //                }
                    //
                    // Update the UI with all of the fetched values.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.activeEnergyBurned = activeEnergyBurned;

                        self.restingEnergyBurned = basalEnergyBurned;

                        self.stepsCounted = stepsCounted;
                        self.stepsExplained = @"Last 7 Days"; // triggers setters below - not used here

                        self.energyConsumed = totalJoulesConsumed;

                        self.netEnergy = self.energyConsumed - self.activeEnergyBurned - self.restingEnergyBurned;

                        [self.refreshControl endRefreshing]; //issue plot data

                        // Unused Energy Formatter
                        // NSEnergyFormatter *energyFormatter = [self energyFormatter];
                        double tempCals = activeEnergyBurned/4184;
                        // NSNumber *calories2 = [activeEnergyBurned doubleValueForUnit:[HKUnit calorieUnit]];
                        NSLog (@"Active Burn / Steps = %.05f ",tempCals/stepsCounted);
                        NSLog (@"Steps (%.f) / Active Burn (%.f) = %.05f",stepsCounted,tempCals,stepsCounted/tempCals);

                    });
                }];
            }];
        }];
    }];
}

//#pragma mark - Most Recent Samples - Fetch Sum Of Samples Today (For Types)
- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    //    NSPredicate *predicate = [self predicateForSamplesThisQtr];
    NSPredicate *predicate = [self predicateForSamplesToday];
    //   NSPredicate *predicate = [self predicateForSamplesThisWeek];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];

        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];

            completionHandler(value, error);
        }
    }];

    [self.healthStore executeQuery:query];
}

#pragma mark - HKStatisticsCollectionQuery -  (by)
- (void)getStepCount{
    NSLog (@"----- getStepCount Entered ------");
    NSDate *fromDate, *toDate, *anchorDate; // Whatever you need in your case
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // from below
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 7;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = 3;

    anchorDate = [calendar dateFromComponents:anchorComponents];

    NSLog (@"GetPlotData 2 - B");





    // Your interval: sum by hour
    //NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.hour = 1;

    // Example predicate

    fromDate = 9/1/2015;
    toDate = 9/10/2015;
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionStrictStartDate];

    // predicate = nil;

    NSLog (@"GetPlotData 2 - C Predicate set is - %@",predicate.description);
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum anchorDate:anchorDate intervalComponents:interval];


    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        // do something with the results

        NSLog(@"GetPlotData 2 - D Check for errors");
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
        }

        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitDay
                             value:-30
                             toDate:endDate
                             options:0];

        NSLog(@"GetPlotData 2 - E in block");

        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {

             NSLog(@"GetPlotData 2 - E in block 2");

             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                 // NSLog(@"Step B - Plot the results");
                 [self plotData:value forDate:date samplesPerSet:interval dataType:@"consumedCaloriesData"];
             }

         }];

    };
    [self.healthStore executeQuery:query];
}


//#pragma mark - Step Count (by)
- (void)getStepStats{

    NSLog (@"----- getRestingCalories Entered ------");
    int sampleInterval = 7;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 7;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 1) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // base time is 0

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort(); // Permissions can cause this error
        }

        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitMonth
                             value:-3
                             toDate:endDate
                             options:0];

        //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {

             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                 // NSLog(@"Step 5 - Plot getStepStats");
                 [self plotData:value forDate:date samplesPerSet:sampleInterval dataType:@"stepCountTEST"];
             }
         }];
    };
    [self.healthStore executeQuery:query];
    [self getStepCollectionByDay];
}

//Plot the weekly step counts over the past 3 months
// Plot Daily Step Counts over last 7 Days
- (void) getStepCollectionByDay {
    // Quantity Type - StepCount
    // SampleInterval- 7
    // Anchor Date   - Monday at 3:00 a.m.
    // QueryType     - HKStatisticsCollectionQuery
    // Options       - HKStatisticsOptionCumulativeSum
    // Start Date    - 6 Days Before
    // End Date      - 0 Today
    // Interval      - 1 Day
    // Enumeration
    // result.sumQuantity

    NSLog (@"----- getStepCollectionByDay Entered -----");
    int numberOfSamplesToCollectInDays = -7;
    int endDateDifferenceFromTodayInDays = 0;
    int startThisManyDaysBeforeEndDate = (numberOfSamplesToCollectInDays) + endDateDifferenceFromTodayInDays;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // set to midnight (-7)

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     //  options:HKStatisticsOptionDiscreteAverage //HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {


        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
        }

        // Set the Start & End Dates used to filter Enumeration
        NSDate *todaysDate  = [NSDate date];
        NSDate *endDate     = [calendar
                               dateByAddingUnit :NSCalendarUnitDay
                               value            :endDateDifferenceFromTodayInDays
                               toDate           :todaysDate
                               options          :0];
        NSDate *startDate   = [calendar
                               dateByAddingUnit :NSCalendarUnitDay
                               value            :startThisManyDaysBeforeEndDate
                               toDate           :endDate
                               options          :0];

        NSLog(@"Plot the DAILY totals for STEP COUNTS over the past WEEK"); //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {


             HKQuantity *quantity = result.sumQuantity;

             //NSLog (@"%@",[quantity description]);
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                 NSLog(@"STEP COUNT - DAILY - LAST WEEK - %.f (%@)",value,[date description]);
                 [self plotData:value forDate:date samplesPerSet:numberOfSamplesToCollectInDays dataType:@"stepData"];
             }

         }];
    };
    [self.healthStore executeQuery:query];
    // self.HRTest;
    [self getWeightCollectionByDay];
}

- (void) getWeightCollectionByDay
{
    // Quantity Type - HKQuantityTypeIdentifierBodyMass
    // SampleInterval- 7
    // Anchor Date   - Monday at 3:00 a.m.
    // QueryType     - HKStatisticsCollectionQuery
    // Options       - HKStatisticsOptionDiscreteAverage
    // Start Date    - 6 Days Before
    // End Date      - 0 Today
    // Interval      - 1 Day
    // Enumeration
    // result.sumQuantity

    NSLog (@"----- getWeightCollectionByDay Entered -----");
    int numberOfSamplesToCollectInDays = -7;
    int endDateDifferenceFromTodayInDays = 0;
    int startThisManyDaysBeforeEndDate = (numberOfSamplesToCollectInDays) + endDateDifferenceFromTodayInDays;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // set to midnight (-7)

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     //options:HKStatisticsOptionCumulativeSum
     options:HKStatisticsOptionDiscreteAverage | HKStatisticsOptionDiscreteMin | HKStatisticsOptionDiscreteMax
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {


        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);

            // *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Statistics option HKStatisticsOptionCumulativeSum is not compatible with discrete data type HKQuantityTypeIdentifierBodyMass'***
            abort();
        }

        // Set the Start & End Dates used to filter Enumeration
        NSDate *todaysDate  = [NSDate date];
        NSDate *endDate     = [calendar
                               dateByAddingUnit :NSCalendarUnitDay
                               value            :endDateDifferenceFromTodayInDays
                               toDate           :todaysDate
                               options          :0];
        NSDate *startDate   = [calendar
                               dateByAddingUnit :NSCalendarUnitDay
                               value            :startThisManyDaysBeforeEndDate
                               toDate           :endDate
                               options          :0];

        NSLog(@"Plot the DAILY totals for WEIGHT over the past WEEK"); //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {


             HKQuantity *avgWeight = result.averageQuantity;
             HKQuantity *minWeight = result.minimumQuantity;
             HKQuantity *maxWeight = result.maximumQuantity;


             // NSLog (@"%@",[quantity description]); //kg
             if (avgWeight) {
                 NSDate *date = result.startDate;
                 double avgWeightInPounds = [avgWeight doubleValueForUnit:[HKUnit poundUnit]];
                 double minWeightInPounds = [minWeight doubleValueForUnit:[HKUnit poundUnit]];
                 double maxWeightInPounds = [maxWeight doubleValueForUnit:[HKUnit poundUnit]];


                 NSLog(@"WEIGHT - DAILY - LAST WEEK - %.01f - %.01f - %.01f (%@) AVG-%@ MIN-%@ MAX-%@",avgWeightInPounds, minWeightInPounds, maxWeightInPounds,[date description],[avgWeight description],[minWeight description],[maxWeight description]);
                 [self plotData:avgWeightInPounds forDate:date samplesPerSet:numberOfSamplesToCollectInDays dataType:@"weightDataAvg"];
                 [self plotData:minWeightInPounds forDate:date samplesPerSet:numberOfSamplesToCollectInDays dataType:@"weightDataMin"];
                 [self plotData:maxWeightInPounds forDate:date samplesPerSet:numberOfSamplesToCollectInDays dataType:@"weightDataMax"];
             }

         }];
    };
    [self.healthStore executeQuery:query];

    [self getWeightAverageMinMax];

}

- (void)getWeightAverageMinMax
{
    NSLog (@"----- getWeightAverageMinMax Entered -----");

    HKQuantityType *cumulativeWeight =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    HKQuantityType *discreteWeight =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    // Cannot combine cumulative options with discrete options.
    // However, you can combine a cumulative option and seperated by source
    HKStatisticsQuery *cumulativeQuery =
    [[HKStatisticsQuery alloc]
     initWithQuantityType:cumulativeWeight
     quantitySamplePredicate:nil
     options: HKStatisticsOptionSeparateBySource
     completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {

         // ... process the results here

         HKQuantity *weightAvg = result.averageQuantity;
         HKQuantity *weightMin = result.minimumQuantity;
         HKQuantity *weightMax = result.maximumQuantity;

         // HKQuantity *sumCalQuantityForSource = [result.sumQuantity  result.sources[0]];

         //      HKQuantity *sumCalQuantityForSource =  result.sumQuantityForSource(result.sources[0]);

         {

             // Get Sources & Dates from result
             // NSDate *startDate = result.startDate;
             // NSDate *endDate = result.endDate;
             // NSString *sources = [result.sources description];

             int i = 0;
             for (i=0; i< [result.sources count]; i++)
             {
                 // HKQuantity *sumCalQuantityForSource =  result.averageQuantity; //(result.sources[i]);

                 NSString *product = [result.sources[i].name description];
                 // ok NSString *bundleID = [result.sources[i].bundleIdentifier description];
                 // double value = [quantity doubleValueForUnit:[HKUnit kilocalorieUnit]]; // chg to pounds
                 double weightInKilogramsAvg = [weightAvg doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo]];
                 double weightInKilogramsMin = [weightMin doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo]];
                 double weightInKilogramsMax = [weightMax doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo]];


                 NSLog(@"WEIGHT TEST------ %@ \t%.f %@",product, weightInKilogramsAvg, [weightAvg description]  ); // ,bundleID);
                 [self plotData:weightInKilogramsAvg forDate:result.startDate samplesPerSet:7 dataType:@"weightDataAvg"];
                 [self plotData:weightInKilogramsMin forDate:result.startDate samplesPerSet:7 dataType:@"weightDataMin"];
                 [self plotData:weightInKilogramsMax forDate:result.startDate samplesPerSet:7 dataType:@"weightDataMax"];
                 // not sent to destination yet


             }

             //[self plotData:value forDate:startDate samplesPerSet:7 dataType:@"weightData"];
         }


     }];
    [self.healthStore executeQuery:cumulativeQuery];


    // You can also combine any number of discrete options
    // and the seperated by source option.
    HKStatisticsQuery *discreteQuery =
    [[HKStatisticsQuery alloc]
     initWithQuantityType:discreteWeight
     quantitySamplePredicate:nil
     options:HKStatisticsOptionDiscreteAverage | HKStatisticsOptionDiscreteMin |
     HKStatisticsOptionDiscreteMax //| HKStatisticsOptionSeparateBySource
     completionHandler:^(HKStatisticsQuery *query, HKStatistics *results, NSError *error) {

         // ... process the results here
         double avgHB = [results.averageQuantity doubleValueForUnit :[HKUnit unitFromString:@"kg"]];  //
         double minHB = [results.minimumQuantity doubleValueForUnit :[HKUnit unitFromString:@"kg"]];  //
         double maxHB = [results.maximumQuantity doubleValueForUnit :[HKUnit unitFromString:@"kg"]];  //[(HKUnit.init(fromString: "count/sec")*60)]]; //:[HKUnit countUnit]];
                                                                                                      // double totalCalories =  (results.maximumQuantity.doubleValueForUnit(HKUnit.init(fromString: "count/s"))*60);
                                                                                                      // get results
         NSLog (@"WEIGHT ---------- %.f  %.f  %.f", maxHB, minHB ,avgHB);//(HKQuantity *)maximumQuantity);

         //enumerate
         // set start end dates for emumeration
         //         NSCalendar *calendar = [NSCalendar currentCalendar];
         //         NSDateComponents *interval = [[NSDateComponents alloc] init];
         //         interval.day = 1;
         //
         //
         //         NSDate *todaysDate = [NSDate date];
         //         NSDate *endDate = [calendar
         //                            dateByAddingUnit:NSCalendarUnitDay
         //                            value:-0
         //                            toDate:todaysDate
         //                            options:0];
         //         NSDate *startDate = [calendar
         //                              dateByAddingUnit:NSCalendarUnitDay
         //                              value:-6
         //                              toDate:endDate
         //                              options:0];

         //         [results
         //          enumerateStatisticsFromDate:startDate
         //          toDate:endDate
         //          withBlock:^(HKStatistics *result, BOOL *stop) {
         //
         //
         //
         //              HKQuantity *quantity = result.sumQuantity;
         //
         //              NSLog (@"%@",[quantity description]);
         //              if (quantity) {
         //                  NSDate *date = result.startDate;
         //                  double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
         //                  NSLog(@"Step 2HRTEST -------------- %.f",value);
         //                  //  [self plotData:value forDate:date samplesPerSet:sampleInterval dataType:@"replace"];
         //              }
         //
         //
         //          }
         //         //end enum
         //     ];
     }];
    [self.healthStore executeQuery:discreteQuery];

    [self HRTest];
}

- (void) HRTest
{

    NSLog (@"----- HRTest Entered -----");

    HKQuantityType *cumulativeActiveEnergyBurned =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];

    HKQuantityType *discreteHeartRate =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    // Cannot combine cumulative options with discrete options.
    // However, you can combine a cumulative option and seperated by source
    HKStatisticsQuery *cumulativeQuery =
    [[HKStatisticsQuery alloc]
     initWithQuantityType:cumulativeActiveEnergyBurned
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource
     completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {

         // ... process the results here

         HKQuantity *quantity = result.sumQuantity;
         // HKQuantity *sumCalQuantityForSource = [result.sumQuantity  result.sources[0]];

         //      HKQuantity *sumCalQuantityForSource =  result.sumQuantityForSource(result.sources[0]);

         if (quantity) {
             NSDate *startDate = result.startDate;
             NSDate *endDate = result.endDate;
             NSString *sources = [result.sources description];

             int i = 0;
             for (i=0; i< result.sources.count; i++)
             {
                 NSString *product = [result.sources[i].name description];
                 NSString *bundleID = [result.sources[i].bundleIdentifier description];
                 double value = [quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
                 NSLog(@"HR - Plot the results \n%@ \n%@ \n%.f \n %@ \n%@ \n%@ \n\n ",[startDate description],[endDate description],value, sources, product ,bundleID);
             }

             // [self plotData:value forDate:date samplesPerSet:sampleInterval dataType:@"stepCountTEST"];
         }


     }];
    [self.healthStore executeQuery:cumulativeQuery];


    // You can also combine any number of discrete options
    // and the seperated by source option.
    HKStatisticsQuery *discreteQuery =
    [[HKStatisticsQuery alloc]
     initWithQuantityType:discreteHeartRate
     quantitySamplePredicate:nil
     options:HKStatisticsOptionDiscreteAverage | HKStatisticsOptionDiscreteMin |
     HKStatisticsOptionDiscreteMax | HKStatisticsOptionSeparateBySource
     completionHandler:^(HKStatisticsQuery *query, HKStatistics *results, NSError *error) {

         // ... process the results here
         double avgHB = [results.averageQuantity doubleValueForUnit :[HKUnit unitFromString:@"count/min"]];  //
         double minHB = [results.minimumQuantity doubleValueForUnit :[HKUnit unitFromString:@"count/min"]];  //
         double maxHB = [results.maximumQuantity doubleValueForUnit :[HKUnit unitFromString:@"count/min"]];  //[(HKUnit.init(fromString: "count/sec")*60)]]; //:[HKUnit countUnit]];
                                                                                                             // double totalCalories =  (results.maximumQuantity.doubleValueForUnit(HKUnit.init(fromString: "count/s"))*60);
                                                                                                             // get results
         NSLog (@"HR ---------- %.f  %.f  %.f", maxHB, minHB ,avgHB);//(HKQuantity *)maximumQuantity);

         //enumerate
         // set start end dates for emumeration
         //         NSCalendar *calendar = [NSCalendar currentCalendar];
         //         NSDateComponents *interval = [[NSDateComponents alloc] init];
         //         interval.day = 1;
         //
         //
         //         NSDate *todaysDate = [NSDate date];
         //         NSDate *endDate = [calendar
         //                            dateByAddingUnit:NSCalendarUnitDay
         //                            value:-0
         //                            toDate:todaysDate
         //                            options:0];
         //         NSDate *startDate = [calendar
         //                              dateByAddingUnit:NSCalendarUnitDay
         //                              value:-6
         //                              toDate:endDate
         //                              options:0];

         //         [results
         //          enumerateStatisticsFromDate:startDate
         //          toDate:endDate
         //          withBlock:^(HKStatistics *result, BOOL *stop) {
         //
         //
         //
         //              HKQuantity *quantity = result.sumQuantity;
         //
         //              NSLog (@"%@",[quantity description]);
         //              if (quantity) {
         //                  NSDate *date = result.startDate;
         //                  double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
         //                  NSLog(@"Step 2HRTEST -------------- %.f",value);
         //                  //  [self plotData:value forDate:date samplesPerSet:sampleInterval dataType:@"replace"];
         //              }
         //
         //
         //          }
         //         //end enum
         //     ];
     }];
    [self.healthStore executeQuery:discreteQuery];



    [self queryHealthDataHeart];


}


#pragma mark HeartRate Sample (future)
- (void)queryHealthDataHeart{
    NSLog (@"----- queryHealthDataHeart Entered ------");

    HKQuantityType *typeHeart =[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:now];
    NSDate *beginOfDay = [calendar dateFromComponents:components];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:beginOfDay endDate:now options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *squery = [[HKStatisticsQuery alloc] initWithQuantityType:typeHeart quantitySamplePredicate:predicate options:HKStatisticsOptionNone completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HKQuantity *quantity = result.averageQuantity;
            double beats = [quantity doubleValueForUnit:[HKUnit countUnit]];
            // _lblHeart.text = [NSString stringWithFormat:@"%.f",beats];

            NSLog (@"******************* HB ******************** %.f",beats);
        }
                       );
    }];
    [self.healthStore executeQuery:squery];
    [self getRestingCalories];

}


#pragma mark - Get Resting Calories Data
- (void) getRestingCalories {

    NSLog (@"----- getRestingCalories Entered ------");
    int sampleInterval = 24;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // set to midnight (-7)

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
        }

        NSDate *todaysDate = [NSDate date];
        NSDate *endDate = [calendar
                           dateByAddingUnit:NSCalendarUnitDay
                           value:-0
                           toDate:todaysDate
                           options:0];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitDay
                             value:-6
                             toDate:endDate
                             options:0];

        //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {



             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit jouleUnit]];
                 // NSLog(@"Step restingCaloriesData - Plot the results");
                 [self plotData:value/4184 forDate:date samplesPerSet:sampleInterval dataType:@"restingCaloriesData"];
             }

         }];
    };
    [self.healthStore executeQuery:query];
    [self getActiveCalories];
}

- (void)getActiveCalories
{

    NSLog (@"----- getActiveCalories Entered ------");
    int sampleInterval = 24;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // set to midnight (-7)

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
        }

        NSDate *todaysDate = [NSDate date];
        NSDate *endDate = [calendar
                           dateByAddingUnit:NSCalendarUnitDay
                           value:-0
                           toDate:todaysDate
                           options:0];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitDay
                             value:-6
                             toDate:endDate
                             options:0];

        //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {



             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit jouleUnit]];
                 //NSLog(@"Step activeCaloriesData - Plot the results");
                 [self plotData:value/4184 forDate:date samplesPerSet:sampleInterval dataType:@"activeCaloriesData"];
             }

         }];
    };
    [self.healthStore executeQuery:query];
    [self getConsumedCalories];
}

#pragma mark - Get Consumed Calories (1 Week)
- (void)getConsumedCalories{

    NSLog (@"----- getConsumedCalories Entered ------");
    int sampleInterval = 24;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
     NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[NSDate date]];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = -0; // set to midnight (-7)

    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];


    HKQuantityType *quantityType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];


    // Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    // Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            abort();
        }

        NSDate *todaysDate = [NSDate date];
        NSDate *endDate = [calendar
                           dateByAddingUnit:NSCalendarUnitDay
                           value:-5
                           toDate:todaysDate
                           options:0];
        NSDate *startDate = [calendar
                             dateByAddingUnit:NSCalendarUnitDay
                             value:-6
                             toDate:endDate
                             options:0];

        //Plot the ... over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {



             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit jouleUnit]];
                 //NSLog(@"Step consumedCaloriesData - Plot the results");
                 [self plotData:value/4184 forDate:date samplesPerSet:sampleInterval dataType:@"consumedCaloriesData"];
             }

         }];
    };
    [self.healthStore executeQuery:query];
    [self getStepCount2];
}

#pragma mark - Get Step Count (by Day)
- (void)getStepCount2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];

    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }

        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                 value:-7
                                                toDate:endDate
                                               options:0];

        // Plot the daily step counts over the past 7 days
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {

                                       HKQuantity *quantity = result.sumQuantity;
                                       if (quantity) {
                                           NSDate *date = result.startDate;
                                           double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           NSLog(@"FUNCT 4 - %@: %.f Active Cals - %.02f", date, value, self.activeEnergyBurned/4184);



                                           // self.weightData = @"123,222,123,222,123,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,267,273,273,273,273,400";
                                       }

                                   }];
    };

    [self.healthStore executeQuery:query];
    // end self.queryHealthDataHeart;

}


#pragma mark - Plot Data
- (void)plotData:(double)valueToPlot forDate:(NSDate *)dateForValue samplesPerSet:(int)numSamples dataType:(NSString *)dataType  {

    if ([dataType isEqualToString:@"consumedCaloriesData"])
    {
        self.consumedCaloriesData = [self.consumedCaloriesData   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
    }
    else if ([dataType isEqualToString:@"weightDataAvg"])
    {
        self.weightData = [self.weightData   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
    }
    else if ([dataType isEqualToString:@"weightDataMin"])
    {
        self.weightDataMin = [self.weightDataMin   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
    }
    else if ([dataType isEqualToString:@"weightDataMin"])
    {
        self.weightDataMax = [self.weightDataMax   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
    }


    else if ([dataType isEqualToString:@"activeCaloriesData"])
    {
        self.activeCaloriesData = [self.activeCaloriesData   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
        //  NSLog (@"PlotData Entered %@ - %.f (restingCaloriesData: %@)", dateForValue,valueToPlot,self.restingCaloriesData);

    }else if ([dataType isEqualToString:@"restingCaloriesData"])
    {
        self.restingCaloriesData = [self.restingCaloriesData   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
        //  NSLog (@"PlotData Entered %@ - %.f (restingCaloriesData: %@)", dateForValue,valueToPlot,self.restingCaloriesData);

    }
    else if ([dataType isEqualToString:@"stepData"])
    {

        self.stepData = [self.stepData   stringByAppendingString:[NSString stringWithFormat:@",%.f", valueToPlot]];
        // NSLog (@"PlotData Entered %@ - %.f (stepData: %@)", dateForValue,valueToPlot,self.stepData);

    }

    //  NSLog (@"PlotData Entered %@ - %.f dataType %@", dateForValue,valueToPlot,dataType);///numSamples);
    //    %f = 25.000000
    //    %.f = 25
    //    %.02f = 25.00

}


#pragma mark - Switch to Arrays Dictionaries or Objects
// Story: 10-7-15 C
// We need to pass data in objects
// understanding of the charts were required first
// now we can build the objet and pass it
// step 1 ...

#pragma mark - Pass Data
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEnergyDetail"]) {
        //  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CombinedChartViewController *destViewController = segue.destinationViewController;
        //self.weightData = @"weightData,333,222,123,222,123,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,267,273,273,273,273,400";

        destViewController.weightData =  self.weightData;

        destViewController.activeCaloriesData  =  self.activeCaloriesData;

        destViewController.restingCaloriesData =  self.restingCaloriesData;

        destViewController.totalCaloriesData =  self.totalCaloriesData;

        destViewController.netCaloriesData =  self.netCaloriesData;

        NSLog(@"consumedCaloriesData - %@",self.consumedCaloriesData);

        destViewController.consumedCaloriesData =  self.consumedCaloriesData;

        destViewController.stepData =  self.stepData;


    }
}

#pragma mark - Calc by Measurements
// Calculates the user's total basal (resting) energy burn based off of their height, weight, age,
// and biological sex. If there is not enough information, return an error.
- (void)fetchTotalBasalBurn:(void(^)(HKQuantity *basalEnergyBurn, NSError *error))completion {
    NSPredicate *todayPredicate = [self predicateForSamplesToday];

    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];

    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *weight, NSError *error) {
        if (!weight) {
            completion(nil, error);

            return;
        }

        [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:todayPredicate completion:^(HKQuantity *height, NSError *error) {
            if (!height) {
                completion(nil, error);

                return;
            }

            NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
            if (!dateOfBirth) {
                completion(nil, error);

                return;
            }

            HKBiologicalSexObject *biologicalSexObject = [self.healthStore biologicalSexWithError:&error];
            if (!biologicalSexObject) {
                completion(nil, error);

                return;
            }

            // Once we have pulled all of the information without errors, calculate the user's total basal energy burn
            HKQuantity *basalEnergyBurn = [self calculateBasalBurnTodayFromWeight:weight height:height dateOfBirth:dateOfBirth biologicalSex:biologicalSexObject];

            completion(basalEnergyBurn, nil);
        }];
    }];
}

- (HKQuantity *)calculateBasalBurnTodayFromWeight:(HKQuantity *)weight height:(HKQuantity *)height dateOfBirth:(NSDate *)dateOfBirth biologicalSex:(HKBiologicalSexObject *)biologicalSex {
    // Only calculate Basal Metabolic Rate (BMR) if we have enough information about the user
    if (!weight || !height || !dateOfBirth || !biologicalSex) {
        return nil;
    }

    // Note the difference between calling +unitFromString: vs creating a unit from a string with
    // a given prefix. Both of these are equally valid, however one may be more convenient for a given
    // use case.
    double heightInCentimeters = [height doubleValueForUnit:[HKUnit unitFromString:@"cm"]];
    double weightInKilograms = [weight doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo]];

    NSDate *now = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
    NSUInteger ageInYears = ageComponents.year;

    // BMR is calculated in kilocalories per day.
    double BMR = [self calculateBMRFromWeight:weightInKilograms height:heightInCentimeters age:ageInYears biologicalSex:[biologicalSex biologicalSex]];

    // Figure out how much of today has completed so we know how many kilocalories the user has burned.
    NSDate *startOfToday = [[NSCalendar currentCalendar] startOfDayForDate:now];
    NSDate *endOfToday = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startOfToday options:0];

    NSTimeInterval secondsInDay = [endOfToday timeIntervalSinceDate:startOfToday];
    double percentOfDayComplete = [now timeIntervalSinceDate:startOfToday] / secondsInDay;

    double kilocaloriesBurned = BMR * percentOfDayComplete;

    return [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:kilocaloriesBurned];
}

#pragma mark - Convenience

- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *now = [NSDate date];

    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];

    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

- (NSPredicate *)predicateForSamplesYesterday {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *now = [NSDate date];

    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];

    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

- (NSPredicate *)predicateForSamplesThisWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    // NSDate *now = [NSDate date];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [calendar
                         dateByAddingUnit:NSCalendarUnitDay
                         value:-7
                         toDate:endDate
                         options:0];


    // NSDate *startDate = [calendar startOfDayForDate:now];
    //NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:startDate options:0];

    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

- (NSPredicate *)predicateForSamplesThisQtr {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    // NSDate *now = [NSDate date];

    // NSDate *startDate = [calendar startOfDayForDate:now];
    // NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [calendar
                         dateByAddingUnit:NSCalendarUnitMonth
                         value:-3
                         toDate:endDate
                         options:0];







    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

/// Returns BMR value in kilocalories per day. Note that there are different ways of calculating the
/// BMR. In this example we chose an arbitrary function to calculate BMR based on weight, height, age,
/// and biological sex.
- (double)calculateBMRFromWeight:(double)weightInKilograms height:(double)heightInCentimeters age:(NSUInteger)ageInYears biologicalSex:(HKBiologicalSex)biologicalSex {
    double BMR;

    // The BMR equation is different between males and females.
    if (biologicalSex == HKBiologicalSexMale) {
        BMR = 66.0 + (13.8 * weightInKilograms) + (5 * heightInCentimeters) - (6.8 * ageInYears);
    }
    else {
        BMR = 655 + (9.6 * weightInKilograms) + (1.8 * heightInCentimeters) - (4.7 * ageInYears);
    }
    
    return BMR;
}

#pragma mark - NSEnergyFormatter

- (NSEnergyFormatter *)energyFormatter {
    static NSEnergyFormatter *energyFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        energyFormatter = [[NSEnergyFormatter alloc] init];
        energyFormatter.unitStyle = NSFormattingUnitStyleLong;
        energyFormatter.forFoodEnergyUse = YES;
        energyFormatter.numberFormatter.maximumFractionDigits = 0;
    });
    
    return energyFormatter;
}



#pragma mark - Setter Overrides

- (void)setActiveEnergyBurned:(double)activeEnergyBurned {
    _activeEnergyBurned = activeEnergyBurned;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.activeEnergyBurnedValueLabel.text = [energyFormatter stringFromJoules:activeEnergyBurned];
}

- (void)setEnergyConsumed:(double)energyConsumed {
    _energyConsumed = energyConsumed;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.consumedEnergyValueLabel.text = [energyFormatter stringFromJoules:energyConsumed];
}

- (void)setRestingEnergyBurned:(double)restingEnergyBurned {
    _restingEnergyBurned = restingEnergyBurned;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.restingEnergyBurnedValueLabel.text = [energyFormatter stringFromJoules:restingEnergyBurned];
}

- (void)setStepsCounted:(double)stepsCounted {
    _stepsCounted = stepsCounted;
    
    //  stepsCounted.numberFormatter.maximumFractionDigits = 0;
    
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:stepsCounted];
    //myDoubleNumber.maximumFractionDigits = 0;
    
    self.stepsCountedValueLabel.text = [numberFormatter stringFromNumber: myDoubleNumber];;
}

- (void)setNetEnergy:(double)netEnergy {
    _netEnergy = netEnergy;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.netEnergyValueLabel.text = [energyFormatter stringFromJoules:netEnergy];
}

- (void)setStepsExplained:(NSString *)stepsExplained {
    _stepsExplained = stepsExplained;
    self.stepsExplainedLabel.text = stepsExplained;
}

@end