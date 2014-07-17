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

#define ARC4RANDOM_MAX	0x100000000
#define indexForProductName   0
//#define indexForProductDetail 1
#define indexForProductPrice  1


@interface OKSonuclarViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property UIColor *mColor;
@property (nonatomic, strong) NSMutableDictionary *resultsList;
@property (nonatomic, strong) NSDictionary *resultsIndex;
- (IBAction)handleLongPress:(id)sender;
@property (nonatomic, strong) NSString *stringToBeSearceh;
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

-(void)initResultsDictionary:(NSDictionary *)dict
{
//  for (NSDictionary *obj in dict) {
////    OKProductJsonType *product = [OKProductJsonType productJsonTypeWithJsonDictionary:obj];
//    NSLog(@"Json Object: %@", obj);
//  }
  NSLog(@"Json Object: %@", dict);
 
//  NSMutableDictionary *brandNameDictionary = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
  self.resultsList = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
  
  for (NSDictionary *obj in dict) {
    OKProductJsonType *product = [OKProductJsonType productJsonTypeWithJsonDictionary:obj];
    NSLog(@"Json Object: %@", obj);

    
    NSMutableArray *brands = [self.resultsList objectForKey:product.brandName];
    if (brands == nil) {
      brands = [[NSMutableArray alloc] init];
    }
    [brands addObject:[NSArray arrayWithObjects:product.name, [NSString stringWithFormat:@"%00.00f$", product.price], nil]];
    [self.resultsList setObject:brands forKey:product.brandName];
//    self.resultsList
  }
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  //TODO:self.resultsList = [[NSMutableDictionary alloc] initWithContentsOfURL:<#(NSURL *)#>];
//  NSString *productNameAVON = @"AVON";
//  NSString *productNameOReal = @"OReal";
//  NSString *productNameHaciAbi = @"HaciAbi";
//  self.resultsList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                      [NSArray arrayWithObjects:
//                       [NSArray arrayWithObjects:@"Creative ZartZurt", @"FalanFilan", @"17.0$", nil],
//                       [NSArray arrayWithObjects:@"Creative ZartZurt", @"FalanFilan", @"17.0$", nil],
//                       [NSArray arrayWithObjects:@"Creative ZartZurt", @"FalanFilan", @"17.0$", nil],
//                       [NSArray arrayWithObjects:@"Creative ZartZurt", @"FalanFilan", @"17.0$", nil], nil], productNameAVON
//                      ,[NSArray arrayWithObjects:
//                        [NSArray arrayWithObjects:@"Oreal Healing", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"Oreal Healing", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"Oreal Healing", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"Oreal Healing", @"FalanFilan", @"17.0$", nil], nil], productNameOReal
//                      ,[NSArray arrayWithObjects:
//                        [NSArray arrayWithObjects:@"HaciAbi Candir", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"HaciAbi Candir", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"HaciAbi Candir", @"FalanFilan", @"17.0$", nil],
//                        [NSArray arrayWithObjects:@"HaciAbi Special", @"FalanFilan", @"24.0$", nil], nil], productNameHaciAbi
//                      ,nil];
  NSAssert([self.resultsList count] > 0, @"view load olmadan result listesinin islenmesi gerekir");
  
  NSArray *keys = [self.resultsList allKeys];
  NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:[keys count]];
  NSInteger ind = 0;
  for (NSString *str in keys) {
    [tmpDict setObject:str forKey:[NSNumber numberWithInteger:ind++]];
  }
  self.resultsIndex = [[NSDictionary alloc] initWithDictionary:tmpDict copyItems:YES];
  //[tmpDict removeAllObjects];
  
  self.refreshControl.tintColor = [UIColor lightGrayColor];
  [self.refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
  
  self.mColor = [UIColor magentaColor];
  
  UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  lpgr.minimumPressDuration = 1.7; //seconds
  lpgr.delegate = self;
  [self.tableView addGestureRecognizer:lpgr];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.refreshControl beginRefreshing];
  
  if (self.tableView.contentOffset.y == 0) {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
      self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.bounds.size.height);
    } completion:^(BOOL finished) {
      if (!finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aman Yarabbi"
                                                        message:@"Operation is Not Completely Finished"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
      }
    }];
  }
  [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doEndUpdateTable
{
  [self.tableView reloadData];
  [self.refreshControl endRefreshing];
}

- (void)updateTable
{
  self.mColor = [UIColor colorWithRed:(CGFloat)arc4random()/ARC4RANDOM_MAX
                                green:(CGFloat)arc4random()/ARC4RANDOM_MAX
                                 blue:(CGFloat)arc4random()/ARC4RANDOM_MAX
                                alpha:0.88f];
  //Update results list.
  //TODO:self.resultsList = [[NSMutableDictionary alloc] initWithContentsOfURL:<#(NSURL *)#>];

  [self performSelector:@selector(doEndUpdateTable) withObject:nil afterDelay:1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.resultsList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  //NSString *str = [self.resultsIndex objectForKey:[NSNumber numberWithInteger:section]];
  //NSArray *arr = [self.resultsList objectForKey:str];
  //NSInteger rslt = [arr count];
  return [[self.resultsList objectForKey:[self.resultsIndex objectForKey:[NSNumber numberWithInteger:section]]] count];
}

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"SonuclarCell";
  OKSonuclarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  if (cell == nil)
  {
    cell = [[OKSonuclarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  NSArray *productsFromSection = [self.resultsList objectForKey:[self.resultsIndex objectForKey:[NSNumber numberWithInteger:indexPath.section]]];
  NSArray *productInfoFromSelectedRow = [productsFromSection objectAtIndex:indexPath.row];
  
  
  //TODO: get product image from url/productinfo-string.
  cell.productName.text = [productInfoFromSelectedRow objectAtIndex:indexForProductName];
  cell.priceLabel.text = [productInfoFromSelectedRow objectAtIndex:indexForProductPrice];
  
  //cell.productName.text = @"Kreatif ZartZurt";
  
    //cell.productImg
    // Configure the cell...
    
    return cell;
}

- (NSArray *)getProductInfoArrayFromIndexPath:(NSIndexPath *)indexPath
{
  NSArray *productsFromSection = [self.resultsList objectForKey:[self.resultsIndex objectForKey:[NSNumber numberWithInteger:indexPath.section]]];
  NSArray *productInfoFromSelectedRow = [productsFromSection objectAtIndex:indexPath.row];
  
  return productInfoFromSelectedRow;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
      self.stringToBeSearceh = [[self getProductInfoArrayFromIndexPath:indexPath] objectAtIndex:indexForProductName];
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
