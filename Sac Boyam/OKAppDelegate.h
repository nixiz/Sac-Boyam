//
//  OKAppDelegate.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const okStringsTableName = @"localized";
static NSString * const appID = @"id921525192";

@interface OKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)showTutorialForViewController:(UIViewController *)controller andPageIndex:(NSInteger)pageNumber;
@end
