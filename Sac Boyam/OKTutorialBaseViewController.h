//
//  OKTutorialBaseViewController.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 27/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OKInfoChildViewControllerDelegate <NSObject>

- (void)skipButtonTapped;
- (void)closeButtonTapped;

@end

@interface OKTutorialBaseViewController : UIViewController
@property (weak, nonatomic) id<OKInfoChildViewControllerDelegate> delegate;
@property NSInteger pageIndex;
@property BOOL showDoneButton;

@end
