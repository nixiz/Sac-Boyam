//
//  TapToPointView.m
//  SacBoyam-BendeDene
//
//  Created by Oguzhan Katli on 21/10/14.
//  Copyright (c) 2014 Oğuzhan Katlı. All rights reserved.
//

#import "TapToPointView.h"

@implementation TapToPointView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//  CGRect rectForImage = CGRectMake(0, 0, 15, 15);
//  CGSize msize = self.bounds.size;
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
  CGContextFillRect(context, rect);
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
  [imageView setImage:img];
  [imageView setAlpha:.85];
  [self addSubview:imageView];
}

@end
