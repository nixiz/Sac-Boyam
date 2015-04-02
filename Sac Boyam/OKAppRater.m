//
//  OKAppRater.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 16/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "OKAppRater.h"
#import "OKUtils.h"
#define alertViewTagNumber 1010
#define alertViewTagNumberForPurchase 10101

@interface OKAppRater ()
@property (strong, nonatomic) NSMutableDictionary *counterDictionary;
@property BOOL isUserRated;
@end

@implementation OKAppRater

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.counterDictionary = [NSMutableDictionary dictionary];
    self.isUserRated = NO;
  }
  return self;
}

+ (instancetype) sharedInstance
{
  static OKAppRater *sharedObj = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedObj = [[OKAppRater alloc] init];
  });
  return sharedObj;
}

- (void)initiateInstanceForAppID:(NSString *)aid localizationTableName:(NSString *)tableName
{
  self.appID = aid;
  self.localizedTableName = tableName;
}

- (void)increaseTimeOfUse
{
  if (self.isUserRated) return;
  NSInteger timesOfResultView = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView forKey:timesOfNotRatedUsesKey];
}

- (void)decreaseTimeOfUse
{
  if (self.isUserRated) return;
  NSInteger timesOfResultView = [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue] - 1;
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView > 0 ? timesOfResultView : 0 forKey:timesOfNotRatedUsesKey];
}

- (void)showRateThisApp
{
  NSInteger timesOfResultView = [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  NSInteger usesUntilPromt = [[[NSUserDefaults standardUserDefaults] objectForKey:usesUntilPromtKey] integerValue];
  self.isUserRated = [[[NSUserDefaults standardUserDefaults] objectForKey:userDidRatedKey] boolValue];
  BOOL userDidRemindMeLatered = [[[NSUserDefaults standardUserDefaults] objectForKey:remindMeLaterKey] boolValue];
  BOOL canbeshowrateview = NO;
  
//  userDidRated = NO;            //just for debug!
//  userDidRemindMeLatered = NO;  //just for debug!
  
  if (self.isUserRated) return; //return user already rated app.
  
  //eger remind me later ise su an ile gecen zamana bak ve ona gore show et
  if (userDidRemindMeLatered)
  {
    NSDate *lastRemindDate = [[NSUserDefaults standardUserDefaults] objectForKey:remindMeLaterDateKey];
    NSInteger betweenDays = [OKUtils daysBetweenDate:lastRemindDate andDate:[NSDate date]];
    NSInteger showDaysUntil = [[NSUserDefaults standardUserDefaults] integerForKey:showDaysUntilPromtKey];
    if (betweenDays - showDaysUntil > 0) {
      canbeshowrateview = YES;
    } else {
      return;
    }
  }
  
  if (timesOfResultView >= usesUntilPromt || canbeshowrateview)
  {
    UIAlertView *rateThisAppAlert = [[UIAlertView alloc] initWithTitle:@"Saç Boyam"
                                                               message:NSLocalizedStringFromTable(@"rateAppMessage", self.localizedTableName, nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedStringFromTable(@"rateAppCancelButton", self.localizedTableName, nil)
                                                     otherButtonTitles:NSLocalizedStringFromTable(@"rateAppOkButton", self.localizedTableName, nil), NSLocalizedStringFromTable(@"rateAppLaterButton", self.localizedTableName, nil), nil];
    [rateThisAppAlert setTag:alertViewTagNumber];
    [rateThisAppAlert show];
  }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if (alertView.tag == alertViewTagNumber)
  {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:timesOfNotRatedUsesKey];
    if ([title isEqualToString:NSLocalizedStringFromTable(@"rateAppCancelButton", self.localizedTableName, nil)]) {
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:remindMeLaterKey];
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDidRatedKey];
    } else if ([title isEqualToString:NSLocalizedStringFromTable(@"rateAppLaterButton", self.localizedTableName, nil)]) {
      //TODO: set remonder for next usage
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:remindMeLaterKey];
      [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:remindMeLaterDateKey];
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:userDidRatedKey];
    } else if ([title isEqualToString:NSLocalizedStringFromTable(@"rateAppOkButton", self.localizedTableName, nil)]) {
      //TODO: go to rate page! set app is rated
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:remindMeLaterKey];
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDidRatedKey];
      [[NSUserDefaults standardUserDefaults] synchronize];
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/%@", self.appID]];/*itms-apps://itunes.apple.com/app/%@*/
      BOOL success = [[UIApplication sharedApplication] openURL:url];
      if (!success) {
        NSLog(@"Failed to open url: %@", [url description]);
      }
      return;
    }
    BOOL isSynced = [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"default values are synced %@", isSynced ? @"successfuly":@"unsuccessfuly");
  } else if (alertView.tag == alertViewTagNumberForPurchase) {
    //TODO:
  } else {
    NSLog(@"unknow handle for alert view!\n%@", [alertView debugDescription]);
  }
}

//- (void)increaseColorFoundKey
//{
//  NSInteger timesOfUse = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:numberOfColorFoundsInOneDayKey] integerValue];
//  [[NSUserDefaults standardUserDefaults] setInteger:timesOfUse forKey:numberOfColorFoundsInOneDayKey];
//}

- (void)resetColorFoundKey
{
  [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:numberOfColorFoundsInOneDayKey];
}

- (void)askForPurchase
{
#ifdef LITE_VERSION
  UIAlertView *rateThisAppAlert = [[UIAlertView alloc] initWithTitle:@"Saç Boyam"
                                                             message:NSLocalizedStringFromTable(@"purchaseAppMessage", self.localizedTableName, nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedStringFromTable(@"purchaseButton", self.localizedTableName, nil)
                                                   otherButtonTitles:NSLocalizedStringFromTable(@"rateAppCancelButton", self.localizedTableName, nil), nil];
  [rateThisAppAlert setTag:alertViewTagNumberForPurchase];
  [rateThisAppAlert show];
  [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastTimeAskedForPurchaseDateKey];
#endif
}

- (BOOL)tryIncreaseAndUseForThisTime
{
#ifdef LITE_VERSION
  NSInteger timesOfUse = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:numberOfColorFoundsInOneDayKey] integerValue];
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfUse forKey:numberOfColorFoundsInOneDayKey];
  NSInteger maximumAllowedUsage = [[[NSUserDefaults standardUserDefaults] objectForKey:maximumAllowedUsageInOneDayKey] integerValue];
  
  if (timesOfUse >= maximumAllowedUsage)
  {
    NSString *purchaseMessage = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedStringFromTable(@"purchaseAppMessage", self.localizedTableName, nil), NSLocalizedStringFromTable(@"getTwoExtraShotMessage", self.localizedTableName, nil)];
    UIAlertView *rateThisAppAlert = [[UIAlertView alloc] initWithTitle:@"Saç Boyam"
                                                               message:purchaseMessage
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedStringFromTable(@"purchaseButton", self.localizedTableName, nil)
                                                     otherButtonTitles:NSLocalizedStringFromTable(@"rateAppCancelButton", self.localizedTableName, nil), nil];
    [rateThisAppAlert setTag:alertViewTagNumberForPurchase];
    [rateThisAppAlert show];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastTimeAskedForPurchaseDateKey];
    return NO;
  }
#endif
  return YES;
}
@end
