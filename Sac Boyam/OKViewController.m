//
//  OKViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "OKZoomView.h"
#import "UIView+CreateImage.h"
//#import "GKImagePicker.h"


struct pixel {
  unsigned char r,g,b,a;
};

@interface OKViewController () <FDTakeDelegate/*, GKImagePickerDelegate, UIImagePickerControllerDelegate*/>
@property (strong, nonatomic) OKZoomView *myView;
@property (strong, nonatomic) NSDictionary *settingsArray;
@property BOOL savePhoto;
//@property (strong, nonatomic) GKImagePicker *imagePicker;
@end

@implementation OKViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
//  [self.navigationController setNavigationBarHidden:NO animated:NO];
  self.settingsArray = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO, @"SavePhotos", @YES, @"EditPhotos", @NO, @"TakeRecord", nil];

//  self.settingsArray = @[@NO, @YES, @NO];
  self.savePhoto = NO;
  
//  UIView *customNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 60)];
//  UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//  [btn1 setFrame:CGRectMake(120, 0, 60, 60)];
//  btn1 setTitle:@"<#string#>" forState:<#(UIControlState)#>

//  UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(SelectNewImage:)];
//  UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//  [fixedSpaceBarButtonItem setWidth:8];
  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:@"Resim Sec" style:UIBarButtonItemStylePlain target:self action:@selector(SelectNewImage:)];
//  self.navigationItem.rightBarButtonItems = @[btn1, fixedSpaceBarButtonItem, btn2];
  self.navigationItem.rightBarButtonItem = btn2;

  NSLog(@"View Frame : %@", NSStringFromCGRect(self.view.frame));
  NSLog(@"View Bounds: %@", NSStringFromCGRect(self.view.bounds));

  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_4"];
  NSLog(@"%@", NSStringFromCGSize(self.navigationController.navigationBar.bounds.size));
  UIGraphicsBeginImageContext(CGSizeMake(320, 75));
  [backgroundImage drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  
//  UIGraphicsBeginImageContext(self.view.frame.size);
//  [backgroundImage drawInRect:self.view.bounds];
//  UIImage *b_image = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_sacBoyasi_4"]];
//  self.view.backgroundColor = [UIColor colorWithPatternImage:b_image];

  self.navigationController.navigationBar.barTintColor = [[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45];
  self.navigationController.navigationBar.backgroundColor = [[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45];
  
//  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
////    image = [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:image];
    self.navigationController.navigationBar.translucent = NO;
//  } else if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0){
//    [self.navigationController.navigationBar setTintColor:[[UIColor colorWithPatternImage:image] colorWithAlphaComponent:0.45]];
//  }
  
//  [self.view.layer insertSublayer:[OKUtils getBackgroundLayer:self.view.bounds] atIndex:0];
  

//  [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//  self.navigationController.navigationBar.shadowImage = [UIImage new];
//  [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:7.0f/255.0f green:120.0f/255.0f blue:225.0f/255.0f alpha:1.0]];
//  NSLog(@"Old Frame : %@", NSStringFromCGRect(self.selectedImage.frame));
//  NSLog(@"Old Bounds: %@", NSStringFromCGRect(self.selectedImage.bounds));

  UIImage *img = [UIImage imageNamed:@"default_screen"];
  img = [img addTextToImageWithText:@"Baslamak Icin Resim Secin"];
  [self.selectedImage setImage: img];
  self.selectedImage.contentMode = UIViewContentModeScaleAspectFit;
  self.selectedImage.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75];
  self.selectedImage.layer.borderWidth = 2.0;
  self.selectedImage.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.45] CGColor];

//  self.imagePicker = [[GKImagePicker alloc] init];
//  self.imagePicker.cropSize = self.selectedImage.bounds.size;
//  self.imagePicker.delegate = self;
  
//  self.previewImage.layer.cornerRadius = self.selectedImage.bounds.size.height / 16;
  self.previewImage.layer.borderWidth = 1.0;
  self.previewImage.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:181.0f/255.0f blue:231.0f/255.0f alpha:0.8] CGColor];

  self.previewImage.layer.cornerRadius = 12.0;
  self.previewImage.layer.masksToBounds = YES;

  self.takeController = [[FDTakeController alloc] init];
  self.takeController.delegate = self;
  
  self.takeController.takePhotoText = @"Take Photo";
  self.takeController.takeVideoText = @"Take Video";
  self.takeController.chooseFromPhotoRollText = @"Choose Existing";
  self.takeController.chooseFromLibraryText = @"Choose Existing";
  self.takeController.cancelText = @"Cancel";
  self.takeController.noSourcesText = @"No Photos Available";
  
  self.takeController.allowsEditingPhoto = YES;
  
  self.myView = [[OKZoomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  //  self.myView = [[MyCutomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];

//  [self SelectNewImage:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  
//  self.myView = [[MyCutomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView = [[OKZoomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:self.selectedImage.frame.origin];
  self.myView.backgroundColor = [UIColor clearColor];
}

- (IBAction)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
//  [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
}
/*
#pragma mark - GKImagePickerDelegate

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
  UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
  [image drawInRect:self.selectedImage.bounds];
  UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  NSLog(@"Small Image Size:   %@", NSStringFromCGSize(smallImage.size));
  
  CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
  UIImage *imageToBeShow = [UIImage imageWithCGImage:imagerRef];
  NSLog(@"Cropped Image Size: %@", NSStringFromCGSize(imageToBeShow.size));

  [self.selectedImage setImage:imageToBeShow];
  [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
//  [self.selectedImage sizeToFit];
}
*/

