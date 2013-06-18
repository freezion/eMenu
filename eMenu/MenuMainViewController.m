//
//  MenuMainViewController.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-7.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "MenuMainViewController.h"
#import "VerticalScrollTabBarView.h"
#import "MultiTabControl.h"
#import "LSTabItem.h"
#import "Reachability.h"
#import "UIView+Addictions.h"

@interface MenuMainViewController (){
    VerticalScrollTabBarView *tabView;
}

@end

@implementation MenuMainViewController

@synthesize controlPanelView;
@synthesize pageTotalNum;
@synthesize messageDishNum;
@synthesize isAddDishFlag;
@synthesize HUD;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.storyborad = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.tableNo = @"";
    self.controlPanelView.image = [UIImage imageNamed:@"default_imgBottomCover"];
    NSArray *dishList = [DishModel getAllDish];
    int count = [dishList count];
    if (count > 0) {
        [self initPage];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无菜品数据，请先同步数据" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void) initPage {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = @"初始化";
	
	[HUD show:YES];
    self.selectTabNow = 999;
    messageDishNum = [OrderDish getTotalDishCount];
    if (messageDishNum > 0) {
        self.orderDishCountImage.image = [UIImage imageNamed:@"DetailTag_1_3.png"];
        self.orderDishCount.text = [NSString stringWithFormat:@"%d", messageDishNum];
    } else {
        self.orderDishCountImage.image = [UIImage imageNamed:@""];
        self.orderDishCount.text = @"";
    }
    
    self.dishTypeList = [NSArray arrayWithArray:[DishTypeModel getAllDishType]];
    self.tabItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.dishTypeList count]; i ++) {
        DishTypeModel *dishTypeModel = [self.dishTypeList objectAtIndex:i];
        LSTabItem *tabItem = [[LSTabItem alloc] initWithTitle:dishTypeModel.typeName];
        tabItem.object = dishTypeModel.typeId;
        tabItem.badgeNumber = [OrderDish getDishTypeCount:dishTypeModel.typeId];
        [self.tabItems addObject:tabItem];
    }
    
    tabView = [[VerticalScrollTabBarView alloc] initWithItems:self.tabItems delegate:self];
    tabView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    tabView.itemPadding = -50.0f;
    tabView.margin = 0.0f;
    tabView.frame = CGRectMake(self.view.viewWidth - 76.0f, 8.0f, 76.0f, self.view.bounds.size.height);
    [tabView setSelectedTabIndex:0];
    [self.view addSubview:tabView];
    
    self.lblMenuType.font = [UIFont fontWithName:@"MicrosoftYaHei" size:25];
    self.lblMenuType.text = ((LSTabItem *)self.tabItems[0]).title;
    
    [self.view addSubview:self.controlPanelView];
    [self.view addSubview:tabView];
    
    // 检索菜品数据
    NSString *typeId = ((DishTypeModel *)[self.dishTypeList objectAtIndex:0]).typeId;
    self.dishList = [NSArray arrayWithArray:[DishModel getDishByType:typeId]];
    
    NSUInteger numberPages = [self getTotalPage:self.dishList];
    //self.orderDishList = [[NSMutableArray alloc] init];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    NSArray *viewsToRemove = [self.scrollView subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];

    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    [HUD hide:YES];
}

- (IBAction)syncData:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"同步数据将花费一定时间，请确保设备处于网络良好状态" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始", nil];
    alertView.tag = 1;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 4) {
            [self closeMenu];
            self.finishOrderRetKey = @"";
        }
    } else {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:HUD];
        [self.view bringSubviewToFront:HUD];
        HUD.dimBackground = YES;
        HUD.delegate = self;
        //[HUD show:YES];
        if (alertView.tag == 1) {
            Reachability *r = [Reachability reachabilityWithHostName:WEBSERVICE_ADDRESS];
            //NSLog(@"%d", [r currentReachabilityStatus]);
            if ([r currentReachabilityStatus] != NotReachable) {
            //if ([r currentReachabilityStatus] == ) {
                HUD.labelText = @"连接中";
                HUD.minSize = CGSizeMake(135.f, 135.f);
                [HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接网络" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        } else if (alertView.tag == 2) {
            self.tableNo = self.txtTableNo.text;
            if ([self.tableNo isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未输入桌号" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                alert.tag = 3;
                [alert show];
            } else {
                [self goWebService];
            }
        }
    }
}

- (void) goWebService {
    NSError *error;
    NSMutableArray *arrayOfDicts = [[NSMutableArray alloc] init];
    NSArray *array = [OrderDish getOrderDishList];
    for (OrderDish *orderDish in array) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              orderDish.dishCode, @"dishCode",
                              orderDish.dishCount, @"dishCount",
                              nil];
        [arrayOfDicts addObject:dict];
    }
    NSArray *info = [NSArray arrayWithArray:arrayOfDicts];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.tableNo, @"tableNo",
                                    info, @"dishList",
                                    nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    self.finishOrderRetKey = [OrderDish postOrderData:jsonString];
    //NSLog(@"retkey ==== %@", self.finishOrderRetKey);
    SystemUtil *systemUtil = [[SystemUtil alloc] init];
    [systemUtil sendNotificatiion];
    
    if ([self.finishOrderRetKey isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未知错误，或网络状况不佳" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下单成功" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        alert.tag = 4;
        [alert show];
    }
}

