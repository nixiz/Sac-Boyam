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
#import "OKSettingsViewController.h"

@interface OKViewController : UIViewController<OKSettingsDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *lblRenkKodu;
- (IBAction)SelectNewImage:(id)sender;

@property FDTakeController *takeController;

@end
