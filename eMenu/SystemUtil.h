//
//  SystemUtil.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-10.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DishModel.h"
#import "GCDAsyncSocket.h"
#import "DishModel.h"
#import "DishTypeModel.h"

@interface SystemUtil : NSObject {
    NSInputStream	*inputStream;
	NSOutputStream	*outputStream;
    GCDAsyncSocket *asyncSocket;
}

@property (nonatomic, retain) GCDAsyncSocket *asyncSocket;
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

- (void) sendNotificatiion;
+ (void) createDishTable;
+ (void) createDishTypeTable;
+ (void) createOrderDishTable;
+ (void) createOrderInfoTable;
+ (void) syncData;
+ (void)deleteAllDish;
+ (void)deleteAllDishType;
+ (void)deleteAllOrderDish;
+ (void)deleteOrderInfo;
+ (NSString *)getDBPath;

@end
