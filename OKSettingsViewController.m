//
//  OKSettingsViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKSettingsViewController.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"
#import "Sac Boyam/UserRecordModel.h"
#import "Sac Boyam/ColorModel.h"
#import "Sac Boyam/OKMainViewController.h"
#import "OKAppDelegate.h"
#import "Sac Boyam/UIView+CreateImage.h"
#import "UIImage+AverageColor.h"
#import "OKSettingsTutorialVC.h"
#import "OKAppRater.h"
#import "UIViewController+MotionEffect.h"

@interface OKSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSDictionary *settingsMap;
- (IBAction)switchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *savePhotosSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *editPhotosSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *takeRecordsSwitch;
- (IBAction)resultsDensityChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *resultDensitySlider;
@property (weak, nonatomic) IBOutlet UITableView *recordsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *findOnTapSwitch;

// The controller (this class fetches nothing if this is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Causes the fetchedResultsController to refetch the data.
// You almost certainly never need to call this.
// The NSFetchedResultsController class observes the context
//  (so if the objects in the context change, you do not need to call performFetch
//   since the NSFetchedResultsController will notice and update the table automatically).
// This will also automatically be called if you change the fetchedResultsController @property.
- (void)performFetch;

// Turn this on before making any changes in the managed object context that
//  are a one-for-one result of the user manipulating rows directly in the table view.
// Such changes cause the context to report them (after a brief delay),
//  and normally our fetchedResultsController would then try to update the table,
//  but that is unnecessary because the changes were made in the table already (by the user)
//  so the fetchedResultsController has nothing to do and needs to ignore those reports.
// Turn this back off after the user has finished the change.
// Note that the effect of setting this to NO actually gets delayed slightly
//  so as to ignore previously-posted, but not-yet-processed context-changed notifications,
//  therefore it is fine to set this to YES at the beginning of, e.g., tableView:moveRowAtIndexPath:toIndexPath:,
//  and then set it back to NO at the end of your implementation of that method.
// It is not necessary (in fact, not desirable) to set this during row deletion or insertion
//  (but definitely for row moves).
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

@property (nonatomic) BOOL beganUpdates;
@end

@implementation OKSettingsViewController

