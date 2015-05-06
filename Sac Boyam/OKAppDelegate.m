//
//  OKAppDelegate.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKAppDelegate.h"
#import "OKUtils.h"
#import "UIView+CreateImage.h"
#import "UIImage+ImageEffects.h"
#import "OKAppRater.h"
//#import "OKInfoViewController.h"

#ifdef LITE_VERSION
NSString * const BannerViewActionWillBegin    = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish    = @"BannerViewActionDidFinish";
NSString * const BannerViewLoadedSuccessfully = @"BannerViewLoadedSuccessfully";
NSString * const BannerViewNotLoaded          = @"BannerViewNotLoaded";

@implementation BannerViewManager {
  ADBannerView *_bannerView;
  NSMutableSet *_bannerViewControllers;
}

+ (BannerViewManager *)sharedInstance
{
  static BannerViewManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[BannerViewManager alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
      _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
      _bannerView = [[ADBannerView alloc] init];
    }
    _bannerView.delegate = self;
    _bannerViewControllers = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)addBannerViewController:(id<BannerViewController_Delegate>) controller
{
  [_bannerViewControllers addObject:controller];
}

- (void)removeBannerViewController:(id<BannerViewController_Delegate>) controller
{
  [_bannerViewControllers removeObject:controller];
}

#pragma mark - iAdNetwork Methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  NSLog(@"Banner loaded successfully!");
  for (id<BannerViewController_Delegate> bvc in _bannerViewControllers) {
    [bvc updateLayout];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewLoadedSuccessfully object:self];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  NSLog(@"An error occured while downloading iAd: %@", [error debugDescription]);
  for (id<BannerViewController_Delegate> bvc in _bannerViewControllers) {
    [bvc updateLayout];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewNotLoaded object:self];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
  [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
  return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
  [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

@end
#endif

@implementation OKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef LITE_VERSION
  NSDictionary *userDefaults = @{savePhotosKey: @NO,
                                 editPhotosKey: @YES,
                                 takeRecordKey: @NO,
                                 resultDensityKey: @7,
                                 showTutorialKey: @YES,
                                 findOnTapKey: @NO,
                                 usesUntilPromtKey: @8,
                                 timesOfNotRatedUsesKey: @-1,
                                 showDaysUntilPromtKey:@11,
                                 remindMeLaterDateKey:[NSDate date],
                                 remindMeLaterKey: @NO,
                                 userDidRatedKey: @NO,
                                 numberOfColorFoundsInOneDayKey: @0,
                                 maximumAllowedUsageInOneDayKey: @7,
                                 lastTimeAskedForPurchaseDateKey: [NSDate date]
                                 };
#else
  NSDictionary *userDefaults = @{savePhotosKey: @NO,
                                 editPhotosKey: @YES,
                                 takeRecordKey: @YES,
                                 resultDensityKey: @7,
                                 showTutorialKey: @YES,
                                 findOnTapKey: @NO,
                                 usesUntilPromtKey: @8,
                                 timesOfNotRatedUsesKey: @-1,
                                 showDaysUntilPromtKey:@11,
                                 remindMeLaterDateKey:[NSDate date],
                                 remindMeLaterKey: @NO,
                                 userDidRatedKey: @NO,
                                 numberOfColorFoundsInOneDayKey: @0,
                                 maximumAllowedUsageInOneDayKey: @7,
                                 lastTimeAskedForPurchaseDateKey: [NSDate date]
                                 };
#endif
  [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
//#if DEBUG
//  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:remindMeLaterKey];
//  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:userDidRatedKey];
//  [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:showDaysUntilPromtKey];
//  [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:timesOfNotRatedUsesKey];
//#endif
  [[OKAppRater sharedInstance] initiateInstanceForAppID:appID localizationTableName:okStringsTableName];
//#ifdef LITE_VERSION
//  [[OKAppRater sharedInstance] initiateInstanceForAppID:@"id982014777" localizationTableName:okStringsTableName];
//#else
//  [[OKAppRater sharedInstance] initiateInstanceForAppID:appID localizationTableName:okStringsTableName];
//#endif
#ifdef LITE_VERSION
  //create dummy instance for singleton initialization.
  NSDate *lastRemindDate = [[NSUserDefaults standardUserDefaults] objectForKey:lastTimeAskedForPurchaseDateKey];
  NSInteger betweenDays = [OKUtils daysBetweenDate:lastRemindDate andDate:[NSDate date]];
  if (betweenDays) {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:numberOfColorFoundsInOneDayKey];
  }
  BannerViewManager *bannerManager = [BannerViewManager sharedInstance];
#endif
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[NSUserDefaults standardUserDefaults] synchronize];
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//  UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//  [navigationController popToRootViewControllerAnimated:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[NSUserDefaults standardUserDefaults] synchronize];
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
