//
//  DishListPreViewController.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-9.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OrderDish.h"

@protocol DishListPreViewDelegate <NSObject>
- (void) closeMenu;
- (void) finishOrder;
- (void) clearList;
- (void) showMessage:(int) num withDishTypeId:(NSString *) dishTypeId;
@end

@interface DishListPreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSMutableArray *listOfItems;
}

@property (nonatomic, retain) id<DishListPreViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *lblTotalPrice;
@property (nonatomic, retain) IBOutlet UILabel *lblTotalUnit;
@property (nonatomic, retain) NSMutableArray *listOfItems;
@property (nonatomic, retain) NSMutableArray *listOfItemKey;
@property (nonatomic, retain) NSMutableDictionary *dishListDict;
@property (nonatomic) int totalPrice;
@property (nonatomic) int totalUnit;

- (IBAction)close:(id)sender;

- (IBAction)finishOrderMenu:(id)sender;

- (IBAction)clearOrderMenuList:(id)sender;

- (IBAction)deleteSingleDish:(id)sender;
- (IBAction)plusAction:(id)sender;
- (IBAction)minusAction:(id)sender;

@end
