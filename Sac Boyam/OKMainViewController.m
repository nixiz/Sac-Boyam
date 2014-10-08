//
//  OKMainViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKMainViewController.h"
#import "OKUtils.h"
#import "UIImage+ImageEffects.h"
#import "OKAppDelegate.h"
#import "UIView+CreateImage.h"
#import "OKTryOnMeVC.h"

@interface OKMainViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *averageColorImageView;
@property (weak, nonatomic) IBOutlet UILabel *productDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
- (IBAction)lookForInternet:(id)sender;
- (IBAction)addRemoveFav:(id)sender;
@end

@implementation OKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [self.view getBackgroundColor];
  
  if (self.colorModel) {
    self.productImageView.image = [UIImage imageWithData:self.colorModel.productImage];
    
    [self.productDetailsLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
    self.productDetailsLabel.numberOfLines = 0;
    self.productDetailsLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %@", NSLocalizedStringFromTable(@"brand", okStringsTableName, nil), self.colorModel.brand.brandName, NSLocalizedStringFromTable(@"product", okStringsTableName, nil), self.colorModel.productName];
  }
  
  if (self.lookingFromFavList == NO) {
    UIBarButtonItem *savebtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"saveButtonName", okStringsTableName, nil) style:UIBarButtonItemStylePlain target:self action:@selector(addRemoveFav:)];
    
    BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
    if (!takeRecord) {
      [savebtn setEnabled:NO];
//      [savebtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = savebtn;
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lookForInternet:(id)sender {
  
//  UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning"
//                                                    message:@"Uygulamadan cikilacak! "
//                                                   delegate:self
//                                          cancelButtonTitle:@"Hayir"
//                                          otherButtonTitles:@"Tamam", nil];
//  [message show];
  
  
  
  NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"https://www.google.com/search?q="];
  [searchText appendString:[self.colorModel.productName stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
  
  NSString *urlStr = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:urlStr];
  BOOL success = [[UIApplication sharedApplication] openURL:url];
  
  if (!success) {
    NSLog(@"Failed to open url: %@", [url description]);
  }
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//  if ([title isEqualToString:@"Hayir"]) {
//    return;
//  }
//  NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"https://www.google.com/search?q="];
//  [searchText appendString:[self.stringToBeSearceh stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
//  
//  NSString *urlStr = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//  NSURL *url = [NSURL URLWithString:urlStr];
//  BOOL success = [[UIApplication sharedApplication] openURL:url];
//  
//  if (!success) {
//    NSLog(@"Failed to open url: %@", [url description]);
//  }
//}

- (IBAction)addRemoveFav:(id)sender {
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (takeRecord) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"takeRecordPromt", okStringsTableName, nil)
                                                      delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                              otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setPlaceholder:NSLocalizedStringFromTable(@"enterNameForProduct", okStringsTableName, nil)];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [textField setAutocorrectionType:UITextAutocorrectionTypeDefault];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    NSString *brandName = [NSString stringWithFormat:@"%@ ", self.colorModel.brand.brandName];
    [textField setText:brandName];
    [alertView show];
  }
}

- (void)dismissAlertView:(UIAlertView *)alertView
{
  if ([alertView isVisible]) {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
  }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)]) {
    return;
  }
  NSString *recordName = [[alertView textFieldAtIndex:0] text];
  //if record name is null or empty
  if ([recordName length] == 0) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"error", okStringsTableName, nil)
                                                        message:NSLocalizedStringFromTable(@"recordNotSaved", okStringsTableName, nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                              otherButtonTitles: nil];
    [alertView show];
    return;
  }
  UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date]
                                                      recordName:recordName
                                                  usedColorModel:self.colorModel
                                          inManagedObjectContext:self.managedObjectContext];
//  UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date] usedColorModel:self.colorModel inManagedObjectContext:self.managedObjectContext];
  if (record) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"savedSuccessfuly", okStringsTableName, nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles: nil];
    [alertView show];
    [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:0.6];

    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedStringFromTable(@"saved", okStringsTableName, nil)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
//    [self.favButton setTitle:NSLocalizedStringFromTable(@"saved", okStringsTableName, nil) forState:UIControlStateNormal];
//    [self.favButton setEnabled:NO];
//    [self.favButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
  }
}
//tryOnMeSegue

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"tryOnMeSegue"]) {
    OKTryOnMeVC *vc = [segue destinationViewController];
    [vc setColorModel:self.colorModel];
  }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.

}

@end