- (void)acceptChangedSetings:(NSDictionary *)settings
{
  //self.settingsArray = @[@NO, @YES, @NO];
  
//  self.takeController.allowsEditingPhoto = [[settings objectAtIndex:1] boolValue];
//  self.savePhoto = [[settings objectAtIndex:0] boolValue];
  self.takeController.allowsEditingPhoto = [settings[@"EditPhotos"] boolValue];
  self.savePhoto = [settings[@"SavePhotos"] boolValue];
  
  self.settingsArray = settings;
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
  //TODO: Ask if user wants to save original photo..
  UIImage *originalImage = (UIImage *) [info objectForKey:
                             UIImagePickerControllerOriginalImage];
  UIImage *imageToBeShow = nil;
  if (self.takeController.allowsEditingPhoto) {
    UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
    [photo drawInRect:self.selectedImage.bounds];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"Small Image Size:   %@", NSStringFromCGSize(smallImage.size));

    CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
    imageToBeShow = [UIImage imageWithCGImage:imagerRef];
    NSLog(@"Cropped Image Size: %@", NSStringFromCGSize(imageToBeShow.size));
    
  } else {
    
    UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
    [photo drawInRect:self.selectedImage.bounds];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
    imageToBeShow = [UIImage imageWithCGImage:imagerRef];
//    imageToBeShow = originalImage;
    
    
  }
  
//  UIGraphicsBeginImageContext(self.selectedImage.bounds.size);
//  [photo drawInRect:self.selectedImage.bounds];
//  UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  NSLog(@"Small Image Size: %@", NSStringFromCGSize(smallImage.size));
//
//  CGImageRef imagerRef = CGImageCreateWithImageInRect([smallImage CGImage], self.selectedImage.bounds);
//  UIImage *croppedImage = [UIImage imageWithCGImage:imagerRef];
//  
//  //[self.imageView setImage:originalImage];
//  NSLog(@"Original Image Size: %@", NSStringFromCGSize(originalImage.size));
//  NSLog(@"Cropped  Image Size: %@", NSStringFromCGSize(croppedImage.size));
//  NSLog(@"Selected ImageBounds: %@", NSStringFromCGRect(self.selectedImage.bounds));
  
  /*UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);*/
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
//  NSLog(@"%@", NSStringFromCGRect(self.selectedImage.frame));
//  NSLog(@"%@", NSStringFromCGRect(self.selectedImage.bounds));
  
  if ([self.selectedImage pointInside:point withEvent:event])
  {
    /***--Crop photo from touched point and calculate average color of cropped photo.--***/
    
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = [self getRectangleFromPoint:point];

    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.selectedImage.image CGImage], rect1);
    UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];

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
    
    //[UIColor colorWithRed:186.0f/255.0f green:209.0f/255.0f blue:232.0f/255.0f alpha:1.0]
//    const CGFloat *components = CGColorGetComponents([color CGColor]);
//    UIColor *inverseColor = [UIColor colorWithRed:fabsf(186.0f/255.0f - components[0]) green:fabsf(209.0f/255.0f - components[1]) blue:fabsf(232.0f/255.0f - components[2]) alpha:1.0];
    
//    CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"borderColor"];
//    colorAnim.fromValue = (id)self.previewImage.layer.borderColor;
//    colorAnim.toValue = (id)[inverseColor CGColor];
//    self.previewImage.layer.borderColor = [inverseColor CGColor];
    self.lblRenkKodu.text = [NSString stringWithFormat:@"Renk Kodu: %@", [OKUtils colorToHexString:color]];
    
    self.myView.previewImage = img;
    self.myView.newPoint = point;
    [self.view addSubview:self.myView];
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

