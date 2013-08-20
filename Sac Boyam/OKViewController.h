//
//  OKViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "MyCutomView.h"

@interface OKViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
- (IBAction)SelectNewImage:(id)sender;

@property FDTakeController *takeController;

@end
