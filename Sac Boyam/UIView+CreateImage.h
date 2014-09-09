//
//  UIView+CreateImage.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CreateImage)
- (UIImage *)createImageFromView;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
-(UIColor *) getBackgroundColor;
@end
