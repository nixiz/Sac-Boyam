//
//  UserRecordModel.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 02/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColorModel;

@interface UserRecordModel : NSManagedObject

@property (nonatomic, retain) NSDate * recordDate;
@property (nonatomic, retain) ColorModel *recordedColor;

@end