- (void) myProgressTask {
    sleep(2);
	// Switch to determinate mode
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"获取数据";
    
	float progress = 0.0f;
	while (progress < 1.0f)
	{
		progress += 0.01f;
		HUD.progress = progress;
		usleep(20000);
	}
    
	// Back to indeterminate mode
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"导入数据";
	[SystemUtil syncData];
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"完成";
	sleep(1);
    [self performSelectorOnMainThread:@selector(initPage) withObject:nil waitUntilDone:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSMutableArray *) listForPage:(int) pageNum {
    NSMutableArray *pageList = [[NSMutableArray alloc] init];
    int start = pageNum * PAGE_ITEM;
    int end = (pageNum + 1) * PAGE_ITEM;
    for (int i = start; i < end; i ++) {
        if (i <= ([self.dishList count] - 1))
            [pageList addObject:[self.dishList objectAtIndex:i]];
    }
    return pageList;
}

- (NSUInteger) getTotalPage:(NSArray *) listData {
    NSUInteger numberPages = listData.count;
    NSUInteger retNum = 0;

    float fltNum = numberPages / 3.0;
    int intNum = numberPages / 3.0;
    if (fltNum > intNum) {
        retNum = intNum + 1;
    } else {
        retNum = intNum;
    }
    self.pageTotalNum = retNum;
    return retNum;
}


#pragma mark -
#pragma mark LSTabBarViewDelegate Methods

- (LSTabControl *)tabBar:(LSTabBarView *)tabBar
          tabViewForItem:(LSTabItem *)item
                 atIndex:(NSInteger)index
{
    return [[MultiTabControl alloc] initWithItem:item];
}


- (void)tabBar:(LSTabBarView *)tabBar
   tabSelected:(LSTabItem *)item
       atIndex:(NSInteger)selectedIndex
{
    
    if (self.selectTabNow != selectedIndex) {
        SystemSoundID soundID;
        self.lblMenuType.font = [UIFont fontWithName:@"MicrosoftYaHei" size:25];
        self.lblMenuType.text = ((LSTabItem *)self.tabItems[selectedIndex]).title;
        if (self.selectTabNow != 999) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"pop" ofType:@"wav" inDirectory:@"/"]]
                                             , &soundID);
            AudioServicesPlaySystemSound (soundID);
        }
        
        // 检索菜品数据
        NSString *typeId = ((DishTypeModel *)[self.dishTypeList objectAtIndex:selectedIndex]).typeId;
        self.dishList = [NSArray arrayWithArray:[DishModel getDishByType:typeId]];
        NSUInteger numberPages = [self getTotalPage:self.dishList];
        //self.orderDishList = [[NSMutableArray alloc] init];
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < numberPages; i++)
        {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;
        
        
        NSArray *viewsToRemove = [self.scrollView subviews];
        for (UIView *v in viewsToRemove) [v removeFromSuperview];
        
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        
        self.scrollView.delegate = self;
        [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
        
        self.pageControl.numberOfPages = numberPages;
        self.pageControl.currentPage = 0;
        
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        //[HUD hide:YES afterDelay:0];
        self.selectTabNow = selectedIndex;
    } 
}

- (void) selectReloadUI {
    
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= pageTotalNum)
        return;
    
    // replace the placeholder if necessary
    
    DishListViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        DishListViewController *dishListViewController = [self.storyborad instantiateViewControllerWithIdentifier:@"DishListViewController"];
        dishListViewController.page = page;
        controller = dishListViewController;
        controller.delegate = self;
        controller.dishList = [self listForPage:page];
        
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }

    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    self.currentPage = page;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // remove all the subviews from our scrollview
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.dishList.count;
    
    // adjust the contentSize (larger or smaller) depending on the orientation
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
    
    // clear out and reload our pages
    self.viewControllers = nil;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    [self loadScrollViewWithPage:self.pageControl.currentPage - 1];
    [self loadScrollViewWithPage:self.pageControl.currentPage];
    [self loadScrollViewWithPage:self.pageControl.currentPage + 1];
    [self gotoPage:NO]; // remain at the same page (don't animate)
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];
}

- (void) showMessage:(int) num withDishTypeId:(NSString *) dishTypeId {
    messageDishNum = messageDishNum + num;
    if (messageDishNum > 0) {
        self.orderDishCountImage.image = [UIImage imageNamed:@"DetailTag_1_3.png"];
        self.orderDishCount.text = [NSString stringWithFormat:@"%d", messageDishNum];
    } else {
        self.orderDishCountImage.image = [UIImage imageNamed:@""];
        self.orderDishCount.text = @"";
    }

    int index = 0;
    for (LSTabItem *item in self.tabItems) {
        if ([item.object isEqual:dishTypeId]) {
            item.badgeNumber = item.badgeNumber + num;
            break;
        }
        index ++;
    }
    [tabView removeFromSuperview];
    tabView = [[VerticalScrollTabBarView alloc] initWithItems:self.tabItems delegate:self];
    tabView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    tabView.itemPadding = -50.0f;
    tabView.margin = 0.0f;
    tabView.frame = CGRectMake(self.view.viewWidth - 76.0f, 8.0f, 76.0f, self.view.bounds.size.height);
    [tabView setSelectedTabIndex:index];
    [self.view addSubview:tabView];

}

