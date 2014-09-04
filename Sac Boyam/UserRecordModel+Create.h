//
//  UserRecordModel+Create.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 02/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UserRecordModel.h"

@interface UserRecordModel (Create)
+ (UserRecordModel *)recordModelWithDate:(NSDate *)recordDate
                              recordName:(NSString *)recordName
                          usedColorModel:(ColorModel *)color
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end
