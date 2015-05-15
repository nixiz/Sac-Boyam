//
//  OKResultsTableViewCell.h
//  Saç Boyam
//
//  Created by Oguzhan Katli on 14/05/15.
//  Copyright (c) 2015 Oguzhan Katli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKResultsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *productDetailLbl;
@property (weak, nonatomic) IBOutlet UIButton *tryButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
//@property (nonatomic, getter=isAddedToFavorites) BOOL favState;
@end
