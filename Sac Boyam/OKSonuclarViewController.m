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

#define ARC4RANDOM_MAX	0x100000000
#define indexForProductName   0
//#define indexForProductDetail 1
#define indexForProductPrice  1
#define MinMaxScale 0.15 //%15
//#define grayScaleScanThreshold (1.0/255.0)*100.0*MinMaxScale
#define grayScaleScanThreshold(x) ((x)/255.0)*100.0*MinMaxScale


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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brand.brandName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];

    CGFloat minval = fabsf(self.grayScale - grayScaleScanThreshold(self.grayScale));
    CGFloat maxval = self.grayScale + grayScaleScanThreshold(self.grayScale);
    request.predicate = [NSPredicate predicateWithFormat: @"grayScale >= %@ AND grayScale <= %@", @(minval), @(maxval)];
    //between burada calismiyor. internette de bunun gibi sorunlar var. o yuzden and kullanarak yaptim.
//    request.predicate = [NSPredicate predicateWithFormat: @"grayScale BETWEEN %@", @[@1, @10]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  CGRect headerViewRect = CGRectMake(0, 0, self.view.bounds.size.width, 50);
  UIView *headerView = [[UIView alloc] initWithFrame:headerViewRect];
  headerView.backgroundColor = self.mColor;
  NSString *productNameString = [self.resultsIndex objectForKey:[NSNumber numberWithInteger:section]];
  
  
  //TODO: Get product Logo from productName value.
  UIImageView *productLogo = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"Default.png"]];
  productLogo.frame = CGRectMake(0, 0, 50, 50);
  productLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
  [headerView addSubview:productLogo];
    
  UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, self.view.bounds.size.width - 50, 50)];
  productName.text = productNameString;
  productName.backgroundColor = [UIColor clearColor];
  [headerView addSubview:productName];
    
  return headerView;
}
*/

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
  cell.productName.text = color.productName;
  cell.priceLabel.text = [color.price stringValue];
  [cell.productImg setImage:[UIImage imageWithData:color.productImage]];
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

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

  NSURL *url = [NSURL URLWithString:searchText];
  BOOL success = [[UIApplication sharedApplication] openURL:url];
  
  if (!success) {
    NSLog(@"Failed to open url: %@", [url description]);
  }
}

@end
