//
//  OKTryOnMeTutVC.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 28/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKTryOnMeTutVC.h"
#import "OKAppDelegate.h"

@interface OKTryOnMeTutVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UILabel *label1;
- (IBAction)doneButtonTapped:(id)sender;
@end

@implementation OKTryOnMeTutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(timerExpired:) userInfo:nil repeats:YES];
}

- (void)timerExpired:(NSTimer *)timer
{
  static int count = 1;
  //
  __block NSString *imageName = [NSString stringWithFormat:@"tryonme-%@%d.png", NSLocalizedStringFromTable(@"lang", okStringsTableName, nil), count++ % 4 + 1];
  [UIView transitionWithView:self.imageView1
                    duration:0.2
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:^{
                    [self.imageView1 setImage:[UIImage imageNamed:imageName]];
                  } completion:nil];

  if (count >= 4 * 2) {
    [timer invalidate];
    count = 1;
  }
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
