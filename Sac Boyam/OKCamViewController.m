//
//  ViewController.m
//  SBKameraEkrani
//
//  Created by Oguzhan Katli on 16/02/15.
//  Copyright (c) 2015 Oğuzhan Katlı. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OKCamViewController.h"

#import "AVCamPreviewView.h"
#import "UIImage+AverageColor.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+GrayScale.h"
#import "OKUtils.h"

#import "OKSelectColorVC.h"
#import "OKSonuclarViewController.h"
#import "OKAppDelegate.h"


static void * CapturingStillImageContext = &CapturingStillImageContext;
//static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface OKCamViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)captureImage:(id)sender;
- (IBAction)switchCameraMode:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *transformableOutlets;
- (IBAction)switchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *autoModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttonOutlets;

@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
//@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;


@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIButton *calculatedColorBtn;
@property (nonatomic, getter=isAutoModeActivated) BOOL autoModeActive;

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIImage *pickedImage;
@end

@implementation OKCamViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  CGRect frameRect = CGRectMake(0, 0, 80, 44);
  self.toolbar = [[UIToolbar alloc] initWithFrame:frameRect];
  [self.toolbar setTintColor:[UIColor clearColor]];
  [self.toolbar setTranslucent:YES];
  
  self.calculatedColorBtn = [[UIButton alloc] initWithFrame:frameRect];
  [self.calculatedColorBtn setTitle:@"Color: " forState:UIControlStateNormal];
  [self.calculatedColorBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
  [self.calculatedColorBtn setImage:[UIImage imageWithColor:[UIColor brownColor] andSize:CGSizeMake(44, 44)] forState:UIControlStateNormal];
  CGSize imageSize = self.calculatedColorBtn.imageView.image.size;
  self.calculatedColorBtn.imageView.layer.cornerRadius = imageSize.height / 4.0;
  self.calculatedColorBtn.imageView.layer.masksToBounds = YES;
  
  [self.calculatedColorBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, - imageSize.width*2 , 0.0, 0.0)];
  CGSize titleSize = [self.calculatedColorBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.calculatedColorBtn.titleLabel.font}];
  [self.calculatedColorBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -titleSize.width*2 - 6)];

  [self.calculatedColorBtn setUserInteractionEnabled:NO];
  [self.calculatedColorBtn setEnabled:NO];
  
  UIBarButtonItem *fixedBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  fixedBtnItem.width = 0;

  UIBarButtonItem *barbtnItem = [[UIBarButtonItem alloc] initWithCustomView:self.calculatedColorBtn];
  
  [self.toolbar setItems:@[fixedBtnItem, barbtnItem]];
  
  self.navigationItem.rightBarButtonItems = @[fixedBtnItem, barbtnItem];
  
  [self.autoModeSwitch setOn:YES];
  [self switchValueChanged:self.autoModeSwitch];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
  
  // Create the AVCaptureSession
  AVCaptureSession *session = [AVCaptureSession new];
  [self setSession:session];
  if ([session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
    [session setSessionPreset:AVCaptureSessionPreset640x480];
  }
  // Setup the preview view
  [[self previewView] setSession:session];
  
  // Check for device authorization
  [self checkDeviceAuthorizationStatus];
  
  // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
  // Why not do all of this on the main queue?
  // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
  
  dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
  [self setSessionQueue:sessionQueue];
  
  dispatch_async(sessionQueue, ^{
//    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    NSError *error = nil;
    
    AVCaptureDevice *videoDevice = [OKCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error)
    {
      NSLog(@"%@", error);
    }
    
    if ([session canAddInput:videoDeviceInput])
    {
      [session addInput:videoDeviceInput];
      [self setVideoDeviceInput:videoDeviceInput];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        // Why are we dispatching this to the main queue?
        // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
        // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
        
        [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
        
        [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
      });
    }
    
//    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
//    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
//    
//    if (error)
//    {
//      NSLog(@"%@", error);
//    }
//    
//    if ([session canAddInput:audioDeviceInput])
//    {
//      [session addInput:audioDeviceInput];
//    }
//    
//    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//    if ([session canAddOutput:movieFileOutput])
//    {
//      [session addOutput:movieFileOutput];
//      AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//      if ([connection isVideoStabilizationSupported]) {
//        [connection setEnablesVideoStabilizationWhenAvailable:YES];
////        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeStandard];
//      }
//      [self setMovieFileOutput:movieFileOutput];
//    }
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([session canAddOutput:stillImageOutput])
    {
      [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
      [session addOutput:stillImageOutput];
      [self setStillImageOutput:stillImageOutput];
    }
    
    AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
    if ([session canAddOutput:output]) {
      [session addOutput:output];
    }
    
    dispatch_queue_t que = dispatch_queue_create("videoutput", NULL);
    [output setSampleBufferDelegate:self queue:que];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    output.minFrameDuration = CMTimeMake(1, 15);
    
    
  });
}

-(void)viewWillAppear:(BOOL)animated
{
  dispatch_async([self sessionQueue], ^{
    [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
    [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
//    [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    
    __weak OKCamViewController *weakSelf = self;
    [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
      OKCamViewController *strongSelf = weakSelf;
      dispatch_async([strongSelf sessionQueue], ^{
        // Manually restarting the session since it must have been stopped due to an error.
        [[strongSelf session] startRunning];
//        [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
      });
    }]];
    [[self session] startRunning];
  });

}

//-(void)viewDidAppear:(BOOL)animated
//{
//  [super viewDidAppear:animated];
//  OKCameraViewController *vc = [[OKCameraViewController alloc] initWithNibName:@"OKCameraViewController" bundle:nil];
//  [self presentViewController:vc animated:NO completion:nil];
//}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  dispatch_async([self sessionQueue], ^{
    [[self session] stopRunning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    
    [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
    [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
    //    [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
  });
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//  dispatch_async([self sessionQueue], ^{
//    [[self session] stopRunning];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
//    [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
//    
//    [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
//    [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
////    [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
//  });
//}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//- (BOOL)prefersStatusBarHidden
//{
//  return YES;
//}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait/*UIInterfaceOrientationPortrait*/;
}

//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//  return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (void)deviceDidRotate:(NSNotification *)notification
{
  UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
  double rotation = 0;
  UIInterfaceOrientation statusBarOrientation;
  switch (currentOrientation) {
    case UIDeviceOrientationFaceDown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationUnknown:
      return;
    case UIDeviceOrientationPortrait:
      rotation = 0;
      statusBarOrientation = UIInterfaceOrientationPortrait;
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      rotation = -M_PI;
      statusBarOrientation = UIInterfaceOrientationPortraitUpsideDown;
      break;
    case UIDeviceOrientationLandscapeLeft:
      rotation = M_PI_2;
      statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
      break;
    case UIDeviceOrientationLandscapeRight:
      rotation = -M_PI_2;
      statusBarOrientation = UIInterfaceOrientationLandscapeRight;
      break;
  }
  CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
  [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)statusBarOrientation];
    [self.transformableOutlets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [(UIView *)obj setTransform:transform];
    }];
    if (statusBarOrientation != UIInterfaceOrientationPortrait) {
      [self.switchLabel setHidden:YES];
    } else {
      [self.switchLabel setHidden:NO];
    }
