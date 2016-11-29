//
//  UIViewController+AutoDissmissAlert.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 02/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "UIViewController+AutoDissmissAlert.h"

@implementation UIViewController (AutoDissmissAlert)

//- (void)dismissAlertView:(UIAlertView *)alertView
//{
//  if ([alertView isVisible]) {
//    [alertView dismissWithClickedButtonIndex:0 animated:YES];
//  }
//}

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title
{
  [self showAutoDismissedAlertWithMessage:message withTitle:title afterDelay:0.3];
}

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title afterDelay:(NSTimeInterval)delay
{
  UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                     }];
  [ac addAction:noAction];
  
  [self presentViewController:ac animated:YES completion:nil];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * 100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
    [ac dismissViewControllerAnimated:YES completion:nil];
  });

}

@end
