//
//  UIImage+AverageColor.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 25/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UIImage+AverageColor.h"

@implementation UIImage (AverageColor)

- (UIColor *)averageColor {
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char rgba[4];
  CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  
  CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  
  if(rgba[3] > 0) {
    CGFloat alpha = ((CGFloat)rgba[3])/255.0;
    CGFloat multiplier = alpha/255.0;
    return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                           green:((CGFloat)rgba[1])*multiplier
                            blue:((CGFloat)rgba[2])*multiplier
                           alpha:alpha];
  }
  else {
    return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                           green:((CGFloat)rgba[1])/255.0
                            blue:((CGFloat)rgba[2])/255.0
                           alpha:((CGFloat)rgba[3])/255.0];
  }
}

- (UIImage *)addTextToImageWithText:(NSString *)text
{
  CGPoint point = CGPointMake(self.size.width/4, self.size.height/2);
  UIFont *font = [UIFont boldSystemFontOfSize:12];
  UIGraphicsBeginImageContext(self.size);
  [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
  CGRect rect = CGRectMake(point.x, point.y, self.size.width, self.size.height);
  [[UIColor whiteColor] set];
  [text drawInRect:CGRectIntegral(rect) withFont:font];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

- (UIImage *)addTextToImageWithText:(NSString *)text atPoint:(CGPoint)point
{
  UIFont *font = [UIFont boldSystemFontOfSize:12];
  UIGraphicsBeginImageContext(self.size);
  [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
  CGRect rect = CGRectMake(point.x, point.y, self.size.width, self.size.height);
  [[UIColor whiteColor] set];
  [text drawInRect:CGRectIntegral(rect) withFont:font];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}


@end
