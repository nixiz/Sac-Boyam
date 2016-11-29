//
//  OKTryOnMeVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 08/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//
#import "OKAppDelegate.h"
#import "OKTryOnMeVC.h"
#import "UIColor+GrayScale.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "OKAppRater.h"
#import "UIView+CreateImage.h"
#import "UIBezierPath+Interpolation.h"
#import "CRVINTERGraphicsView.h"
#import "TapToPointView.h"
#import "OKMainViewController.h"

#import "OKSettingsTutorialVC.h"
#import "UIViewController+AutoDissmissAlert.h"

@interface OKTryOnMeVC () <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage *defaultImage;
@property (weak, nonatomic) IBOutlet UIImageView *previewImg;

@property CGRect previewImageBound;
@property (strong) UIColor *color;
@property (strong, nonatomic) UIButton *takePicBtn;

@property (strong, nonatomic) NSMutableArray *bezierPoints;
@property UITapGestureRecognizer *gestureRecognizer;
@property NSInteger tapCount;
@property (strong, nonatomic) CRVINTERGraphicsView *graphView;
- (IBAction)editButtonsTapped:(id)sender;
@property (strong, nonatomic) UIView *settingsView;
@property CGFloat blendAlphaValue;
@property (weak, nonatomic) IBOutlet UIToolbar *tryToolBar;
@property CGRect settingsViewRecoverFrame;
@property CGRect settingsViewHideFrame;

@property (strong, nonatomic) UIBezierPath *currentImagePath;
@property (strong, nonatomic) OKZoomView *myView;

@property (nonatomic) NSDictionary *framesDictionary;
@property (nonatomic) NSDictionary *explanationsDictionary;
@property (nonatomic) BOOL imageChanged;
@property NSInteger unsuccessTapCount;
@end

@implementation OKTryOnMeVC

- (void)viewDidLoad {
  [super viewDidLoad];  
  UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showTutorial)];
  
  self.navigationItem.rightBarButtonItems = @[camBtn, infoBtn];
  self.view.backgroundColor = [self.view getBackgroundColor];

  self.unsuccessTapCount = 1;
  self.tapCount = 0;
  self.bezierPoints = [NSMutableArray new];

  self.graphView = [[CRVINTERGraphicsView alloc] initWithFrame:self.view.frame];
  self.graphView.backgroundColor = [UIColor clearColor];
  [self.graphView setIsClosed:NO];
  [self.graphView setUseHermite:YES];
  [self.view insertSubview:self.graphView aboveSubview:self.previewImg];
  
