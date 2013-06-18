//
//  DishListCell.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-10.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DishListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *dishCode;
@property (nonatomic, retain) IBOutlet UILabel *dishName;
@property (nonatomic, retain) IBOutlet UILabel *dishPrice;
@property (nonatomic, retain) IBOutlet UILabel *dishCount;
@property (nonatomic, retain) IBOutlet UILabel *dishUnit;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *btnPlus;
@property (nonatomic, retain) IBOutlet UIButton *btnMinus;

@end
