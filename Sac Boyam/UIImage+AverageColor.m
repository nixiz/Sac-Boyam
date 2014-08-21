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

- (UIImage *)addTextToImageWithText:(NSString *)text andColor:(UIColor *)color
{
  if (color == nil) {
//    color = [UIColor whiteColor];
    //mercur white on interface builder colour palette
    color = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
  }
//  CGPoint point = CGPointMake(self.size.width/4, self.size.height/2);
//  UIFont *font = [UIFont boldSystemFontOfSize:16];
  UIGraphicsBeginImageContext(self.size);
  [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
  CGRect rect = CGRectMake(0, self.size.height/2, self.size.width, self.size.height);
  NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:24], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle};
  [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
//  [[UIColor whiteColor] set];
//  [color set];
//  [text drawInRect:CGRectIntegral(rect) withFont:font];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

- (UIImage *)addTextToImageWithText:(NSString *)text atPoint:(CGPoint)point andColor:(UIColor *)color
{
  if (color == nil) {
    color = [UIColor whiteColor];
  }
//  UIFont *font = [UIFont boldSystemFontOfSize:16];
  UIGraphicsBeginImageContext(self.size);
  [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
  CGRect rect = CGRectMake(point.x, point.y, self.size.width, self.size.height);
  NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle};
  [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
//  [[UIColor whiteColor] set];
//  [color set];
//  [text drawInRect:CGRectIntegral(rect) withFont:font];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count
{
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
  
  // First get the image into your data buffer
  CGImageRef imageRef = [image CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
  
  // Now your rawData contains the image data in the RGBA8888 pixel format.
  int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
  for (int ii = 0 ; ii < count ; ++ii)
  {
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    byteIndex += 4;
    
    UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    [result addObject:acolor];
  }
  
  free(rawData);
  
  return result;
}

- (UIImage *)cropImageWithRect:(CGRect)rect {
  
  rect = CGRectMake(rect.origin.x*self.scale,
                    rect.origin.y*self.scale,
                    rect.size.width*self.scale,
                    rect.size.height*self.scale);
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                        scale:self.scale
                                  orientation:self.imageOrientation];
  CGImageRelease(imageRef);
  return croppedImage;
}

- (UIImage *)cropImageWithRect:(CGRect)rect withBound:(CGRect)bound
{
  UIGraphicsBeginImageContext( bound.size );
  [self drawInRect:bound];
  UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  rect = CGRectMake(rect.origin.x*picture1.scale,
                    rect.origin.y*picture1.scale,
                    rect.size.width*picture1.scale,
                    rect.size.height*picture1.scale);
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([picture1 CGImage], rect);
  UIImage *result = [UIImage imageWithCGImage:imageRef
                                        scale:picture1.scale
                                  orientation:picture1.imageOrientation];
  CGImageRelease(imageRef);
  return result;
}


@end
