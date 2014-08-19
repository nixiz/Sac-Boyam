//
//  ColorModel.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 19/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BrandModel;

@interface ColorModel : NSManagedObject

@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSNumber * grayScale;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSData * productImage;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) BrandModel *brand;

@end
