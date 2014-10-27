//
//  OKInfoChildViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKInfoChildViewController.h"
#import "UIView+CreateImage.h"
#import "UIImage+ImageEffects.h"

@interface OKInfoChildViewController ()
//@property (weak, nonatomic) IBOutlet UIImageView *InfoImage;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
//@property (weak, nonatomic) IBOutlet UIButton *skipButton;
- (IBAction)skipButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;

@end

@implementation OKInfoChildViewController

- (void)viewDidLoad {
  [super viewDidLoad];
//  self.view.backgroundColor = [UIColor colorWithPatternImage:self.image];
  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_6"];
//  UIGraphicsBeginImageContext(self.view.bounds.size);
//  [backgroundImage drawInRect:self.view.bounds];
//  UIImage *backgroundcolor = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  backgroundImage = [backgroundImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.4 alpha:0.6] saturationDeltaFactor:1.3 maskImage:nil];
//  backgroundImage = [backgroundImage applyDarkEffect];
  
  UIColor *backColor = [UIColor colorWithPatternImage:backgroundImage];
  self.view.backgroundColor = backColor;
  [self.doneButton setTitle:@"done" forState:UIControlStateNormal];
//  [self.skipButton setTitle:@"skip" forState:UIControlStateNormal];
  
//  self.showDoneButton = YES; //always show done button!
//  if (self.pageIndex == 4) {
////    [self.skipButton setHidden:YES];
//    [self.doneButton setHidden:NO];
//  } else {
////    [self.skipButton setHidden:NO];
//    if (!self.showDoneButton) {
//      [self.doneButton setHidden:YES];
//    }
//  }
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)skipButtonTapped:(id)sender {
  if ([[self delegate] respondsToSelector:@selector(skipButtonTapped)]) {
    [self.delegate skipButtonTapped];
  }
}

- (IBAction)doneButtonTapped:(id)sender {
  if ([[self delegate] respondsToSelector:@selector(closeButtonTapped)]) {
    [self.delegate closeButtonTapped];
  }
}
@end