- (UIColor*) getAverageColorOfCroppedImage:(UIImage*)image
{
  NSUInteger red = 0;
  NSUInteger green = 0;
  NSUInteger blue = 0;
  
  
  // Allocate a buffer big enough to hold all the pixels
  
  struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
  if (pixels != nil)
  {
    
    CGContextRef context = CGBitmapContextCreate(
                                                 (void*) pixels,
                                                 image.size.width,
                                                 image.size.height,
                                                 8,
                                                 image.size.width * 4,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 kCGImageAlphaPremultipliedLast
                                                 );
    
    if (context != NULL)
    {
      // Draw the image in the bitmap
      
      CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
      
      // Now that we have the image drawn in our own buffer, we can loop over the pixels to
      // process it. This simple case simply counts all pixels that have a pure red component.
      
      // There are probably more efficient and interesting ways to do this. But the important
      // part is that the pixels buffer can be read directly.
      
      NSUInteger numberOfPixels = image.size.width * image.size.height;
      for (int i=0; i<numberOfPixels; i++) {
        red += pixels[i].r;
        green += pixels[i].g;
        blue += pixels[i].b;
      }
      
      
      red   /= numberOfPixels;
      green /= numberOfPixels;
      blue  /= numberOfPixels;
      
      
      CGContextRelease(context);
    }
    
    free(pixels);
  }
  return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point
{
  
  UIColor* color = nil;
  
  CGImageRef inImage;
  
  inImage = self.selectedImage.image.CGImage;
  
  
  // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
  CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
  if (cgctx == NULL) { return nil; /* error */ }
  
  size_t w = CGImageGetWidth(inImage);
  size_t h = CGImageGetHeight(inImage);
  CGRect rect = {{0,0},{w,h}};
  
  
  // Draw the image to the bitmap context. Once we draw, the memory
  // allocated for the context for rendering will then contain the
  // raw image data in the specified color space.
  CGContextDrawImage(cgctx, rect, inImage);
  
  // Now we can get a pointer to the image data associated with the bitmap
  // context.
  unsigned char* data = CGBitmapContextGetData (cgctx);
  if (data != NULL) {
    //offset locates the pixel in the data from x,y.
    //4 for 4 bytes of data per pixel, w is width of one row of data.
    int offset = 4*((w*round(point.y))+round(point.x));
    int alpha =  data[offset];
    int red = data[offset+1];
    int green = data[offset+2];
    int blue = data[offset+3];
    color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
  }
  
  // When finished, release the context
  //CGContextRelease(cgctx);
  // Free image data memory for the context
  if (data) { free(data); }
  
  return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
  CGContextRef    context = NULL;
  CGColorSpaceRef colorSpace;
  void *          bitmapData;
  int             bitmapByteCount;
  int             bitmapBytesPerRow;
  
  // Get image width, height. We'll use the entire image.
  size_t pixelsWide = CGImageGetWidth(inImage);
  size_t pixelsHigh = CGImageGetHeight(inImage);
  
  // Declare the number of bytes per row. Each pixel in the bitmap in this
  // example is represented by 4 bytes; 8 bits each of red, green, blue, and
  // alpha.
  bitmapBytesPerRow   = (pixelsWide * 4);
  bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
  
  // Use the generic RGB color space.
  colorSpace = CGColorSpaceCreateDeviceRGB();
  
  if (colorSpace == NULL)
  {
    fprintf(stderr, "Error allocating color space\n");
    return NULL;
  }
  
  // Allocate memory for image data. This is the destination in memory
  // where any drawing to the bitmap context will be rendered.
  bitmapData = malloc( bitmapByteCount );
  if (bitmapData == NULL)
  {
    fprintf (stderr, "Memory not allocated!");
    CGColorSpaceRelease( colorSpace );
    return NULL;
  }
  
  // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
  // per component. Regardless of what the source image format is
  // (CMYK, Grayscale, and so on) it will be converted over to the format
  // specified here by CGBitmapContextCreate.
  context = CGBitmapContextCreate (bitmapData,
                                   pixelsWide,
                                   pixelsHigh,
                                   8,      // bits per component
                                   bitmapBytesPerRow,
                                   colorSpace,
                                   kCGImageAlphaPremultipliedFirst);
  if (context == NULL)
  {
    free (bitmapData);
    fprintf (stderr, "Context not created!");
  }
  
  // Make sure and release colorspace before returning
  CGColorSpaceRelease( colorSpace );
  
  return context;
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
    [vc setCurrentSettings:self.settingsArray];
    
//    UIImage *underlyingImage = [self.view createImageFromView];
//    underlyingImage = [underlyingImage applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
}


/*
- (UIImage *)captureScreenInRect:(CGRect)captureFrame
{
  
  CALayer *layer;
  layer = self.view.layer;
  UIGraphicsBeginImageContext(self.view.frame.size);
  CGContextClipToRect (UIGraphicsGetCurrentContext(), captureFrame);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return screenImage;
}
*/
@end
