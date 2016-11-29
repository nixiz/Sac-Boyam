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
#import "OKResultsTableViewCell.h"
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
#import "UIViewController+MotionEffect.h"
#import "OKAppRater.h"

#define ARC4RANDOM_MAX	0x100000000
#define indexForProductName   0
//#define indexForProductDetail 1
#define indexForProductPrice  1
#define tableCellHeightForNormalView 70
#define tableCellHeightForDetailView 150
#define tagForShowSettingsPage 303030
#define tagForAddToFavorites 202020

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
@property (strong, nonatomic) UIBarButtonItem *settingsBtn;
@property (strong, nonatomic) UIBarButtonItem *infoBtn;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSMutableSet *favoritedCellIndexPathList;
@property (strong, nonatomic) NSIndexPath *savingIndexPath;

- (IBAction)addCellToFav:(id)sender;
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
  CGFloat minval = fabs(self.grayScale - grayScaleScanThreshold(self.grayScale));
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
  self.settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_navBar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(settingsFromResultsTap:)];
  
  self.infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showTutorial)];
//  [self addMotionEffectToViewOnlyHorizontal:self.settingsBtn withCustomMinMaxRelativities:-10];
  
  self.navigationItem.rightBarButtonItems = @[self.settingsBtn, self.infoBtn];
  self.view.backgroundColor = [self.view getBackgroundColor];
  self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

  self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  self.favoritedCellIndexPathList = [NSMutableSet setWithCapacity:5];
  
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
//      NSAssert(NO, @"Sen hayirdir!!");
      NSLog(@"scrollToRowAtIndexPath [0,0] not finished properly!");
      return;
    }
//    [self.tableView beginUpdates];
//    [self.tableView deselectRowAtIndexPath:self.lastSelectedIndexPath animated:NO];
//    [self.tableView endUpdates];
    
    OKResultsTableViewCell *cellView = (OKResultsTableViewCell *)[[self.tableView visibleCells] firstObject];
    //  NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cellView];
    
    CGRect cellViewFrame  = [cellView frame];
    //  CGRect frameInView = [self.view convertRect:cellViewFrame toView:cellView];
    //  CGRect fromView = [self.view convertRect:cellViewFrame fromView:cellView];
    CGRect toView = [cellView convertRect:[self.view convertRect:cellViewFrame toView:cellView] toView:nil];
    cellViewFrame = toView;
    
    CGRect cellImageViewFrame = [cellView.productImageView frame];
    cellImageViewFrame = [cellView.productImageView convertRect:cellImageViewFrame toView:nil];
    //  cellImageViewFrame = [self.view convertRect:cellImageViewFrame fromView:cellView];
    //  cellImageViewFrame = [self.view convertRect:cellImageViewFrame toView:nil];
    
    CGRect cellTextViewFrame  = [[cellView productNameLbl] frame];
    cellTextViewFrame = [cellView.productNameLbl convertRect:cellTextViewFrame toView:nil];
    cellTextViewFrame.size.height = cellImageViewFrame.size.height;
    //  cellTextViewFrame = [self.view convertRect:cellTextViewFrame fromView:cellView];
    //  cellTextViewFrame = [self.view convertRect:cellTextViewFrame toView:nil];
    
    CGRect sectionFrame = CGRectMake(cellViewFrame.origin.x, cellViewFrame.origin.y - tableCellHeightForNormalView, cellViewFrame.size.width, tableCellHeightForNormalView);
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath isEqual:[tableView indexPathForSelectedRow]]) {
    return tableCellHeightForDetailView;
  }
  return tableCellHeightForNormalView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return tableCellHeightForNormalView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  CGRect headerViewRect = CGRectMake(0, 0, self.view.bounds.size.width, tableCellHeightForNormalView);
  UIView *headerView = [[UIView alloc] initWithFrame:headerViewRect];
