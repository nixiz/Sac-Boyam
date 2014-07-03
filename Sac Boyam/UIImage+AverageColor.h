//
//  UIImage+AverageColor.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 25/06/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AverageColor)
- (UIColor *)averageColor;
- (UIImage *)addTextToImageWithText:(NSString *)text;
- (UIImage *)addTextToImageWithText:(NSString *)text atPoint:(CGPoint)point;

@end
