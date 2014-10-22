//
//  OKTryOnMeActionVC.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 09/10/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OKTryOnMeActionDelegate <NSObject>

-(void)actionCompletedWithResolution:(CGFloat)res;

@end

@interface OKTryOnMeActionVC : UIViewController
@property (weak, nonatomic) id<OKTryOnMeActionDelegate> delegate;
@property (strong, nonatomic) UIColor *productColor;
@property (strong, nonatomic) UIColor *userColor;
@end