//  [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.70]];
  headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];

  UIImageView *productLogo = [[UIImageView alloc] initWithImage:
                              [UIImage imageWithData:color.brand.brandImage]];
  productLogo.frame = CGRectMake(0, 0, tableCellHeightForNormalView, tableCellHeightForNormalView);
  productLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
  [headerView addSubview:productLogo];
    
  UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(tableCellHeightForNormalView + 10, 0, self.view.bounds.size.width - tableCellHeightForNormalView, tableCellHeightForNormalView)];
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
  static NSString *CellIdentifier = @"dynamicTableCell";
  OKResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  if (cell == nil)
  {
    cell = [[OKResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.70]];
  
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [cell setTintColor:[UIColor blackColor]];
  cell.productNameLbl.text = color.productName;
  if ([self isIndexPathContainsOnMyList:indexPath]) {
    [cell.favButton setImage:[UIImage imageNamed:@"star-rated.png"] forState:UIControlStateNormal];
  } else {
    [cell.favButton setImage:[UIImage imageNamed:@"star-unrated.png"] forState:UIControlStateNormal];
  }

  [cell.tryButton setHidden:YES];
  [cell.productDetailLbl setHidden:YES];
  [cell.productDetailLbl setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
  cell.productDetailLbl.numberOfLines = 0;
  cell.productDetailLbl.text = color.productName;
  [cell.productImageView setImage:[UIImage imageWithData:color.productImage]];
  return cell;
}
/*
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView beginUpdates];
  OKResultsTableViewCell *cell = (OKResultsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  [cell.tryButton setHidden:YES];
  [cell.productDetailLbl setHidden:YES];
  [tableView endUpdates];
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView beginUpdates];
  OKResultsTableViewCell *deselectedCell = (OKResultsTableViewCell *)[tableView cellForRowAtIndexPath:self.lastSelectedIndexPath];
  [deselectedCell.tryButton setHidden:YES];
  [deselectedCell.productDetailLbl setHidden:YES];
  self.lastSelectedIndexPath = indexPath;
  OKResultsTableViewCell *selectedCell = (OKResultsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  [selectedCell.tryButton setHidden:NO];
  [selectedCell.productDetailLbl setHidden:NO];
  [tableView endUpdates];
}

#pragma mark - UIAlertView Delegate

- (void)showAlertViewForNoResultsFound
{
  UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""
                                                              message:NSLocalizedStringFromTable(@"no-results-found-msg", okStringsTableName, nil)
                                                       preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                           [self settingsFromResultsTap:nil];
                                                         }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                       // no action!
                                                     }];
  [ac addAction:okAction];
  [ac addAction:cancelAction];
  
  [self presentViewController:ac animated:YES completion:nil];
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

-(void)settingsFromResultsTap:(id)sender
{
  [self performSegueWithIdentifier:@"settingSegueFromResults" sender:sender];
}

-(IBAction)unwindToResults:(UIStoryboardSegue *)segue
{
  UIViewController *vc = segue.sourceViewController;
  
  if ([vc isKindOfClass:[OKSettingsViewController class]]) {
    [self refreshFetcedResultController:self.managedObjectContext];
  }
}

#ifdef LITE_VERSION
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  if ([identifier isEqualToString:@"tryOnMeSegue"] || [identifier isEqualToString:@"tryOnMeSegueNew"])
  {
    [[OKAppRater sharedInstance] askForPurchase];
    return NO;
  }
  return YES;
}
#endif

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
  } else if ([[segue identifier] isEqualToString:@"tryOnMeSegue"] || [[segue identifier] isEqualToString:@"tryOnMeSegueNew"]) {
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ColorModel *color = [self.fetchedResultsController objectAtIndexPath:self.lastSelectedIndexPath];
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

#pragma mark - Private Methods

- (void)updateNumberOfViewResult
{
  NSInteger timesOfResultView = 1 + [[[NSUserDefaults standardUserDefaults] objectForKey:timesOfNotRatedUsesKey] integerValue];
  [[NSUserDefaults standardUserDefaults] setInteger:timesOfResultView forKey:timesOfNotRatedUsesKey];
  BOOL isSynced = [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"number of uses are synced %@", isSynced ? @"successfuly":@"unsuccessfuly");
}

- (BOOL)isIndexPathContainsOnMyList:(NSIndexPath *)indexPath
{
  __block BOOL objFound = NO;
  [self.favoritedCellIndexPathList enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    NSIndexPath *ind = (NSIndexPath *)obj;
    if ([ind isEqual:indexPath]) {
      *stop = YES;
      objFound = YES;
    }
  }];
  return objFound;
}

- (IBAction)addCellToFav:(id)sender
{
#ifdef LITE_VERSION
  [[OKAppRater sharedInstance] askForPurchase];
  return;
//#error "free version build error"
#else
//#error "paid version build error"
  BOOL takeRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:takeRecordKey] boolValue];
  if (!takeRecord) {
    //TODO: Ask for enable records!
    return;
  }
  UIButton *btn = (UIButton *)sender;
  self.savingIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)btn.superview.superview];
  if ([self isIndexPathContainsOnMyList:self.savingIndexPath]) return;
  
  ColorModel *colorModel = [self.fetchedResultsController objectAtIndexPath:self.savingIndexPath];
  UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                              message:NSLocalizedStringFromTable(@"takeRecordPromt", okStringsTableName, nil)
                                                       preferredStyle:UIAlertControllerStyleAlert];
  UITextField *textField = [[ac textFields] objectAtIndex:0];
  [textField setPlaceholder:NSLocalizedStringFromTable(@"enterNameForProduct", okStringsTableName, nil)];
  [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
  [textField setAutocorrectionType:UITextAutocorrectionTypeDefault];
  [textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
  NSString *brandName = colorModel.brand.brandName;
  
  NSString *fieldText = [NSString stringWithFormat:@"%@ ", brandName];
  [textField setText:fieldText];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                                         style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                         }];
  
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                       NSString *recordName = fieldText;
                                                       //if record name is null or empty
                                                       if ([recordName length] == 0) {
                                                         UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"error", okStringsTableName, nil)
                                                                                                                     message:NSLocalizedStringFromTable(@"recordNotSaved", okStringsTableName, nil)
                                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                                         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                                                                                style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                }];
                                                         [ac addAction:cancelAction];
                                                         
                                                         [self presentViewController:ac animated:YES completion:nil];
                                                         return;
                                                       }
                                                       ColorModel *colorModel = [self.fetchedResultsController objectAtIndexPath:self.savingIndexPath];
                                                       UserRecordModel *record = [UserRecordModel recordModelWithDate:[NSDate date]
                                                                                                           recordName:recordName
                                                                                                       usedColorModel:colorModel
                                                                                               inManagedObjectContext:self.managedObjectContext];
                                                       if (record)
                                                       {
                                                         OKResultsTableViewCell *cell = (OKResultsTableViewCell *)[self.tableView cellForRowAtIndexPath:self.savingIndexPath];
                                                         if ([self isIndexPathContainsOnMyList:self.savingIndexPath]) return;
                                                         [self.favoritedCellIndexPathList addObject:self.savingIndexPath];
                                                         [cell.favButton setImage:[UIImage imageNamed:@"star-rated.png"] forState:UIControlStateNormal];
                                                       }
                                                     }];
  [ac addAction:okAction];
  [ac addAction:cancelAction];
  
  [self presentViewController:ac animated:YES completion:nil];
#endif
}
@end
