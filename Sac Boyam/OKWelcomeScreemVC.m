//
//  OKWelcomeScreemVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 20/02/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "OKWelcomeScreemVC.h"
#import "UIView+CreateImage.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKSelectColorVC.h"
#import "OKSettingsViewController.h"
#import "OKCamViewController.h"
#import "OKAppRater.h"
#import "UIViewController+MotionEffect.h"
#import "OKAppDelegate.h"
#import "OKImagePickerViewController.h"

#ifdef LITE_VERSION
@interface OKWelcomeScreemVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, OKSettingsDelegate, UIAlertViewDelegate, BannerViewController_Delegate>
#else
@interface OKWelcomeScreemVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, OKSettingsDelegate, UIAlertViewDelegate>
#endif
- (IBAction)selectPicFromLibrary:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *picLibraryButton;
@property (nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *filesDictionary;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (strong) CAGradientLayer *cameraButtonGradient;
//@property NSInteger totalUsageForThisInstance;
@end

@implementation OKWelcomeScreemVC

- (void)viewDidLoad {
  [super viewDidLoad];
//  self.totalUsageForThisInstance = 0;
  
//  UIImage *backgrounImage = [UIImage imageNamed:@"patt-4.jpg"];
//  //TODO: do vibration and blur here!
////  backgrounImage = [backgrounImage applyDarkEffect];
//  backgrounImage = [backgrounImage applyBlurWithRadius:1.3 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
//  
//  UIColor *backgroundPatternColor = [UIColor colorWithPatternImage:backgrounImage];
//  [self addMotionEffectToView:self.view];
  self.view.backgroundColor = [self.view getBackgroundColor];
  
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
  self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:0.80];
  UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_navBar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(settingsButtonTap:)];
  self.navigationItem.rightBarButtonItem = settingsBtn;

  if (!self.managedObjectContext) [self initManagedDocument];
#ifdef LITE_VERSION
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
  [[BannerViewManager sharedInstance] addBannerViewController:self];
#endif
  
  self.imagePickerController = [UIImagePickerController new];
  self.imagePickerController.delegate = self;
  [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  [self.imagePickerController.navigationBar setTintColor:[[UIColor blackColor] colorWithAlphaComponent:.8]];
  [self.imagePickerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
  
  UIImage *cameraImage = [UIImage imageNamed:@"take_a_pic"];
  
  UIColor *startColor = [UIColor colorWithWhite:0.45 alpha:1.0];
  UIColor *endColor = [UIColor blackColor];
  
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.cameraButton.bounds;
  gradient.startPoint = CGPointMake(0.1, 0.1);
  gradient.endPoint = CGPointMake(1.0, 1.0);
//  gradient.position = CGPointMake(0.0, 0.0);
  gradient.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
  
  CALayer *maskLayer = [CALayer layer];
  maskLayer.contents = (id)cameraImage.CGImage;
  maskLayer.frame = gradient.frame;
  gradient.mask = maskLayer;
  
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"colors"];
  anim.toValue = @[(id)endColor.CGColor, (id)endColor.CGColor];
  anim.duration = 2.5;
  anim.autoreverses = YES;
  anim.repeatCount = HUGE_VALF;
  [gradient addAnimation:anim forKey:@"gradientColorAnimation"];

  [self.cameraButton.layer insertSublayer:gradient atIndex:0];
  self.cameraButtonGradient = gradient;
  
//  [self addMotionEffectToViewOnlyHorizontal:self.cameraButton];
  [self addMotionEffectToView:self.picLibraryButton];
  
  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:13.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [timer fire];
  });
}

//-(void)viewDidAppear:(BOOL)animated
//{
//  [super viewDidAppear:animated];
//  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//}
 /*
  AVAuthorizationStatusNotDetermined = 0,
  AVAuthorizationStatusRestricted,
  AVAuthorizationStatusDenied,
  AVAuthorizationStatusAuthorized
*/
#ifdef LITE_VERSION
-(void)dealloc
{
  [[BannerViewManager sharedInstance] removeBannerViewController:self];
}
#endif

