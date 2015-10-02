/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Displays energy-related information retrieved from HealthKit.
            
*/

#import "AAPLEnergyViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

// import the chart controller here
// then - define a STRING *(ChartData1) as a property of that object
// Call the ChartData1 object and add each item to it with a ',' seperating to make CSV.
#import "CombinedChartViewController.h"




@interface AAPLEnergyViewController()

@property (nonatomic, weak) IBOutlet UILabel *activeEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *restingEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *consumedEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *netEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsCountedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *stepsExplainedLabel;

@property (nonatomic) double activeEnergyBurned;
@property (nonatomic) double restingEnergyBurned;
@property (nonatomic) double basalEnergyBurned;
@property (nonatomic) double energyConsumed;
@property (nonatomic) double netEnergy;
@property (nonatomic) double stepsCounted;
@property (nonatomic) NSString *stepsExplained;


@end

@implementation AAPLEnergyViewController

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.refreshControl addTarget:self action:@selector(refreshStatistics) forControlEvents:UIControlEventValueChanged];
    
    [self refreshStatistics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Reading HealthKit Data

- (void)refreshStatistics {
    [self.refreshControl beginRefreshing];
    
    HKQuantityType *energyConsumedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *basalEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

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

                [self getPlotData ]; //]:stepCountType unit:[HKUnit countUnit] completion:^(double stepsCounted, NSError *error) {


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
                    
                    [self.refreshControl endRefreshing];

                    //test
                    NSEnergyFormatter *energyFormatter = [self energyFormatter];
                    double tempCals = activeEnergyBurned/4184;
                    // NSNumber *calories2 = [activeEnergyBurned doubleValueForUnit:[HKUnit calorieUnit]];
                    NSLog (@"Active Burn / Steps = %.05f ",tempCals/stepsCounted);
                    NSLog (@"Steps (%.f) / Active Burn (%.f) = %.05f",stepsCounted,tempCals,stepsCounted/tempCals);

                    //NSEnergyFormatter *energyFormatter = [[NSEnergyFormatter alloc] init];
                    //NSLog(@"Calories: %@", [energyFormatter stringFromValue:1000 unit:NSEnergyFormatterUnitCalorie]); //Calories: 1,000 cal
                    //NSLog(@"Joule: %@", [energyFormatter stringFromValue:1000 unit:NSEnergyFormatterUnitJoule])

                    //self.getPlotData2;
                    //self.getPlotData;
                    //[self plotData:2.0 forDate:@"1/1/2001"];
                });
            }];}];
        }];
    }];
}

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

- (void)getPlotData2{
    NSLog (@"GetPlotData 2 - A Entered");
NSDate *fromDate, *toDate, *startDate, *endDate, *anchorDate; // Whatever you need in your case
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
             NSLog(@"Step B - Plot the results");
             [self plotData:value forDate:date samplesPerSet:interval];
         }

     }];

};
[self.healthStore executeQuery:query];
}



- (void)getPlotData{

    NSLog (@"getPlotData Entered");
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


    NSLog(@"Step 1 - Create the query");// Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    NSLog(@"Step 2 - Set the results handler");// Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        NSLog(@"Step 3 - Check for errors");
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

        NSLog(@"Step 4 - Plot the weekly step counts over the past 3 months"); //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {



             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                 NSLog(@"Step 5 - Plot the results");
                 [self plotData:value forDate:date samplesPerSet:sampleInterval];
             }
             
         }];
    };
    [self.healthStore executeQuery:query];
    self.getPlotData3;
}

- (void) getPlotData3 {

    NSLog (@"getPlotData 3 Entered");
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
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];


    NSLog(@"Step 3.1 - Create the query");// Create the query
    HKStatisticsCollectionQuery *query =
    [[HKStatisticsCollectionQuery alloc]
     initWithQuantityType:quantityType
     quantitySamplePredicate:nil
     options:HKStatisticsOptionCumulativeSum
     anchorDate:anchorDate
     intervalComponents:interval];


    NSLog(@"Step 3.2 - Set the results handler");// Set the results handler
    query.initialResultsHandler =
    ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {

        NSLog(@"Step 3.3 - Check for errors");
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

        NSLog(@"Step 3.4 - Plot the weekly step counts over the past 3 months"); //Plot the weekly step counts over the past 3 months
        [results
         enumerateStatisticsFromDate:startDate
         toDate:endDate
         withBlock:^(HKStatistics *result, BOOL *stop) {



             HKQuantity *quantity = result.sumQuantity;
             if (quantity) {
                 NSDate *date = result.startDate;
                 double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                 NSLog(@"Step 3.5 - Plot the results");
                 [self plotData:value forDate:date samplesPerSet:sampleInterval];
             }
             
         }];
    };
    [self.healthStore executeQuery:query];
    self.getPlotData4;
}

- (void)getPlotData4
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


                                           //CombinedChartViewController.chartData1 = @"123,222,123,222,123,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,271,271,273,271,270,269,268,270,269,267,273,273,273,273,267,273,273,273,273,400";
                                       }
                                       
                                   }];
    };
    
    [self.healthStore executeQuery:query];

}
- (void)plotData:(double)valueToPlot forDate:(NSDate *)dateForValue samplesPerSet:(int)numSamples  {


    NSLog (@"PlotData Entered %@ - %.f (Average - %.f)", dateForValue,valueToPlot,valueToPlot/numSamples);
//    %f = 25.000000
//    %.f = 25
//    %.02f = 25.00

}

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