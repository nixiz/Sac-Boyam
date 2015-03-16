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

@implementation OKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
                                 userDidRatedKey: @NO
                                 };
  [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
#if DEBUG
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:remindMeLaterKey];
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:userDidRatedKey];
  [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:showDaysUntilPromtKey];
  [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:timesOfNotRatedUsesKey];
#endif
  [[OKAppRater sharedInstance] initiateInstanceForAppID:appID localizationTableName:okStringsTableName];
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
