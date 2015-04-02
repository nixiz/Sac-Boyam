//
//  OKAppDelegate.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 8/20/13.
//  Copyright (c) 2013 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString * const okStringsTableName = @"localized";
static NSString * const appID = @"id921525192";

#ifdef LITE_VERSION
#import <iAd/iAd.h>
extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;
extern NSString * const BannerViewLoadedSuccessfully;
extern NSString * const BannerViewNotLoaded;

@protocol BannerViewController_Delegate <NSObject>
-(void)updateLayout;
@end

@interface BannerViewManager : NSObject <ADBannerViewDelegate>

@property (nonatomic, readonly) ADBannerView *bannerView;

+ (BannerViewManager *)sharedInstance;

- (void)addBannerViewController:(id<BannerViewController_Delegate>) controller;
- (void)removeBannerViewController:(id<BannerViewController_Delegate>) controller;

@end
#endif

@interface OKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//- (void)showTutorialForViewController:(UIViewController *)controller andPageIndex:(NSInteger)pageNumber;
@end
