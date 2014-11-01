//
//  OKInfoViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKInfoViewController.h"
#import "OKTutorialBaseViewController.h"
#import "OKInfoChildViewController.h"
#import "OKWelcomeViewController.h"
#import "OKSelectColorTutorialVC.h"
#import "OKResultsDetailTutVCViewController.h"
#import "OKSettingsTutVC.h"
#import "OKTryOnMeTutVC.h"


@interface OKInfoViewController () <OKInfoChildViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageController;
@property NSInteger presentationCount;
@end

@implementation OKInfoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                      options:nil];
  self.pageController.dataSource = self;
  [self.pageController.view setFrame:self.view.bounds];
  self.pageController.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.65];
  if (!self.pageIndex) {
    self.pageIndex = 0; //set page index to welcome presentation
  }
  
  //eger program ilk acildiysa welcome ekrani icin bir fazla presentasyon goster!
  self.presentationCount = 5;
//  if (self.pageIndex == OKWelcomeScreenPage) {
//    self.presentationCount = 6;
//  }
  OKTutorialBaseViewController *child = [self viewControllerAtIndex:self.pageIndex];
  NSArray *childViewControllers = @[child];
  
  [self.pageController setViewControllers:childViewControllers
                                direction:UIPageViewControllerNavigationDirectionForward
                                 animated:NO completion:nil];
  [self addChildViewController:self.pageController];
  [self.view addSubview:self.pageController.view];
  [self.pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (OKTutorialBaseViewController *)viewControllerAtIndex:(NSUInteger)index {
  OKTutorialBaseViewController *childViewController = nil;
  switch (index) {
    case OKWelcomeScreenPage:
      childViewController = [[OKWelcomeViewController alloc] initWithNibName:@"OKWelcomeViewController" bundle:nil];
      break;
    case OKSelectColorPage:
      childViewController = [[OKSelectColorTutorialVC alloc] initWithNibName:@"OKSelectColorTutorialVC" bundle:nil];
      break;
    case OKResultDetailPage:
      childViewController = [[OKResultsDetailTutVCViewController alloc] initWithNibName:@"OKResultsDetailTutVCViewController" bundle:nil];
      break;
    case OKSettingsPage:
      childViewController = [[OKSettingsTutVC alloc] initWithNibName:@"OKSettingsTutVC" bundle:nil];
      break;
    case OKTryOnMePage:
      childViewController = [[OKTryOnMeTutVC alloc] initWithNibName:@"OKTryOnMeTutVC" bundle:nil];
      break;
    default:
      childViewController = [[OKInfoChildViewController alloc] initWithNibName:@"OKInfoChildViewController" bundle:nil];
      break;
  }
  childViewController.pageIndex = index;
  childViewController.delegate = self;
  
  return childViewController;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSInteger index = [(OKTutorialBaseViewController *)viewController pageIndex];
  if (index == 0) {
    return nil;
  }
  return [self viewControllerAtIndex:--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSInteger index = [(OKTutorialBaseViewController *)viewController pageIndex];
  index += 1;
  if (index == self.presentationCount) {
    return nil;
  }
  return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
  return self.presentationCount;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
//  if (self.presentationCount == 5) {
//    return self.pageIndex - 1;
//  }
  return self.pageIndex;
}

#pragma mark - OKInfoChildViewControllerDelegate

- (void)skipButtonTapped
{
  self.pageIndex = self.presentationCount - 1;
  OKTutorialBaseViewController *child = [self viewControllerAtIndex:self.pageIndex];
  NSArray *childViewControllers = @[child];
  
  [self.pageController setViewControllers:childViewControllers
                                direction:UIPageViewControllerNavigationDirectionForward
                                 animated:YES completion:nil];
//  NSAssert(NO, @"Not Implemented!");
}

- (void)closeButtonTapped
{
  [self dismissViewControllerAnimated:YES completion:nil];
  //  NSAssert(NO, @"Not Implemented!");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
