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
                     (id)[[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.90f]  CGColor], //white color
                     (id)[[UIColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:130.0f/255.0f alpha:0.85f] CGColor], //yellow
                     //                     (id)[[UIColor colorWithRed:87.0f/255.0f green:49.0f/255.0f blue:27.0f/255.0f alpha:1.0f]    CGColor], //red
                     nil];
  gradient.colors = colors;
  gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], /*[NSNumber numberWithFloat:0.85f],*/ [NSNumber numberWithFloat:1.0f], nil];
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

@end
