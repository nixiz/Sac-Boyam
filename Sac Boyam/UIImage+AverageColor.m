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
  unsigned long byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
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

+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
  UIImage *img;
  CGRect rect = CGRectMake(0, 0, size.width, size.height);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return img;
}

+(UIImage *)imageWithCMSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  UIImage *img;
  
  // Get a CMSampleBuffer's Core Video image buffer for the media data
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the base address of the pixel buffer
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  
  // Get the number of bytes per row for the pixel buffer
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  
  // Get the number of bytes per row for the pixel buffer
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  // Create a device-dependent RGB color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // Create a bitmap graphics context with the sample buffer data
  CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                               bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  // Create a Quartz image from the pixel data in the bitmap graphics context
  CGImageRef quartzImage = CGBitmapContextCreateImage(context);
  // Unlock the pixel buffer
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  // Free up the context and color space
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  // Create an image object from the Quartz image
  img = [UIImage imageWithCGImage:quartzImage];
  
  // Release the Quartz image
  CGImageRelease(quartzImage);
  
  return img;
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


- (UIImage *)fixOrientation {
  
  // No-op if the orientation is already correct
  if (self.imageOrientation == UIImageOrientationUp) return self;
  
  // We need to calculate the proper transformation to make the image upright.
  // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
  CGAffineTransform transform = CGAffineTransformIdentity;
//  switch (currentOrientation) {
//    case UIDeviceOrientationFaceDown:
//    case UIDeviceOrientationFaceUp:
//    case UIDeviceOrientationUnknown:
//      return;
//    case UIDeviceOrientationPortrait:
//      rotation = 0;
//      statusBarOrientation = UIInterfaceOrientationPortrait;
//      break;
//    case UIDeviceOrientationPortraitUpsideDown:
//      rotation = -M_PI;
//      statusBarOrientation = UIInterfaceOrientationPortraitUpsideDown;
//      break;
//    case UIDeviceOrientationLandscapeLeft:
//      rotation = M_PI_2;
//      statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
//      break;
//    case UIDeviceOrientationLandscapeRight:
//      rotation = -M_PI_2;
//      statusBarOrientation = UIInterfaceOrientationLandscapeRight;
//      break;
//  }
  switch (self.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
      break;
  }
  
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
      break;
  }
  
  // Now we draw the underlying CGImage into a new context, applying the transform
  // calculated above.
  CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                           CGImageGetBitsPerComponent(self.CGImage), 0,
                                           CGImageGetColorSpace(self.CGImage),
                                           CGImageGetBitmapInfo(self.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
      break;
  }
  
  // And now we just create a new UIImage from the drawing context
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  return img;
}
@end
