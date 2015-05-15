//
//  OKSelectColorVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 20/02/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "OKSelectColorVC.h"
#import "UIView+CreateImage.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+GrayScale.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "OKSettingsViewController.h"
#import "OKSonuclarViewController.h"
#import "OKAppDelegate.h"
#import "UIViewController+AutoDissmissAlert.h"
#import "OKAppRater.h"

//#ifdef LITE_VERSION
//#import <iAd/iAd.h>
//#endif

#define MaximumAllowedNonFoundTapCount 6
#define AutoFindSuggestionAlertViewTag 11
//#ifdef LITE_VERSION
//@interface OKSelectColorVC () <OKSettingsDelegate, UIAlertViewDelegate, ADBannerViewDelegate>
//#else
@interface OKSelectColorVC () <OKSettingsDelegate, UIAlertViewDelegate>
//#endif
@property (strong, nonatomic) OKZoomView *myView;
@property (strong) UIColor *color;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIButton *findButton;
@property (nonatomic) BOOL findOnTap;
@property (nonatomic) BOOL cameFirstTime;
@property (nonatomic) NSInteger nonFoundTapCount;
#ifdef LITE_VERSION
//@property (strong, nonatomic) ADBannerView *bannerView;
#endif
@end

@implementation OKSelectColorVC

- (void)viewDidLoad {
  [super viewDidLoad];
//  UIToolbar *tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
//  [tools setTintColor:[UIColor clearColor]];
//  [tools setTranslucent:YES];
  
//  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
//                                                              style:UIBarButtonItemStylePlain
//                                                             target:self
//                                                             action:@selector(showTutorial)];

  self.findButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.findButton setFrame:CGRectMake(0, 0, 88, 30)];
  
  [self.findButton setTitle:NSLocalizedStringFromTable(@"find", okStringsTableName, nil) forState:UIControlStateNormal];
  [self.findButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.8] forState:UIControlStateNormal];

  UIImage *img = [UIImage imageWithColor:[[UIColor clearColor] colorWithAlphaComponent:0.35] andSize:CGSizeMake(30, 30)];
  [self.findButton setImage:img  forState:UIControlStateNormal];
  [self.findButton addTarget:self action:@selector(findForSelectedColor) forControlEvents:UIControlEventTouchUpInside];
  CGSize imageSize = self.findButton.imageView.image.size;
  self.findButton.imageView.layer.cornerRadius = imageSize.height / 4.0;
  self.findButton.imageView.layer.masksToBounds = YES;
  
  [self.findButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, - imageSize.width*2 , 0.0, 0.0)];
  CGSize titleSize = [self.findButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.findButton.titleLabel.font}];
  [self.findButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -titleSize.width*2 - 6)];
  [self.findButton setEnabled:NO];
  
  UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithCustomView:self.findButton];
//  [tools setItems:@[infoBtn, searchBtn] animated:NO];
  
  UIBarButtonItem *fixedBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedBtnItem.width = -16;
  
  self.navigationItem.rightBarButtonItems = @[fixedBtnItem, searchBtn];
  self.cameFirstTime = NO;
/*
  BOOL canEditImage = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  if (canEditImage) {
    [self.imageView setUserInteractionEnabled:YES];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
    [pinchGestureRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:pinchGestureRecognizer];
    
    // create and configure the rotation gesture
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureDetected:)];
    [rotationGestureRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:rotationGestureRecognizer];
    
    // creat and configure the pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
//    [panGestureRecognizer setMinimumNumberOfTouches:3];
//    [panGestureRecognizer setMaximumNumberOfTouches:3];
    [panGestureRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:panGestureRecognizer];
  }
*/
  
#ifdef LITE_VERSION
//  self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//  self.bannerView.delegate = self;
//  [self.view addSubview:self.bannerView];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bannerViewLoadStateChanged:) name:BannerViewLoadedSuccessfully object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bannerViewLoadStateChanged:) name:BannerViewNotLoaded object:nil];
  //[self.view addSubview:[BannerViewManager sharedInstance].bannerView];
