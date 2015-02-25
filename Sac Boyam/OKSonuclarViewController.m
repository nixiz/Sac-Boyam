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
#import "OKInfoViewController.h"

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
//  UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"settings", okStringsTableName, nil)
//                                                           style:UIBarButtonItemStylePlain
//                                                          target:self action:@selector(settingsFromResultsTap:)];
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
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)showTutorial
{
//  UIImage * screenShot = [[self view] createImageFromView];
//  screenShot = [screenShot applyDarkEffect];
  OKInfoViewController *vc = [[OKInfoViewController alloc] initWithNibName:@"OKInfoViewController" bundle:nil];
//  vc.screenShot = screenShot;
  [vc setPageIndex:OKSelectColorPage];
//  vc.pageIndex = 1;
  //  [vc setModalPresentationStyle:UIModalPresentationFullScreen];
  //  [vc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
  [self presentViewController:vc animated:NO completion:nil];
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
  headerView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.65];
  //TODO: Get product Logo from productName value.
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];

  UIImageView *productLogo = [[UIImageView alloc] initWithImage:
                              [UIImage imageWithData:color.brand.brandImage]];
  productLogo.frame = CGRectMake(0, 0, 70, 70);
  productLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
  [headerView addSubview:productLogo];
    
  UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 70, 70)];
  productName.text = color.brand.brandName;
  productName.backgroundColor = [UIColor clearColor];
  [headerView addSubview:productName];
    
  return headerView;
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
//  UIImage *cellImage = [UIImage imageNamed:@"resultsTableCell"];
//  cell.backgroundColor = [UIColor colorWithPatternImage:cellImage];

  //  cell.productName.adjustsFontSizeToFitWidth = YES;
  cell.productName.lineBreakMode = NSLineBreakByWordWrapping;
  cell.productName.numberOfLines = 2;
  cell.productName.text = color.productName;
//  cell.priceLabel.text = [[color.price stringValue] stringByAppendingString:@" TL"];
  cell.priceLabel.text = @"";
  [cell.productImg setImage:[UIImage imageWithData:color.productImage]];
  return cell;
}

/*
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
//  UILongPressGestureRecognizer *gestureRecognizer = (UILongPressGestureRecognizer *)sender;
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    CGPoint tapPoint = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapPoint];
    if (indexPath != nil) {
      //    OKSonuclarCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
      self.stringToBeSearceh = color.productName;
      NSLog(@"Tapped Cell product is %@", self.stringToBeSearceh);
      
      UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@ icin internete bakilsin mi?", self.stringToBeSearceh]
                                                       delegate:self
                                              cancelButtonTitle:@"Hayir"
                                              otherButtonTitles:@"Tamam", nil];
      [message show];
    }
  }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:@"Hayir"]) {
    return;
  }
  NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"https://www.google.com/search?q="];
  [searchText appendString:[self.stringToBeSearceh stringByReplacingOccurrencesOfString:@" " withString:@"+"]];

  NSString *urlStr = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:urlStr];
  BOOL success = [[UIApplication sharedApplication] openURL:url];
  
  if (!success) {
    NSLog(@"Failed to open url: %@", [url description]);
  }
}
*/
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  //resultDetailSegue
  if ([[segue identifier] isEqualToString:@"resultDetailSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OKMainViewController *vc = [segue destinationViewController];
    //TODO: share color model to to destination view controller
    [vc setColorModel:color];
    [vc setManagedObjectContext:self.managedObjectContext];
    vc.lookingFromFavList = NO;
  } else if ([[segue identifier] isEqualToString:@"settingSegueFromResults"]) {
    OKSettingsViewController *vc = [segue destinationViewController];
    [vc setManagedObjectContext:self.managedObjectContext];
  }
}

@end
