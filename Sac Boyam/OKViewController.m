//
//  OKViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OKViewController.h"
#import "UIColor+GrayScale.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "UIView+CreateImage.h"
#import "OKWaitForResultsVC.h"
#import "OKSonuclarViewController.h"
#import "OKProductJsonType.h"
#import "OKAppDelegate.h"
#import "OKTutorialViewController.h"

struct pixel {
  unsigned char r,g,b,a;
};

@interface OKViewController () <FDTakeDelegate, OKWaitForResultsDelegate>
@property (strong, nonatomic) OKZoomView *myView;
@property (strong, nonatomic) OKWaitForResultsVC *myModalViewController;
@property (strong) UIColor *color;
- (IBAction)findForColorButtonTapped:(id)sender;
@property BOOL savePhoto;
@property BOOL userCanceledRequest;

@property (strong, nonatomic) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *filesDictionary;
@property CGRect previewImageBound;
@property (strong, nonatomic) UIButton *takePicBtn;
@end

@implementation OKViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.userCanceledRequest = NO;
  
  UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"settings", okStringsTableName, nil) style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTap:)];
  self.navigationItem.rightBarButtonItem = btn2;
  self.navigationItem.leftBarButtonItem = camBtn;
//  self.navigationItem.rightBarButtonItems = @[btn2, camBtn];
  
  self.lblRenkKodu.adjustsFontSizeToFitWidth = YES;
  self.lblRenkKodu.text = NSLocalizedStringFromTable(@"averageColorLableString", okStringsTableName, nil);

  NSLog(@"View Frame : %@", NSStringFromCGRect(self.view.frame));
  NSLog(@"View Bounds: %@", NSStringFromCGRect(self.view.bounds));
  NSLog(@"Navigation Bar frame  size %@", NSStringFromCGSize(self.navigationController.navigationBar.frame.size));
  NSLog(@"Navigation Bar frame  %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
  NSLog(@"Navigation Bar bounds  %@", NSStringFromCGRect(self.navigationController.navigationBar.bounds));
  NSLog(@"Navigation Bar bounds size %@", NSStringFromCGSize(self.navigationController.navigationBar.bounds.size));

  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_5"];
  UIGraphicsBeginImageContext(CGSizeMake(320, self.navigationController.navigationBar.bounds.size.height + 20));
  [backgroundImage drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  
  UIGraphicsBeginImageContext(self.view.bounds.size);
  [backgroundImage drawInRect:self.view.bounds];
  UIImage *redrawedBckgroundImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  redrawedBckgroundImage = [redrawedBckgroundImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  self.view.backgroundColor = [UIColor colorWithPatternImage:redrawedBckgroundImage];
  
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:image];
  self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:1.0 alpha:0.80];
  self.navigationController.navigationBar.translucent = NO;
  
  NSString *imageOverlayString = NSLocalizedStringFromTable(@"imageOverlay", okStringsTableName, nil);
  self.takePicBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height/2.0, self.view.bounds.size.width, 30);
  [self.takePicBtn setFrame:buttonFrame];
  [self.takePicBtn addTarget:self action:@selector(SelectNewImage:) forControlEvents:UIControlEventTouchUpInside];
  [self.takePicBtn setTitle:imageOverlayString forState:UIControlStateNormal];
  [self.takePicBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
  [self.takePicBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:24]];
  
  [self.view addSubview:self.takePicBtn];
  
  self.selectedImage.contentMode = UIViewContentModeScaleAspectFill;
  self.selectedImage.backgroundColor = [UIColor clearColor];
  self.selectedImage.layer.borderWidth = 2.0;
  self.selectedImage.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.45] CGColor];
  
  self.previewImage.image = [UIImage imageWithColor:[UIColor clearColor] andSize:self.previewImage.bounds.size];
  self.previewImage.layer.borderWidth = 1.0;
  self.previewImage.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.8] CGColor];

  self.previewImage.layer.cornerRadius = 12.0;
  self.previewImage.layer.masksToBounds = YES;
  
  self.takeController = [[FDTakeController alloc] init];
  self.takeController.delegate = self;
  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
  
  self.myView = [[OKZoomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];
  
//  [self performSelector:@selector(showTutorial) withObject:nil afterDelay:1.5];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (!self.managedObjectContext) [self initManagedDocument];
}

