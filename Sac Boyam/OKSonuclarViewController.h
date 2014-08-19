//
//  OKSonuclarViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/21/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BrandModel+Create.h"
#import "ColorModel+Create.h"

@interface OKSonuclarViewController : CoreDataTableViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(void)initResultsWithGrayScaleValue:(CGFloat)grayScale forManagedObjectContext:(NSManagedObjectContext *)context;
@end
