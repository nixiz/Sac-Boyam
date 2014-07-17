//
//  OKProductJsonType.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 15/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKProductJsonType.h"

@implementation OKProductJsonType


-(id)initWithName:(NSString *)name brandName:(NSString *)brandName andPrice:(float) price
{
  if (self = [super init]) {
    
    self.name = name;
    self.brandName = brandName;
    self.price = price;
    self.red = 0.0;
    self.green = 0.0f;
    self.blue = 0.0f;
    self.grayScale = 0.0f;
  }
  return self;
}

-(void)setColorWithRed:(float)red green:(float)green blue:(float)blue andGrayScale:(float)grayScale
{
  self.red = red;
  self.green = green;
  self.blue = blue;
  self.grayScale = grayScale;
}

+(instancetype)productJsonTypeWithName:(NSString *)name brandName:(NSString *)brandName price:(float)price andGrayScale:(float)grayScale
{
  OKProductJsonType *returnType = [[self alloc] initWithName:name brandName:brandName andPrice:price];
  returnType->_grayScale = grayScale;
//  returnType.grayScale = grayScale;
  return returnType;
}

+(instancetype)productJsonTypeWithJsonDictionary:(NSDictionary *)dict
{
  OKProductJsonType *returnType = [[self alloc] init];
  returnType->_name = [dict objectForKey:@"Name"];
  returnType->_brandName = [dict objectForKey:@"BrandName"];
  returnType->_price = [[dict objectForKey:@"Price"] floatValue];
  returnType->_red = [[dict objectForKey:@"Red"] floatValue];
  returnType->_green = [[dict objectForKey:@"Green"] floatValue];
  returnType->_blue = [[dict objectForKey:@"Blue"] floatValue];
  returnType->_grayScale = [[dict objectForKey:@"GrayScale"] floatValue];

  return returnType;
}

@end
