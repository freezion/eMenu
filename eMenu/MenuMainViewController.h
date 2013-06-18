//
//  MenuMainViewController.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-7.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LSTabBarView.h"
#import "DishListViewController.h"
#import "DishListPreViewController.h"
#import "DishModel.h"
#import "MBProgressHUD.h"
#import "SearchDishViewController.h"

@interface MenuMainViewController : UIViewController <LSTabBarViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate, DishListPreViewDelegate, DishListViewDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, SearchDishDelegate> {
    int pageTotalNum;
    int messageDishNum;
    MBProgressHUD *HUD;
    BOOL isAddDishFlag;
}

@property (nonatomic, retain) IBOutlet UIImageView *controlPanelView;
@property (nonatomic, retain) IBOutlet UILabel *lblMenuType;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIImageView *orderDishCountImage;
@property (nonatomic, retain) IBOutlet UILabel *orderDishCount;
@property (nonatomic, retain) NSString *tableNo;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) UITextField *txtTableNo;
@property (nonatomic, retain) UIStoryboard *storyborad;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, retain) NSMutableArray *tabItems;
@property (nonatomic, retain) NSArray *dishList;
@property (nonatomic, retain) NSArray *dishTypeList;
@property (nonatomic) int selectTabNow;
@property (nonatomic) int currentPage;
@property (nonatomic) int pageTotalNum;
@property (nonatomic) int messageDishNum;
@property (nonatomic, retain) NSString *finishOrderRetKey;
@property (nonatomic, retain) DishListPreViewController *dishListPreViewController;
@property (nonatomic, retain) SearchDishViewController *searchDishViewController;
@property (nonatomic) BOOL isAddDishFlag;

- (IBAction)showDishPreListPopView:(id)sender;
- (IBAction)showSearchPopView:(id)sender;
- (IBAction)syncData:(id)sender;

@end
