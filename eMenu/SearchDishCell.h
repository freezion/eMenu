//
//  SearchDishCell.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-16.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchDishCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *dishImage;
@property (nonatomic, retain) IBOutlet UILabel *lblDishCode;
@property (nonatomic, retain) IBOutlet UILabel *lblDishName;
@property (nonatomic, retain) IBOutlet UIButton *btnPlus;

@end
