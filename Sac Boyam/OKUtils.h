//
//  OKUtils.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 26/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *savePhotosKey = @"savephotosKey";
static NSString *editPhotosKey = @"editphotosKey";
static NSString *takeRecordKey = @"takerecordKey";
static NSString *findOnTapKey = @"findontapKey";
static NSString *resultDensityKey = @"resultDensityKey";
static NSString *showTutorialKey = @"showTutorialKey";
static NSString *userDefaultPhotoKey = @"userPhotoKey";

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
