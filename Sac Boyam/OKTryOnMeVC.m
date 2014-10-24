//
//  OKTryOnMeVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 08/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//
#import "OKAppDelegate.h"
#import "OKTryOnMeVC.h"
#import "FDTakeController.h"
#import "MyCutomView.h"
#import "UIColor+GrayScale.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "UIView+CreateImage.h"
#import "UIView+draggable.h"
#import "UIBezierPath+Interpolation.h"
#import "CRVINTERGraphicsView.h"
#import "TapToPointView.h"

@interface OKTryOnMeVC () <FDTakeDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *previewImg;
@property FDTakeController *takeController;

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
@end

@implementation OKTryOnMeVC

- (void)viewDidLoad {
  [super viewDidLoad];  
  UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
//  UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(ActionButtonTapped:)];
  self.navigationItem.rightBarButtonItem = camBtn;
  self.view.backgroundColor = [self.view getBackgroundColor];

  self.tapCount = 0;
  self.bezierPoints = [NSMutableArray new];

  self.graphView = [[CRVINTERGraphicsView alloc] initWithFrame:self.view.frame];
  self.graphView.backgroundColor = [UIColor clearColor];
  [self.graphView setIsClosed:NO];
  [self.graphView setUseHermite:YES];
  [self.view insertSubview:self.graphView aboveSubview:self.previewImg];
  
  self.gestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(tapped:)];
  self.gestureRecognizer.delegate = self;
  self.gestureRecognizer.numberOfTapsRequired = 1;
  self.gestureRecognizer.numberOfTouchesRequired = 1;
  [self.view addGestureRecognizer:self.gestureRecognizer];

  self.takeController = [[FDTakeController alloc] init];
  self.takeController.delegate = self;
  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];

  UIImage *userPhoto = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:userDefaultPhotoKey]];
  if (userPhoto) {
    [self.previewImg setImage:userPhoto];
  } else {
    NSString *imageOverlayString = NSLocalizedStringFromTable(@"imageOverlay", okStringsTableName, nil);
    self.takePicBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height/2.0, self.view.bounds.size.width, 30);
    [self.takePicBtn setFrame:buttonFrame];
    [self.takePicBtn addTarget:self action:@selector(SelectNewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.takePicBtn setTitle:imageOverlayString forState:UIControlStateNormal];
    [self.takePicBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
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
  self.blendAlphaValue = .64;
  CGRect toolBarFrame = self.tryToolBar.frame;
  self.settingsViewRecoverFrame = CGRectMake(0, toolBarFrame.origin.y - 52 + 20/*size of status bar*/, toolBarFrame.size.width, 56);
  self.settingsViewHideFrame = CGRectMake(0, toolBarFrame.origin.y + 20/*size of status bar*/, toolBarFrame.size.width, 56);
  self.settingsView = [[UIView alloc] initWithFrame:self.settingsViewHideFrame];
//  self.settingsView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.82];
  self.settingsView.backgroundColor = [[self.view getBackgroundColor] colorWithAlphaComponent:0.82];
  
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
  [sliderExplanationLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.85]];
  [sliderExplanationLabel setTextAlignment:NSTextAlignmentCenter];
  //  [sliderExplanationLabel setAdjustsFontSizeToFitWidth:YES];
  [self.settingsView addSubview:sliderExplanationLabel];
  
  UISlider *alphaSlider = [[UISlider alloc] init];
  [alphaSlider setFrame:CGRectMake(0, 20, self.view.bounds.size.width, 36)];
  [alphaSlider setMaximumValue:1.0];
  [alphaSlider setMinimumValue:0.0];
  [alphaSlider setValue:self.blendAlphaValue animated:NO];
//  [sliderFPS setMinimumTrackImage:[[UIImage imageNamed:@"camera_slider_empty.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")]
//                         forState:UIControlStateNormal];
//  [sliderFPS setMaximumTrackImage:[[UIImage imageNamed:@"camera_slider_full.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")]
  UIImage *maxColorImage = [UIImage imageWithColor:self.color andSize:CGSizeMake(8, 8)];
  UIImage *minColorImage = [UIImage imageWithColor:[[UIColor colorWithWhite:0.8 alpha:0.32] colorWithAlphaComponent:0.32] andSize:CGSizeMake(8, 8)];
  [alphaSlider setMaximumTrackImage:[minColorImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")] forState:UIControlStateNormal];
  [alphaSlider setMinimumTrackImage:[maxColorImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"8")] forState:UIControlStateNormal];
  [alphaSlider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
  [self.settingsView addSubview:alphaSlider];
//  [self.settingsView setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.previewImageBound = self.previewImg.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
}

- (void)saveImageToUserDefaults
{
  [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(self.previewImg.image) forKey:userDefaultPhotoKey];
  if (![[NSUserDefaults standardUserDefaults] synchronize]) {
    NSLog(@"User Defaults can not be saved!!!");
  }
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
  if ([self.takePicBtn isDescendantOfView:self.view]) {
    [self.takePicBtn removeFromSuperview];
  }
  NSLog(@"Image Size:   %@", NSStringFromCGSize(photo.size));
  UIGraphicsBeginImageContext(self.previewImageBound.size);
  [photo drawInRect:self.previewImageBound];
  UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [self.previewImg setImage:imageToBeShow];
  [self.previewImg sizeToFit];
  if ([[NSUserDefaults standardUserDefaults] objectForKey:userDefaultPhotoKey] == nil) {
    [self saveImageToUserDefaults];
  } else {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"shouldSaveUserDefaultPhoto", okStringsTableName, nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                              otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
    [alertView show];
  }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)]) {
    return;
  }
  [self saveImageToUserDefaults];
}

