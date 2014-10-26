//
//  OKUtils.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 26/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKUtils.h"
#import "UIImage+ImageEffects.h"

@implementation OKUtils

+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds
{
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = bounds;
  
  NSArray *colors = [NSArray arrayWithObjects:
                     (id)[[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0f] CGColor], //white color
                     (id)[[UIColor colorWithRed:180.0f/255.0f green:174.0f/255.0f blue:174.0f/255.0f alpha:1.0f] CGColor], //yellow
                     (id)[[UIColor colorWithRed:149.0f/255.0f green:144.0f/255.0f blue:144.0f/255.0f alpha:1.0f] CGColor], //red
                     nil];
  gradient.colors = colors;
  gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.55f], [NSNumber numberWithFloat:1.0f], nil];
  //  gradient.startPoint = CGPointZero;
  //  gradient.endPoint = CGPointMake(0.5, 1);
  //  [self.view.layer insertSublayer:gradient atIndex:0];
  return gradient;
}

+(CAGradientLayer *)getBackgroundLayer:(CGRect)bounds withColors:(NSArray *)colors andLocations:(NSArray *)locations
{
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = bounds;
  gradient.colors = colors;
  gradient.locations = locations;
  return gradient;
}

+ (NSString *)colorToHexString:(UIColor *)color
{
  NSString *hexString = nil;
  
  if (color && CGColorGetNumberOfComponents(color.CGColor) == 4) {
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r,g,b;
    r = roundf(components[0] * 255.0);
    g = roundf(components[1] * 255.0);
    b = roundf(components[2] * 255.0);
    
    hexString = [NSString stringWithFormat:@"%02x%02x%02x", (int)r, (int)g, (int)b];
  }
  
  return hexString;
}

+ (NSString *)colorToJsonString:(UIColor *)color
{
  NSString *jsonString = nil;
  
  if (color && CGColorGetNumberOfComponents(color.CGColor) == 4) {
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r,g,b;
    r = roundf(components[0] * 255.0);
    g = roundf(components[1] * 255.0);
    b = roundf(components[2] * 255.0);
    
    NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.5f", r], [NSString stringWithFormat:@"%1.5f", g], [NSString stringWithFormat:@"%1.5f", b], nil];
    NSArray *keys = [NSArray arrayWithObjects:@"Red", @"Green", @"Blue", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (!jsonData) {
      NSLog(@"Error writing json data: %@", error.localizedDescription);
    } else {
      jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
//    hexString = [NSString stringWithFormat:@"%02x%02x%02x", (int)r, (int)g, (int)b];
  }
  
  return jsonString;
}

+(UIColor *)getBackgroundColor
{
  UIColor *backgroundColor = nil;
  //[UIColor colorWithRed:186.0f/255.0f green:209.0f/255.0f blue:232.0f/255.0f alpha:1.0]
//  backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:4.0f/255.0f blue:177.0f/255.0f alpha:1.0]; //koyu pembe
//  backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:109.0f/255.0f blue:220.0f/255.0f alpha:1.0]; //daha acik pembe
  backgroundColor = [UIColor colorWithRed:255.0/255.0 green:190.0/255.0 blue:201.0/255.0 alpha:1.0];
  return backgroundColor;
}

+(NSString *)dateToString:(NSDate *)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
  return [dateFormatter stringFromDate:date];
}
/*
+(NSArray *)getNavigationBarRightSideItemsForController:(id)instance selector:(SEL)action andForPage:(OKPageType) pageType
{
//  NSArray *arr = nil;
  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"] style:UIBarButtonItemStylePlain target:instance action:@selector(settingsButtonTap:)];
  
  UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
  //  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"settings", okStringsTableName, nil) style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTap:)];
  UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_navBar"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTap:)];

}
*/
@end
