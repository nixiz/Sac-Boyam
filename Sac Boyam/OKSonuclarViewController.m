//
//  OKSonuclarViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/21/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKAppDelegate.h"
#import "OKSonuclarViewController.h"
#import "OKSonuclarCell.h"
#import "OKProductJsonType.h"
#import "ColorModel+Create.h"
#import "BrandModel+Create.h"
#import "OKUtils.h"
#import "OKMainViewController.h"
#import "OKSettingsViewController.h"
#import "UIView+CreateImage.h"
#import "UIImage+ImageEffects.h"
#import "OKTryOnMeVC.h"
#import "OKSettingsTutorialVC.h"
#import "OKAppRater.h"

#define ARC4RANDOM_MAX	0x100000000
#define indexForProductName   0
//#define indexForProductDetail 1
#define indexForProductPrice  1
#define MinMaxScale 0.07 //%15
//#define grayScaleScanThreshold (1.0/255.0)*100.0*MinMaxScale
#define grayScaleScanThreshold(x) ((x)/255.0)*100.0*([[[NSUserDefaults standardUserDefaults] objectForKey:resultDensityKey] floatValue]/100.0)

@interface OKSonuclarViewController () <UIAlertViewDelegate>
@property UIColor *mColor;
@property (nonatomic, strong) NSMutableDictionary *resultsList;
@property (nonatomic, strong) NSDictionary *resultsIndex;
//- (IBAction)handleLongPress:(id)sender;
@property (nonatomic, strong) NSString *stringToBeSearceh;
@property CGFloat grayScale;

@property (strong, nonatomic) NSDictionary *framesDictionary;
@property (strong, nonatomic) NSDictionary *explanationsDictionary;

@end

@implementation OKSonuclarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)refreshFetcedResultController:(NSManagedObjectContext *)context
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ColorModel"];
/* 
 //core data fetching'de bu islem calismiyor. 
 //Bunun calisabilmesi icin fetch edilen objelerin once memoriye alinmasi sonradan karsilastirilmasi gerekiyor
  __block float grayScaleOfGivenValue = self.grayScale;
  NSSortDescriptor *customSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"grayScale" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
    NSAssert([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]], @"Objects Must Be Float!");
    float distToDefaultValueForObj1 = fabsf([obj1 floatValue] - grayScaleOfGivenValue);
    float distToDefaultValueForObj2 = fabsf([obj2 floatValue] - grayScaleOfGivenValue);
    if (distToDefaultValueForObj1 < distToDefaultValueForObj2) {
      return NSOrderedAscending;
    } else if (distToDefaultValueForObj1 > distToDefaultValueForObj2) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
*/
/*
 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrandModel"];
 request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brandName"
 ascending:YES
 selector:@selector(localizedCaseInsensitiveCompare:)]];
 request.predicate = [NSPredicate predicateWithFormat:@"brandName = %@", brandName];
 
 NSError *error;
 NSArray *matches = [context executeFetchRequest:request error:&error];
*/
  
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brand.brandName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"grayScale" ascending:YES]];
//  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brand.brandName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], customSortDesc];
  
  NSLog(@"given scale density %@", [[NSUserDefaults standardUserDefaults] objectForKey:resultDensityKey]);
  CGFloat minval = fabsf(self.grayScale - grayScaleScanThreshold(self.grayScale));
  CGFloat maxval = self.grayScale + grayScaleScanThreshold(self.grayScale);
  request.predicate = [NSPredicate predicateWithFormat: @"grayScale >= %@ AND grayScale <= %@", @(minval), @(maxval)];
  //between burada calismiyor. internette de bunun gibi sorunlar var. o yuzden and kullanarak yaptim.
  //    request.predicate = [NSPredicate predicateWithFormat: @"grayScale BETWEEN %@", @[@1, @10]];
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"brand.brandName" cacheName:nil];
  self.fetchedResultsController.delegate = self;
//  [self.fetchedResultsController performFetch:nil];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  _managedObjectContext = managedObjectContext;
  if (managedObjectContext) {
    [self refreshFetcedResultController:managedObjectContext];
  } else {
    self.fetchedResultsController = nil;
  }
}

-(void)initResultsWithGrayScaleValue:(CGFloat)grayScale forManagedObjectContext:(NSManagedObjectContext *)context
{
  self.grayScale = grayScale;
  self.managedObjectContext = context;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.navigationItem setTitle:NSLocalizedStringFromTable(@"resultsTitle", okStringsTableName, nil)];
  UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_navBar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(settingsFromResultsTap:)];
  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showTutorial)];
  self.navigationItem.rightBarButtonItems = @[settingsBtn, infoBtn];
  self.view.backgroundColor = [self.view getBackgroundColor];
  self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
  [[OKAppRater sharedInstance] increaseTimeOfUse];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [[OKAppRater sharedInstance] showRateThisApp];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)showAlertViewForNoResultsFound
{
  UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedStringFromTable(@"no-results-found-msg", okStringsTableName, nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil), nil];
  [message show];
}

