//
//  OKTutorialBaseViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 27/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKTutorialBaseViewController.h"

@interface OKTutorialBaseViewController ()

@end

@implementation OKTutorialBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_6"];
  UIColor *backColor = [UIColor colorWithPatternImage:backgroundImage];
  self.view.backgroundColor = backColor;
  //  UIGraphicsBeginImageContext(self.view.bounds.size);
  //  [backgroundImage drawInRect:self.view.bounds];
  //  UIImage *backgroundcolor = UIGraphicsGetImageFromCurrentImageContext();
  //  UIGraphicsEndImageContext();
  //  backgroundImage = [backgroundImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.4 alpha:0.6] saturationDeltaFactor:1.3 maskImage:nil];
  //  backgroundImage = [backgroundImage applyDarkEffect];
    // Do any additional setup after loading the view.
}
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
