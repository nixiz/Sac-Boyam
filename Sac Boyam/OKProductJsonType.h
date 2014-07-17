//
//  OKProductJsonType.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 15/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKProductJsonType : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *brandName;
@property float price;
@property float red;
@property float green;
@property float blue;
@property float grayScale;

-(id)initWithName:(NSString *)name brandName:(NSString *)brandName andPrice:(float) price;
-(void)setColorWithRed:(float)red green:(float)green blue:(float)blue andGrayScale:(float)grayScale;
+(instancetype)productJsonTypeWithName:(NSString *)name brandName:(NSString *)brandName price:(float)price andGrayScale:(float)grayScale;
+(instancetype)productJsonTypeWithJsonDictionary:(NSDictionary *)dict;
@end
