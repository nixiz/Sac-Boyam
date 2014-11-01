//
//  OKSelectColorTutorialVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 27/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKSelectColorTutorialVC.h"

@interface OKSelectColorTutorialVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;
@property (strong, nonatomic) NSArray *sequencedViews;
- (IBAction)doneButtonTapped:(id)sender;
@end

@implementation OKSelectColorTutorialVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageView1.layer.cornerRadius = 4.0;
  self.imageView1.layer.masksToBounds = YES;
  self.imageView2.layer.cornerRadius = 4.0;
  self.imageView2.layer.masksToBounds = YES;
  self.imageView3.layer.cornerRadius = 4.0;
  self.imageView3.layer.masksToBounds = YES;
  self.imageView4.layer.cornerRadius = 4.0;
  self.imageView4.layer.masksToBounds = YES;
  self.imageView5.layer.cornerRadius = 4.0;
  self.imageView5.layer.masksToBounds = YES;
  self.imageView6.layer.cornerRadius = 4.0;
  self.imageView6.layer.masksToBounds = YES;

  NSArray *sequence1Arr = @[self.imageView1, self.label1];
  NSArray *sequence2Arr = @[self.imageView2, self.label2];
  NSArray *sequence3Arr = @[self.imageView3, self.label3];
  NSArray *sequence4Arr = @[self.imageView4, self.label4];
  NSArray *sequence5Arr = @[self.imageView5, self.label5];
  NSArray *sequence6Arr = @[self.imageView6, self.label6];
  self.sequencedViews = @[sequence1Arr, sequence2Arr, sequence3Arr, sequence4Arr, sequence5Arr, sequence6Arr];
  [self.imageView1 setHidden:YES];
  [self.label1 setHidden:YES];
  [self.imageView2 setHidden:YES];
  [self.label2 setHidden:YES];
  [self.imageView3 setHidden:YES];
  [self.label3 setHidden:YES];
  [self.imageView4 setHidden:YES];
  [self.label4 setHidden:YES];
  [self.imageView5 setHidden:YES];
  [self.label5 setHidden:YES];
  [self.imageView6 setHidden:YES];
  [self.label6 setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!animated) {
    [self.imageView1 setHidden:NO];
    [self.label1 setHidden:NO];
    [self.imageView2 setHidden:NO];
    [self.label2 setHidden:NO];
    [self.imageView3 setHidden:NO];
    [self.label3 setHidden:NO];
    [self.imageView4 setHidden:NO];
    [self.label4 setHidden:NO];
    [self.imageView5 setHidden:NO];
    [self.label5 setHidden:NO];
    [self.imageView6 setHidden:NO];
    [self.label6 setHidden:NO];
    return;
  }
  for (NSArray *arr in self.sequencedViews) {
    //TODO: for performance issues dont do this animations for older iphones(4, 4s, gibi)
    __block BOOL firstItemIsImageView = [arr[0] isKindOfClass:[UIImageView class]];
    
    [UIView transitionWithView:firstItemIsImageView ? arr[0] : arr[1]
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                      [arr[0] setHidden:NO];
                    }
                    completion:^(BOOL finished) {
                      [UIView transitionWithView:firstItemIsImageView ? arr[1] : arr[0]
                                        duration:0.6
                                         options:UIViewAnimationOptionTransitionCrossDissolve
                                      animations:^{
                                        [arr[1] setHidden:NO];
                                      }
                                      completion:nil];
                      
                    }];
  }//for-in
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButtonTapped:(id)sender {
  if ([[self delegate] respondsToSelector:@selector(closeButtonTapped)]) {
    [self.delegate closeButtonTapped];
  }
}
@end
