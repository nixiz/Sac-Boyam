//
//  OKUtils.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 26/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString const *savePhotosKey = @"savephotosKey";
static NSString const *editPhotosKey = @"editphotosKey";
static NSString const *takeRecordKey = @"takerecordKey";
static NSString const *findOnTapKey = @"findontapKey";
static NSString const *resultDensityKey = @"resultDensityKey";
static NSString const *showTutorialKey = @"showTutorialKey";
static NSString const *userDefaultPhotoKey = @"userPhotoKey";
static NSString const *appWasRatedKey          = @"appratedkey";
static NSString const *lastRateShowDateKey     = @"lastrateshowdate";
static NSString const *daysUntilPromtKey       = @"usesUntilPromtKey";
static NSString const *usesUntilPromtKey       = @"usesUntilPromtKey";
static NSString const *timesOfNotRatedUsesKey  = @"timesOfNotRatedUsesKey";
static NSString const *canshowratekey  = @"canshowratekey";

typedef NS_ENUM(NSInteger, OKPageType) {
  OKWelcomeScreenPage = 0,
  OKSelectColorPage = 1,
//  OKResultsPage = 2,
  OKResultDetailPage = 2,
  OKSettingsPage = 3,
  OKTryOnMePage = 4
};

@interface OKUtils : NSObject

+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds;
+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds withColors:(NSArray *)colors andLocations:(NSArray *)locations;
+ (NSString *)colorToHexString:(UIColor *)color;
+ (NSString *)colorToJsonString:(UIColor *)color;

+(NSString *)dateToString:(NSDate *)date;

+(UIColor *)getBackgroundColor;
//+(NSArray *)getNavigationBarRightSideItemsForController:(id)instance selector:(SEL)action andForPage:(OKPageType) pageType;
@end
