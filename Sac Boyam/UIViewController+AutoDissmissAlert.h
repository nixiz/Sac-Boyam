//
//  UIViewController+AutoDissmissAlert.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 02/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AutoDissmissAlert)
- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title;
- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title afterDelay:(NSTimeInterval)delay;

@end
