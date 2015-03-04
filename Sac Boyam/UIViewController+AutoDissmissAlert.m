//
//  UIViewController+AutoDissmissAlert.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 02/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "UIViewController+AutoDissmissAlert.h"

@implementation UIViewController (AutoDissmissAlert)

- (void)dismissAlertView:(UIAlertView *)alertView
{
  if ([alertView isVisible]) {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
  }
}

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title
{
  [self showAutoDismissedAlertWithMessage:message withTitle:title afterDelay:0.3];
}

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title afterDelay:(NSTimeInterval)delay
{
  UIAlertView *alarma = [[UIAlertView alloc] initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
  [alarma show];
  [self performSelector:@selector(dismissAlertView:) withObject:alarma afterDelay:delay];
}

@end