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
    self.productDetailsLabel.text = [NSString stringWithFormat:@"Brand: %@\nProduct: %@", self.colorModel.brand.brandName, self.colorModel.productName];
  }
  
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (!takeRecord) {
    [self.favButton setEnabled:NO];
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

}

- (IBAction)addRemoveFav:(id)sender {
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (takeRecord) {
    UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date] usedColorModel:self.colorModel inManagedObjectContext:self.managedObjectContext];
    if (record) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Basari ile kaydedildi" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
      [alertView show];
    }
  }
  

}
@end
