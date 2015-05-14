//
//  OKImagePickerViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 14/05/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import "OKImagePickerViewController.h"

@interface OKImagePickerViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
//@property (strong, nonatomic) UIImage *croppedImage;
- (IBAction)tabbarBtnPressed:(UIBarButtonItem *)sender;

@property CGFloat lastScale;
@property CGFloat lastRotation;
@property CGFloat firstX;
@property CGFloat firstY;
@property (strong, nonatomic) CAShapeLayer *marque;
@end

@implementation OKImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  [self.selectedImageView setUserInteractionEnabled:YES];
  
  // create and configure the pinch gesture
  UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
  [pinchGestureRecognizer setDelegate:self];
  [self.selectedImageView addGestureRecognizer:pinchGestureRecognizer];
  
  // create and configure the rotation gesture
  UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureDetected:)];
  [rotationGestureRecognizer setDelegate:self];
  [self.selectedImageView addGestureRecognizer:rotationGestureRecognizer];
  
  // creat and configure the pan gesture
  UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
  [panGestureRecognizer setDelegate:self];
  [self.selectedImageView addGestureRecognizer:panGestureRecognizer];
  
  UITapGestureRecognizer *tapProfileImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
  [tapProfileImageRecognizer setNumberOfTapsRequired:1];
  [tapProfileImageRecognizer setDelegate:self];
  [self.selectedImageView addGestureRecognizer:tapProfileImageRecognizer];
  
  [self.selectedImageView setImage:self.selectedImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tabbarBtnPressed:(UIBarButtonItem *)sender
{
//  UIImage *imageToBeReturned = self.selectedImage;
  if (sender.tag == 1) {
    UIGraphicsBeginImageContext( self.selectedImageView.bounds.size );
    [self.selectedImageView.image drawInRect:self.selectedImageView.bounds];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.selectedImage = croppedImage;
  }
//  [self dismissViewControllerAnimated:YES completion:nil];
  [self performSegueWithIdentifier:@"unwindToMainPageSegue" sender:self];
}

#pragma mark - Gesture Recognizers

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer
{
  if([recognizer state] == UIGestureRecognizerStateBegan) {
    _lastScale = 1.0;
  }
  
  CGFloat scale = 1.0 - (_lastScale - [recognizer scale]);
  
  CGAffineTransform currentTransform = self.selectedImageView.transform;
  CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
  
  [self.selectedImageView setTransform:newTransform];
  
  _lastScale = [recognizer scale];
//  [self showOverlayWithFrame:self.selectedImageView.frame];
}

- (void)rotationGestureDetected:(UIRotationGestureRecognizer *)recognizer
{
  if([recognizer state] == UIGestureRecognizerStateEnded)
  {
    _lastRotation = 0.0;
    return;
  }
  
  CGFloat rotation = 0.0 - (_lastRotation - [recognizer rotation]);
  
  CGAffineTransform currentTransform = self.selectedImageView.transform;
  CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
  
  [self.selectedImageView setTransform:newTransform];
  
  _lastRotation = [recognizer rotation];
//  [self showOverlayWithFrame:self.selectedImageView.frame];
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
  CGPoint translatedPoint = [recognizer translationInView:recognizer.view];
  
  if([recognizer state] == UIGestureRecognizerStateBegan) {
    _firstX = [self.selectedImageView center].x;
    _firstY = [self.selectedImageView center].y;
  }
  
  translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
  
  [self.selectedImageView setCenter:translatedPoint];
//  [self showOverlayWithFrame:self.selectedImageView.frame];
}

- (void)tapGestureDetected:(UIPanGestureRecognizer *)recognizer
{
  
}

/*
-(void)showOverlayWithFrame:(CGRect)frame {
  
  if (![_marque actionForKey:@"linePhase"]) {
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.5f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [_marque addAnimation:dashAnimation forKey:@"linePhase"];
  }
  
  _marque.bounds = CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
  _marque.position = CGPointMake(frame.origin.x + canvas.frame.origin.x, frame.origin.y + canvas.frame.origin.y);
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  [_marque setPath:path];
  CGPathRelease(path);
  
  _marque.hidden = NO;
}
*/

/*
- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer
{
  UIGestureRecognizerState state = [recognizer state];
  
  if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
  {
    CGFloat scale = [recognizer scale];
    [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, scale, scale)];
    [recognizer setScale:1.0];
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

@end