//    [self.imageView setTransform:transform];
    [[UIApplication sharedApplication] setStatusBarOrientation:statusBarOrientation];
  } completion:nil];
}

- (BOOL)shouldAutorotate
{
  // Disable autorotation of the interface when recording is in progress.
  return ![self lockInterfaceRotation];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (context == CapturingStillImageContext)
  {
    BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
    
    if (isCapturingStillImage)
    {
      [self runStillImageCaptureAnimation];
    }
  }
  else if (context == SessionRunningAndDeviceAuthorizedContext)
  {
    BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (isRunning)
      {
//        [[self cameraButton] setEnabled:YES];
//        [[self recordButton] setEnabled:YES];
//        [[self stillButton] setEnabled:YES];
      }
      else
      {
//        [[self cameraButton] setEnabled:NO];
//        [[self recordButton] setEnabled:NO];
//        [[self stillButton] setEnabled:NO];
      }
    });
  }
  else
  {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark Actions

- (IBAction)captureImage:(id)sender
{
//  [self.captureButton setUserInteractionEnabled:NO];
  [self.captureButton setEnabled:NO];
  dispatch_async([self sessionQueue], ^{
    // Update the orientation on the still image output video connection before capturing.
//    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)currentOrientation];
    
    // Flash set to Auto for Still Capture
    [OKCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
    
    // Capture a still image.
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
      
      if (imageDataSampleBuffer)
      {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
//        image = [UIImage imageWithCGImage:[image CGImage]
//                                    scale:1.0
//                              orientation:UIImageOrientationUp];

        self.pickedImage = image;

        BOOL savePhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:savePhotosKey] boolValue];
        if (savePhoto) {
          UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        if ([self isAutoModeActivated]) {
          if (self.color) {
            [self performSegueWithIdentifier:@"resultsSegueFromCam" sender:self];
            //TODO: find results for color
          } else {
            NSLog(@"Upps!");
            //TODO: burasi olmamali ama olursa da image dan color bul ve find
            
          }
        } else {
          
          [self performSegueWithIdentifier:@"SelectColorSegueFromCam" sender:self];
          //TODO: show select color VC
          
        }
//        [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.captureButton setEnabled:YES];
      });
    }];
  });
}

