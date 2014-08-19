//
//  ColorModel+Create.m
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 14/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "ColorModel+Create.h"
#import "BrandModel+Create.h"

@implementation ColorModel (Create)

+(ColorModel *)colorModelWithInfo:(OKProductType *)product
           inManagedObjectContext:(NSManagedObjectContext *)context
{
  ColorModel *cm = nil;
  
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ColorModel"];
  request.predicate = [NSPredicate predicateWithFormat:@"productName = %@", product.productName];
  
  NSError *error;
  NSArray *mathes = [context executeFetchRequest:request error:&error];
  
  if (!mathes || error || ([mathes count] > 1)) {
    //handle error
  } else if ([mathes count]) {
    cm = [mathes lastObject];
  } else {
    cm = [NSEntityDescription insertNewObjectForEntityForName:@"ColorModel" inManagedObjectContext:context];
//    cm.productName = product.productName;
    cm.red = [NSNumber numberWithFloat:product.red];
    cm.green = [NSNumber numberWithFloat:product.green];
    cm.blue = [NSNumber numberWithFloat:product.blue];
    cm.grayScale = [NSNumber numberWithFloat:product.grayScale];
    cm.price = [NSNumber numberWithFloat:product.price];
    cm.productName = product.productName;
    cm.productImage = product.productImage;
    BrandModel *brand = [BrandModel brandModelWithName:product.brandName brandImage:product.brandImage inManagedObjectContext:context];
    cm.brand = brand;
  }
  return cm;
}

+(ColorModel *)colorModelFromProductName:(NSString *)productName
                  inManagedObjectContext:(NSManagedObjectContext *)context
{
  ColorModel *cm = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ColorModel"];
  request.predicate = [NSPredicate predicateWithFormat:@"productName = %@", productName];
  
  NSError *error;
  NSArray *mathes = [context executeFetchRequest:request error:&error];
  
  if ([mathes count]) {
    cm = [mathes lastObject];
  }
  return cm;
}

@end
