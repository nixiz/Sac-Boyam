//
//  OKSettingsTutorialVC.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 03/03/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OKTutorialControllerDelegate <NSObject>
@optional
- (BOOL)showExplanationViewBelowForItem:(NSString *)item;
- (CGRect)getImageMaskRectForItem:(NSString *)item;
- (CGRect)getFrameForItem:(NSString *)item;
@end

@interface OKSettingsTutorialVC : UIViewController
@property (weak, nonatomic) id<OKTutorialControllerDelegate> delegate;
@property (nonatomic) BOOL showExplanationBelowView;
@property (nonatomic) NSInteger heightOfExplanationView;
//- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andItemNames:(NSArray *)contentPointsDict;
- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andContentPoints:(NSDictionary *)contentPointsDict;
- (void)initiateTutorialControllerWithBgImg:(UIImage *)image andContentPoints:(NSDictionary *)contentPointsDict WithExplanationDescriptors:(NSDictionary *)explDescriptorDict;
@end
