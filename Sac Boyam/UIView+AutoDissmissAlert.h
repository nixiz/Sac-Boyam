//
//  UIView+AutoDissmissAlert.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 20/02/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoDissmissAlert)

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title;
- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title afterDelay:(NSTimeInterval)delay;

@end
