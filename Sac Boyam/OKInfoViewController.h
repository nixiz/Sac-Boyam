//
//  OKInfoViewController.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKUtils.h"

@interface OKInfoViewController : UIViewController <UIPageViewControllerDataSource>

@property OKPageType pageIndex;
@property (strong, nonatomic) UIImage *screenShot;
@end

