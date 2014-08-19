//
//  BrandModel+Create.h
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 14/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "BrandModel.h"

@interface BrandModel (Create)
+ (BrandModel *)brandModelWithName:(NSString *)brandName
                        brandImage:(NSData *)brandImg
            inManagedObjectContext:(NSManagedObjectContext *)context;
+ (BrandModel *)brandModelFromBrandName:(NSString *)brandName
                 inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllBrandsInManagedObjectContext:(NSManagedObjectContext *)context;
@end
