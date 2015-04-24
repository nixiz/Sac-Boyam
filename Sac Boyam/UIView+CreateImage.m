//
//  UIView+CreateImage.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UIView+CreateImage.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (CreateImage)

- (UIImage *)createImageFromViewAfterScreenUpdates:(BOOL)afterUpdate
{
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
  [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdate];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSLog(@"Captured Image Size %@", NSStringFromCGSize([image size]));
  return image;
}

- (UIImage *)createImageFromView
{
  return [self createImageFromViewAfterScreenUpdates:YES];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
  CGImageRef maskRef = maskImage.CGImage;
  
  CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                      CGImageGetHeight(maskRef),
                                      CGImageGetBitsPerComponent(maskRef),
                                      CGImageGetBitsPerPixel(maskRef),
                                      CGImageGetBytesPerRow(maskRef),
                                      CGImageGetDataProvider(maskRef), NULL, false);
  
  CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
  UIImage *returnImage = [UIImage imageWithCGImage:masked];
  CGImageRelease(mask);
  CGImageRelease(masked);
  return returnImage;
}

-(UIColor *) getBackgroundColor
{
  UIImage *backgrounImage = [UIImage imageNamed:@"patt-4.jpg"];
  //TODO: do vibration and blur here!
  //  backgrounImage = [backgrounImage applyDarkEffect];
  backgrounImage = [backgrounImage applyBlurWithRadius:1.3 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  UIColor *backgroundPatternColor = [UIColor colorWithPatternImage:backgrounImage];
  return backgroundPatternColor;
//  return [UIColor whiteColor];
//  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_5"];
//  UIGraphicsBeginImageContext(self.bounds.size);
//  [backgroundImage drawInRect:self.bounds];
//  UIImage *backgroundcolor = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  
//  backgroundcolor = [backgroundcolor applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
//  return [UIColor colorWithPatternImage:backgroundcolor];
}


@end
