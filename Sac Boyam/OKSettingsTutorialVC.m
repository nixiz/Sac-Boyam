//
//  OKSettingsTutorialVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 03/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "OKSettingsTutorialVC.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+AverageColor.h"
#import "OKAppDelegate.h"

@interface OKSettingsTutorialVC () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) NSDictionary *pointsDict;
//@property (strong, nonatomic) NSEnumerator *dictEnumerator;
@property (strong, nonatomic) IBOutlet UIImageView *maskImageView;
@property (strong, nonatomic) UILabel *textLbl;
- (IBAction)tapped:(UITapGestureRecognizer *)sender;
@property (strong, nonatomic) NSDictionary *textDict;
@end

@implementation OKSettingsTutorialVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.autoresizesSubviews = NO;
  UIColor *tintColor = [UIColor colorWithWhite:0.51 alpha:0.73];
  UIImage *img = [self.backgroundImage applyBlurWithRadius:10 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
  self.view.backgroundColor = [UIColor colorWithPatternImage:img];
  
  CGRect firstElementRect = [[self.pointsDict valueForKey:@"item-1"] CGRectValue];
  CGPoint firstElementPoint = firstElementRect.origin;
  
  CGRect rectForFisrtElement = CGRectMake(0, 0, self.view.bounds.size.width, firstElementRect.size.height);
  rectForFisrtElement.origin.y = firstElementPoint.y;
  NSLog(@"Frame Rect %@", NSStringFromCGRect(rectForFisrtElement));
  self.maskImageView = [[UIImageView alloc] initWithFrame:rectForFisrtElement];
  [self.maskImageView setContentMode:UIViewContentModeCenter];
  [self.maskImageView setAlpha:0.8];
  UIImage *maskImg = [self.backgroundImage cropImageWithRect:rectForFisrtElement];
  [self.maskImageView setImage:maskImg];
  [self.view addSubview:self.maskImageView];
  
//  self.textLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, rectForFisrtElement.origin.y - 50.0, self.view.bounds.size.width, 50.0)];
  self.textLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50.0)];
  [self.textLbl setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0]];
  [self.textLbl setNumberOfLines:0];
  [self.textLbl setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.85]];
  [self.textLbl setTextAlignment:NSTextAlignmentCenter];
  [self.textLbl setAdjustsFontSizeToFitWidth:YES];
  
  [self.textLbl setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
  [self.textLbl setText:NSLocalizedStringFromTable(@"tap-to-cont", okStringsTableName, nil)];

  UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.textLbl.frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12.5, 12.5)];
  CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
  maskLayer.frame = self.textLbl.frame;
  maskLayer.path = maskPath.CGPath;
  self.textLbl.layer.mask = maskLayer;
  [self.view addSubview:self.textLbl];
  [self.textLbl setFrame:CGRectMake(0.0, rectForFisrtElement.origin.y - 50.0, self.view.bounds.size.width, 50.0)];
  
  //NSLocalizedStringFromTable(@"recordTime", okStringsTableName, nil)
  self.textDict = @{@"item-1": @"settings-item-1-exp",
                    @"item-2": @"settings-item-2-exp",
                    @"item-3": @"settings-item-3-exp",
                    @"item-4": @"settings-item-4-exp",
                    @"item-5": @"settings-item-5-exp"};
  
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andContentPoints:(NSDictionary *)contentPointsDict
{
  self.backgroundImage = image;
  self.pointsDict = contentPointsDict;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Gesture Handle

- (IBAction)tapped:(UITapGestureRecognizer *)sender
{
  static int counter = 0;
  
  if (++counter <= 5)
  {
    CGRect firstElementRect = [[self.pointsDict valueForKey:[NSString stringWithFormat:@"item-%@", @(counter)]] CGRectValue];
    CGPoint firstElementPoint = firstElementRect.origin;
    
    CGRect rectForFisrtElement = CGRectMake(0, 0, self.view.bounds.size.width, firstElementRect.size.height);
    rectForFisrtElement.origin.y = firstElementPoint.y;
    NSLog(@"Frame Rect %@", NSStringFromCGRect(rectForFisrtElement));
    
    UIImage *maskImg = [self.backgroundImage cropImageWithRect:rectForFisrtElement];
    
    CGRect rectForLbl = CGRectMake(0.0, rectForFisrtElement.origin.y - 50.0, self.view.bounds.size.width, 50.0);
    NSString *textForLbl = [self.textDict valueForKey:[NSString stringWithFormat:@"item-%@", @(counter)]];
    textForLbl = NSLocalizedStringFromTable(textForLbl, okStringsTableName, nil);
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
      [self.textLbl setFrame:rectForLbl];
      [self.textLbl setText:textForLbl];
      [self.maskImageView setFrame:rectForFisrtElement];
      [self.maskImageView setImage:maskImg];
    } completion:nil];
  } else {
    [self.view setUserInteractionEnabled:NO];
    [self dismissViewControllerAnimated:YES completion:^{
      [self.view setUserInteractionEnabled:YES];
      counter = 0;
    }];
  }
}
@end
