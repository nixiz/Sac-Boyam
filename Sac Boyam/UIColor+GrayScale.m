//
//  UIColor+GrayScale.m
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 15/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UIColor+GrayScale.h"

@implementation UIColor (GrayScale)

-(CGFloat) grayScaleColor
{
  CGFloat gray = 0.0;
  const CGFloat *comp = CGColorGetComponents([self CGColor]);
  gray = (0.299f * comp[0]) + (0.587f * comp[1]) + (0.114f * comp[2]);
  return gray;
}


@end
