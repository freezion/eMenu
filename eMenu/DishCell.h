//
//  DishCell.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-13.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DishCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *dishImage;
@property (nonatomic, weak) IBOutlet UIImageView *isPopularImage;
@property (nonatomic, weak) IBOutlet UIImageView *isMemberImage;
@property (nonatomic, retain) IBOutlet UIButton *btnPlus;
@property (nonatomic, retain) IBOutlet UIButton *btnMinus;
@property (nonatomic, retain) IBOutlet UILabel *lblDishCode;
@property (nonatomic, retain) IBOutlet UILabel *lblDishName;
@property (nonatomic, retain) IBOutlet UITextView *txtDishDesc;
@property (nonatomic, retain) IBOutlet UILabel *lblDishPrice;
@property (nonatomic, retain) IBOutlet UILabel *lblDishUnit;
@property (nonatomic, retain) IBOutlet UILabel *lblMemberPrice;
@property (nonatomic, retain) IBOutlet UILabel *lblMemberUnit;
@property (nonatomic, retain) IBOutlet UILabel *lblMemberCon;
@property (nonatomic, retain) IBOutlet UILabel *lblDishCount;

@end
