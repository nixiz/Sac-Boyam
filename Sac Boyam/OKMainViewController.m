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

@interface OKMainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *averageColorImageView;
@property (weak, nonatomic) IBOutlet UILabel *productDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *tryBtn;
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
  if (self.lookingFromFavList == NO)
  {
    UIBarButtonItem *savebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRemoveFav:)];
    
    BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
    if (!takeRecord) {
      [savebtn setEnabled:NO];
    }
    self.navigationItem.rightBarButtonItem = savebtn;
    [self.tryBtn setHidden:YES];
  }
  else
  {
    [self.tryBtn setHidden:NO];
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

- (IBAction)lookForInternet:(id)sender
{
  NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"https://www.google.com/search?q="];
  [searchText appendString:[self.colorModel.productName stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
  
  NSString *urlStr = [searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
  NSURL *url = [NSURL URLWithString:urlStr];
  BOOL success = [[UIApplication sharedApplication] openURL:url];
  
  if (!success) {
    NSLog(@"Failed to open url: %@", [url description]);
  }
}

- (IBAction)addRemoveFav:(id)sender {
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (takeRecord) {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:NSLocalizedStringFromTable(@"takeRecordPromt", okStringsTableName, nil)
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UITextField *textField = [[ac textFields] objectAtIndex:0];
    [textField setPlaceholder:NSLocalizedStringFromTable(@"enterNameForProduct", okStringsTableName, nil)];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [textField setAutocorrectionType:UITextAutocorrectionTypeDefault];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    NSString *brandName = [NSString stringWithFormat:@"%@ ", self.colorModel.brand.brandName];
    [textField setText:brandName];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                                       style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                       }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                                         NSString *recordName = [[ac textFieldAtIndex:0] text];
                                                         NSString *recordName = brandName;
                                                         //if record name is null or empty
                                                         if ([recordName length] == 0) {
                                                           UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"error", okStringsTableName, nil)
                                                                                                                       message:NSLocalizedStringFromTable(@"recordNotSaved", okStringsTableName, nil)
                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                           UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                                                                                  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                  }];
                                                           [ac addAction:cancelAction];
                                                           
                                                           [self presentViewController:ac animated:YES completion:nil];
                                                           return;
                                                         }
                                                         UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date]
                                                                                                             recordName:recordName
                                                                                                         usedColorModel:self.colorModel
                                                                                                 inManagedObjectContext:self.managedObjectContext];
                                                         //  UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date] usedColorModel:self.colorModel inManagedObjectContext:self.managedObjectContext];
                                                         if (record) {
                                                           UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                                                                       message:NSLocalizedStringFromTable(@"savedSuccessfuly", okStringsTableName, nil)
                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                           
                                                           [self presentViewController:ac animated:YES completion:nil];
                                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(600 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                                                             [ac dismissViewControllerAnimated:YES completion:nil];
                                                           });

                                                           [self.navigationItem.rightBarButtonItem setEnabled:NO];
                                                         }
                                                       }];
    [ac addAction:okAction];
    [ac addAction:cancelAction];
    
    [self presentViewController:ac animated:YES completion:nil];
    
  }
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"tryOnMeSegue"]) {
    OKTryOnMeVC *vc = [segue destinationViewController];
    [vc setColorModel:self.colorModel];
  }
}

@end
