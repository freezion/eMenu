//
//  SearchDishViewController.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-16.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchDishDelegate <NSObject>
- (void) closeSearch;
- (void) showMessage:(int) num withDishTypeId:(NSString *) dishTypeId;
@end

@interface SearchDishViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *btnSearch;
@property (nonatomic, retain) IBOutlet UITextField *txtSearch;
@property (nonatomic, retain) id<SearchDishDelegate> delegate;

@property (nonatomic, retain) NSArray *dishList;

- (IBAction)searchDish:(id)sender;
- (IBAction)close:(id)sender;

@end
