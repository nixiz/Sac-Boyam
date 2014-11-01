//
//  OKSettingsTutVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 28/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKSettingsTutVC.h"

@interface OKSettingsTutVC ()
@property (weak, nonatomic) IBOutlet UISwitch *viewObj1;
@property (weak, nonatomic) IBOutlet UISwitch *viewObj2;
@property (weak, nonatomic) IBOutlet UISwitch *viewObj3;
@property (weak, nonatomic) IBOutlet UISlider *sliderObj4;
- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation OKSettingsTutVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.viewObj1 setOn:NO animated:NO];
  [self.viewObj2 setOn:NO animated:NO];
  [self.viewObj3 setOn:NO animated:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
//  if (!animated) {
//    return;
//  }
  [self.viewObj2 setOn:YES animated:YES];
  [self.viewObj3 setOn:YES animated:YES];
  [self.sliderObj4 setValue:self.sliderObj4.maximumValue * 0.7 animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self.viewObj1 setOn:NO animated:NO];
  [self.viewObj2 setOn:NO animated:NO];
  [self.viewObj3 setOn:NO animated:NO];
  [self.sliderObj4 setValue:self.sliderObj4.minimumValue animated:NO];
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
