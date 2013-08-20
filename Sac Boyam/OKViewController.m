//
//  OKViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKViewController.h"
#import <QuartzCore/QuartzCore.h>

struct pixel {
  unsigned char r,g,b,a;
};

@interface OKViewController () <FDTakeDelegate>
@property (strong, nonatomic) MyCutomView *myView;

@end

@implementation OKViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.navigationController setNavigationBarHidden:NO animated:NO];

  self.takeController = [[FDTakeController alloc] init];
  self.takeController.delegate = self;
  
  self.takeController.takePhotoText = @"Take Photo";
  self.takeController.takeVideoText = @"Take Video";
  self.takeController.chooseFromPhotoRollText = @"Choose Existing";
  self.takeController.chooseFromLibraryText = @"Choose Existing";
  self.takeController.cancelText = @"Cancel";
  self.takeController.noSourcesText = @"No Photos Available";
  
  self.takeController.allowsEditingPhoto = YES;
  [self SelectNewImage:self];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  
  self.myView = [[MyCutomView alloc] initWithFrame:self.selectedImage.bounds andStartPoint:CGPointMake(0, 0)];
  self.myView.backgroundColor = [UIColor clearColor];
  
}

- (IBAction)SelectNewImage:(id)sender {
  [self.takeController takePhotoOrChooseFromLibrary];
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
  UIAlertView *alertView;
  if (madeAttempt)
    alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled after selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  else
    alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled without selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
  //TODO: Ask if user wants to save original photo..
  //UIImage *originalImage = (UIImage *) [info objectForKey:
  //                           UIImagePickerControllerOriginalImage];
  //[self.imageView setImage:originalImage];
  
  //UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
  [self.selectedImage setImage:photo];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[touches allObjects] objectAtIndex:0];
  CGPoint point = [touch locationInView:self.view];
  
  if ([self.selectedImage pointInside:point withEvent:event])
  {
    // Create a rectangle (10x10) from touched touched point
    CGRect rect1 = CGRectMake(point.x - 5, point.y - 5, 10, 10);
    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.selectedImage.image CGImage], rect1);
    //DEBUG_ONLY//UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    //DEBUG_ONLY//[self.previewImage setImage:img];
    // calculate average color for next steps
    UIColor *color = [self getAverageColorOfCroppedImage:[UIImage imageWithCGImage:imageRef]];
    //DEBUG_ONLY//NSLog(@"Average Color of Picture: %@", [CIColor colorWithCGColor:color.CGColor].stringRepresentation);
    
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
    CGRect rect1 = CGRectMake(point.x - 5, point.y - 5, 10, 10);
    // Crop a picture from given rectangle
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.selectedImage.image CGImage], rect1);
    //DEBUG_ONLY//UIImage *tmp_img = [UIImage imageWithCGImage:imageRef];
    //DEBUG_ONLY//[self.previewImage setImage:img];
    // calculate average color for next steps
    UIColor *color = [self getAverageColorOfCroppedImage:[UIImage imageWithCGImage:imageRef]];
    //DEBUG_ONLY//NSLog(@"Average Color of Picture: %@", [CIColor colorWithCGColor:color.CGColor].stringRepresentation);
    
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
