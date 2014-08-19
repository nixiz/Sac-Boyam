//
//  BrandModel+Create.m
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 14/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "BrandModel+Create.h"

@implementation BrandModel (Create)

+ (BrandModel *)brandModelWithName:(NSString *)brandName
                        brandImage:(NSData *)brandImg
            inManagedObjectContext:(NSManagedObjectContext *)context;
{
  BrandModel *bm = nil;
  
  if (brandName.length) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrandModel"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brandName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"brandName = %@", brandName];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] > 1)) { //eger birden fazla brand geldiyse veya fetch basarili olmadiysa
      //handle error
    } else if (![matches count]) { //eger boyle bir brand objesi yoksa yarat
      bm = [NSEntityDescription insertNewObjectForEntityForName:@"BrandModel" inManagedObjectContext:context];
      bm.brandName = brandName;
      bm.brandImage = brandImg;
      
    } else { //boyle bir brand varsa olani donder
      bm = [matches lastObject];
    }
  }
  
  
  
  return bm;
}

+ (BrandModel *)brandModelFromBrandName:(NSString *)brandName
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
  BrandModel *brand = nil;
  if (brandName.length) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrandModel"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brandName"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"brandName = %@", brandName];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) { //eger birden fazla brand geldiyse veya fetch basarili olmadiysa
      //handle error
    } else if (![matches count]) { //eger boyle bir brand objesi yoksa yarat
//      bm = [NSEntityDescription insertNewObjectForEntityForName:@"BrandModel" inManagedObjectContext:context];
//      bm.brandName = brandName;
//      bm.brandImage = brandImg;
      
    } else { //boyle bir brand varsa olani donder
      brand = [matches lastObject];
    }
  }
  
  return brand;
}

+ (NSArray *)getAllBrandsInManagedObjectContext:(NSManagedObjectContext *)context
{
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrandModel"];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"brandName"
                                                            ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)]];
  request.predicate = nil;
  
  NSError *error;
  NSArray *matches = [context executeFetchRequest:request error:&error];
  
  if (error || ![matches count]) {
    NSLog(@"[%@ %@]: Error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error ? [error localizedDescription] : @"There is no brand in here");
  }
  return matches;
}

@end
