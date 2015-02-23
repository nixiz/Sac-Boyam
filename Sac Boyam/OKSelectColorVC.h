//
//  OKSelectColorVC.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 20/02/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKSelectColorVC : UIViewController
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIImage *selectedPicture;
@end
