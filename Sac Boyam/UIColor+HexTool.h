//
//  UIColor+HexTool.h
//  RenkBul
//
//  Created by Oguzhan Katli on 27/11/14.
//  Copyright (c) 2014 Oğuzhan Katlı. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexTool)

+ (UIColor *)colorFromHexString:(NSString *)hexColor andAlpha:(float)alpha;
- (NSString *)colorToHexString;

- (NSString *)colorDomainName;

@end
