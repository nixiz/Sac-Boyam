//
//  OKUtils.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 26/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *savePhotosKey = @"savephotosKey";
static NSString *editPhotosKey = @"editphotosKey";
static NSString *takeRecordKey = @"takerecordKey";

@interface OKUtils : NSObject

+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds;
+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds withColors:(NSArray *)colors andLocations:(NSArray *)locations;
+ (NSString *)colorToHexString:(UIColor *)color;
+ (NSString *)colorToJsonString:(UIColor *)color;

+(UIColor *)getBackgroundColor;
@end
