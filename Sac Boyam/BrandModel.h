//
//  BrandModel.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 19/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColorModel;

@interface BrandModel : NSManagedObject

@property (nonatomic, retain) NSData * brandImage;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSSet *products;
@end

@interface BrandModel (CoreDataGeneratedAccessors)

- (void)addProductsObject:(ColorModel *)value;
- (void)removeProductsObject:(ColorModel *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
