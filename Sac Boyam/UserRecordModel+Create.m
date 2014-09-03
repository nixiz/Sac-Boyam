//
//  UserRecordModel+Create.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 02/09/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "UserRecordModel+Create.h"

@implementation UserRecordModel (Create)

+ (UserRecordModel *)recordModelWithDate:(NSDate *)recordDate
                          usedColorModel:(ColorModel *)color
                  inManagedObjectContext:(NSManagedObjectContext *)context
{
  UserRecordModel *recordModel = nil;
  
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserRecordModel"];
  request.predicate = [NSPredicate predicateWithFormat:@"recordDate = %@", recordDate];
  
  NSError *error;
  NSArray *mathes = [context executeFetchRequest:request error:&error];
  
  if (!mathes || error || ([mathes count] > 1)) {
    NSLog(@"Error occured for fetch request %@", error ? [error userInfo] : @"unknown error!!!");
  } else if ([mathes count]) {
    recordModel = [mathes lastObject];
  } else {
    recordModel = [NSEntityDescription insertNewObjectForEntityForName:@"UserRecordModel" inManagedObjectContext:context];
    recordModel.recordDate = recordDate;
    recordModel.recordedColor = color;
  }
  return recordModel;
}

@end
