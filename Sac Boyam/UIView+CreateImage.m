//
//  UIView+CreateImage.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UIView+CreateImage.h"

@implementation UIView (CreateImage)

- (UIImage *)createImageFromView
{
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
  [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end
