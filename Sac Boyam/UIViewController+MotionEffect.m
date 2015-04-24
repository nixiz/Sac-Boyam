//
//  UIViewController+MotionEffect.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/04/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "UIViewController+MotionEffect.h"

@implementation UIViewController (MotionEffect)
- (void)addMotionEffectToViewOnlyHorizontal:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue
{
  // Set horizontal effect
  UIInterpolatingMotionEffect *horizontalMotionEffect =
  [[UIInterpolatingMotionEffect alloc]
   initWithKeyPath:@"center.x"
   type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
  horizontalMotionEffect.minimumRelativeValue = @(-relativeValue);
  horizontalMotionEffect.maximumRelativeValue = @(relativeValue);
  
  // Create group to combine both
  UIMotionEffectGroup *group = [UIMotionEffectGroup new];
  group.motionEffects = @[horizontalMotionEffect];
  
  // Add both effects to your view
  [toView addMotionEffect:group];
}


- (void)addMotionEffectToViewOnlyHorizontal:(UIView *)toView
{
  [self addMotionEffectToViewOnlyHorizontal:toView withCustomMinMaxRelativities:10];
}

- (void)addMotionEffectToViewOnlyVertical:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue
{
  // Set vertical effect
  UIInterpolatingMotionEffect *verticalMotionEffect =
  [[UIInterpolatingMotionEffect alloc]
   initWithKeyPath:@"center.y"
   type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
  verticalMotionEffect.minimumRelativeValue = @(-relativeValue);
  verticalMotionEffect.maximumRelativeValue = @(relativeValue);
  
  // Create group to combine both
  UIMotionEffectGroup *group = [UIMotionEffectGroup new];
  group.motionEffects = @[verticalMotionEffect];
  
  // Add both effects to your view
  [toView addMotionEffect:group];
}

- (void)addMotionEffectToViewOnlyVertical:(UIView *)toView
{
  [self addMotionEffectToViewOnlyVertical:toView withCustomMinMaxRelativities:10];
}

- (void)addMotionEffectToView:(UIView *)toView withCustomMinMaxRelativities:(NSInteger)relativeValue
{
  // Set vertical effect
  UIInterpolatingMotionEffect *verticalMotionEffect =
  [[UIInterpolatingMotionEffect alloc]
   initWithKeyPath:@"center.y"
   type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
  verticalMotionEffect.minimumRelativeValue = @(-relativeValue);
  verticalMotionEffect.maximumRelativeValue = @(relativeValue);
  
  // Set horizontal effect
  UIInterpolatingMotionEffect *horizontalMotionEffect =
  [[UIInterpolatingMotionEffect alloc]
   initWithKeyPath:@"center.x"
   type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
  horizontalMotionEffect.minimumRelativeValue = @(-relativeValue);
  horizontalMotionEffect.maximumRelativeValue = @(relativeValue);
  
  // Create group to combine both
  UIMotionEffectGroup *group = [UIMotionEffectGroup new];
  group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
  
  // Add both effects to your view
  [toView addMotionEffect:group];
}

- (void)addMotionEffectToView:(UIView *)toView
{
  [self addMotionEffectToView:toView withCustomMinMaxRelativities:10];
}


@end