- (IBAction)switchCameraMode:(id)sender {
//  [[self cameraButton] setEnabled:NO];
//  [[self recordButton] setEnabled:NO];
//  [[self stillButton] setEnabled:NO];
  [self.buttonOutlets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKindOfClass:[UISwitch class]]) {
      [(UISwitch *)obj setEnabled:NO];
    } else {
      [(UIButton *)obj setEnabled:NO];
    }
  }];
  
  dispatch_async([self sessionQueue], ^{
    AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
    
    switch (currentPosition)
    {
      case AVCaptureDevicePositionUnspecified:
        preferredPosition = AVCaptureDevicePositionBack;
        break;
      case AVCaptureDevicePositionBack:
        preferredPosition = AVCaptureDevicePositionFront;
        break;
      case AVCaptureDevicePositionFront:
        preferredPosition = AVCaptureDevicePositionBack;
        break;
    }
    
    AVCaptureDevice *videoDevice = [OKCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    [[self session] beginConfiguration];
    
    [[self session] removeInput:[self videoDeviceInput]];
    if ([[self session] canAddInput:videoDeviceInput])
    {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
      
      [OKCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
      
      [[self session] addInput:videoDeviceInput];
      [self setVideoDeviceInput:videoDeviceInput];
    }
    else
    {
      [[self session] addInput:[self videoDeviceInput]];
    }
    
    [[self session] commitConfiguration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.buttonOutlets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UISwitch class]]) {
          [(UISwitch *)obj setEnabled:YES];
        } else {
          [(UIButton *)obj setEnabled:YES];
        }
      }];
    });
  });
}

//- (BOOL)isSessionRunningAndDeviceAuthorized
//{
//  return [[self session] isRunning] && [self isDeviceAuthorized];
//}

