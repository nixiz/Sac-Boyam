//
//  OKWelcomeViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 27/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKWelcomeViewController.h"

@interface OKWelcomeViewController ()
- (IBAction)skipButtonTapped:(id)sender;

@end

@implementation OKWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_6"];
  UIColor *backColor = [UIColor colorWithPatternImage:backgroundImage];
  self.view.backgroundColor = backColor;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)skipButtonTapped:(id)sender {
  if ([[self delegate] respondsToSelector:@selector(skipButtonTapped)]) {
    [self.delegate skipButtonTapped];
  }
}
@end