#endif
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.myView = [[OKZoomView alloc] initWithFrame:self.imageView.bounds andStartPoint:self.imageView.bounds.origin];
  self.myView.backgroundColor = [UIColor clearColor];
  self.findOnTap = [[[NSUserDefaults standardUserDefaults] objectForKey:findOnTapKey] boolValue];

  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    self.cameFirstTime = YES;
    [self showTutorialWithWelcomeScreen:YES];
  }
#ifdef LITE_VERSION
//  self.bannerView.delegate = self;
  [self.view addSubview:[BannerViewManager sharedInstance].bannerView];
  [self layoutAnimated:NO];
#endif
}

-(void)viewDidLayoutSubviews
{
//  NSLog(@"ImageView bound %@", NSStringFromCGRect(self.imageView.bounds));
  //viewDidLayoutSubviews, her view objesi degistirildiginde(previewview eklenip silindiginde) burasi cagirildigindan dolayi
  //resmin tekrar boyutlandirilmasi islemi bir kere yapilmalidir.
  if (self.selectedPicture && !CGSizeEqualToSize(self.imageView.image.size, self.imageView.bounds.size))
  {
    CGRect boundRect = self.imageView.bounds;
//    CGFloat ratio = MIN(boundRect.size.height / self.selectedPicture.size.height, boundRect.size.width / self.selectedPicture.size.width);
//    boundRect.size.width  *= ratio;
//    boundRect.size.width = ceilf(boundRect.size.width);
//    boundRect.size.height *= ratio;
//    boundRect.size.height = ceilf(boundRect.size.height);
//    CGContextDrawImage(<#CGContextRef c#>, <#CGRect rect#>, <#CGImageRef image#>)
    
    UIGraphicsBeginImageContext(boundRect.size);
    [self.selectedPicture drawInRect:boundRect];
    UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    NSLog(@"Re Scaled Image Size: %@", NSStringFromCGSize(imageToBeShow.size));
    [self.imageView setImage:imageToBeShow];
  }
//  [self.imageView setContentMode:UIViewContentModeCenter];
#ifdef LITE_VERSION
  [self layoutAnimated:[UIView areAnimationsEnabled]];
#endif
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)showTutorial
{
  [self showTutorialWithWelcomeScreen:NO];
}

- (void)showTutorialWithWelcomeScreen:(BOOL)showWelcomeScreen
{
//  [self showAutoDismissedAlertWithMessage:NSLocalizedStringFromTable(@"firstTimeOnColorSelectMsg", okStringsTableName, nil) withTitle:nil afterDelay:2.0];
//#ifndef LITE_VERSION
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"welcome", okStringsTableName, nil)
                                                      message:NSLocalizedStringFromTable(@"firstTimeOnColorSelectMsg", okStringsTableName, nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
  [alertView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.73]];
  [alertView setTag:10];
  [alertView show];
  [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:1.6];
//#endif
  
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:showTutorialKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)findForSelectedColor
{
  if (self.color) {
    if ([[OKAppRater sharedInstance] tryIncreaseAndUseForThisTime]) {
      [self performSegueWithIdentifier:@"resultsSegue" sender:self];
    }
  } else {
//    UIPopoverController *popVc = [[UIPopoverController alloc] initWithContentViewController:self];
//    popVc.delegate = self;
//    UIBarButtonItem *barBtnItm = (UIBarButtonItem *)[self.findButton superview];
//    assert(barBtnItm);
//    [popVc presentPopoverFromBarButtonItem:barBtnItm permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    dispatch_async(dispatch_get_main_queue(), ^{
//      [NSThread sleepForTimeInterval:.5];
//      [popVc dismissPopoverAnimated:YES];
//    });
  }
}

#pragma mark - OKSettingsDelegate

- (void)acceptChangedSetings
{
  self.findOnTap = [[[NSUserDefaults standardUserDefaults] objectForKey:findOnTapKey] boolValue];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  //ignore if alertview is auto dismissable
  if (alertView.tag == 10) { return; }
  else if (alertView.tag == AutoFindSuggestionAlertViewTag) {
    self.nonFoundTapCount = NSIntegerMin;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedStringFromTable(@"NOButonTitle", okStringsTableName, nil)]) {
      return;
    }
    [self performSegueWithIdentifier:@"settingSegueFromSelect" sender:nil];
  }
}

