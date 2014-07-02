//
//  OKMainViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKMainViewController.h"
#import "OKViewController.h"
#import "OKUtils.h"

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
  [self.view.layer insertSublayer:[OKUtils getBackgroundLayer:self.view.bounds] atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
//  [self.navigationController setNavigationBarHidden:YES animated:YES];
  [super viewDidAppear:animated];
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//  for (UIView *view in self.view.subviews) {
//    if (view.tag == 132) {
//      [view removeFromSuperview];
//    }
//  }
//  [super viewDidDisappear:animated];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//  [self.navigationController setNavigationBarHidden:NO animated:YES];
  //if ([segue.identifier isEqualToString:@"SecondScreenSegue"])
  //{
  //  OKViewController *seguewController = [segue destinationViewController];
  //  //[seguewController.selectedImage setImage:self.selectedImage];
  //}
}

@end
