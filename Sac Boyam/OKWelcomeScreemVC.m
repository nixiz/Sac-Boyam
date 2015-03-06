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

@interface OKWelcomeScreemVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, OKSettingsDelegate, UIAlertViewDelegate>
- (IBAction)selectPicFromLibrary:(id)sender;
@property (nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *filesDictionary;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation OKWelcomeScreemVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
  self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:0.80];
  UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_navBar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(settingsButtonTap:)];
  self.navigationItem.rightBarButtonItem = settingsBtn;
  
  self.imagePickerController = [UIImagePickerController new];
  self.imagePickerController.delegate = self;
  [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  [self.imagePickerController.navigationBar setTintColor:[[UIColor blackColor] colorWithAlphaComponent:.8]];
  [self.imagePickerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
  
  if (!self.managedObjectContext) [self initManagedDocument];
  
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    [self showTutorialWithWelcomeScreen:YES];
  }
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

- (void)showTutorialWithWelcomeScreen:(BOOL)showWelcomeScreen
{
//  OKInfoViewController *vc = [[OKInfoViewController alloc] initWithNibName:@"OKInfoViewController" bundle:nil];
//  [vc setPageIndex:OKWelcomeScreenPage];
//  [self presentViewController:vc animated:NO completion:nil];
  
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:showTutorialKey] boolValue]) {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:showTutorialKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

#pragma mark - Image Pick

- (IBAction)selectPicFromLibrary:(id)sender {
//  [self.imagePickerController isBeingPresented]
  [self.imagePickerController setAllowsEditing:[[[NSUserDefaults standardUserDefaults] objectForKey:editPhotosKey] boolValue]];

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
  [picker dismissViewControllerAnimated:NO completion:^{
    [self.view setUserInteractionEnabled:YES];
    [self performSegueWithIdentifier:@"SelectColorSegue" sender:nil];
  }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:^{
    [self.view setUserInteractionEnabled:YES];
  }];
}

#pragma mark - Navigation

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
  }
}

#pragma mark - OKSettingsDelegate

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