- (void)viewDidAppear:(BOOL)animated {
  self.myView = [[OKZoomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];
  self.previewImageBound = self.selectedImage.bounds;
  
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
  }
  [super viewDidAppear:animated];
}

- (void)showTutorial
{
  [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
}

- (IBAction)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
}

-(void)userCancelledRequest
{
  [self.myModalViewController dismissViewControllerAnimated:YES completion:nil];
  self.userCanceledRequest = YES;
}

- (void)acceptChangedSetings
{
  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
}

- (void)testAlertView
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Holaa!" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
  [alertView show];
  [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:1.3];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  NSString *completionMessage = NSLocalizedStringFromTable(@"imageSavedSuccessfully", okStringsTableName, nil);
  if (error) {
    completionMessage = [error localizedDescription];
  }
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:completionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
  [alertView show];
  [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:0.8];
}

- (void)dismissAlertView:(UIAlertView *)alertView
{
  if ([alertView isVisible]) {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
  }
}

#pragma mark - FDTakeDelegate

//- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
//{
//}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
  if ([self.takePicBtn isDescendantOfView:self.view]) {
    [self.takePicBtn removeFromSuperview];
  }
  UIImagePickerControllerSourceType imgSource = (UIImagePickerControllerSourceType)[[info objectForKey:kUIImagePickerControllerSourceType] integerValue];
  if (imgSource == UIImagePickerControllerSourceTypeCamera && self.savePhoto)
  {
    UIImage *originalImage = (UIImage *) [info objectForKey:
                                          UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
  }
  
  NSLog(@"Image Size:   %@", NSStringFromCGSize(photo.size));
  UIGraphicsBeginImageContext(self.previewImageBound.size);
  [photo drawInRect:self.previewImageBound];
  UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [self.selectedImage setImage:imageToBeShow];
  [self.selectedImage sizeToFit];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.selectedImage.image == nil) return;
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if (CGRectContainsPoint(self.selectedImage.frame, point))
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];
    rect1 = CGRectOffset(rect1, -self.selectedImage.frame.origin.x, -self.selectedImage.frame.origin.y);

    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.selectedImage.image CGImage], rect1);
    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    // calculate average color for next steps
    UIColor *color = [tmp_img averageColor];
    
    // show average color for user interaction.
    CGRect rect = self.previewImage.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.previewImage setImage:img];
    
    self.myView.newPoint = point;
    [self.view addSubview:self.myView];
    [self.myView setNeedsDisplay];
  }
  
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.selectedImage.image == nil) return;

  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if (CGRectContainsPoint(self.selectedImage.frame, point))
  {
    /***--Crop photo from touched point and calculate average color of cropped photo.--***/
    
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];
    rect1 = CGRectOffset(rect1, -self.selectedImage.frame.origin.x, -self.selectedImage.frame.origin.y);

    // Crop a picture from given rectangle
    UIImage *tmp_img = [self.selectedImage.image cropImageWithRect:rect1];

    // calculate average color for next steps
    self.color = [tmp_img averageColor];
    
    // show average color for user interaction.
    CGRect rect = self.previewImage.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.previewImage setImage:img];
    
    self.myView.previewImage = img;
    self.myView.newPoint = point;
    [self.myView setNeedsDisplay];
  }
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.myView removeFromSuperview];
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.myView removeFromSuperview];
  [super touchesCancelled:touches withEvent:event];
}

- (CGRect)getRectangleFromPoint:(CGPoint)point
{
  CGSize drawableSize = self.selectedImage.bounds.size;
  CGFloat scaleFactor = self.view.window.screen.nativeScale;
  drawableSize.width *= scaleFactor;
  CGFloat capturePixelSize = drawableSize.width * 0.1;
  CGFloat dx,dy;
  dx = point.x >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  dy = point.y >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, capturePixelSize, capturePixelSize);
}

