//
//  OKInfoViewController.m
//  Saç Boyam
//
//  Created by Oguzhan Katli on 24/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKInfoViewController.h"
#import "OKInfoChildViewController.h"

@interface OKInfoViewController () <OKInfoChildViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageController;

@end

@implementation OKInfoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                      options:nil];
  self.pageController.dataSource = self;
  [self.pageController.view setFrame:self.view.bounds];
  
  if (!self.pageIndex) {
    self.pageIndex = 0;
  }
  OKInfoChildViewController *child = [self viewControllerAtIndex:self.pageIndex];
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

- (OKInfoChildViewController *)viewControllerAtIndex:(NSUInteger)index {
  
  OKInfoChildViewController *childViewController = [[OKInfoChildViewController alloc] initWithNibName:@"OKInfoChildViewController" bundle:nil];
  childViewController.text = [NSString stringWithFormat:@"Screen %lu", (unsigned long)index];
  childViewController.pageIndex = index;
  childViewController.image = self.screenShot;
  childViewController.delegate = self;
  
  return childViewController;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSInteger index = [(OKInfoChildViewController *)viewController pageIndex];
  if (index == 0) {
    return nil;
  }
  return [self viewControllerAtIndex:--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSInteger index = [(OKInfoChildViewController *)viewController pageIndex];
  index += 1;
  if (index == 5) {
    return nil;
  }
  return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
  return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
  return self.pageIndex;
}

#pragma mark - OKInfoChildViewControllerDelegate

- (void)skipButtonTapped
{
  self.pageIndex = 4;
  OKInfoChildViewController *child = [self viewControllerAtIndex:self.pageIndex];
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
