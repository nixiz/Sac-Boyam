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
#import "OKInfoViewController.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "OKSettingsViewController.h"
#import "OKSonuclarViewController.h"
#import "OKAppDelegate.h"

@interface OKSelectColorVC () <OKSettingsDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) OKZoomView *myView;
@property (strong) UIColor *color;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIButton *findButton;
@end

@implementation OKSelectColorVC

- (void)viewDidLoad {
  [super viewDidLoad];
//  UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_white_navbar.png"]
//                                                                style:UIBarButtonItemStylePlain
//                                                               target:self
//                                                               action:@selector(findForSelectedColor)];

//  UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithTitle:@"Find"
//                                                                style:UIBarButtonItemStylePlain
//                                                               target:self
//                                                               action:@selector(findForSelectedColor)];
  UIToolbar *tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
  [tools setTintColor:[UIColor clearColor]];
  [tools setTranslucent:YES];
  
  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showTutorial)];
  
  self.findButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.findButton setFrame:CGRectMake(0, 0, 88, 30)];
  
  [self.findButton setTitle:NSLocalizedStringFromTable(@"find", okStringsTableName, nil) forState:UIControlStateNormal];
  [self.findButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.8] forState:UIControlStateNormal];
//  [self.findButton setTintColor:[UIColor colorWithWhite:0.0 alpha:0.8]];

  UIImage *img = [UIImage imageWithColor:[[UIColor clearColor] colorWithAlphaComponent:0.35] andSize:CGSizeMake(30, 30)];
//  cell.imageView.layer.cornerRadius = cell.bounds.size.height / 4.0;
//  cell.imageView.layer.masksToBounds = YES;
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
  [tools setItems:@[infoBtn, searchBtn] animated:NO];
  
  UIBarButtonItem *fixedBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedBtnItem.width = -16;
  
//  self.navigationItem.rightBarButtonItem = searchBtn;
  self.navigationItem.rightBarButtonItems = @[fixedBtnItem, searchBtn];
//  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
//  self.view.backgroundColor = [self.view getBackgroundColor];
  
//  if (self.selectedPicture) {
//    [self.imageView setImage:self.selectedPicture];
//  }
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.myView = [[OKZoomView alloc] initWithFrame:self.imageView.bounds andStartPoint:self.imageView.bounds.origin];
  self.myView.backgroundColor = [UIColor clearColor];
}

-(void)viewDidLayoutSubviews
{
//  NSLog(@"ImageView bound %@", NSStringFromCGRect(self.imageView.bounds));
  //viewDidLayoutSubviews, her view objesi degistirildiginde(previewview eklenip silindiginde) burasi cagirildigindan dolayi
  //resmin tekrar boyutlandirilmasi islemi bir kere yapilmalidir.
  if (self.selectedPicture && !CGSizeEqualToSize(self.imageView.image.size, self.imageView.bounds.size))
  {
    CGRect boundRect = self.imageView.bounds;
    UIGraphicsBeginImageContext(boundRect.size);
    [self.selectedPicture drawInRect:boundRect];
    UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    NSLog(@"Re Scaled Image Size: %@", NSStringFromCGSize(imageToBeShow.size));
    [self.imageView setImage:imageToBeShow];
  }
 
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
  OKInfoViewController *vc = [[OKInfoViewController alloc] initWithNibName:@"OKInfoViewController" bundle:nil];
  if (showWelcomeScreen) {
    [vc setPageIndex:OKWelcomeScreenPage];
  } else {
    [vc setPageIndex:OKSelectColorPage];
  }
  [self presentViewController:vc animated:YES completion:nil];
  
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:showTutorialKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)findForSelectedColor
{
  if (self.color) {
    [self performSegueWithIdentifier:@"resultsSegue" sender:self];
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
  //  self.takeController.allowsEditingPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue];
  //  self.savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
}

#pragma mark - Touch Handles

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.imageView.image == nil) return;
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];

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
  if (self.imageView.image == nil) return;
  
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
  [super touchesEnded:touches withEvent:event];
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



#pragma mark - Navigation
/*
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  if ([identifier isEqualToString:@"resultsSegue"]) {
    if (self.imageView.image == nil) {
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
*/
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  if ([[segue identifier] isEqualToString:@"resultsSegue"]) {
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

@end
