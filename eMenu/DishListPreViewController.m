//
//  DishListPreViewController.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-9.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "DishListPreViewController.h"
#import "DishListCell.h"

@interface DishListPreViewController ()

@end

@implementation DishListPreViewController

@synthesize listOfItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    listOfItems = [[NSMutableArray alloc] init];
    self.listOfItemKey = [[NSMutableArray alloc] init];
    self.dishListDict = [[NSMutableDictionary alloc] init];
    self.totalUnit = 0;
    self.totalPrice = 0;
    NSArray *orderList = [OrderDish getOrderDishList];
    BOOL flag = FALSE;
    for (DishModel *dishModel in orderList) {
        int dishPrice = [dishModel.dishPrice intValue];
        int dishCount = [dishModel.dishCount intValue];
        int dishMemberPrice = [dishModel.dishMemberPrice intValue];
        if (dishMemberPrice > 0) {
            self.totalPrice = dishMemberPrice * dishCount + self.totalPrice;
        } else {
            self.totalPrice = dishPrice * dishCount + self.totalPrice;
        }
        self.totalUnit = dishCount + self.totalUnit;
        
        NSString *dishTypeName = dishModel.dishTypeName;
        for (NSString *key in self.dishListDict) {
            if ([key isEqualToString:dishTypeName]) {
                flag = TRUE;
                break;
            }
        }
        
        if (flag) {
            NSMutableArray *array = [self.dishListDict objectForKey:dishTypeName];
            [array addObject:dishModel];
        } else {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:dishModel];
            [self.dishListDict setObject:array forKey:dishTypeName];
        }
        flag = FALSE;
    }
    self.lblTotalPrice.textColor = [UIColor redColor];
    self.lblTotalPrice.text = [NSString stringWithFormat:@"%d.00", self.totalPrice];
    self.lblTotalUnit.text = [NSString stringWithFormat:@"%d", self.totalUnit];
    for (NSString *key in self.dishListDict) {
        [self.listOfItemKey addObject:key];
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)close:(id)sender {
    [self.delegate closeMenu];
}

- (IBAction)finishOrderMenu:(id)sender {
    [self.delegate finishOrder];
}

- (IBAction)clearOrderMenuList:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清空" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 1;
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    } else {
        listOfItems = [[NSMutableArray alloc] init];
        self.listOfItemKey = [[NSMutableArray alloc] init];
        self.dishListDict = [[NSMutableDictionary alloc] init];
        self.totalPrice = 0;
        self.totalUnit = 0;
        [self.tableView reloadData];
        self.lblTotalUnit.text = @"0";
        self.lblTotalPrice.text = @"0.00";
        [self.delegate clearList];
    }
}

- (IBAction)plusAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSArray *arrayForCurrentSection = [self.dishListDict objectForKey:[self.listOfItemKey objectAtIndex:indexPath.section]];
        DishModel *dishModel = [arrayForCurrentSection objectAtIndex:indexPath.row];
        DishListCell *cell = (DishListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int dishCount = [cell.dishCount.text intValue] + 1;
        int dishPrice = [cell.dishPrice.text intValue];
        int money = [self.lblTotalPrice.text intValue] + 1 * dishPrice;
        cell.dishCount.text = [NSString stringWithFormat:@"%d", dishCount];
        self.lblTotalUnit.text = [NSString stringWithFormat:@"%d", [self.lblTotalUnit.text intValue] + 1];
        self.lblTotalPrice.text = [NSString stringWithFormat:@"%d.00", money];
        [OrderDish insertOrUpdateOrder:dishModel.dishCode withDishCount:cell.dishCount.text withAdd:@"0" withDishTypeId:dishModel.dishTypeId withDishTypeName:dishModel.dishTypeName];
        [self.delegate showMessage:1 withDishTypeId:dishModel.dishTypeId];
    }
}