- (void)showTutorial
{
  BOOL tableContainsResult = [[self.tableView visibleCells] count] > 0;
  if (!tableContainsResult) {
    [self showAlertViewForNoResultsFound];
    //TODO: show alert view and suggest to increase search threshold in settings page
    return;
  }
  [UIView animateWithDuration:0.4 animations:^{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
  } completion:^(BOOL finished) {
    if (!finished) {
      NSAssert(NO, @"Sen hayirdir!!");
    }
    OKSonuclarCell *cellView = (OKSonuclarCell *)[[self.tableView visibleCells] firstObject];
    //  NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cellView];
    
    CGRect cellViewFrame  = [cellView frame];
    //  CGRect frameInView = [self.view convertRect:cellViewFrame toView:cellView];
    //  CGRect fromView = [self.view convertRect:cellViewFrame fromView:cellView];
    CGRect toView = [cellView convertRect:[self.view convertRect:cellViewFrame toView:cellView] toView:nil];
    cellViewFrame = toView;
    
    CGRect cellImageViewFrame = [cellView.productImg frame];
    cellImageViewFrame = [cellView.productImg convertRect:cellImageViewFrame toView:nil];
    //  cellImageViewFrame = [self.view convertRect:cellImageViewFrame fromView:cellView];
    //  cellImageViewFrame = [self.view convertRect:cellImageViewFrame toView:nil];
    
    CGRect cellTextViewFrame  = [[cellView productName] frame];
    cellTextViewFrame = [cellView.productName convertRect:cellTextViewFrame toView:nil];
    //  cellTextViewFrame = [self.view convertRect:cellTextViewFrame fromView:cellView];
    //  cellTextViewFrame = [self.view convertRect:cellTextViewFrame toView:nil];
    
    CGRect sectionFrame = CGRectMake(cellViewFrame.origin.x, cellViewFrame.origin.y - 70.0, cellViewFrame.size.width, 70.0);
    
    self.framesDictionary = @{@"item-1": [NSValue valueWithCGRect:sectionFrame],
                              @"item-2": [NSValue valueWithCGRect:cellViewFrame],
                              @"item-3": [NSValue valueWithCGRect:cellImageViewFrame],
                              @"item-4": [NSValue valueWithCGRect:cellTextViewFrame]};
    
    self.explanationsDictionary = @{@"item-1": @"results-item-1-exp",
                                    @"item-2": @"results-item-2-exp",
                                    @"item-3": @"results-item-3-exp",
                                    @"item-4": @"results-item-4-exp"};
    
    [self performSegueWithIdentifier:@"ResultsTutorialSegue" sender:nil];
  }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  CGRect headerViewRect = CGRectMake(0, 0, self.view.bounds.size.width, 70);
  UIView *headerView = [[UIView alloc] initWithFrame:headerViewRect];
  headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
  //TODO: Get product Logo from productName value.
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];

  UIImageView *productLogo = [[UIImageView alloc] initWithImage:
                              [UIImage imageWithData:color.brand.brandImage]];
  productLogo.frame = CGRectMake(0, 0, 70, 70);
  productLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
  [headerView addSubview:productLogo];
    
  UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 70, 70)];
  [productName setFont:[UIFont boldSystemFontOfSize:15.0]];
  productName.text = color.brand.brandName;
  productName.backgroundColor = [UIColor clearColor];
  [headerView addSubview:productName];
    
  return headerView;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"resultDetailSegue" sender:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"SonuclarCell";
  OKSonuclarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  if (cell == nil)
  {
    cell = [[OKSonuclarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [cell setTintColor:[UIColor blackColor]];
  cell.productName.text = color.productName;
//  cell.priceLabel.text = @"";
  [cell.productImg setImage:[UIImage imageWithData:color.productImage]];
  return cell;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:@"Hayir"]) {
    return;
  }
  
  [self settingsFromResultsTap:nil];
}

-(IBAction)unwindToResults:(UIStoryboardSegue *)segue
{
  UIViewController *vc = segue.sourceViewController;
  
  if ([vc isKindOfClass:[OKSettingsViewController class]]) {
    [self refreshFetcedResultController:self.managedObjectContext];
  }
}

-(void)settingsFromResultsTap:(id)sender
{
  [self performSegueWithIdentifier:@"settingSegueFromResults" sender:sender];
}

- (void)updateNumberOfViewResult
{
  NSInteger timesOfResultView = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView forKey:timesOfNotRatedUsesKey];
  BOOL isSynced = [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"number of uses are synced %@", isSynced ? @"successfuly":@"unsuccessfuly");
}

#pragma mark - OKTutorialControllerDelegate

- (CGRect)getImageMaskRectForItem:(NSString *)item
{
  return CGRectZero;
}

- (CGRect)getFrameForItem:(NSString *)item
{
  return CGRectZero;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"resultDetailSegue"]) {
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OKMainViewController *vc = [segue destinationViewController];
    [vc setColorModel:color];
    [vc setManagedObjectContext:self.managedObjectContext];
    vc.lookingFromFavList = NO;
    [[OKAppRater sharedInstance] increaseTimeOfUse];
  } else if ([[segue identifier] isEqualToString:@"settingSegueFromResults"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setManagedObjectContext:self.managedObjectContext];
  } else if ([[segue identifier] isEqualToString:@"tryOnMeSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OKTryOnMeVC *vc = [segue destinationViewController];
    [vc setColorModel:color];
    [vc setManagedObjectContext:self.managedObjectContext];
    [[OKAppRater sharedInstance] decreaseTimeOfUse];
  } else if ([[segue identifier] isEqualToString:@"ResultsTutorialSegue"]) {
    UIImage *screenShot = [self.tableView.superview createImageFromViewAfterScreenUpdates:NO];
    OKSettingsTutorialVC *vc = [segue destinationViewController];
    [vc initiateTutorialControllerWithBgImg:screenShot andContentPoints:self.framesDictionary WithExplanationDescriptors:self.explanationsDictionary];
    [vc setShowExplanationBelowView:YES];
    [vc setHeightOfExplanationView:90];
  } else {
    NSLog(@"Unidentified segue raised with name %@", [segue identifier]);
  }
}

@end