-(void)settingsButtonTap:(id)sender
{
  [self performSegueWithIdentifier:@"settingsSegue" sender:sender];
}

#pragma mark - Navigation

//-(IBAction)unwindToRoot:(UIStoryboardSegue *)segue
//{
//  UIViewController *vc = segue.sourceViewController;
//  
//  if ([vc isKindOfClass:[OKSettingsViewController class]]) {
////    [self refreshFetcedResultController:self.managedObjectContext];
//  }
//}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  if ([identifier isEqualToString:@"resultsSegue"]) {
    if (self.selectedImage.image == nil) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                          message:NSLocalizedStringFromTable(@"noImageToFound", okStringsTableName, nil)
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                otherButtonTitles: nil];
      [alertView show];
      return NO;
    }
  }
  return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"settingsSegue"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setDelegate:self];
    [vc setManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"resultsSegue"]) {
    if (self.document.documentState != UIDocumentStateNormal) {
      return;
    }
    CGFloat grayScaleValueOfColor = [self.color grayScaleColor];
    OKSonuclarViewController *vc = [segue destinationViewController];
    [vc initResultsWithGrayScaleValue:grayScaleValueOfColor forManagedObjectContext:self.managedObjectContext];
//    [self.navigationController pushViewController:vc animated:YES];
  } else if ([[segue identifier] isEqualToString:@"tutorialSegue"]) {
    UIImage * screenShot = [[self view] createImageFromView];
    screenShot = [screenShot applyDarkEffect];
    OKTutorialViewController *vc = segue.destinationViewController;
    [vc initWithMainImage:screenShot andText:@"Hede Hodo"];
  }
}

- (void)showAutoDismissedAlertWithMessage:(NSString *)message withTitle:(NSString *)title
{
  UIAlertView *alarma = [[UIAlertView alloc] initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                         otherButtonTitles:nil];
  [alarma show];
  [self performSelector:@selector(dismissAlertView:) withObject:alarma afterDelay:3.0];
}

- (void)simulateDataFetched
{
  [self.myModalViewController dismissViewControllerAnimated:YES completion:nil];

  OKSonuclarViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"sonuclarViewController"];
  [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)findForColorButtonTapped:(id)sender {
  //if the context was not created yet return!
  if (self.document.documentState != UIDocumentStateNormal) {
    return;
  }
  CGFloat grayScaleValueOfColor = [self.color grayScaleColor];
  OKSonuclarViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"sonuclarViewController"];
  [vc initResultsWithGrayScaleValue:grayScaleValueOfColor forManagedObjectContext:self.managedObjectContext];
  [self.navigationController pushViewController:vc animated:YES];
}

-(void)documentIsReady
{
  //the document is ready!
//  [self.tableView reloadData];
}

-(void)initManagedDocument
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSURL *documentsDir = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
  
  NSString *docName = @"SacBoyalari.dm";
  NSURL *url = [documentsDir URLByAppendingPathComponent:docName isDirectory:YES];
  
  NSURL *persUrl = [url URLByAppendingPathComponent:@"StoreContent" isDirectory:YES];
  if (![[NSFileManager defaultManager] fileExistsAtPath:[persUrl path]]) {
    NSError *error;
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
    NSLog(@"File successfuly copied to folder %@", persUrl);
  }
  
  NSLog(@"DB path: %@", url);
  self.document = [[UIManagedDocument alloc] initWithFileURL:url];
  if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
    [self.document openWithCompletionHandler:^(BOOL success) {
      if (success) {
        self.managedObjectContext = self.document.managedObjectContext;
        [self documentIsReady];
      }
      if (!success) NSLog(@"Couldnt open document at %@", url);
    }];
  } else {
    [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
      if (success) {
        self.managedObjectContext = self.document.managedObjectContext;
        [self documentIsReady];
      }
      if (!success) NSLog(@"Couldnt create document at %@", url);
    }];
  }
  //  UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
}


@end
