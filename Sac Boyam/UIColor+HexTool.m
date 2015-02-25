//
//  UIColor+HexTool.m
//  RenkBul
//
//  Created by Oguzhan Katli on 27/11/14.
//  Copyright (c) 2014 Oğuzhan Katlı. All rights reserved.
//

#import "UIColor+HexTool.h"

@implementation UIColor (HexTool)
+(UIColor *)colorFromHexString:(NSString *)hexColor andAlpha:(float)alpha
{
  //  NSString *colorString = [[hexColor substringToIndex:1] isEqualToString:@"#"] ? hexColor : [NSString stringWithFormat:@"#%@", hexColor];
  unsigned int rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexColor];
  [scanner scanHexInt:&rgbValue];
  
  UIColor *color = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                   green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                                    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                                   alpha:alpha];
  
  return color;
}

- (NSString *)colorToHexString
{
  NSString *hexString = nil;
  
  if (self && CGColorGetNumberOfComponents(self.CGColor) == 4) {
    
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r,g,b;
    r = roundf(components[0] * 255.0);
    g = roundf(components[1] * 255.0);
    b = roundf(components[2] * 255.0);
    
    hexString = [NSString stringWithFormat:@"%02X%02X%02X", (int)r, (int)g, (int)b];
  }
  
  return hexString;
}

- (NSString *)colorDomainName
{
  NSString *colorName = nil;
  CGFloat h,s,b,a = 0;
  [self getHue:&h saturation:&s brightness:&b alpha:&a];
  int hue =(int)(h * 360); //hue degerini [0.0 ... 1.0] den [0 360] domaine ayarla.
  s = s * 4.0; //saturation degerini 0 -> 4 arasi scale yap
  b = b * 8.0; //brightness degerini 0 -> 8 arasi scale yap
  //see
/* hue degerlerine gore renklerin tablosu icin http://www.workwithcolor.com/red-color-hue-range-01.htm
  hue scala 0 -> 360
  red            [355,360],[0,10]
  red&Orange     [11, 20]
  orange&brown   [21, 40] (Brown = 30)
  orange&yellow  [41, 50]
  yellow         [51, 60]
  yellow&green   [61, 80]
  green          [81, 140]
  green&cyan     [141,169]
  cyan           [170,200]
  cyan&blue      [201,220]
  blue           [221,240]
  blue&magenta   [241,280]
  magenta        [281,320]
  magenta&pink   [321,330]
  pink           [331,345]
  pink&red       [346,354]
*/

  //saturation / brightness ve hue degerleri arasindaki tablo iliskisi icin: https://en.wikipedia.org/wiki/HSL_and_HSV
  //eger saturation degeri 1/4 den daha kucukse renk gri tonlarinda demektir.
  if (s <= 1.0) {
    //ve eger brigthness degeri 7/8 den buyukse ren beyaz demektir.
    if (b >= 7.0) {
      colorName = @"white";
    } else if (b <=2.0) { // bright degeri 2/8 den kucuk ise renk siyah olmus demektir.
      colorName = @"black";
    } else { // bu saturasyon ve normal brightness degerleri arasinda ise renk gri tonlarinda demektir.
      colorName = @"gray";
    }
    return colorName;
  }
  //eger brightness deger 2/8 den kucuk ise renk siyah demektir.
  if (b <= 2.0) {
    colorName = @"black";
    return colorName;
  }
  //eger saturasyon ve brightness degerleri normal ise hue degerinden renk bulunur.
  switch (hue)
  {
    case 0 ... 10:
    case 355 ... 360:
      colorName = @"red";
      break;
    case 11 ... 20:
      colorName = @"red or orange";
      break;
    case 21 ... 40:
      if (hue >= 29.0 && hue <= 31.0) {
        colorName = @"brown";
      } else {
        colorName = @"orange or brown";
      }
      break;
    case 41 ... 50:
      colorName = @"orange or yellow";
      break;
    case 51 ... 60:
      colorName = @"yellow";
      break;
    case 61 ... 80:
      colorName = @"yellow or green";
      break;
    case 81 ... 140:
      colorName = @"green";
    break;
    case 141 ... 169:
      colorName = @"green or cyan";
    break;
    case 170 ... 200:
      colorName = @"cyan";
    break;
    case 201 ... 220:
      colorName = @"cyan or blue";
      break;
    case 221 ... 240:
      colorName = @"blue";
    break;
    case 241 ... 280:
      colorName = @"blue or magenta";
    break;
    case 281 ... 320:
      colorName = @"magenta";
      break;
    case 321 ... 330:
      colorName = @"magenta or pink";
    break;
    case 331 ... 345:
      colorName = @"pink";
    break;
    case 346 ... 354:
      colorName = @"pink or red";
    break;
    default:
      NSLog(@"unknown hue value %d", hue);
      colorName = nil;
      break;
  }
  return colorName;
}

@end
