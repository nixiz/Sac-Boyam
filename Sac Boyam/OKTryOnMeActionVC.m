//
//  OKTryOnMeActionVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 09/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKTryOnMeActionVC.h"
#import "UIColor+GrayScale.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "UIView+CreateImage.h"

@interface OKTryOnMeActionVC ()
@property (weak, nonatomic) IBOutlet UILabel *sliderResolutionLbl;
@property (weak, nonatomic) IBOutlet UISlider *resSlider;
- (IBAction)sliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *productColorImg;
@property (weak, nonatomic) IBOutlet UIImageView *userColorImg;
- (IBAction)actionDoneTapped:(id)sender;
@end

@implementation OKTryOnMeActionVC

- (void)viewDidLoad {
  [super viewDidLoad];
  
  CGRect rect = self.productColorImg.bounds;
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [self.productColor CGColor]);
  CGContextFillRect(context, rect);
  UIImage *blendImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
//  self.previewImage.layer.borderWidth = 1.0;
//  self.previewImage.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.8] CGColor];
  
  self.productColorImg.layer.cornerRadius = 12.0;
  self.productColorImg.layer.masksToBounds = YES;
  [self.productColorImg setImage:blendImage];
  
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context2 = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context2, [self.userColor CGColor]);
  CGContextFillRect(context2, rect);
  UIImage *firstImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  self.userColorImg.layer.cornerRadius = 12.0;
  self.userColorImg.layer.masksToBounds = YES;
  [self.userColorImg setImage:firstImage];
  
  CGRect viewRect = CGRectMake(0, 0, self.view.bounds.size.width, 170);
  viewRect.origin = self.view.bounds.origin;
  self.view.frame = viewRect;
//  self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.45];
//  self.sliderValue = self.resSlider.value;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
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

- (IBAction)sliderValueChanged:(id)sender {
  [self.sliderResolutionLbl setText:[@(self.resSlider.value) stringValue]];
}

- (IBAction)actionDoneTapped:(id)sender {
  if (self.delegate) {
    if ([self.delegate respondsToSelector:@selector(actionCompletedWithResolution:)]) {
      [self.delegate actionCompletedWithResolution:self.resSlider.value];
    }
  } else {
    [self dismissViewControllerAnimated:NO completion:nil];
  }
}
@end
