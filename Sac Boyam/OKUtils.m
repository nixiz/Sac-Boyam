//
//  OKUtils.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 26/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKUtils.h"

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

+(UIColor *)getBackgroundColor
{
  UIColor *backgroundColor = nil;
  //[UIColor colorWithRed:186.0f/255.0f green:209.0f/255.0f blue:232.0f/255.0f alpha:1.0]
//  backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:4.0f/255.0f blue:177.0f/255.0f alpha:1.0]; //koyu pembe
//  backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:109.0f/255.0f blue:220.0f/255.0f alpha:1.0]; //daha acik pembe
  backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.45];
  return backgroundColor;
}


@end