//@synthesize fetchedResultsController = _fetchedResultsController;
//@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
//@synthesize debug = _debug;
//@synthesize beganUpdates = _beganUpdates;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

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
//  [self addMotionEffectToView:self.view];

  self.view.backgroundColor = [self.view getBackgroundColor];

  [self addMotionEffectToViewOnlyHorizontal:self.savePhotosSwitch  withCustomMinMaxRelativities:5];
  [self addMotionEffectToViewOnlyHorizontal:self.editPhotosSwitch  withCustomMinMaxRelativities:7];
  [self addMotionEffectToViewOnlyHorizontal:self.findOnTapSwitch   withCustomMinMaxRelativities:10];
  [self addMotionEffectToViewOnlyHorizontal:self.takeRecordsSwitch withCustomMinMaxRelativities:13];
  
  self.fetchedResultsController.delegate = self;
  
  self.settingsMap = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
  [self.savePhotosSwitch setOn:[self.settingsMap[savePhotosKey] boolValue] animated:YES];
  [self.savePhotosSwitch setOnTintColor:[[UIColor blackColor] colorWithAlphaComponent:.85]];
  [self.editPhotosSwitch setOn:[self.settingsMap[editPhotosKey] boolValue] animated:YES];
  [self.editPhotosSwitch setOnTintColor:[[UIColor blackColor] colorWithAlphaComponent:.85]];
  [self.takeRecordsSwitch setOn:[self.settingsMap[takeRecordKey] boolValue] animated:YES];
  [self.takeRecordsSwitch setOnTintColor:[[UIColor blackColor] colorWithAlphaComponent:.85]];
  [self.findOnTapSwitch setOn:[self.settingsMap[findOnTapKey] boolValue] animated:YES];
  [self.findOnTapSwitch setOnTintColor:[[UIColor blackColor] colorWithAlphaComponent:.85]];
  [self.resultDensitySlider setValue:[self.settingsMap[resultDensityKey] floatValue] animated:YES];
  
  self.recordsTableView.backgroundColor = [UIColor clearColor];
  UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoMark_navBar"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showTutorial)];

  [self.navigationItem setTitle:NSLocalizedStringFromTable(@"settingsTitle", okStringsTableName, nil)];
  //eger result sayfasi tarafindan acilmissa!
  if (self.delegate == nil) {
    UIBarButtonItem *unwindButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(performUnwindSegue:)];
    self.navigationItem.rightBarButtonItems = @[unwindButton, infoBtn];
    self.navigationItem.hidesBackButton = YES;
  } else {
    self.navigationItem.rightBarButtonItem = infoBtn;
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTutorial
{
  [self performSegueWithIdentifier:@"SettingsTutorialSegue" sender:nil];
}

- (IBAction)switchValueChanged:(id)sender
{
  UISwitch *_switch = (UISwitch *)sender;
  NSLog(@"Switch with Tag %ld value chaged to %@", (long)_switch.tag, _switch.on == YES ? @"YES" : @"NO");
  NSString *keyString;
  switch (_switch.tag) {
    case 0:
      keyString = savePhotosKey;
      break;
    case 1:
      keyString = editPhotosKey;
      break;
    case 2:
      keyString = takeRecordKey;
      break;
    case 3:
      keyString = findOnTapKey;
      break;
    default: //default'ta zaten degisen olmayacagi icin asagidaki if dongusunde sikinti olmamasi icin herhangi biri olabilir
      keyString = editPhotosKey;
      break;
  }
  
#ifdef LITE_VERSION
  if ([keyString isEqualToString:findOnTapKey] || [keyString isEqualToString:takeRecordKey]) {
    [[OKAppRater sharedInstance] askForPurchase];
    [_switch setOn:!_switch.on animated:YES];
    return;
  }
#endif
  
  if ([keyString isEqualToString:takeRecordKey] && !_switch.on) {
    //eger take record kapatildiysa
    //NSString *completionMessage = NSLocalizedStringFromTable(@"imageSavedSuccessfully", okStringsTableName, nil);

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Warning", okStringsTableName, nil)
                                                                message:NSLocalizedStringFromTable(@"DeleteAllRecordsPromt", okStringsTableName, nil)
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         [self deleteAllEntries];
                                                       }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancelButtonForURLReq", okStringsTableName, nil)
                                                       style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                         [self.takeRecordsSwitch setOn:YES animated:YES];
                                                       }];
    [ac addAction:okAction];
    [ac addAction:noAction];
    
    [self presentViewController:ac animated:YES completion:nil];
  } else {
    // ayarlar degistiginde buraya girilecegi icin degistimi diye kontrol etmeye gerek yok.
    [[NSUserDefaults standardUserDefaults] setObject:@(_switch.on) forKey:keyString];
    if ([self.delegate respondsToSelector:@selector(acceptChangedSetings)]) {
      [self.delegate acceptChangedSetings];
    }
  }
}

- (IBAction)resultsDensityChanged:(id)sender {
  [[NSUserDefaults standardUserDefaults] setObject:@(self.resultDensitySlider.value) forKey:resultDensityKey];
}

/*
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSString *str = [alertView buttonTitleAtIndex:buttonIndex];
  if ([str isEqualToString:NSLocalizedStringFromTable(@"OKButtonTitle", okStringsTableName, nil)]) {
    [self deleteAllEntries];
  } else {
    [self.takeRecordsSwitch setOn:YES animated:YES];
  }
}
*/

-(void)deleteAllEntries
{
  NSError *error;
  for (UserRecordModel *record in [self.fetchedResultsController fetchedObjects]) {
    [self.managedObjectContext deleteObject:record];
  }
  [self.managedObjectContext save:&error];
  if (error) {
    NSLog(@"An error occured when saving. %@", [error userInfo]);
  }
  [[NSUserDefaults standardUserDefaults] setObject:@(self.takeRecordsSwitch.on) forKey:takeRecordKey];

  [self.recordsTableView reloadData];
}

-(void)performUnwindSegue:(id)sender
{
  [self performSegueWithIdentifier:@"unwindToResultsSegue" sender:sender];
}

//-----------------------------oOo-------------------------oOo-----------------------oOo----------------------------------//

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
  _managedObjectContext = managedObjectContext;
  if (managedObjectContext) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserRecordModel"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recordDate" ascending:NO]];
    request.predicate = nil; //get all records
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
  } else {
    self.fetchedResultsController = nil;
  }
}

#pragma mark - Fetching