//  self.gestureRecognizer = [[UITapGestureRecognizer alloc]
//                            initWithTarget:self
//                            action:@selector(tapped:)];
//  self.gestureRecognizer.delegate = self;
//  self.gestureRecognizer.numberOfTapsRequired = 1;
//  self.gestureRecognizer.numberOfTouchesRequired = 1;
//  [self.view addGestureRecognizer:self.gestureRecognizer];

  UIImage *userPhoto = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:userDefaultPhotoKey]];
  if (userPhoto) {
    [self.previewImg setImage:userPhoto];
    self.defaultImage = userPhoto;
  } else {
    NSString *imageOverlayString = NSLocalizedStringFromTable(@"imageOverlay", okStringsTableName, nil);
    self.takePicBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height/2.0, self.view.bounds.size.width, 30);
    [self.takePicBtn setFrame:buttonFrame];
    [self.takePicBtn addTarget:self action:@selector(SelectNewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.takePicBtn setTitle:imageOverlayString forState:UIControlStateNormal];
    [self.takePicBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    [self.takePicBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:24]];
    
    [self.view addSubview:self.takePicBtn];
  }
  
  if (self.colorModel) {
    self.color = [UIColor colorWithRed:[self.colorModel.red floatValue]
                                 green:[self.colorModel.green floatValue]
                                  blue:[self.colorModel.blue floatValue]
                                 alpha:1.0];
  } else {
    //it cant be null
    assert(NO);
  }
  self.blendAlphaValue = .24;
  CGRect toolBarFrame = self.tryToolBar.frame;
  self.settingsViewRecoverFrame = CGRectMake(0, toolBarFrame.origin.y - 52 + 20/*size of status bar*/, toolBarFrame.size.width, 56);
  self.settingsViewHideFrame = CGRectMake(0, toolBarFrame.origin.y + 20/*size of status bar*/, toolBarFrame.size.width, 56);
  self.settingsView = [[UIView alloc] initWithFrame:self.settingsViewHideFrame];
  self.settingsView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
  
  self.settingsView.layer.cornerRadius = 4.0;
  /*******
   | "lorem ipsum ipsala kim kum"   label column  (12 px)
   |
   |      -------X------            slider column (44 px)
   |
   *******/
  //create view objects for settings tap
  UILabel *sliderExplanationLabel = [[UILabel alloc] init];
  [sliderExplanationLabel setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
  [sliderExplanationLabel setText:NSLocalizedStringFromTable(@"tryOnMeSliderLabelText", okStringsTableName, nil)];
  [sliderExplanationLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
  [sliderExplanationLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.85]];
  [sliderExplanationLabel setTextAlignment:NSTextAlignmentCenter];
  //  [sliderExplanationLabel setAdjustsFontSizeToFitWidth:YES];
  [self.settingsView addSubview:sliderExplanationLabel];
  
  UISlider *alphaSlider = [[UISlider alloc] init];
  [alphaSlider setFrame:CGRectMake(0, 20, self.view.bounds.size.width, 36)];
  [alphaSlider setMaximumValue:1.0];
  [alphaSlider setMinimumValue:0.0];
  [alphaSlider setValue:self.blendAlphaValue animated:NO];
  [alphaSlider setContinuous:NO];
//  [sliderFPS setMinimumTrackImage:[[UIImage imageNamed:@"camera_slider_empty.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")]
//                         forState:UIControlStateNormal];
//  [sliderFPS setMaximumTrackImage:[[UIImage imageNamed:@"camera_slider_full.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")]
  UIImage *maxColorImage = [UIImage imageWithColor:self.color andSize:CGSizeMake(8, 8)];
  UIImage *minColorImage = [UIImage imageWithColor:[[UIColor colorWithWhite:0.2 alpha:0.32] colorWithAlphaComponent:0.32] andSize:CGSizeMake(8, 8)];
  [alphaSlider setMaximumTrackImage:[minColorImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")] forState:UIControlStateNormal];
  [alphaSlider setMinimumTrackImage:[maxColorImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")] forState:UIControlStateNormal];
  [alphaSlider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
  [self.settingsView addSubview:alphaSlider];
  
  [self.tryToolBar setBackgroundColor:[self.view getBackgroundColor]];
  [self.tryToolBar setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.previewImageBound = self.previewImg.bounds;
  self.myView = [[OKZoomView alloc] initWithFrame:self.previewImg.bounds andStartPoint:self.previewImg.bounds.origin];
  self.myView.backgroundColor = [UIColor clearColor];

  self.framesDictionary = @{@"item-1": [NSValue valueWithCGRect:self.previewImg.frame],
                            @"item-2": [NSValue valueWithCGRect:self.previewImg.frame],
                            @"item-3": [NSValue valueWithCGRect:self.previewImg.frame],
                            @"item-4": [NSValue valueWithCGRect:self.tryToolBar.frame],
                            @"item-5": [NSValue valueWithCGRect:self.tryToolBar.frame],
                            @"item-6": [NSValue valueWithCGRect:self.tryToolBar.frame]};
  
  self.explanationsDictionary = @{@"item-1": @"try-item-1-exp",
                                  @"item-2": @"try-item-2-exp",
                                  @"item-3": @"try-item-3-exp",
                                  @"item-4": @"try-item-4-exp",
                                  @"item-5": @"try-item-5-exp",
                                  @"item-6": @"try-item-6-exp"};
  [[OKAppRater sharedInstance] increaseTimeOfUse];
  [[OKAppRater sharedInstance] showRateThisApp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)showRateThisApp
//{
//  NSInteger timesOfResultView = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
//  NSInteger usesUntilPromt = [[[NSUserDefaults standardUserDefaults] objectForKey:usesUntilPromtKey] integerValue];
//  BOOL userDidRated = [[[NSUserDefaults standardUserDefaults] objectForKey:userDidRatedKey] boolValue];
//  
//  userDidRated = NO;
//  if (timesOfResultView > usesUntilPromt && !userDidRated) {
//    UIAlertView *rateThisAppAlert = [[UIAlertView alloc] initWithTitle:@"Saç Boyam"
//                                                               message:NSLocalizedStringFromTable(@"rateAppMessage", okStringsTableName, nil)
//                                                              delegate:self
//                                                     cancelButtonTitle:NSLocalizedStringFromTable(@"rateAppCancelButton", okStringsTableName, nil)
//                                                     otherButtonTitles:NSLocalizedStringFromTable(@"rateAppOkButton", okStringsTableName, nil), NSLocalizedStringFromTable(@"rateAppLaterButton", okStringsTableName, nil), nil];
//    [rateThisAppAlert setTag:101];
//    [rateThisAppAlert show];
//  }
//  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView forKey:timesOfNotRatedUsesKey];
//  BOOL isSynced = [[NSUserDefaults standardUserDefaults] synchronize];
//  NSLog(@"number of uses are synced %@", isSynced ? @"successfuly":@"unsuccessfuly");
//}

- (void)SelectNewImage:(id)sender {
//  [self.takeController takePhotoOrChooseFromLibrary];
  UIImagePickerController *imagePickerController = [UIImagePickerController new];
  [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  [imagePickerController setAllowsEditing:[[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue]];
  imagePickerController.delegate = self;
  [imagePickerController.navigationBar setTintColor:[[UIColor blackColor] colorWithAlphaComponent:.8]];

  [self presentViewController:imagePickerController animated:YES completion:^{
    [self.view setUserInteractionEnabled:NO];
  }];

}

- (void)saveImageToUserDefaults
{
  [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(self.previewImg.image) forKey:userDefaultPhotoKey];
  if (![[NSUserDefaults standardUserDefaults] synchronize]) {
    NSLog(@"User Defaults can not be saved!!!");
  }
}

- (void)showTutorial
{
  if ([self isSettingsViewShowing]) {
    [self showHideSettingsPage:^(BOOL finished) {
      [self performSegueWithIdentifier:@"TryTutorialSegue" sender:nil];
    }];
//    [self performSelectorOnMainThread:@selector(showHideSettingsPage) withObject:nil waitUntilDone:YES];
  } else {
    [self performSegueWithIdentifier:@"TryTutorialSegue" sender:nil];
  }
//  [self performSegueWithIdentifier:@"TryTutorialSegue" sender:nil];
}

#pragma mark - Image Pick

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *photo = nil;
  UIImage *editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
  UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
  if (editedImage) {
    photo = editedImage;
  } else if (originalImage) {
    photo = originalImage;
  } else {
    photo = nil;
    NSLog(@"asdasdasd!");
  }
  
  if ([self.takePicBtn isDescendantOfView:self.view]) {
    [self.takePicBtn removeFromSuperview];
  }
  NSLog(@"Image Size:   %@", NSStringFromCGSize(photo.size));
  UIGraphicsBeginImageContext(self.previewImageBound.size);
  [photo drawInRect:self.previewImageBound];
  UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [self.previewImg setImage:imageToBeShow];
  //  [self.previewImg sizeToFit];
  [self saveImageToUserDefaults];
//  if ([[NSUserDefaults standardUserDefaults] objectForKey:userDefaultPhotoKey] == nil) {
//    [self saveImageToUserDefaults];
//  } else {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:NSLocalizedStringFromTable(@"shouldSaveUserDefaultPhoto", okStringsTableName, nil)
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
//                                              otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
//    [alertView setTag:11];
//    [alertView show];
//  }
  
  [picker dismissViewControllerAnimated:NO completion:^{
    [self.view setUserInteractionEnabled:YES];
//    [self performSegueWithIdentifier:@"SelectColorSegue" sender:nil];
  }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:^{
    [self.view setUserInteractionEnabled:YES];
  }];
}

/* Deprecated alert view delegate removed
#pragma mark - UIAlertViewDelegate

//-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if (alertView.tag == 11) {
    if ([title isEqualToString:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)]) {
      return;
    }
    [self saveImageToUserDefaults];
  } else {
    NSLog(@"unknow handle for alert view!\n%@", [alertView debugDescription]);
  }
}
*/

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  // test if our control subview is on-screen
  if ([touch.view isDescendantOfView:self.tryToolBar]) {
    // we touched our control surface
    return NO; // ignore the touch
  }
  return YES; // handle the touch
}

-(void)tapped:(UITapGestureRecognizer *)gesture {
  // eger settings ekrani gozukuyorsa diger islemleri yapma
  if ([self.settingsView isDescendantOfView:self.view]) return;
  //  [self animateHelpText:0.0];
  const char *encoding = @encode(CGPoint);
  CGPoint touchedPt = [gesture locationOfTouch:0 inView:self.view];
//  CGRect rectForImage = CGRectMake(touchedPt.x - 3.25, touchedPt.y - 3.25, 7.5, 7.5);
  CGRect rectForImage = [self getRectangleFromPoint:touchedPt];
  
  if (CGRectContainsPoint(self.previewImg.frame, touchedPt)) {
    
    TapToPointView *v = [[TapToPointView alloc] initWithFrame:rectForImage];
    v.point = touchedPt;
    [v setCount:self.tapCount++];
    
    [self.view addSubview:v];
    [v setNeedsDisplay];
    
    [self.graphView.interpolationPoints addObject:[NSValue valueWithBytes:&touchedPt objCType:encoding]];
    [self.graphView setNeedsDisplay];

    CGPoint touchedPtForImage = [gesture locationOfTouch:0 inView:self.previewImg];
    [self.bezierPoints addObject:[NSValue valueWithBytes:&touchedPtForImage objCType:encoding]];
  }
}

#pragma mark - Touch Handles

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.previewImg.image == nil) return;
  if ([self isSettingsViewShowing]) {
    [self showHideSettingsPage:nil];
  }
  const char *encoding = @encode(CGPoint);

  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  //bu islem iki size arasinda bir farklilik olmasa dahi yapilabilir. scale 1 olacagindan degisen bir
  //sey olmayacaktir. Ama performans acisindan fazla islem yapmamak adina, eger scale in 1 olacagindan
  //eminsen, burayi yapmamakta fayda vardir.
//  float scaleFactorForX = self.previewImg.image.size.width / self.previewImg.bounds.size.width;
//  float scaleFactorForY = self.previewImg.image.size.height / self.previewImg.bounds.size.height;
//  CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);
  CGPoint touchedPointOnOriginalImage = [touch locationInView:self.previewImg];
  
  if (CGRectContainsPoint(self.previewImg.frame, point))
  {
    CGRect rectForImage = [self getRectangleForTavView:point];
    TapToPointView *v = [[TapToPointView alloc] initWithFrame:rectForImage];
    v.point = point;
    [v setCount:self.tapCount++];
    
    [self.view addSubview:v];
    [v setNeedsDisplay];
    
    [self.graphView.interpolationPoints addObject:[NSValue valueWithBytes:&point objCType:encoding]];
    [self.graphView setNeedsDisplay];
    
    [self.bezierPoints addObject:[NSValue valueWithBytes:&touchedPointOnOriginalImage objCType:encoding]];

    // Create a rectangle (10x10) from touched touched point
//    CGRect rect1 = [self getRectangleFromPoint:touchedPointOnOriginalImage];
//    rect1 = CGRectOffset(rect1, -self.previewImg.frame.origin.x, -self.previewImg.frame.origin.y);
    
    // Crop a picture from given rectangle
//    CGImageRef imageRef = CGImageCreateWithImageInRect([self.previewImg.image CGImage], rect1);
//    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    
//    UIImage *img = [UIImage imageWithColor:[self.color colorWithAlphaComponent:self.blendAlphaValue] andSize:rect1.size];
//    UIImage *finalImage = [self blendImagesUsingCIHueBlendMode:tmp_img and:img desiredSize:rect1.size];
//
//    self.myView.previewImage = finalImage;
//    self.myView.newPoint = point;
//    [self.view addSubview:self.myView];
//    [self.myView setNeedsDisplay];
  }
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.previewImg.image == nil) return;
  if ([touches count] > 1) return; //if pressed for editing
  const char *encoding = @encode(CGPoint);
  
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
//  float scaleFactorForX = self.previewImg.image.size.width / self.previewImg.bounds.size.width;
//  float scaleFactorForY = self.previewImg.image.size.height / self.previewImg.bounds.size.height;
//  CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);
  CGPoint touchedPointOnOriginalImage = [touch locationInView:self.previewImg];

  if (CGRectContainsPoint(self.previewImg.bounds, point))
  {
    CGFloat dist = [self getDistanceWithPoint:[[self.bezierPoints lastObject] CGPointValue] andPoint:touchedPointOnOriginalImage];
    NSLog(@"Distance from touch began point %f", dist);
    if (dist > (30.0 * [self getScaleFactor]))
    {
      CGRect rectForImage = [self getRectangleForTavView:point];
      TapToPointView *v = [[TapToPointView alloc] initWithFrame:rectForImage];
      v.point = point;
      [v setCount:self.tapCount++];
      
      [self.view addSubview:v];
      [v setNeedsDisplay];
      
      [self.graphView.interpolationPoints addObject:[NSValue valueWithBytes:&point objCType:encoding]];
      [self.graphView setNeedsDisplay];
      
      [self.bezierPoints addObject:[NSValue valueWithBytes:&touchedPointOnOriginalImage objCType:encoding]];
    }
//    // Create a rectangle (10x10) from touched touched point
//    CGRect rect1 = [self getRectangleFromPoint:touchedPointOnOriginalImage];
//    rect1 = CGRectOffset(rect1, -self.previewImg.frame.origin.x, -self.previewImg.frame.origin.y);
//    
//    // Crop a picture from given rectangle
//    UIImage *tmp_img = [self.previewImg.image cropImageWithRect:rect1];
//    
//    // calculate average color for next steps
//    UIImage *img = [UIImage imageWithColor:[self.color colorWithAlphaComponent:self.blendAlphaValue] andSize:rect1.size];
//    UIImage *finalImage = [self blendImagesUsingCIHueBlendMode:tmp_img and:img desiredSize:rect1.size];
//    self.myView.previewImage = finalImage;
//    self.myView.newPoint = point;
//    [self.myView setNeedsDisplay];
  }
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.previewImg.image == nil) return;
  if ([touches count] > 1) return; //if pressed for editing
  const char *encoding = @encode(CGPoint);
  
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
//  float scaleFactorForX = self.previewImg.image.size.width / self.previewImg.bounds.size.width;
//  float scaleFactorForY = self.previewImg.image.size.height / self.previewImg.bounds.size.height;
//  CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);
  CGPoint touchedPointOnOriginalImage = [touch locationInView:self.previewImg];

  if (CGRectContainsPoint(self.previewImg.bounds, point))
  {
    CGFloat dist = [self getDistanceWithPoint:[[self.bezierPoints lastObject] CGPointValue] andPoint:touchedPointOnOriginalImage];
    NSLog(@"Distance from touch began point %f", dist);
    if (dist > (30.0 * [self getScaleFactor]))
    {
      CGRect rectForImage = [self getRectangleForTavView:point];
      TapToPointView *v = [[TapToPointView alloc] initWithFrame:rectForImage];
      v.point = point;
      [v setCount:self.tapCount++];
      
      [self.view addSubview:v];
      [v setNeedsDisplay];
      
      [self.graphView.interpolationPoints addObject:[NSValue valueWithBytes:&point objCType:encoding]];
      [self.graphView setNeedsDisplay];
      
      [self.bezierPoints addObject:[NSValue valueWithBytes:&touchedPointOnOriginalImage objCType:encoding]];
    }
  }
    //  [self.myView removeFromSuperview];
  [super touchesEnded:touches withEvent:event];
}

#pragma mark - ToolBar Button Handles

- (IBAction)editButtonsTapped:(id)sender {
  NSInteger btnTag = ((UIButton *)sender).tag;
//  NSLog(@"Button %@ tapped", [[((UIButton *)sender) titleLabel] text]);
  switch (btnTag) {
    case 11: //undo last button (B1)
      [self removeLastTapView];
      break;
    case 10: //save button     (B2)
//      [self removeallTapViews];
      [self saveImageToAlbum];
      break;
    case 12: //done button      (B3)
      [self createMaskImageFromBezierPaths];
      break;
    case 13:
      [self reloadOriginalImage];
      break;
    case 14:
      [self showHideSettingsPage:nil];
      break;
    default:
      break;
  }
}

- (void)showHideSettingsPage:(void (^)(BOOL finished))completion
{
  static CGFloat currentBlendValue = 0.64;
  //update frames
  CGRect toolBarFrame = self.tryToolBar.frame;
  self.settingsViewRecoverFrame = CGRectMake(0, toolBarFrame.origin.y - 56, toolBarFrame.size.width, 56);
  self.settingsViewHideFrame = CGRectMake(0, toolBarFrame.origin.y, toolBarFrame.size.width, 56);
  if ([self isSettingsViewShowing]) {
    [UIView transitionWithView:self.settingsView
                      duration:0.4
                       options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionCurveLinear
                    animations:^{
                      [self.settingsView setFrame:self.settingsViewHideFrame];
                      [self.settingsView setAlpha:0.0];
                    }
                    completion:^(BOOL finished) {
                      if (!finished) {
                        NSLog(@"asdasdas");
                      }
                      [self.settingsView removeFromSuperview];
                      if (completion) {
                        completion(finished);
                      }
//                      if (currentBlendValue != self.blendAlphaValue) {
//                        [self reloadOriginalImage];
//                      }
                    }];
  } else {
    currentBlendValue = self.blendAlphaValue;
    [self.view insertSubview:self.settingsView belowSubview:self.tryToolBar];
//    [self.view addSubview:self.settingsView];
    [UIView transitionWithView:self.settingsView
                      duration:0.4
                       options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionCurveLinear
                    animations:^{
                      [self.settingsView setFrame:self.settingsViewRecoverFrame];

                      [self.settingsView setAlpha:1.0];
                    }
                    completion:^(BOOL finished) {
                      if (!finished) {
                        NSLog(@"asdasdas");
                      }
                      if (completion) {
                        completion(finished);
                      }
                    }];
  }
}

- (BOOL)isSettingsViewShowing
{
  return [self.settingsView isDescendantOfView:self.view];
}

- (void)removeLastTapView
{
  for (UIView *v in [self.view subviews]) {
    if ([v isKindOfClass:[TapToPointView class]] ) {
      if ([(TapToPointView *)v count] == self.tapCount - 1) {
        [v removeFromSuperview];
        self.tapCount -= 1;
        //Burasi dogru calisacakmi?!
        [self.bezierPoints removeLastObject];
        [self.graphView.interpolationPoints removeLastObject];
        [self.graphView setNeedsDisplay];
        break;
      }
    }
  }
}

- (void)saveImageToAlbum
{
  if (!self.imageChanged) {
    return;
  }
  [self.view setUserInteractionEnabled:NO];
//  CGImageRef imgRef = [self.previewImg.image CGImage];
//  
//  UIImage *imgToSave = [UIImage imageWithCGImage:imgRef];
//  
////  CGImageRelease(imgRef);
  UIImage *imgToSave = [UIImage imageWithCGImage:self.previewImg.image.CGImage];
  UIImageWriteToSavedPhotosAlbum(imgToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
  [self.view setUserInteractionEnabled:YES];
  if (error) {
    NSLog(@"An Error Occured while saving image %@", [error debugDescription]);
//    [self showAutoDismissedAlertWithMessage:NSLocalizedStringFromTable(@"imageSavedSuccessfully", okStringsTableName, nil) withTitle:nil afterDelay:0.6];
  } else {
    [self showAutoDismissedAlertWithMessage:NSLocalizedStringFromTable(@"imageSavedSuccessfully", okStringsTableName, nil) withTitle:nil afterDelay:1.2];
  }
  self.imageChanged = NO;
}

- (void)removeallTapViews
{
  for (UIView *v in [self.view subviews]) {
    if ([v isKindOfClass:[TapToPointView class]] ) {
      [v removeFromSuperview];
    }
  }
  [self.bezierPoints removeAllObjects];
  [self.graphView.interpolationPoints removeAllObjects];
  [self.graphView setNeedsDisplay];
  self.tapCount = 0;
}

- (void)reloadOriginalImage
{
  [self removeallTapViews];
  UIImage *userPhoto = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:userDefaultPhotoKey]];
  if (userPhoto) {
    [self.previewImg setImage:userPhoto];
  }
}

#pragma mark Create Mask Image & Paint
- (void)createMaskImageFromBezierPaths
{
  static BOOL youMadeIt = NO;
  if ([self.bezierPoints count] == 0)
  {
    self.unsuccessTapCount += 1;
    if (self.unsuccessTapCount > 2 && !youMadeIt) {
      self.unsuccessTapCount = 1;
      [self showTutorial];
    }
    return;
  }
  youMadeIt = YES;
  if (!self.imageChanged) {
    self.imageChanged = YES;
  }
//  [self.graphView setIsClosed:YES];
  UIBezierPath *path = [UIBezierPath interpolateCGPointsWithHermite:self.bezierPoints closed:YES];
  [self removeallTapViews];
  self.currentImagePath = path;

  //eger alpha slider gosterilmiyorsa goster
//  if (![self isSettingsViewShowing]) {
//    [self showHideSettingsPage];
//  }
  [self applyNewColorToImage:[path copy]];
}

- (void)applyNewColorToImage:(UIBezierPath *)path
{
  NSLog(@"BlendValue: %f", self.blendAlphaValue);
  UIGraphicsBeginImageContext(self.previewImg.bounds.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [[self.color colorWithAlphaComponent:self.blendAlphaValue] CGColor]);
  [path fill];
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  UIImage *finalImage = [self blendImagesUsingCIHueBlendMode:self.previewImg.image and:img desiredSize:self.previewImg.bounds.size];
  [self.previewImg setImage:finalImage];
}

- (UIImage *)cropImageUsingBezierPath:(UIImage *)image bezierPath:(UIBezierPath *)path
{
  UIImage *croppedImage = nil;
  UIImageView *view = [[UIImageView alloc] initWithFrame:self.previewImg.frame];
  [view setImage:image];
  
  CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.path = path.CGPath;
  [view.layer setMask:shapeLayer];//or make it as [imageview.layer setMask:shapeLayer];
  //and add imageView as subview of whichever view you want. draw the original image
  //on the imageview in that case
  
  UIGraphicsBeginImageContext(view.bounds.size);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  croppedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return croppedImage;
}

- (UIImage *)blendImages:(UIImage *)sourceImage withBezierPath:(UIBezierPath *)path andColorToBurn:(UIColor *)color
{
  UIImage *blendImage = nil;
  CGFloat hue, sat, brigh, alpa;
  [color getHue:&hue saturation:&sat brightness:&brigh alpha:&alpa];
  
  UIGraphicsBeginImageContext(self.previewImg.bounds.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Use existing opacity as is
  [sourceImage drawInRect:CGRectMake(0,0,self.previewImg.bounds.size.width, self.previewImg.bounds.size.height)];
  
  CGContextSetBlendMode(context, kCGBlendModeHue);
  [color set];
  [path fill];
  
  blendImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  return blendImage;
}

- (UIImage *)blendImages:(UIImage *)firstImage and:(UIImage *)secondImage desiredSize:(CGSize)size
{
  UIImage *blendImage = nil;
  
  UIGraphicsBeginImageContext( size );

  [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
  
//  [secondImage drawInRect:CGRectMake(0,0, size.width, size.height) blendMode:kCGBlendModeHue alpha:.64];
  [secondImage drawInRect:CGRectMake(0,0, size.width, size.height) blendMode:kCGBlendModeHue alpha:self.blendAlphaValue];
//  [secondImage drawInRect:CGRectMake(0,0, size.width, size.height) blendMode:kCGBlendModeHue alpha:1.0];
  
  blendImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return blendImage;
}

- (UIImage *)blendImagesUsingCIHueBlendMode:(UIImage *)firstImage and:(UIImage *)secondImage desiredSize:(CGSize)size
{
  CIImage *inputImg = [CIImage imageWithCGImage:[secondImage CGImage]];
  CIImage *inputBckImg = [CIImage imageWithCGImage:[firstImage CGImage]];
  CIContext *context = [CIContext contextWithOptions:nil];               // 1
  CIFilter* composite = [CIFilter filterWithName:@"CIHueBlendMode"];
  [composite setValue:inputImg forKey:@"inputImage"];
  [composite setValue:inputBckImg forKey:@"inputBackgroundImage"];
  
  CIImage *outputImage = [composite outputImage];
  CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
  UIImage *rtrnImg = [UIImage imageWithCGImage:cgimg];
  CGImageRelease(cgimg);
  
  return rtrnImg;
}

- (CGFloat)getScaleFactor
{
  CGFloat scaleFactor = [UIScreen mainScreen].scale;
  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
    scaleFactor = [UIScreen mainScreen].nativeScale;
  }
  return scaleFactor;
}

- (CGRect)getRectangleForTavView:(CGPoint)point
{
  CGFloat natureSize = 3.25;
//  CGFloat scaleFactor = [UIScreen mainScreen].scale;
//  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
//    scaleFactor = [UIScreen mainScreen].nativeScale;
//  }
  natureSize = natureSize * [self getScaleFactor];
  
  CGFloat dx, dy;
  dx = point.x >= natureSize/2.0 ? natureSize/2.0 : 0;
  dy = point.y >= natureSize/2.0 ? natureSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, natureSize, natureSize);
}

- (CGRect)getRectangleFromPoint:(CGPoint)point
{
  CGSize drawableSize = self.previewImg.bounds.size;
  
//  CGFloat scaleFactor = [UIScreen mainScreen].scale;
//  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
//    scaleFactor = [UIScreen mainScreen].nativeScale;
//  }
  //  CGFloat scaleFactor = self.view.window.screen.nativeScale;
  drawableSize.width *= [self getScaleFactor];
  CGFloat capturePixelSize = floorf(drawableSize.width * 0.1);
//  capturePixelSize = self.myView.bounds.size.width;
  
  CGFloat dx,dy;
  dx = point.x >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  dy = point.y >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, capturePixelSize, capturePixelSize);
}

- (void)alphaSliderChanged:(id)sender
{
  self.blendAlphaValue = ((UISlider *)sender).value;
}

- (CGRect)statusBarFrameViewRect:(UIView*)view
{
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
  CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
  CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
  return statusBarViewRect;
}

- (CGFloat)getDistanceWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
  float dx = fabs(point1.x - point2.x);
  float dy = fabs(point1.y - point2.y);
  return sqrtf(dx*dx + dy*dy);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"TryTutorialSegue"]) {
    UIImage *screenShot = [self.view createImageFromViewAfterScreenUpdates:NO];
    OKSettingsTutorialVC *vc = [segue destinationViewController];
    [vc initiateTutorialControllerWithBgImg:screenShot andContentPoints:self.framesDictionary WithExplanationDescriptors:self.explanationsDictionary];
    [vc setShowExplanationBelowView:NO];
    [vc setHeightOfExplanationView:44];
  }
}

@end
