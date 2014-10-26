//
//  OKInfoChildViewController.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

@protocol OKInfoChildViewControllerDelegate <NSObject>

- (void)skipButtonTapped;
- (void)closeButtonTapped;

@end

@interface OKInfoChildViewController : UIViewController
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;
@property (weak, nonatomic) id<OKInfoChildViewControllerDelegate> delegate;
@property NSInteger pageIndex;
@property BOOL showDoneButton;
@end