#pragma mark - Touch Handles

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.imageView.image == nil) return;
//  if ([touches count] > 1) return; //if pressed for editing
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];

#ifdef LITE_VERSION
  //eger banner view varsa ve basilan nokta banner ise don
  if (CGRectContainsPoint([BannerViewManager sharedInstance].bannerView.frame, point) && [BannerViewManager sharedInstance].bannerView.bannerLoaded)
    return;
#endif
  /*
     Eger imageview uzerine eklenmis image'in size i imageview in kendi size i ile
     ayni degil ise, (yani image in size i imageview in size indan daha buyukse gibi)
     resimin dokundugun yere tekabul eden kesimini almak icin aradaki scale farkini hesaba katmak lazim
     bu hesap asagida ki gibi yapilmalidir:
     
     float scaleFactorForX = self.imageView.image.size.width / self.imageView.bounds.size.width;
     float scaleFactorForY = self.imageView.image.size.height / self.imageView.bounds.size.height;
     CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);
     
     [self getRectangleFromPoint:point] metodu cagirilirken buradan hesaplanan rect verilmelidir.
   */
  
  //bu islem iki size arasinda bir farklilik olmasa dahi yapilabilir. scale 1 olacagindan degisen bir
  //sey olmayacaktir. Ama performans acisindan fazla islem yapmamak adina, eger scale in 1 olacagindan
  //eminsen, burayi yapmamakta fayda vardir.
  float scaleFactorForX = self.imageView.image.size.width / self.imageView.bounds.size.width;
  float scaleFactorForY = self.imageView.image.size.height / self.imageView.bounds.size.height;
  CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);

  if (CGRectContainsPoint(self.imageView.frame, point))
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:touchedPointOnOriginalImage];
    rect1 = CGRectOffset(rect1, -self.imageView.frame.origin.x, -self.imageView.frame.origin.y);
    NSLog(@"Rect %@", NSStringFromCGRect(rect1));
    
    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imageView.image CGImage], rect1);
    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (self.color == nil) {
      [self.findButton setEnabled:YES];
    }
    // calculate average color for next steps
    self.color = [tmp_img averageColor];
    
    [self.findButton setImage:[UIImage imageWithColor:self.color andSize:CGSizeMake(30, 30)]  forState:UIControlStateNormal];
    self.myView.previewImage = [UIImage imageWithColor:self.color andSize:self.myView.imageView.bounds.size];
//    self.myView.previewImage = tmp_img;
    self.myView.newPoint = point;
    [self.view addSubview:self.myView];
    [self.myView setNeedsDisplay];
  }
  
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//  if (self.imageView.image == nil) return;
  if ([touches count] > 1) return; //if pressed for editing
  
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  float scaleFactorForX = self.imageView.image.size.width / self.imageView.bounds.size.width;
  float scaleFactorForY = self.imageView.image.size.height / self.imageView.bounds.size.height;
  CGPoint touchedPointOnOriginalImage = CGPointMake(point.x * scaleFactorForX, point.y * scaleFactorForY);
  
  if (CGRectContainsPoint(self.imageView.bounds, point))
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:touchedPointOnOriginalImage];
    rect1 = CGRectOffset(rect1, -self.imageView.frame.origin.x, -self.imageView.frame.origin.y);
    
    // Crop a picture from given rectangle
    UIImage *tmp_img = [self.imageView.image cropImageWithRect:rect1];
    
    // calculate average color for next steps
    self.color = [tmp_img averageColor];
    
    [self.findButton setImage:[UIImage imageWithColor:self.color andSize:CGSizeMake(30, 30)]  forState:UIControlStateNormal];

    self.myView.previewImage = [UIImage imageWithColor:self.color andSize:self.myView.imageView.bounds.size];
