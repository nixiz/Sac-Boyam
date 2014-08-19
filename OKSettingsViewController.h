//
//  OKSettingsViewController.h
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OKSettingsDelegate <NSObject>

- (void)acceptChangedSetings;

@end

@interface OKSettingsViewController : UIViewController
@property (weak) id<OKSettingsDelegate> delegate;

-(void)setCurrentSettings:(NSDictionary *)settings;
@end
