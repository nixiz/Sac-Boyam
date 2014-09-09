//
//  OKTutorialViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 08/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKTutorialViewController.h"

@interface OKTutorialViewController ()
@property (weak, nonatomic) UIImage *mainImage;
@property (weak, nonatomic) NSString *text;

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
  self.view.backgroundColor = [UIColor clearColor];
  self.imageView.image = self.mainImage;
    // Do any additional setup after loading the view.
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
