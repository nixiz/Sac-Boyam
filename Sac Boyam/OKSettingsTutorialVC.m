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
#define DefaultHeightForExplView 50

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
  UIColor *tintColor = [UIColor colorWithWhite:0.37 alpha:0.73];
  UIImage *img = [self.backgroundImage applyBlurWithRadius:7 tintColor:tintColor saturationDeltaFactor:.8 maskImage:nil];
//  self.view.backgroundColor = [UIColor colorWithPatternImage:[self.backgroundImage applyDarkEffect]];
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
  
  CGSize cornerRadiusForLayer = CGSizeMake(self.heightOfExplanationView/4.0, self.heightOfExplanationView/4.0);
  
//  self.maskImageView.layer.masksToBounds = YES;
//  self.maskImageView.layer.mask = [self getMaskLayerForView:self.maskImageView toTopOfView:self.showExplanationBelowView cornerRadii:cornerRadiusForLayer];
  
  self.textLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.heightOfExplanationView)];
  [self.textLbl setFont:[UIFont fontWithName:@"Helvetica Neue Medium" size:17.0]];
  [self.textLbl setNumberOfLines:0];
  [self.textLbl setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.85]];
  [self.textLbl setTextAlignment:NSTextAlignmentCenter];
  [self.textLbl setAdjustsFontSizeToFitWidth:YES];
  [self.textLbl setMinimumScaleFactor:12.0/17.0]; //set minimum fint size to 13
//  [self.textLbl setBackgroundColor:[UIColor clearColor]];
  [self.textLbl setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.35]];
  NSString *textForLbl = [self.textDict valueForKey:@"item-1"];
  textForLbl = NSLocalizedStringFromTable(textForLbl, okStringsTableName, nil);
  NSString *tapToContStr = NSLocalizedStringFromTable(@"tap-to-cont", okStringsTableName, nil);
  if (self.showExplanationBelowView) {
    [self.textLbl setText:[NSString stringWithFormat:@"%@\n%@", textForLbl, tapToContStr]];
  } else {
    [self.textLbl setText:[NSString stringWithFormat:@"%@\n%@", tapToContStr, textForLbl]];
  }
  
  self.textLbl.layer.mask = [self getMaskLayerForView:self.textLbl toTopOfView:!self.showExplanationBelowView cornerRadii:cornerRadiusForLayer];
  [self.view addSubview:self.textLbl];
  
  if (self.showExplanationBelowView) {
    [self.textLbl setFrame:CGRectMake(0.0, rectForFisrtElement.origin.y + rectForFisrtElement.size.height, self.view.bounds.size.width, self.heightOfExplanationView)];
  } else {
    [self.textLbl setFrame:CGRectMake(0.0, rectForFisrtElement.origin.y - self.heightOfExplanationView, self.view.bounds.size.width, self.heightOfExplanationView)];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andContentPoints:(NSDictionary *)contentPointsDict WithExplanationDescriptors:(NSDictionary *)explDescriptorDict
{
  self.backgroundImage = image;
  self.pointsDict = contentPointsDict;
  self.textDict = explDescriptorDict;
  NSAssert([self.pointsDict count] == [self.textDict count], @"Counts of dictionaries must be same! [%lu]!=[%lu]", (unsigned long)[self.pointsDict count], (unsigned long)[self.textDict count]);
  self.heightOfExplanationView = DefaultHeightForExplView;
  self.showExplanationBelowView = NO;
//  self.dictEnumerator = [self.pointsDict keyEnumerator];
}

- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andContentPoints:(NSDictionary *)contentPointsDict
{
  NSDictionary *dict = @{@"item-1": @"settings-item-1-exp",
                         @"item-2": @"settings-item-2-exp",
                         @"item-3": @"settings-item-3-exp",
                         @"item-4": @"settings-item-4-exp",
                         @"item-5": @"settings-item-5-exp"};
  [self initiateTutorialControllerWithBgImg:image andContentPoints:contentPointsDict WithExplanationDescriptors:dict];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CAShapeLayer *)getMaskLayerForView:(UIView *)view toTopOfView:(BOOL)top cornerRadii:(CGSize)cornerRadius
{
  UIBezierPath *maskPath;
  CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
  [maskLayer setBackgroundColor:[UIColor clearColor].CGColor];
  if (!top) {
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:cornerRadius];
  } else {
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:cornerRadius];
  }
  maskLayer.frame = view.bounds;
  maskLayer.path = maskPath.CGPath;
  return maskLayer;
}

#pragma mark - Gesture Handle

- (IBAction)tapped:(UITapGestureRecognizer *)sender
{
  static int counter = 1;
  if (++counter <= self.pointsDict.count)
  {
    NSString *itemName = [NSString stringWithFormat:@"item-%@", @(counter)];
    
    CGRect firstElementRect = [[self.pointsDict valueForKey:itemName] CGRectValue];
    CGPoint firstElementPoint = firstElementRect.origin;
    
    CGRect rectForFisrtElement = CGRectMake(0, firstElementPoint.y, self.view.bounds.size.width, firstElementRect.size.height);
    NSLog(@"Frame Rect %@", NSStringFromCGRect(rectForFisrtElement));
    
    UIImage *maskImg = [self.backgroundImage cropImageWithRect:rectForFisrtElement];
    
    BOOL showBelow = self.showExplanationBelowView;
    if ([self.delegate respondsToSelector:@selector(showExplanationViewBelowForItem:)]) {
      showBelow = [self.delegate showExplanationViewBelowForItem:itemName];
    }
    CGRect rectForLbl = CGRectMake(0.0, rectForFisrtElement.origin.y - self.heightOfExplanationView, self.view.bounds.size.width, self.heightOfExplanationView);
    if (showBelow) {
      rectForLbl = CGRectMake(0.0, rectForFisrtElement.origin.y + rectForFisrtElement.size.height, self.view.bounds.size.width, self.heightOfExplanationView);
    }
//    CGRect rectForLbl = CGRectMake(0.0, rectForFisrtElement.origin.y - 50.0, self.view.bounds.size.width, 50.0);
    
    NSString *textForLbl = [self.textDict valueForKey:itemName];
    textForLbl = NSLocalizedStringFromTable(textForLbl, okStringsTableName, nil);
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent animations:^{
      [self.textLbl setFrame:rectForLbl];
      [self.textLbl setText:textForLbl];
      [self.maskImageView setFrame:rectForFisrtElement];
//      if (!CGSizeEqualToSize(self.maskImageView.frame.size, rectForFisrtElement.size)) {
//        self.maskImageView.layer.mask.frame = self.maskImageView.bounds;
////        self.maskImageView.layer.mask = [self getMaskLayerForView:self.maskImageView toTopOfView:self.showExplanationBelowView cornerRadii:CGSizeMake(self.heightOfExplanationView/4.0, self.heightOfExplanationView/4.0)];
//      }
      [self.maskImageView setImage:maskImg];
    } completion:nil];
  } else {
    [UIView transitionWithView:self.view duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut animations:^{
      [self.maskImageView removeFromSuperview];
      [self.textLbl removeFromSuperview];
    } completion:^(BOOL finished) {
      [self dismissViewControllerAnimated:NO completion:^{
        counter = 1;
      }];
    }];
    
  }
}
@end
