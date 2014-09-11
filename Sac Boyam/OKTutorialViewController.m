//
//  OKTutorialViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKTutorialViewController.h"
#import "OKUtils.h"
#import "OKAppDelegate.h"

@interface OKTutorialViewController ()
@property (weak, nonatomic) UIImage *mainImage;
@property (weak, nonatomic) NSString *text;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

- (IBAction)onSkipButtonTap:(id)sender;

@end

@implementation OKTutorialViewController

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
  static NSString *veryLongString = @"Merhaba!\nIzin verirsen programin nasil calistigini sana gostermek istiyorum. Yukarida \"Camera\" isareti olan yerden resim secerek baslayabilirsin.";
  self.view.backgroundColor = [UIColor clearColor];
  self.imageView.image = self.mainImage;
  [self.skipButton setTitle:NSLocalizedStringFromTable(@"skipButtonName", okStringsTableName, nil) forState:UIControlStateNormal];
  
//  NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    // Do any additional setup after loading the view.
  UILabel *lbl = [[UILabel alloc] init];
//  CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, 50);
  NSDictionary *att = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0]};
  CGRect textRect = [veryLongString boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 120.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:att context:nil];
  [lbl setFrame:textRect];
  lbl.center = self.view.center;
  [lbl setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
  [lbl setLineBreakMode:NSLineBreakByWordWrapping];
  [lbl setText:veryLongString];
  [lbl setNumberOfLines:0];
  [self.view addSubview:lbl];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initWithMainImage:(UIImage *)image andText:(NSString *)text
{
  self.mainImage = image;
  self.text = text;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSkipButtonTap:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end
