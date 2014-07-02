//
//  OKZoomView.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 02/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKZoomView : UIView
- (id)initWithFrame:(CGRect)frame andStartPoint:(CGPoint)point;
- (id)initWithFrame:(CGRect)frame andStartPoint:(CGPoint)point PreviewImage:(UIImage *)previewImage;

@property CGPoint newPoint;
@property (strong) UIImage *previewImage;
@property (strong, nonatomic) UIImageView *imageView;
@end
