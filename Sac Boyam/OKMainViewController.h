//
//  OKMainViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorModel.h"
#import "BrandModel.h"
#import "UserRecordModel+Create.h"

@interface OKMainViewController : UIViewController
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) ColorModel *colorModel;
@property BOOL lookingFromFavList;
@end