- (void)timerFireMethod:(NSTimer *)timer
{
  if (self.view.window && self.isViewLoaded) {
    NSLog(@"Fired!!");
    //TODO: Add animations here
    CABasicAnimation *bounceAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    bounceAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    bounceAnim.duration = .1250;
    bounceAnim.repeatCount = 2;
    bounceAnim.autoreverses = YES;
    bounceAnim.removedOnCompletion = YES;
    bounceAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.03, .92, 1.0)];
    [self.cameraButton.layer addAnimation:bounceAnim forKey:@"buttonBounce"];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = .125;
    animation.repeatCount = 1;
    animation.fromValue = [NSValue valueWithCGPoint:self.cameraButton.center];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.cameraButton.center.x, self.cameraButton.center.y-10)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = YES;
    [self.cameraButton.layer addAnimation:animation forKey:@"position"];
  }
//  [timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(void)settingsButtonTap:(id)sender
{
  [self performSegueWithIdentifier:@"settingsSegue" sender:sender];
}

#pragma mark - Image Pick

- (IBAction)selectPicFromLibrary:(id)sender
{
//  self.totalUsageForThisInstance += 1;
//  if (self.totalUsageForThisInstance > 2) //2 times allowed to select or capture image
//  {
//    [[OKAppRater sharedInstance] askForPurchase];
//    return;
//  }

  [self.imagePickerController setAllowsEditing:[[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue]];
//  [self.imagePickerController setAllowsEditing:NO];
  [self presentViewController:self.imagePickerController animated:YES completion:^{
    [self.view setUserInteractionEnabled:NO];
  }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
  UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
  if (editedImage) {
    self.pickedImage = editedImage;
  } else if (originalImage) {
    self.pickedImage = originalImage;
  } else {
    self.pickedImage = nil;
    NSLog(@"asdasdasd!");
  }
//  self.pickedImage = originalImage;
  [picker dismissViewControllerAnimated:NO completion:^{
    [self.view setUserInteractionEnabled:YES];
//    [self performSegueWithIdentifier:@"ImagePickerSegue" sender:nil];
    [self performSegueWithIdentifier:@"SelectColorSegue" sender:nil];
  }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//#ifdef LITE_VERSION
//  self.totalUsageForThisInstance -= 1;
//#endif
  [picker dismissViewControllerAnimated:YES completion:^{
    [self.view setUserInteractionEnabled:YES];
  }];
}

#pragma mark - Navigation

#ifdef LITE_VERSION
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  if ([identifier isEqualToString:@"settingsSegue"])
  {
    return YES;
  }
//  self.totalUsageForThisInstance += 1;
//  if (self.totalUsageForThisInstance > [[NSUserDefaults standardUserDefaults] integerForKey:maximumAllowedUsageInOneDayKey]) //2 times allowed to select or capture image
//  {
//    [[OKAppRater sharedInstance] askForPurchase];
//    return NO;
//  }
  return YES;
}
#endif

- (IBAction)unwindToMainPage:(UIStoryboardSegue *)segue
{
  UIViewController *sourceVC = segue.sourceViewController;
  if ([sourceVC isKindOfClass:[OKImagePickerViewController class]]) {
//    UIImage *returnedImage = self.pickedImage;
    [self performSegueWithIdentifier:@"SelectColorSegue" sender:nil];
  }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  self.navigationItem.backBarButtonItem =
//  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home-icon.png"] style:UIBarButtonItemStyleBordered target:nil action:nil];

  if ([[segue identifier] isEqualToString:@"SelectColorSegue"]) {
    OKSelectColorVC *vc = [segue destinationViewController];
    [vc setSelectedPicture:self.pickedImage];
    [vc setManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"settingsSegue"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setDelegate:self];
    [vc setManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"cameraSegue"]) {
    OKCamViewController *vc = [segue destinationViewController];
    [vc setManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"ImagePickerSegue"]) {
    OKImagePickerViewController *vc = [segue destinationViewController];
    [vc setSelectedImage:self.pickedImage];
  }
}

#pragma mark - OKSettingsDelegate
#ifdef LITE_VERSION
-(void)viewDidLayoutSubviews
{
  CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
  ADBannerView *bannerView = [BannerViewManager sharedInstance].bannerView;
  bannerFrame.size = [bannerView sizeThatFits:contentFrame.size];
  if (bannerView.bannerLoaded) {
    contentFrame.size.height -= bannerFrame.size.height;
    bannerFrame.origin.y = contentFrame.size.height;
  } else {
    bannerFrame.origin.y = contentFrame.size.height;
  }
  if (self.isViewLoaded && (self.view.window != nil)) {
    [self.view addSubview:bannerView];
    bannerView.frame = bannerFrame;
  }
}

-(void)updateLayout
{
  [UIView animateWithDuration:0.25 animations:^{
    // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
    // or hidden depending upon whether its bannerLoaded property is YES or NO.  We just need our view
    // to (re)lay itself out so -viewDidLayoutSubviews will be called.
    // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
    // as requiring layout...
    [self.view setNeedsLayout];
    // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
    [self.view layoutIfNeeded];
    // ...which has the same effect.
  }];
}

- (void)willBeginBannerViewActionNotification:(NSNotification *)notification
{
  if (self.isViewLoaded && (self.view.window != nil))
  {
    NSLog(@"willBeginBannerViewActionNotification");
//    self.totalUsageForThisInstance = 0;
  }
}

- (void)didFinishBannerViewActionNotification:(NSNotification *)notification
{
  if (self.isViewLoaded && (self.view.window != nil))
  {
    NSLog(@"didFinishBannerViewActionNotification");
  }
}
#endif
//- (void)acceptChangedSetings
//{
////  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
////  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
//}

#pragma mark - CoreData Initialization

-(void)initManagedDocument
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSURL *documentsDir = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
  
  NSString *docName = @"SacBoyalari.dm";
  NSURL *url = [documentsDir URLByAppendingPathComponent:docName isDirectory:YES];
  
  NSURL *persUrl = [url URLByAppendingPathComponent:@"StoreContent" isDirectory:YES];
  if (![[NSFileManager defaultManager] fileExistsAtPath:[persUrl path]]) {
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:persUrl withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success || error) {
      NSLog(@"Error: %@", [error userInfo]); return;
    }
    persUrl = [persUrl URLByAppendingPathComponent:@"persistentStore"];
    NSURL *preloadUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"persistentStore" ofType:@""]];
    
    if (![[NSFileManager defaultManager]  copyItemAtURL:preloadUrl toURL:persUrl error:&error])
    {
      NSLog(@"Error %@", [error userInfo]);
    }
    NSLog(@"DocumentsDir Dir: %@", [documentsDir lastPathComponent]);
    success = [documentsDir setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
      NSLog(@"Error excluding %@ from backup %@", [persUrl lastPathComponent], error);
      return;
    }
    
    NSLog(@"File successfuly copied to folder %@", persUrl);
  }
  
  NSLog(@"DB path: %@", url);
  NSError *_error;
  BOOL _success = [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&_error];
  if (!_success) {
    NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], _error);
    //    abort();
  }
  
  self.document = [[UIManagedDocument alloc] initWithFileURL:url];
  if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
    [self.document openWithCompletionHandler:^(BOOL success) {
      if (success) {
        self.managedObjectContext = self.document.managedObjectContext;
//        [self documentIsReady];
      }
      if (!success) NSLog(@"Couldnt open document at %@", url);
    }];
  } else {
    [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
      if (success) {
        self.managedObjectContext = self.document.managedObjectContext;
//        [self documentIsReady];
      }
      if (!success) NSLog(@"Couldnt create document at %@", url);
    }];
  }
  //  UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
}

@end
