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

@interface OKTryOnMeVC () <FDTakeDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *previewImg;
@property (weak, nonatomic) IBOutlet UISlider *blendSlider;
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;
- (IBAction)sliderValueChanged:(id)sender;
@property (strong, nonatomic) OKZoomView *myView;
@property FDTakeController *takeController;

@property (strong, nonatomic) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *filesDictionary;
@property CGRect previewImageBound;
@property (strong) UIColor *color;
@property (strong, nonatomic) UIButton *takePicBtn;

@property CGFloat blendValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@end

@implementation OKTryOnMeVC

- (void)viewDidLoad {
  [super viewDidLoad];  
  UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(SelectNewImage:)];
  self.navigationItem.rightBarButtonItem = camBtn;
  self.view.backgroundColor = [self.view getBackgroundColor];

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
  
  self.myView = [[OKZoomView alloc] initWithFrame:self.previewImg.bounds andStartPoint:self.previewImg.frame.origin];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.myView = [[OKZoomView alloc] initWithFrame:self.previewImg.bounds andStartPoint:self.previewImg.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];
  self.previewImageBound = self.previewImg.bounds;
  [self sliderValueChanged:self.blendSlider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
}

- (UIImage *)blendImages:(UIImage *)firstImage and:(UIImage *)secondImage desiredSize:(CGSize)size;
{
  UIImage *blendImage = nil;
  
  UIGraphicsBeginImageContext( size );
  
  // Use existing opacity as is
  [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
  // Apply supplied opacity
  [secondImage drawInRect:CGRectMake(0,0, size.width, size.height) blendMode:kCGBlendModeNormal alpha:self.blendValue];
  
  blendImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  return blendImage;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.previewImg.image == nil) return;
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if (CGRectContainsPoint(self.previewImg.frame, point))
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];
    rect1 = CGRectOffset(rect1, -self.previewImg.frame.origin.x, -self.previewImg.frame.origin.y);
    
    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.previewImg.image CGImage], rect1);
    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    // calculate average color for next steps
    UIColor *blendColor = [tmp_img averageColor];
    
    CGRect rect = CGRectMake(0, 0, rect1.size.width, rect1.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [blendColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *blendImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context2 = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context2, [self.color CGColor]);
    CGContextFillRect(context2, rect);
    UIImage *firstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *finalImage = [self blendImages:firstImage and:blendImage desiredSize:rect1.size];
    UIColor *color1 = [firstImage averageColor];
    UIColor *color2 = [blendImage averageColor];
    UIColor *color3 = [finalImage averageColor];
    NSLog(@"\nFirstColor: %@\nSecondColor: %@\nFinalColor: %@", [color1 description], [color2 description], [color3 description]);
    
    [self.imgView1 setImage:firstImage];

    
    self.myView.newPoint = point;
    [self.view addSubview:self.myView];
    [self.myView setNeedsDisplay];
  }
  
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.previewImg.image == nil) return;
  
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if (CGRectContainsPoint(self.previewImg.frame, point))
  {
    /***--Crop photo from touched point and calculate average color of cropped photo.--***/
    
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];
    rect1 = CGRectOffset(rect1, -self.previewImg.frame.origin.x, -self.previewImg.frame.origin.y);
    
    // Crop a picture from given rectangle
    UIImage *tmp_img = [self.previewImg.image cropImageWithRect:rect1];
    
    // calculate average color for next steps
    UIColor *blendColor = [tmp_img averageColor];

    CGRect rect = CGRectMake(0, 0, rect1.size.width, rect1.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [blendColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *blendImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context2 = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context2, [self.color CGColor]);
    CGContextFillRect(context2, rect);
    UIImage *firstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *finalImage = [self blendImages:firstImage and:blendImage desiredSize:rect1.size];
    
//    [self.imgView1 setImage:firstImage];
    [self.imgView2 setImage:blendImage];
    
    self.myView.previewImage = finalImage;
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
  CGSize drawableSize = self.previewImg.bounds.size;
  CGFloat scaleFactor = [UIScreen mainScreen].scale;
  if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
    scaleFactor = [UIScreen mainScreen].nativeScale;
  }
  drawableSize.width *= scaleFactor;
  CGFloat capturePixelSize = drawableSize.width * 0.1;
  CGFloat dx,dy;
  dx = point.x >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  dy = point.y >= capturePixelSize/2.0 ? capturePixelSize/2.0 : 0;
  
  return CGRectMake(point.x - dx, point.y - dy, capturePixelSize, capturePixelSize);
}

- (void)saveImageToUserDefaults
{
  [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(self.previewImg.image) forKey:userDefaultPhotoKey];
  if (![[NSUserDefaults standardUserDefaults] synchronize]) {
    NSLog(@"User Defaults can not be saved!!!");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sliderValueChanged:(id)sender {
  
  self.blendValue = [((UISlider *)sender) value];
  [self.sliderLabel setText:[NSString stringWithFormat:@"Blend Value: %f", self.blendValue]];
}
@end
