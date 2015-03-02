//
//  OKSettingsViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol OKSettingsDelegate <NSObject>
@optional
- (void)acceptChangedSetings;

@end

@interface OKSettingsViewController : UIViewController<NSFetchedResultsControllerDelegate>
@property (weak) id<OKSettingsDelegate> delegate;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Set to YES to get some debugging output in the console.
@property BOOL debug;

//-(void)setCurrentSettings:(NSDictionary *)settings;
@end