//+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
//{
//  return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
//}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
  CGPoint devicePoint = CGPointMake(.5, .5);
  [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
  dispatch_async([self sessionQueue], ^{
    AVCaptureDevice *device = [[self videoDeviceInput] device];
    NSError *error = nil;
    if ([device lockForConfiguration:&error])
    {
      if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
      {
        [device setFocusMode:focusMode];
        [device setFocusPointOfInterest:point];
      }
      if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
      {
        [device setExposureMode:exposureMode];
        [device setExposurePointOfInterest:point];
      }
      [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
      [device unlockForConfiguration];
    }
    else
    {
      NSLog(@"%@", error);
    }
  });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
  if ([device hasFlash] && [device isFlashModeSupported:flashMode])
  {
    NSError *error = nil;
    if ([device lockForConfiguration:&error])
    {
      [device setFlashMode:flashMode];
      [device unlockForConfiguration];
    }
    else
    {
      NSLog(@"%@", error);
    }
  }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
  AVCaptureDevice *captureDevice = [devices firstObject];
  
  for (AVCaptureDevice *device in devices)
  {
    if ([device position] == position)
    {
      captureDevice = device;
      break;
    }
  }
  
  return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[[self previewView] layer] setOpacity:0.0];
    [UIView animateWithDuration:.25 animations:^{
      [[[self previewView] layer] setOpacity:1.0];
    }];
  });
}

- (void)checkDeviceAuthorizationStatus
{
  NSString *mediaType = AVMediaTypeVideo;
  
  [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
    if (granted)
    {
      //Granted access to mediaType
      [self setDeviceAuthorized:YES];
    }
    else
    {
      //Not granted access to mediaType
      dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                    message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        [self setDeviceAuthorized:NO];
      });
    }
  }];
}

- (IBAction)switchValueChanged:(id)sender {
  BOOL switchState = [(UISwitch *)sender isOn];
  self.autoModeActive = switchState;
  [UIView transitionWithView:self.switchLabel duration:0.4 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
    if (switchState) {
      [self.switchLabel setText:@"Auto"];
      [self.calculatedColorBtn setHidden:NO];
      [self.imageView setHidden:NO];
    } else {
      [self.switchLabel setText:@"Manual"];
      [self.calculatedColorBtn setHidden:YES];
      [self.imageView setHidden:YES];
    }
  } completion:nil];
}

-(BOOL)isAutoModeActivated
{
  return _autoModeActive;
}

#pragma mark - Video Capture

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
  if (![self isAutoModeActivated]) return; //return immediately

  //get frame image from current buffer
  UIImage *outputImg = [UIImage imageWithCMSampleBuffer:sampleBuffer];
  outputImg =
  [UIImage imageWithCGImage:[outputImg CGImage]
                      scale:1.0
                orientation: UIImageOrientationRight];
//  outputImg = [outputImg fixOrientation];
  
  UIGraphicsBeginImageContext(self.view.bounds.size);
  [outputImg drawInRect:self.view.bounds];
  outputImg = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  //get current frame rectangle where overlay image shown.
  CGRect cropRect = self.imageView.frame;
  // Crop a picture from given rectangle
  UIImage *tmp_img = [outputImg cropImageWithRect:cropRect];
  
  UIGraphicsBeginImageContext(CGSizeMake(44, 44));
  [tmp_img drawInRect:CGRectMake(0, 0, 44, 44)];
  UIImage *imageToBeShow = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // calculate average color for next steps
  self.color = [imageToBeShow averageColor];

  dispatch_async(dispatch_get_main_queue(), ^{
    
//    [self.calculatedColorBtn setImage:imageToBeShow forState:UIControlStateNormal];
    [self.calculatedColorBtn setImage:[UIImage imageWithColor:self.color andSize:CGSizeMake(44, 44)] forState:UIControlStateNormal];
    
  });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"resultsSegueFromCam"]) {
    CGFloat grayScaleValueOfColor = [self.color grayScaleColor];
    OKSonuclarViewController *vc = [segue destinationViewController];
    [vc initResultsWithGrayScaleValue:grayScaleValueOfColor forManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"SelectColorSegueFromCam"]) {
    OKSelectColorVC *vc = [segue destinationViewController];
    [vc setSelectedPicture:self.pickedImage];
    [vc setManagedObjectContext:self.managedObjectContext];
  }
}

@end
