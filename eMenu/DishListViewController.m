//
//  DishListViewController.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-13.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "DishListViewController.h"

@interface DishListViewController ()

@end

@implementation DishListViewController

@synthesize page;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dishList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DishCell";
    DishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
    
    UIImage *image = [UIImage imageNamed:@"nopic.png"];
    NSRange range = [dishModel.imageUrl rangeOfString:@"."];
    if (2147483647 != range.location) {
        image = [UIImage imageWithContentsOfFile:dishModel.imageUrl];
        cell.dishImage.userInteractionEnabled = YES;
    }
    
    [cell.dishImage setImage:image];
    [cell.dishImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMedia:)]];
    
    if ([dishModel.isPopular isEqualToString:@"1"]) {
        cell.isPopularImage.image = [UIImage imageNamed:@"recommended_1_2.png"];
    } else {
        cell.isPopularImage.image = [UIImage imageNamed:@""];
    }
    int dishPrice = [dishModel.dishPrice intValue];
    int dishMemberPrice = [dishModel.dishMemberPrice intValue];
    cell.lblDishCode.text = dishModel.dishCode;
    cell.lblDishName.text = dishModel.dishName;
    cell.lblDishPrice.text = [NSString stringWithFormat:@"%d.00", dishPrice];
    cell.lblDishUnit.text = dishModel.unit;
    if (dishMemberPrice > 0) {
        cell.lblMemberPrice.text = dishModel.dishMemberPrice;
        cell.lblMemberUnit.text = dishModel.unit;
        cell.lblMemberCon.text = @"/";
        cell.isMemberImage.image = [UIImage imageNamed:@"coupon.png"];
    }
    
    cell.txtDishDesc.text = dishModel.dishDesc;
    cell.lblDishCount.tag = indexPath.row;
    cell.lblDishCount.text = dishModel.dishCount;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction)plusDish:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
        DishCell *cell = (DishCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        cell.lblDishCount.text = [NSString stringWithFormat:@"%d", [cell.lblDishCount.text intValue] + 1];
        [OrderDish insertOrUpdateOrder:dishModel.dishCode withDishCount:cell.lblDishCount.text withAdd:@"0" withDishTypeId:dishModel.dishTypeId withDishTypeName:dishModel.dishTypeName];
        [self.delegate showMessage:1 withDishTypeId:dishModel.dishTypeId];
    }
}

- (IBAction)minusDish:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
        DishCell *cell = (DishCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.lblDishCount.text intValue] > 0) {
            cell.lblDishCount.text = [NSString stringWithFormat:@"%d", [cell.lblDishCount.text intValue] - 1];
            [OrderDish insertOrUpdateOrder:dishModel.dishCode withDishCount:cell.lblDishCount.text withAdd:@"0" withDishTypeId:dishModel.dishTypeId withDishTypeName:dishModel.dishTypeName];
            [self.delegate showMessage:-1 withDishTypeId:dishModel.dishTypeId];
        }
    }
}

- (void)openMedia:(UITapGestureRecognizer *) gestureRecognizer {
    UIImageView *tableGridImage = (UIImageView*)gestureRecognizer.view;
    CGPoint buttonPosition = [tableGridImage convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
        UIImage *image = [UIImage imageWithContentsOfFile:dishModel.imageUrl];
        [self.delegate showLargeImage:image];
    }
}

@end
