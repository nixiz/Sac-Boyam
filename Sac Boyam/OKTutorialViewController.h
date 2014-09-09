//
//  OKTutorialViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKTutorialViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
-(void)initWithMainImage:(UIImage *)image andText:(NSString *)text;
@end
