//
//  OKProductType.m
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 15/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKProductType.h"

@implementation OKProductType

+(instancetype) productTypeWithOptions:(NSDictionary *)options
{
  OKProductType *returnObj = [[self alloc] init];
  returnObj->_red = [options[RedValueKey] floatValue];
  returnObj->_green = [options[GreenValueKey] floatValue];
  returnObj->_blue = [options[BlueValueKey] floatValue];
  returnObj->_grayScale = [options[GrayScaleValueKey] floatValue];
  returnObj->_price = [options[PriceValueKey] floatValue];
  
  returnObj->_productName = options[ProductNameKey];
  returnObj->_brandName = options[BrandNameKey];

  returnObj->_productImage = options[ProductImgKey];
  returnObj->_brandImage = options[BrandImgKey];

  return returnObj;
}

+(NSDictionary *) createProductOptionsDictionaryWithProductName:(NSString *)productName
                                                           red:(float)red
                                                         green:(float)green
                                                          blue:(float)blue
                                                     grayScale:(float)grayScale
                                                         price:(float)price
                                                     brandName:(NSString *)brandName
                                              productImageData:(NSData *)productImg
                                                brandImageData:(NSData *)brandImg
{
  NSDictionary *returnObj = @{RedValueKey: @(red), GreenValueKey: @(green), BlueValueKey: @(blue), GrayScaleValueKey: @(grayScale),
                              ProductNameKey: productName, PriceValueKey: @(price), ProductImgKey: productImg,
                              BrandNameKey: brandName, BrandImgKey: brandImg};
  return returnObj;
}

@end
