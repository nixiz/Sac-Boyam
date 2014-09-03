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


@interface OKMainViewController ()
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
  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_4"];
  UIGraphicsBeginImageContext(self.view.bounds.size);
  [backgroundImage drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
  self.view.backgroundColor = [UIColor colorWithPatternImage:image];
  
  if (self.colorModel) {
    self.productImageView.image = [UIImage imageWithData:self.colorModel.productImage];
    
    
    [self.productDetailsLabel setFont:[UIFont systemFontOfSize:12]];
    self.productDetailsLabel.numberOfLines = 3;
    self.productDetailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.productDetailsLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %@", NSLocalizedStringFromTable(@"brand", okStringsTableName, nil), self.colorModel.brand.brandName, NSLocalizedStringFromTable(@"product", okStringsTableName, nil), self.colorModel.productName];
  }
  
  
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (!takeRecord) {
    [self.favButton setEnabled:NO];
    [self.favButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
  }
  if (self.lookingFromFavList) {
//    [self.favButton setTitle:@"Favorilerden Cikart" forState:UIControlStateNormal];
    [self.favButton setHidden:YES];
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
  NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"https://www.google.com/search?q="];
  [searchText appendString:[self.colorModel.productName stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
  
  NSString *urlStr = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:urlStr];
  BOOL success = [[UIApplication sharedApplication] openURL:url];
  
  if (!success) {
    NSLog(@"Failed to open url: %@", [url description]);
  }
}

- (IBAction)addRemoveFav:(id)sender {
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (takeRecord) {
    UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date] usedColorModel:self.colorModel inManagedObjectContext:self.managedObjectContext];
    if (record) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                          message:NSLocalizedStringFromTable(@"savedSuccessfuly", okStringsTableName, nil)
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                otherButtonTitles:nil];
      [alertView show];
      [self.favButton setTitle:NSLocalizedStringFromTable(@"saved", okStringsTableName, nil) forState:UIControlStateNormal];
      [self.favButton setEnabled:NO];
      [self.favButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
  }

}
@end
