//
//  SearchDishViewController.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-16.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "SearchDishViewController.h"
#import "DishModel.h"
#import "SearchDishCell.h"
#import "OrderDish.h"
#import "UIImageView+WebCache.h"

@interface SearchDishViewController ()

@end

@implementation SearchDishViewController

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
    self.dishList = [DishModel getAllDish];
    self.txtSearch.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchDish:(id)sender {
    NSString *searchData = self.txtSearch.text;
    if (![@"" isEqualToString:searchData]) {
        self.dishList = [DishModel searchDish:searchData];
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *searchData = self.txtSearch.text;
    if (![@"" isEqualToString:searchData]) {
        self.dishList = [DishModel searchDish:searchData];
        [self.tableView reloadData];
    }
    return YES;
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
    static NSString *CellIdentifier = @"SearchDishCell";
    SearchDishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
    //UIImage *image = [UIImage imageNamed:@"nopic.png"];
    NSRange range = [dishModel.imageUrl rangeOfString:@"."];
    if (2147483647 != range.location) {
        //image = [UIImage imageWithContentsOfFile:dishModel.imageUrl];
        cell.dishImage.userInteractionEnabled = YES;
    }
    
    //[cell.dishImage setImage:image];
    NSString *smallImage = [dishModel.imageUrl stringByAppendingString:@"_s.jpg"];
    [cell.dishImage setImageWithURL:[NSURL fileURLWithPath:smallImage]];
    cell.lblDishCode.text = dishModel.dishCode;
    cell.lblDishName.text = dishModel.dishName;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)close:(id)sender {
    [self.delegate closeSearch];
}

- (IBAction)plusDish:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        DishModel *dishModel = [self.dishList objectAtIndex:indexPath.row];
        int count = [OrderDish getDishCountByCode:dishModel.dishCode];
        [OrderDish insertOrUpdateOrder:dishModel.dishCode withDishCount:[NSString stringWithFormat:@"%d", (count + 1)] withAdd:@"0" withDishTypeId:dishModel.dishTypeId withDishTypeName:dishModel.dishTypeName];
        [self.delegate showMessage:1 withDishTypeId:dishModel.dishTypeId];
    }
}

@end