- (void)performFetch
{
  if (self.fetchedResultsController) {
    if (self.fetchedResultsController.fetchRequest.predicate) {
      if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
    } else {
      if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
    }
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
  } else {
    if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  }
  [self.recordsTableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
  NSFetchedResultsController *oldfrc = _fetchedResultsController;
  if (newfrc != oldfrc) {
    _fetchedResultsController = newfrc;
    newfrc.delegate = self;
    if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
      self.title = newfrc.fetchRequest.entity.name;
    }
    if (newfrc) {
      if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
      [self performFetch];
    } else {
      if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
      [self.recordsTableView reloadData];
    }
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return NSLocalizedStringFromTable(@"favDyes", okStringsTableName, nil);
//	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  //favDyes
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//  return [self.fetchedResultsController sectionIndexTitles];
  return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
    [self.recordsTableView beginUpdates];
    self.beganUpdates = YES;
  }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
  {
    switch(type)
    {
      case NSFetchedResultsChangeInsert:
        [self.recordsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
      case NSFetchedResultsChangeDelete:
        [self.recordsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        break;
      default:
        // Do nothing for other cases.
        break;
    }
  }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
  {
    switch(type)
    {
      case NSFetchedResultsChangeInsert:
        [self.recordsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
      case NSFetchedResultsChangeDelete:
        [self.recordsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
      case NSFetchedResultsChangeUpdate:
        [self.recordsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
      case NSFetchedResultsChangeMove:
        [self.recordsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.recordsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
    }
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  if (self.beganUpdates) [self.recordsTableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
  _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
  if (suspend) {
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
  } else {
    [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
  }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"RecordsCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  cell.backgroundColor = [UIColor clearColor];

  UserRecordModel *record = [self.fetchedResultsController objectAtIndexPath:indexPath];

  cell.textLabel.adjustsFontSizeToFitWidth = YES;
  [cell.textLabel setTextColor:[UIColor blackColor]];
  cell.textLabel.text = record.recordName;

  cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
  [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedStringFromTable(@"recordTime", okStringsTableName, nil), [OKUtils dateToString:record.recordDate]];
  
  UIImage *productImg = [UIImage imageWithData:record.recordedColor.productImage];
  [cell.imageView setImage:productImg];
  cell.imageView.layer.cornerRadius = cell.bounds.size.height / 4.0;
  cell.imageView.layer.masksToBounds = YES;
  
  return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    UserRecordModel *mob = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.fetchedResultsController.managedObjectContext deleteObject:mob];
  }
  
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"favDetailSegue"]) {
    NSIndexPath *indexPath = [self.recordsTableView indexPathForCell:sender];
    UserRecordModel *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OKMainViewController *vc = [segue destinationViewController];
    [vc setColorModel:record.recordedColor];
    [vc setManagedObjectContext:self.managedObjectContext];
    vc.lookingFromFavList = YES;
    [vc.navigationItem setTitle:record.recordName];
  } else if ([[segue identifier] isEqualToString:@"SettingsTutorialSegue"]) {
    UIImage *screenShot = [self.view createImageFromViewAfterScreenUpdates:NO];
//    NSLog(@"Frame %@  Bound %@", NSStringFromCGRect(self.savePhotosSwitch.frame) , NSStringFromCGRect(self.savePhotosSwitch.bounds));
//    NSLog(@"Frame %@  Bound %@", NSStringFromCGRect(self.takeRecordsSwitch.frame) , NSStringFromCGRect(self.takeRecordsSwitch.bounds));
//    NSLog(@"Frame %@  Bound %@", NSStringFromCGRect(self.recordsTableView.frame) , NSStringFromCGRect(self.recordsTableView.bounds));
    
    NSDictionary *pointDict = @{@"item-1": [NSValue valueWithCGRect:self.savePhotosSwitch.frame],
                                @"item-2": [NSValue valueWithCGRect:self.editPhotosSwitch.frame],
                                @"item-4": [NSValue valueWithCGRect:self.takeRecordsSwitch.frame],
                                @"item-3": [NSValue valueWithCGRect:self.findOnTapSwitch.frame],
                                @"item-5": [NSValue valueWithCGRect:self.resultDensitySlider.frame],
                                @"item-6": [NSValue valueWithCGRect:self.recordsTableView.frame]};

    NSDictionary *dict = @{@"item-1": @"settings-item-1-exp",
                           @"item-2": @"settings-item-2-exp",
                           @"item-3": @"settings-item-3-exp",
                           @"item-4": @"settings-item-4-exp",
                           @"item-5": @"settings-item-5-exp",
                           @"item-6": @"settings-item-6-exp"};

    OKSettingsTutorialVC *vc = [segue destinationViewController];
    [vc initiateTutorialControllerWithBgImg:screenShot andContentPoints:pointDict WithExplanationDescriptors:dict];
  }
}


@end
