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


static NSString * const okStringsTableName = @"localized";

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
@end

@implementation OKViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.userCanceledRequest = NO;
  
  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  /*
   UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
   
   UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   fixedSpaceBarButtonItem.width = 20;
   
   NSString *selectPhotoString = NSLocalizedStringFromTable(@"selectPhoto", okStringsTableName, nil);
   //  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:nil action:nil];
   UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:selectPhotoString style:UIBarButtonItemStylePlain target:self action:@selector(SelectNewImage:)];
   
   self.navigationItem.rightBarButtonItems = @[btn2, fixedSpaceBarButtonItem, camBtn];
   */
  NSString *selectPhotoString = NSLocalizedStringFromTable(@"selectPhoto", okStringsTableName, nil);
  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:selectPhotoString style:UIBarButtonItemStylePlain target:self action:@selector(SelectNewImage:)];
  self.navigationItem.rightBarButtonItem = btn2;

  NSLog(@"View Frame : %@", NSStringFromCGRect(self.view.frame));
  NSLog(@"View Bounds: %@", NSStringFromCGRect(self.view.bounds));

  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_4"];
  NSLog(@"Navigation Bar frame  size %@", NSStringFromCGSize(self.navigationController.navigationBar.frame.size));
  NSLog(@"Navigation Bar frame  %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
  NSLog(@"Navigation Bar bounds  %@", NSStringFromCGRect(self.navigationController.navigationBar.bounds));
  NSLog(@"Navigation Bar bounds size %@", NSStringFromCGSize(self.navigationController.navigationBar.bounds.size));
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
  
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:122.0/255.0 blue:246.0/255.0 alpha:1.0]}];

  /*
  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
    self.navigationController.navigationBar.barTintColor = [[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45];
    self.navigationController.navigationBar.backgroundColor = [[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45];
    self.navigationController.navigationBar.translucent = NO;
  } else if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0){
    //[[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45]];
  }*/
  
  self.navigationController.navigationBar.barTintColor = [[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45];
  self.navigationController.navigationBar.translucent = NO;
  
  UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSString *imageOverlayString = NSLocalizedStringFromTable(@"imageOverlay", okStringsTableName, nil);
//  img = [img addTextToImageWithText:imageOverlayString andColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:246.0/255.0 alpha:1.0]];
  img = [img addTextToImageWithText:imageOverlayString andColor:nil];
  
  [self.selectedImage setImage: img];
  self.selectedImage.contentMode = UIViewContentModeScaleAspectFit;
  self.selectedImage.backgroundColor = [UIColor clearColor];
//  self.selectedImage.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75];
  self.selectedImage.layer.borderWidth = 2.0;
  self.selectedImage.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.45] CGColor];
  
  self.previewImage.image = [UIImage imageWithColor:[UIColor clearColor] andSize:self.previewImage.bounds.size];
  self.previewImage.layer.borderWidth = 1.0;
  self.previewImage.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:181.0f/255.0f blue:231.0f/255.0f alpha:0.8] CGColor];

  self.previewImage.layer.cornerRadius = 12.0;
  self.previewImage.layer.masksToBounds = YES;
  
//  UIColor *avColor = [backgroundImage averageColor];
//  CGRect rect = self.previewImage.bounds;
//  UIGraphicsBeginImageContext(rect.size);
//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGContextSetFillColorWithColor(context, [avColor CGColor]);
//  CGContextFillRect(context, rect);
//  UIImage *s_img = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  [self.previewImage setImage:s_img];

  self.takeController = [[FDTakeController alloc] init];
  self.takeController.delegate = self;
  self.takeController.allowsEditingPhoto = YES;
  
  self.myView = [[OKZoomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];
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
}

- (IBAction)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
}

-(void)userCancelledRequest
{
  [self.myModalViewController dismissViewControllerAnimated:YES completion:nil];
  self.userCanceledRequest = YES;

  //TODO: cancel url request
//  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(simulateDataFetched) object:nil];
//  self performSelector:<#(SEL)#> withObject:<#(id)#> afterDelay:<#(NSTimeInterval)#>
}

- (void)acceptChangedSetings
{
  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
  
//  self.settingsArray = settings;
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

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
//  [self.navigationController popToRootViewControllerAnimated:NO];
//  UIAlertView *alertView;
//  if (madeAttempt)
//    alertView = [[UIAlertView alloc] initWithTitle:@"Ooopps!!" message:@"The take was cancelled after selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////  else
////    alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled without selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//  [alertView show];
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
  UIImagePickerControllerSourceType imgSource = (UIImagePickerControllerSourceType)[[info objectForKey:kUIImagePickerControllerSourceType] integerValue];
  if (imgSource == UIImagePickerControllerSourceTypeCamera && self.savePhoto)
  {
    UIImage *originalImage = (UIImage *) [info objectForKey:
                                          UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
  }
  
  UIImage *imageToBeShow = nil;
  if (self.takeController.allowsEditingPhoto)
  {
    UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
    [photo drawInRect:self.selectedImage.bounds];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"Small Image Size:   %@", NSStringFromCGSize(smallImage.size));

    CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
    imageToBeShow = [UIImage imageWithCGImage:imagerRef];
    NSLog(@"Cropped Image Size: %@", NSStringFromCGSize(imageToBeShow.size));
    CGImageRelease(imagerRef);
  }
  else
  {
    UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
    [photo drawInRect:self.selectedImage.bounds];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
    imageToBeShow = [UIImage imageWithCGImage:imagerRef];
    CGImageRelease(imagerRef);
  }
  [self.selectedImage setImage:imageToBeShow];
  [self.selectedImage sizeToFit];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if ([self.selectedImage pointInside:point withEvent:event])
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];
    
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
  
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if ([self.selectedImage pointInside:point withEvent:event])
  {
    /***--Crop photo from touched point and calculate average color of cropped photo.--***/
    
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];

    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.selectedImage.image CGImage], rect1);
    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

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

//#if TARGET_IPHONE_SIMULATOR
//    NSString *colorCodeString = NSLocalizedStringFromTable(@"colorCode", okStringsTableName, nil);
//    self.lblRenkKodu.text = [NSString stringWithFormat:@"%@: %@", colorCodeString, [OKUtils colorToHexString:self.color]];
    
//#endif
    self.myView.previewImage = img;
    self.myView.newPoint = point;
//    [self.view addSubview:self.myView];
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
  CGFloat dx,dy;
  dx = point.x >= 16 ? 16 : 0;
  dy = point.y >= 16 ? 16 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, 32, 32);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"settingsSegue"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setDelegate:self];
    [vc setManagedObjectContext:self.managedObjectContext];
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
      NSLog(@"Error: %@", [error userInfo]);
    }
    persUrl = [persUrl URLByAppendingPathComponent:@"persistentStore"];
    NSURL *preloadUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"persistentStore" ofType:@""]];
    
    if (![[NSFileManager defaultManager]  copyItemAtURL:preloadUrl toURL:persUrl error:&error])
    {
      NSLog(@"Error %@", [error userInfo]);
    }
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
