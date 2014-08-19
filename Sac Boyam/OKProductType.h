//
//  OKProductType.h
//  SacBoyamMigrateApp
//
//  Created by Oguzhan Katli on 15/08/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#define ProductNameKey @"productName"
#define BrandNameKey @"brandName"
#define ProductImgKey @"productImg"
#define BrandImgKey @"brandImg"
#define RedValueKey @"redValue"
#define GreenValueKey @"greenValue"
#define BlueValueKey @"blueValue"
#define GrayScaleValueKey @"grayScaleValue"
#define PriceValueKey @"priceValue"


#import <Foundation/Foundation.h>



@interface OKProductType : NSObject

@property float red;
@property float green;
@property float blue;
@property float grayScale;
@property float price;
@property (nonatomic, strong) NSString * productName;
@property (nonatomic, strong) NSData * productImage;
@property (nonatomic, strong) NSString * brandName;
@property (nonatomic, strong) NSData * brandImage;
//@property (nonatomic, retain) BrandModel *brand;


+(instancetype) productTypeWithOptions:(NSDictionary *)options;

+(NSDictionary *) createProductOptionsDictionaryWithProductName:(NSString *)productName
                                                           red:(float)red
                                                         green:(float)green
                                                          blue:(float)blue
                                                     grayScale:(float)grayScale
                                                         price:(float)price
                                                     brandName:(NSString *)brandName
                                              productImageData:(NSData *)productImg
                                                brandImageData:(NSData *)brandImg;

@end
