//
//  UIViewController+MotionEffect.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/04/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MotionEffect)
- (void)addMotionEffectToViewOnlyHorizontal:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue;
- (void)addMotionEffectToViewOnlyHorizontal:(UIView *)toView;
- (void)addMotionEffectToViewOnlyVertical:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue;
- (void)addMotionEffectToViewOnlyVertical:(UIView *)toView;
- (void)addMotionEffectToView:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue;
- (void)addMotionEffectToView:(UIView *)toView;
@end
