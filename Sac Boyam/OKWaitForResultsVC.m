//
//  OKWaitForResultsVC.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 14/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKWaitForResultsVC.h"

static NSString * const okStringsTableName = @"localized";

@interface OKWaitForResultsVC ()
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong) UIActivityIndicatorView *activityView;
@end

@implementation OKWaitForResultsVC

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
  UIImageView *backView = [[UIImageView alloc] initWithFrame:self.view.frame];
  backView.image = self.backgroundImage;
  backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
  [self.view addSubview:backView];
  
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [btn setTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil) forState:UIControlStateNormal];
  btn.frame = CGRectMake(0, 0, 80.0f, 40.0f);
  CGPoint centerPointForButton = self.view.center;
  centerPointForButton.y -= 40.0f;
  centerPointForButton.x += 20.0f;
  btn.center = centerPointForButton;
//  [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view addSubview:btn];
  
  self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  CGPoint centerPoint = self.view.center;
  centerPoint.y -= 40.0f;
  centerPoint.x -= 20.0f;
  self.activityView.center = centerPoint;
//  [self.activityView setHidesWhenStopped:YES];
//  [self.activityView startAnimating];
//  [self.activityView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view addSubview:self.activityView];
  
  UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 16.0f)];
  lbl.center = self.view.center;
  [lbl setText:NSLocalizedStringFromTable(@"pleaseWaitFor", okStringsTableName, nil)];
  [lbl setTextColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:246.0/255.0 alpha:1.0]];
  [lbl setTextAlignment:NSTextAlignmentCenter];
  [lbl setFont:[UIFont systemFontOfSize:16]];
//  [lbl setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view addSubview:lbl];
  
//  CGRect recc = CGRectInset(self.view.frame, -150, 150);
//  self.view.frame = recc;

  
//  NSDictionary *viewsDict = NSDictionaryOfVariableBindings(btn, _activityView);
//  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_activityView]-(12)-[btn]"
//                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                    metrics:nil
//                                                                      views:viewsDict]];

//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityView
//                                                        attribute:NSLayoutAttributeTrailing
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:btn
//                                                        attribute:NSLayoutAttributeLeading
//                                                       multiplier:1.0 constant:8.0]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
//                                                        attribute:NSLayoutAttributeCenterX
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view.superview
//                                                        attribute:NSLayoutAttributeCenterX
//                                                       multiplier:1.0f constant:0.0f]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
//                                                        attribute:NSLayoutAttributeCenterY
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view.superview
//                                                        attribute:NSLayoutAttributeCenterY
//                                                       multiplier:1.0f constant:0.0f]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn
//                                                        attribute:NSLayoutAttributeBottom
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:lbl
//                                                        attribute:NSLayoutAttributeTop
//                                                       multiplier:1.0f constant:8.0f]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lbl
//                                                        attribute:NSLayoutAttributeTrailing
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view.superview
//                                                        attribute:NSLayoutAttributeLeading
//                                                       multiplier:1.0f constant:20.0f]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lbl
//                                                        attribute:NSLayoutAttributeLeading
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view.superview
//                                                        attribute:NSLayoutAttributeTrailing
//                                                       multiplier:1.0f constant:20.0f]];
  
  
      // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.activityView startAnimating];
  [self.activityView setHidesWhenStopped:YES];
}

-(void)closeModalViewAnimated:(BOOL) animated
{
  [self.activityView stopAnimating];
//  [self dismissViewControllerAnimated:animated completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelButtonPressed:(UIButton *)sender
{
  [self.activityView stopAnimating];
  if ([self.delegate respondsToSelector:@selector(userCancelledRequest)])
    [self.delegate userCancelledRequest];
}

-(void)initWithBackgroundImage:(UIImage *)image
{
  self.backgroundImage = image;
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

@end
