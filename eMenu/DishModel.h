//
//  DishModel.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-7.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DishModel : NSObject {
    NSString *dishCode;
    NSString *dishName;
    NSString *dishDesc;
    NSString *dishPrice;
    NSString *dishMemberPrice;
    NSString *isPopular;
    NSString *unit;
    NSString *imageUrl;
    NSString *dishTypeId;
    NSString *dishTypeName;
    NSString *dishCount;
}

@property (nonatomic, retain) NSString *dishCode;
@property (nonatomic, retain) NSString *dishName;
@property (nonatomic, retain) NSString *dishDesc;
@property (nonatomic, retain) NSString *dishPrice;
@property (nonatomic, retain) NSString *dishMemberPrice;
@property (nonatomic, retain) NSString *isPopular;
@property (nonatomic, retain) NSString *unit;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *dishTypeId;
@property (nonatomic, retain) NSString *dishTypeName;
@property (nonatomic, retain) NSString *dishCount;

- (NSString *) downloadImage:(NSString *) imageUrl;
+ (NSMutableArray *) getAllDish;
+ (NSMutableArray *) getDishByType:(NSString *) dishTypeId;
+ (NSMutableArray *) searchDish:(NSString *) searchData;

@end