//    self.myView.previewImage = tmp_img;
    self.myView.newPoint = point;
    [self.myView setNeedsDisplay];
  }
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.myView removeFromSuperview];
  self.nonFoundTapCount += 1;
  [super touchesEnded:touches withEvent:event];
  if (self.findOnTap && !self.cameFirstTime) {
    [self performSegueWithIdentifier:@"resultsSegue" sender:nil];
  }
  if (self.cameFirstTime || self.nonFoundTapCount >= MaximumAllowedNonFoundTapCount) {
    self.cameFirstTime = NO;
    if (!self.findOnTap)
    {
#ifndef LITE_VERSION
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                          message:NSLocalizedStringFromTable(@"askForFindOnTapMsg", okStringsTableName, nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedStringFromTable(@"NOButonTitle", okStringsTableName, nil)
                                                otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
//      [alertView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.73]];
      [alertView setTag:AutoFindSuggestionAlertViewTag];
      [alertView show];
#endif
    }
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.myView removeFromSuperview];
  [super touchesCancelled:touches withEvent:event];
}

- (CGRect)getRectangleFromPoint:(CGPoint)point
{
  CGSize drawableSize = self.imageView.bounds.size;
  
  CGFloat scaleFactor = [UIScreen mainScreen].scale;
  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
    scaleFactor = [UIScreen mainScreen].nativeScale;
  }
  //  CGFloat scaleFactor = self.view.window.screen.nativeScale;
  drawableSize.width *= scaleFactor;
  CGFloat capturePixelSize = floorf(drawableSize.width * 0.1);
  
  CGFloat dx,dy;
  dx = point.x >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  dy = point.y >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, capturePixelSize, capturePixelSize);
}
/*
#pragma mark - Gesture Recognizers

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer
{
  UIGestureRecognizerState state = [recognizer state];
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
  {
    CGFloat scale = [recognizer scale];
//    if (scale > 1.0f && scale <= 2.5f) {
      [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, scale, scale)];
      [recognizer setScale:1.0];
//    }
  }
}

- (void)rotationGestureDetected:(UIRotationGestureRecognizer *)recognizer
{
  UIGestureRecognizerState state = [recognizer state];
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
  {
    CGFloat rotation = [recognizer rotation];
    [recognizer.view setTransform:CGAffineTransformRotate(recognizer.view.transform, rotation)];
    [recognizer setRotation:0];
  }
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
  UIGestureRecognizerState state = [recognizer state];
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
  {
    CGPoint translation = [recognizer translationInView:recognizer.view];
    [recognizer.view setTransform:CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y)];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
  }
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  if ([[segue identifier] isEqualToString:@"resultsSegue"]) {
    self.nonFoundTapCount = 0; //reset counter
    CGFloat grayScaleValueOfColor = [self.color grayScaleColor];
    OKSonuclarViewController *vc = [segue destinationViewController];
    [vc initResultsWithGrayScaleValue:grayScaleValueOfColor forManagedObjectContext:self.managedObjectContext];
    //    [self.navigationController pushViewController:vc animated:YES];
  } else if ([[segue identifier] isEqualToString:@"settingSegueFromSelect"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setDelegate:self];
    [vc setManagedObjectContext:self.managedObjectContext];
  }
}

#pragma mark - iAdNetwork Methods
#ifdef LITE_VERSION
- (void)layoutAnimated:(BOOL)animated
{
//  CGRect contentFrame = self.view.bounds;
  ADBannerView *__bannerView = [BannerViewManager sharedInstance].bannerView;
  CGRect bannerFrame = __bannerView.frame;
  
  if (__bannerView.bannerLoaded) {
//    contentFrame.size.height -= self.bannerView.frame.size.height;
    bannerFrame.origin.y = self.view.bounds.size.height - __bannerView.frame.size.height;
  } else {
    bannerFrame.origin.y = self.view.bounds.size.height;
  }
  
  [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
    [self.view layoutIfNeeded];
//    [__bannerView setNeedsLayout];
    __bannerView.frame = bannerFrame;
    [__bannerView layoutIfNeeded];
  }];
}

- (void)willBeginBannerViewActionNotification:(NSNotification *)notification
{
  if (self.isViewLoaded && (self.view.window != nil))
  {
    NSLog(@"willBeginBannerViewActionNotification");
    [[OKAppRater sharedInstance] resetColorFoundKey];
  }
}

- (void)didFinishBannerViewActionNotification:(NSNotification *)notification
{
  if (self.isViewLoaded && (self.view.window != nil))
  {
    NSLog(@"didFinishBannerViewActionNotification");
  }
}

- (void)bannerViewLoadStateChanged:(NSNotification *)notification
{
  [self layoutAnimated:YES];
}

#endif
@end
