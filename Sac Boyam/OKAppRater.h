//
//  OKAppRater.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 16/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *remindMeLaterDateKey        = @"remindmelaterdateKey";
static NSString *remindMeLaterKey        = @"remindmelaterKey";
static NSString *showDaysUntilPromtKey   = @"showDaysUntilPromtKey";
static NSString *usesUntilPromtKey       = @"usesUntilPromtKey";
static NSString *timesOfNotRatedUsesKey  = @"timesOfNotRatedUsesKey";
static NSString *userDidRatedKey  = @"userDidRatedKey";
static NSString *numberOfColorFoundsInOneDayKey  = @"numberOfColorFoundsInOneDayKey";
static NSString *maximumAllowedUsageInOneDayKey  = @"maximumAllowedUsageInOneDayKey";
static NSString *lastTimeAskedForPurchaseDateKey = @"lastTimeAskedForPurchaseDateKey";

@interface OKAppRater : NSObject <UIAlertViewDelegate>

+ (instancetype) sharedInstance;

- (void)showRateThisApp;
- (void)initiateInstanceForAppID:(NSString *)aid localizationTableName:(NSString *)tableName;
- (void)increaseTimeOfUse;
- (void)decreaseTimeOfUse;

//- (void)increaseColorFoundKey;
- (void)resetColorFoundKey;
- (void)askForPurchase;
- (BOOL)tryIncreaseAndUseForThisTime;

@property (strong, nonatomic) NSString *appID;
@property (nonatomic, assign) NSString *localizedTableName;

@end
