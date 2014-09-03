//
//  OKSonuclarViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/21/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import "OKSonuclarViewController.h"
#import "OKSonuclarCell.h"
#import "OKProductJsonType.h"
#import "ColorModel+Create.h"
#import "BrandModel+Create.h"
#import "OKUtils.h"
#import "OKMainViewController.h"

#define ARC4RANDOM_MAX	0x100000000
#define indexForProductName   0
//#define indexForProductDetail 1
#define indexForProductPrice  1
#define MinMaxScale 0.07 //%15
//#define grayScaleScanThreshold (1.0/255.0)*100.0*MinMaxScale
#define grayScaleScanThreshold(x) ((x)/255.0)*100.0*([[[NSUserDefaults standardUserDefaults] objectForKey:resultDensityKey] floatValue]/100.0)

@interface OKSonuclarViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property UIColor *mColor;
@property (nonatomic, strong) NSMutableDictionary *resultsList;
@property (nonatomic, strong) NSDictionary *resultsIndex;
- (IBAction)handleLongPress:(id)sender;
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

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  _managedObjectContext = managedObjectContext;
  if (managedObjectContext) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ColorModel"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brand.brandName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"grayScale" ascending:YES]];

    NSLog(@"given scale density %@", [[NSUserDefaults standardUserDefaults] objectForKey:resultDensityKey]);
    CGFloat minval = fabsf(self.grayScale - grayScaleScanThreshold(self.grayScale));
    CGFloat maxval = self.grayScale + grayScaleScanThreshold(self.grayScale);
    request.predicate = [NSPredicate predicateWithFormat: @"grayScale >= %@ AND grayScale <= %@", @(minval), @(maxval)];
    //between burada calismiyor. internette de bunun gibi sorunlar var. o yuzden and kullanarak yaptim.
//    request.predicate = [NSPredicate predicateWithFormat: @"grayScale BETWEEN %@", @[@1, @10]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"brand.brandName" cacheName:nil];
    self.fetchedResultsController.delegate = self;
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
  UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  lpgr.minimumPressDuration = 1.5; //seconds
  lpgr.delegate = self;
  [self.tableView addGestureRecognizer:lpgr];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 75.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  CGRect headerViewRect = CGRectMake(0, 0, self.view.bounds.size.width, 75);
  UIView *headerView = [[UIView alloc] initWithFrame:headerViewRect];
  headerView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.85];
  //TODO: Get product Logo from productName value.
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
  ColorModel *color = [self.fetchedResultsController objectAtIndexPath:indexPath];

  UIImageView *productLogo = [[UIImageView alloc] initWithImage:
                              [UIImage imageWithData:color.brand.brandImage]];
  productLogo.frame = CGRectMake(0, 0, 75, 75);
  productLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
  [headerView addSubview:productLogo];
    
  UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 75, 75)];
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
  
  //TODO: get product image from url/productinfo-string.
//  cell.productName.adjustsFontSizeToFitWidth = YES;
  cell.productName.lineBreakMode = NSLineBreakByWordWrapping;
  cell.productName.numberOfLines = 2;
  cell.productName.text = color.productName;
  cell.priceLabel.text = [[color.price stringValue] stringByAppendingString:@" TL"];
  [cell.productImg setImage:[UIImage imageWithData:color.productImage]];
  return cell;
}

#pragma mark - Table view delegate

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
  }
}

@end
