//
//  OrderDish.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-14.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface OrderDish : NSObject {
    NSString *dishCode;
    NSString *dishCount;
    NSString *isAdd;
    NSString *dishTypeId;
    NSString *dishTypeName;
    NSString *totalPrice;
    NSString *totalUnit;
    NSString *orderId;
}

@property (nonatomic, retain) NSString *dishCode;
@property (nonatomic, retain) NSString *dishCount;
@property (nonatomic, retain) NSString *isAdd;
@property (nonatomic, retain) NSString *dishTypeId;
@property (nonatomic, retain) NSString *dishTypeName;
@property (nonatomic, retain) NSString *totalPrice;
@property (nonatomic, retain) NSString *totalUnit;

+ (int) getTotalDishCount;
+ (int) getTotalDishMoney;
+ (int) getDishTypeCount:(NSString *) dishTypeId;
+ (void) insertOrUpdateOrder:(NSString *) dishCode withDishCount:(NSString *) dishCount withAdd:(NSString *) isAdd withDishTypeId:(NSString *) dishTypeId withDishTypeName:(NSString *) dishTypeName;
+ (NSMutableArray *) getOrderDishList;
+ (int) getDishCountByCode:(NSString *) dishCode;
+ (void) deleteOrderDishByCode:(NSString *) dishCode;

+ (NSString *) postOrderData:(NSString *) jsonData;

@end