- (IBAction)showDishPreListPopView:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.2;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    
    DishListPreViewController *controller = [self.storyborad instantiateViewControllerWithIdentifier:@"DishListPreViewController"];
    controller.view.frame = CGRectMake(370.0f, 46.0f, 330.0f, 773.0f);
    controller.delegate = self;
    self.dishListPreViewController = controller;
    [self.view addSubview:self.dishListPreViewController.view];
    
    [[self.dishListPreViewController.view layer] addAnimation:animation forKey:@"animation"];

}

- (IBAction)showSearchPopView:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.2;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    
    SearchDishViewController *controller = [self.storyborad instantiateViewControllerWithIdentifier:@"SearchDishViewController"];
    controller.view.frame = CGRectMake(70.0f, 46.0f, 393.0f, 700.0f);
    controller.delegate = self;
    self.searchDishViewController = controller;
    [self.view addSubview:self.searchDishViewController.view];
    
    [[self.searchDishViewController.view layer] addAnimation:animation forKey:@"animation"];
}

- (void) closeMenu {
    CGRect napkinTopFrame = self.dishListPreViewController.view.frame;
    napkinTopFrame.origin.y = napkinTopFrame.origin.y - 773;
    [UIView animateWithDuration:0.7
                          delay:0
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.dishListPreViewController.view.frame = napkinTopFrame;
                         self.dishListPreViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.dishListPreViewController.view removeFromSuperview];
                     }];

    // 检索菜品数据
    NSString *typeId = ((DishTypeModel *)[self.dishTypeList objectAtIndex:self.selectTabNow]).typeId;
    self.dishList = [NSArray arrayWithArray:[DishModel getDishByType:typeId]];
    NSUInteger numberPages = [self getTotalPage:self.dishList];
    //self.orderDishList = [[NSMutableArray alloc] init];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    
    NSArray *viewsToRemove = [self.scrollView subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
    
    self.pageControl.numberOfPages = numberPages;
    //NSLog(@"%d", self.currentPage);
    self.pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    //[HUD hide:YES afterDelay:0];
    //self.selectTabNow = selectedIndex;
}

- (void) closeSearch {
    CGRect napkinTopFrame = self.searchDishViewController.view.frame;
    napkinTopFrame.origin.y = napkinTopFrame.origin.y - 700;
    [UIView animateWithDuration:0.7
                          delay:0
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.searchDishViewController.view.frame = napkinTopFrame;
                         self.searchDishViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.searchDishViewController.view removeFromSuperview];
                     }];
    
}

- (void) finishOrder {
    self.txtTableNo = [[UITextField alloc] init];
    NSArray *array = [OrderDish getOrderDishList];
    if (array.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未有点菜" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入桌号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"完成", nil];
        alert.tag = 2;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        self.txtTableNo = [alert textFieldAtIndex:0];
        self.txtTableNo.placeholder = @"输入桌号";
        self.txtTableNo.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [alert show];
    }
}

- (void) clearList {
    self.orderDishCountImage.image = [UIImage imageNamed:@""];
    self.orderDishCount.text = @"";
    messageDishNum = 0;
    for (LSTabItem *item in self.tabItems) {
        item.badgeNumber = 0;
    }
    [tabView removeFromSuperview];
    tabView = [[VerticalScrollTabBarView alloc] initWithItems:self.tabItems delegate:self];
    tabView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
    tabView.itemPadding = -50.0f;
    tabView.margin = 0.0f;
    tabView.frame = CGRectMake(self.view.viewWidth - 76.0f, 8.0f, 76.0f, self.view.bounds.size.height);
    [tabView setSelectedTabIndex:0];
    [self.view addSubview:tabView];
    [SystemUtil deleteAllOrderDish];
    
    // 检索菜品数据
    NSString *typeId = ((DishTypeModel *)[self.dishTypeList objectAtIndex:0]).typeId;
    self.dishList = [NSArray arrayWithArray:[DishModel getDishByType:typeId]];
    
    NSUInteger numberPages = [self getTotalPage:self.dishList];
    //self.orderDishList = [[NSMutableArray alloc] init];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;

    
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }

    
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void) showLargeImage:(UIImage *) image {
    UIView *darkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    darkView.alpha = 0.7;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDarkView:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, image.size.width - 100, image.size.height)];
    [imageView setCenter:darkView.center];
    imageView.tag = 10;
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view addSubview:imageView];
    [UIView commitAnimations];
}

- (void)dismissDarkView:(UITapGestureRecognizer *) gestureRecognizer {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

@end
