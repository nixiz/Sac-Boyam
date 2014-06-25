//
//  OKMainViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKMainViewController.h"
#import "OKViewController.h"

@interface OKMainViewController ()
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
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnStartClicked:(id)sender {
}


-(IBAction)returned:(UIStoryboardSegue *)segue {
  
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  //if ([segue.identifier isEqualToString:@"SecondScreenSegue"])
  //{
  //  OKViewController *seguewController = [segue destinationViewController];
  //  //[seguewController.selectedImage setImage:self.selectedImage];
  //}
}
*/
@end