#pragma mark - UIGestureRecognizerDelegate

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
  }
  CGPoint touchedPtForImage = [gesture locationOfTouch:0 inView:self.previewImg];
  [self.bezierPoints addObject:[NSValue valueWithBytes:&touchedPtForImage objCType:encoding]];
}

- (IBAction)editButtonsTapped:(id)sender {
  NSInteger btnTag = ((UIButton *)sender).tag;
//  NSLog(@"Button %@ tapped", [[((UIButton *)sender) titleLabel] text]);
  switch (btnTag) {
    case 11: //undo last button (B1)
      [self removeLastTapView];
      break;
    case 10: //clear button     (B2)
      [self removeallTapViews];
      break;
    case 12: //done button      (B3)
      [self createMaskImageFromBezierPaths];
      break;
    case 13:
      [self reloadOriginalImage];
      break;
    case 14:
      [self showHideSettingsPage];
      break;
    default:
      break;
  }
}

- (void)showHideSettingsPage
{
  static CGFloat currentBlendValue = 0.64;
  //update frames
  CGRect toolBarFrame = self.tryToolBar.frame;
  self.settingsViewRecoverFrame = CGRectMake(0, toolBarFrame.origin.y - 56, toolBarFrame.size.width, 56);
  self.settingsViewHideFrame = CGRectMake(0, toolBarFrame.origin.y, toolBarFrame.size.width, 56);
  if ([self.settingsView isDescendantOfView:self.view]) {
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
                    }];
  }
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

- (void)createMaskImageFromBezierPaths
{
//  [self.graphView setIsClosed:YES];
  UIBezierPath *path = [UIBezierPath interpolateCGPointsWithHermite:self.bezierPoints closed:YES];
  [self removeallTapViews];
  
  UIGraphicsBeginImageContext(self.previewImg.bounds.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [self.color CGColor]);
  [path fill];
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  NSLog(@"BlendValue: %f", self.blendAlphaValue);
//  UIImage *croppedImage = [self cropImageUsingBezierPath:self.previewImg.image bezierPath:[path copy]];
//  UIGraphicsBeginImageContext( self.previewImg.bounds.size );
//  
//  [croppedImage drawInRect:CGRectMake(0,0,self.previewImg.bounds.size.width, self.previewImg.bounds.size.height)];
//  
//  [img drawInRect:CGRectMake(0,0, self.previewImg.bounds.size.width, self.previewImg.bounds.size.height) blendMode:kCGBlendModeNormal alpha:self.blendAlphaValue];
//  
//  croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
  
  UIImage *finalImage = [self blendImages:self.previewImg.image and:img desiredSize:self.previewImg.bounds.size];
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

- (UIImage *)blendImages:(UIImage *)sourceImage withBezierPath:(UIBezierPath *)path andColorToBurn:(UIColor *)color;
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

- (UIImage *)blendImages:(UIImage *)firstImage and:(UIImage *)secondImage desiredSize:(CGSize)size;
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

- (CGRect)getRectangleFromPoint:(CGPoint)point
{
  CGFloat natureSize = 3.25;
  CGFloat scaleFactor = [UIScreen mainScreen].scale;
  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
    scaleFactor = [UIScreen mainScreen].nativeScale;
  }
  natureSize = natureSize * scaleFactor;

  CGFloat dx, dy;
  dx = point.x >= natureSize/2.0 ? natureSize/2.0 : 0;
  dy = point.y >= natureSize/2.0 ? natureSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, natureSize, natureSize);
}

- (void)alphaSliderChanged:(id)sender
{
  self.blendAlphaValue = ((UISlider *)sender).value;
//  [self reloadOriginalImage];
}

- (CGRect)statusBarFrameViewRect:(UIView*)view
{
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
  
  CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
  
  CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
  
  return statusBarViewRect;
}
@end
