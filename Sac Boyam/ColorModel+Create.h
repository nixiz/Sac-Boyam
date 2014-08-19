//
//  ColorModel+Create.h
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 14/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "ColorModel.h"
#import "OKProductType.h"

@interface ColorModel (Create)

+(ColorModel *)colorModelWithInfo:(OKProductType *)product
           inManagedObjectContext:(NSManagedObjectContext *)context;

+(ColorModel *)colorModelFromProductName:(NSString *)productName
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
