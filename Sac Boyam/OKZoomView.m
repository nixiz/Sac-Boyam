//
//  OKZoomView.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 02/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKZoomView.h"
#import "UIImage+AverageColor.h"
#import "OKUtils.h"
#import "UIImage+ImageEffects.h"

@implementation OKZoomView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.newPoint = CGPointMake(0, 0);
    self.previewImage = nil;
    CGRect rec = [self getRectangleFromPoint:self.newPoint withDimensions:80];
    self.imageView = [[UIImageView alloc] initWithFrame:rec];
    self.imageView.layer.cornerRadius = 80;
    self.imageView.layer.masksToBounds = YES;

    [self.imageView setAlpha:0.95];

    [self addSubview:self.imageView];
    // Initialization code
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame andStartPoint:(CGPoint)point
{
  self = [super initWithFrame:frame];
  if (self) {
    self.newPoint = point;
    self.previewImage = nil;
    CGRect rec = [self getRectangleFromPoint:self.newPoint withDimensions:80];
    self.imageView = [[UIImageView alloc] initWithFrame:rec];
    self.imageView.layer.cornerRadius = 80;
    self.imageView.layer.masksToBounds = YES;
    [self.imageView setAlpha:0.95];

    [self addSubview:self.imageView];
    // Initialization code
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame andStartPoint:(CGPoint)point PreviewImage:(UIImage *)previewImage
{
  self = [super initWithFrame:frame];
  if (self) {
    self.newPoint = point;
    self.previewImage = previewImage;
    CGRect rec = [self getRectangleFromPoint:self.newPoint withDimensions:80];
    self.imageView = [[UIImageView alloc] initWithFrame:rec];
    self.imageView.layer.cornerRadius = 80;
    self.imageView.layer.masksToBounds = YES;
    [self.imageView setAlpha:0.95];

    [self addSubview:self.imageView];

    // Initialization code
  }
  return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGRect rec = [self getRectangleFromPoint:self.newPoint withDimensions:80];

  UIImage *glossImage = [UIImage imageNamed:@"final_effect_2.png"];

  CGRect drawingRect = CGRectMake(0, 0, rec.size.width, rec.size.height);
  UIGraphicsBeginImageContext(drawingRect.size);
  [self.previewImage drawInRect:drawingRect];
  [glossImage drawInRect:drawingRect blendMode:kCGBlendModeScreen alpha:0.3];
  UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  [self.imageView setFrame:rec];
  [self.imageView setImage:blendedImage];
  self.imageView.layer.borderWidth = 3.0;
  self.imageView.layer.borderColor = [[UIColor clearColor] CGColor];
/*
 [self.view.layer insertSublayer:[OKUtils getBackgroundLayer:self.view.bounds] atIndex:0];
*/
  
}

- (CGRect)getRectangleFromPoint:(CGPoint)point
{
  CGFloat dx,dy;
  dx = point.x >= 16 ? 16 : 0;
  dy = point.y >= 16 ? 16 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, 32, 32);
}

- (CGRect)getRectangleFromPoint:(CGPoint)point withDimensions:(CGFloat)dim
{
  CGFloat dx,dy;
//  dx = point.x >= dim ? dim : 0;
//  dy = point.y >= dim ? dim : 0;
  dx = dim;
  dy = dim;
  
  return CGRectMake(point.x - dx, point.y - dy, dim * 2, dim * 2);
}

/*
 UIGraphicsBeginImageContextWithOptions(self.previewImage.size, NO, self.previewImage.scale);
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextTranslateCTM(context, 0, self.previewImage.size.height);
 CGContextScaleCTM(context, 1.0, -1.0);
 
 CGContextSetBlendMode(context, kCGBlendModeNormal);
 
 // Create gradient
 NSArray *colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[self.previewImage averageColor].CGColor, nil];
 //  CGFloat locations[2] = {0.05, 0.9};
 CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
 CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
 
 // Apply gradient
 CGContextClipToMask(context, rect, self.previewImage.CGImage);
 CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, self.previewImage.size.height), kCGGradientDrawsAfterEndLocation);
 //  CGPoint startPoint = CGPointMake(rec.origin.x, rec.origin.y);
 //  CGPoint endPoint = CGPointMake(self.previewImage.size.width / 2, self.previewImage.size.height / 2);
 //  CGContextDrawRadialGradient(context, gradient, startPoint, 0, endPoint, 10, kCGGradientDrawsAfterEndLocation);
 UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 CGGradientRelease(gradient);
 CGColorSpaceRelease(space);
*/
@end
