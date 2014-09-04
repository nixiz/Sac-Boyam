//
//  UserRecordModel.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColorModel;

@interface UserRecordModel : NSManagedObject

@property (nonatomic, retain) NSDate * recordDate;
@property (nonatomic, retain) NSString * recordName;
@property (nonatomic, retain) ColorModel *recordedColor;

@end
