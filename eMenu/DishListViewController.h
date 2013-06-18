//
//  DishListViewController.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-13.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishModel.h"
#import "DishCell.h"
#import "OrderDish.h"

@protocol DishListViewDelegate <NSObject>
- (void) showMessage:(int) num withDishTypeId:(NSString *) dishTypeId;

- (void) showLargeImage:(UIImage *) image;
@end

@interface DishListViewController : UITableViewController {
    NSUInteger page;
}

@property (nonatomic) NSUInteger page;
@property (nonatomic) bool clearFlag;
@property (nonatomic, retain) id<DishListViewDelegate> delegate;
@property (nonatomic, retain) NSArray *dishList;

- (IBAction)plusDish:(id)sender;
- (IBAction)minusDish:(id)sender;

@end
