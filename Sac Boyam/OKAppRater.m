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

@interface OKAppRater ()
@property (strong, nonatomic) NSMutableDictionary *counterDictionary;
@end

@implementation OKAppRater

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.counterDictionary = [NSMutableDictionary dictionary];
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
  NSInteger timesOfResultView = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView forKey:timesOfNotRatedUsesKey];
}

- (void)decreaseTimeOfUse
{
  NSInteger timesOfResultView = [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue] - 1;
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView > 0 ? timesOfResultView : 0 forKey:timesOfNotRatedUsesKey];
}

- (void)showRateThisApp
{
  NSInteger timesOfResultView = [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  NSInteger usesUntilPromt = [[[NSUserDefaults standardUserDefaults] objectForKey:usesUntilPromtKey] integerValue];
  BOOL userDidRated = [[[NSUserDefaults standardUserDefaults] objectForKey:userDidRatedKey] boolValue];
  BOOL userDidRemindMeLatered = [[[NSUserDefaults standardUserDefaults] objectForKey:remindMeLaterKey] boolValue];
  BOOL canbeshowrateview = NO;
  
  userDidRated = NO;            //just for debug!
//  userDidRemindMeLatered = NO;  //just for debug!
  
  if (userDidRated) return; //return user already rated app.
  
  //eger remind me later ise su an ile gecen zamana bak ve ona gore show et
  if (userDidRemindMeLatered)
  {
    NSDate *lastRemindDate = [[NSUserDefaults standardUserDefaults] objectForKey:remindMeLaterDateKey];
    NSInteger betweenDays = [OKUtils daysBetweenDate:lastRemindDate andDate:[NSDate date]];
    NSInteger showDaysUntil = [[[NSUserDefaults standardUserDefaults] objectForKey:showDaysUntilPromtKey] integerValue];
    if (betweenDays - showDaysUntil > 0) {
      canbeshowrateview = YES;
    } else {
      return;
    }
  }
  
  if (timesOfResultView > usesUntilPromt || canbeshowrateview)
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
  if (alertView.tag == alertViewTagNumber) {
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
  } else {
    NSLog(@"unknow handle for alert view!\n%@", [alertView debugDescription]);
  }
}

@end
