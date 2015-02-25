//
//  UIImage+AverageColor.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 25/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface UIImage (AverageColor)
- (UIColor *)averageColor;
- (UIImage *)addTextToImageWithText:(NSString *)text andColor:(UIColor *)color;
- (UIImage *)addTextToImageWithText:(NSString *)text atPoint:(CGPoint)point andColor:(UIColor *)color;
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count;
- (UIImage *)cropImageWithRect:(CGRect)rect;
- (UIImage *)cropImageWithRect:(CGRect)rect withBound:(CGRect)bound;

+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size;

+(UIImage *)imageWithCMSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (UIImage *)fixOrientation;
@end
