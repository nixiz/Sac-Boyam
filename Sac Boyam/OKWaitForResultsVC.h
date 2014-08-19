//
//  OKWaitForResultsVC.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 14/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OKWaitForResultsDelegate <NSObject>

-(void)userCancelledRequest;

@end

@interface OKWaitForResultsVC : UIViewController
@property (weak, nonatomic) id<OKWaitForResultsDelegate> delegate;

-(void)initWithBackgroundImage:(UIImage *)image;
-(void)closeModalViewAnimated:(BOOL) animated;
@end