- (IBAction)minusAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSArray *arrayForCurrentSection = [self.dishListDict objectForKey:[self.listOfItemKey objectAtIndex:indexPath.section]];
        DishModel *dishModel = [arrayForCurrentSection objectAtIndex:indexPath.row];
        DishListCell *cell = (DishListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int dishCount = [cell.dishCount.text intValue] - 1;
        if (dishCount > 0) {
            int dishPrice = [cell.dishPrice.text intValue];
            int money = [self.lblTotalPrice.text intValue] - 1 * dishPrice;
            cell.dishCount.text = [NSString stringWithFormat:@"%d", dishCount];
            self.lblTotalUnit.text = [NSString stringWithFormat:@"%d", [self.lblTotalUnit.text intValue] - 1];
            self.lblTotalPrice.text = [NSString stringWithFormat:@"%d.00", money];
            [OrderDish insertOrUpdateOrder:dishModel.dishCode withDishCount:cell.dishCount.text withAdd:@"0" withDishTypeId:dishModel.dishTypeId withDishTypeName:dishModel.dishTypeName];
            [self.delegate showMessage:-1 withDishTypeId:dishModel.dishTypeId];
        }
    }
}

- (IBAction) deleteSingleDish:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSArray *arrayForCurrentSection = [self.dishListDict objectForKey:[self.listOfItemKey objectAtIndex:indexPath.section]];
        DishModel *dishModel = [arrayForCurrentSection objectAtIndex:indexPath.row];
        DishListCell *cell = (DishListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int count = [cell.dishCount.text intValue];
        [OrderDish deleteOrderDishByCode:dishModel.dishCode];
        [self.delegate showMessage:(-1 * count) withDishTypeId:dishModel.dishTypeId];
        
        listOfItems = [[NSMutableArray alloc] init];
        self.listOfItemKey = [[NSMutableArray alloc] init];
        self.dishListDict = [[NSMutableDictionary alloc] init];
        self.totalPrice = 0;
        self.totalUnit = 0;
        
        int price = [dishModel.dishPrice intValue];
        int memberPrice = [dishModel.dishMemberPrice intValue];
        int unit = [cell.dishCount.text intValue];
        int nowPrice = [self.lblTotalPrice.text intValue];
        int nowUnit = [self.lblTotalUnit.text intValue];
        if (memberPrice > 0) {
            self.lblTotalPrice.text = [NSString stringWithFormat:@"%d.00", (nowPrice - memberPrice * unit)];
        } else {
            self.lblTotalPrice.text = [NSString stringWithFormat:@"%d.00", (nowPrice - price * unit)];
        }
        self.lblTotalUnit.text = [NSString stringWithFormat:@"%d", (nowUnit - unit)];
        NSArray *orderList = [OrderDish getOrderDishList];
        
        BOOL flag = false;
        for (DishModel *dishModel in orderList) {
            NSString *dishTypeName = dishModel.dishTypeName;
            for (NSString *key in self.dishListDict) {
                if ([key isEqualToString:dishTypeName]) {
                    flag = TRUE;
                    break;
                }
            }
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if (flag) {
                array = [self.dishListDict objectForKey:dishTypeName];
                [array addObject:dishModel];
            } else {
                [array addObject:dishModel];
                [self.dishListDict setObject:array forKey:dishTypeName];
            }
        }
        
        for (NSString *key in self.dishListDict) {
            [self.listOfItemKey addObject:key];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.listOfItemKey count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dishListDict objectForKey:[self.listOfItemKey objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.listOfItemKey objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DishListCell";
	DishListCell *cell = (DishListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *arrayForCurrentSection = [self.dishListDict objectForKey:[self.listOfItemKey objectAtIndex:indexPath.section]];
    DishModel *dishModel = [arrayForCurrentSection objectAtIndex:indexPath.row];
    int dishPrice = [dishModel.dishPrice intValue];
    int dishMemberPrice = [dishModel.dishMemberPrice intValue];
    cell.dishName.text = dishModel.dishName;
    if (dishMemberPrice > 0) {
        cell.dishPrice.text = [NSString stringWithFormat:@"%d.00", dishMemberPrice];
    } else {
        cell.dishPrice.text = [NSString stringWithFormat:@"%d.00", dishPrice];
    }
    
    cell.dishUnit.text = dishModel.unit;
    cell.dishCount.text = dishModel.dishCount;
    cell.dishCode.text = dishModel.dishCode;
    
    cell.backgroundColor = [UIColor clearColor];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
