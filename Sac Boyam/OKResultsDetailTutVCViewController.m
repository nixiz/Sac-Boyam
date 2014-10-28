//
//  OKResultsDetailTutVCViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 28/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKResultsDetailTutVCViewController.h"

@interface OKResultsDetailTutVCViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
- (IBAction)doneButtonTapped:(id)sender;
@property (strong, nonatomic) NSArray *viewCollection;
@end

@implementation OKResultsDetailTutVCViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.viewCollection = @[self.imageView1, self.label1, self.label2];
  [self.viewCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [(UIView *)obj setHidden:YES];
  }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!animated) {
    [self.viewCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [(UIView *)obj setHidden:NO];
    }];
    return;
  }
//  [self.viewCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//    UIView *v = (UIView *)obj;
//    [UIView transitionWithView:v
//                      duration:0.8
//                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionTransitionFlipFromLeft
//                    animations:^{
//                      [v setHidden:NO];
//                    } completion:nil];
//    
//    
//  }];
  [UIView transitionWithView:self.imageView1
                    duration:0.2
                     options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionTransitionFlipFromLeft
                  animations:^{
                    [self.imageView1 setHidden:NO];
                  } completion:^(BOOL finished) {
                    [UIView transitionWithView:self.label1
                                      duration:0.4
                                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionTransitionFlipFromLeft
                                    animations:^{
                                      [self.label1 setHidden:NO];
                                    }
                                    completion:^(BOOL finished) {
                                      [UIView transitionWithView:self.label2
                                                        duration:0.6
                                                         options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionTransitionFlipFromLeft
                                                      animations:^{
                                                        [self.label2 setHidden:NO];
                                                      } completion:nil];
                                    }];
                  }];
  
  
  
}

-(void)viewDidDisappear:(BOOL)animated
{
  [self.viewCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [(UIView *)obj setHidden:YES];
  }];
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
