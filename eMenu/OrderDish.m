//
//  OrderDish.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-14.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "OrderDish.h"
#import "SystemUtil.h"
#import "GDataXMLNode.h"

@implementation OrderDish

@synthesize dishCount;
@synthesize dishCode;
@synthesize isAdd;
@synthesize dishTypeId;
@synthesize dishTypeName;
@synthesize totalPrice;
@synthesize totalUnit;

+ (NSString *) postOrderData:(NSString *) jsonData {
    //NSLog(@"%@", jsonData);
    NSString *webserviceUrl = [WEBSERVICE_ADDRESS stringByAppendingString:@"SyncMenu.asmx/SyncOrderDish"];
    NSURL *url = [NSURL URLWithString:webserviceUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request setPostValue:jsonData forKey:@"Json"];
    [request buildPostBody];
    [request setDelegate:self];
    [request startSynchronous];
    NSString *retStr = @"";
    //NSLog(@"%d",  request.responseStatusCode);
    if(request.responseStatusCode == 200)
    {
        NSError *error;
        NSData *responseData = [request responseData];

        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData options:0 error:&error];
        GDataXMLElement *root = [doc rootElement];
        retStr = [root stringValue];
        //NSLog(@"%@", retStr);
    }    
    return retStr;
}

+ (int) getTotalDishCount {
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    int count = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT SUM(DISHCOUNT) FROM ORDERDISH;";
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                char * str = (char*)sqlite3_column_text(statement, 0);
                if (str){
                    NSString *dishCountField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    count = [dishCountField intValue];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return count;
}

+ (int) getTotalDishMoney {
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    int price = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT SUM(DISHPRICE) FROM ORDERDISH;";
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                char * str = (char*)sqlite3_column_text(statement, 0);
                if (str){
                    NSString *dishCountField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    price = [dishCountField intValue];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return price;
}

+ (void) insertOrUpdateOrder:(NSString *) dishCode withDishCount:(NSString *) dishCount withAdd:(NSString *) isAdd withDishTypeId:(NSString *) dishTypeId withDishTypeName:(NSString *) dishTypeName
{
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    int count = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM ORDERDISH WHERE DISHCODE = \"%@\";", dishCode];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *countField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                 count = [countField intValue];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    
    if (count > 0) {
        if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK) {
            NSString *querySQL = [NSString stringWithFormat:@"UPDATE ORDERDISH SET DISHCOUNT = \"%@\" WHERE DISHCODE = \"%@\";", dishCount, dishCode];
            const char *insert_stmt = [querySQL UTF8String];
            sqlite3_prepare_v2(eMenuDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
            } else {
                NSLog(@"更新失败");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    } else {
        if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK) {
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO ORDERDISH VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", dishCode, dishCount, isAdd, dishTypeId, dishTypeName];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(eMenuDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(eMenuDB);
        }
    }
}

+ (NSMutableArray *) getOrderDishList {
    NSMutableArray *dishList = [[NSMutableArray alloc] init];
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT d.*, od.DISHCOUNT, od.DISHTYPENAME FROM ORDERDISH od, DISH d WHERE od.DISHCODE = d.DISHCODE AND od.DISHCOUNT > 0;";
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                DishModel *dishModel = [[DishModel alloc] init];
                // dishCode
                NSString *dishCodeField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                dishModel.dishCode = dishCodeField;
                // dishName
                NSString *dishNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                dishModel.dishName = dishNameField;
                // dishDesc
                NSString *dishDescField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                dishModel.dishDesc = dishDescField;
                // dishPrice
                NSString *dishPriceField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                dishModel.dishPrice = dishPriceField;
                // dishMemberPrice
                NSString *dishMemberPriceField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                dishModel.dishMemberPrice = dishMemberPriceField;
                // isPopular
                NSString *isPopularField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                dishModel.isPopular = isPopularField;
                // unit
                NSString *unitField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                dishModel.unit = unitField;
                // imageUrl
                NSString *imageUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                dishModel.imageUrl = imageUrlField;
                // dishTypeId
                NSString *dishTypeIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                dishModel.dishTypeId = dishTypeIdField;
                // dishCount
                NSString *dishCountField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                dishModel.dishCount = dishCountField;
                // dishTypeName
                NSString *dishTypeNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 10)];
                dishModel.dishTypeName = dishTypeNameField;
                
                [dishList addObject:dishModel];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return dishList;
}

+ (int) getDishTypeCount:(NSString *) dishTypeId {
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    int count = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT SUM(DISHCOUNT) FROM ORDERDISH WHERE DISHTYPEID = \"%@\";", dishTypeId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                char * str = (char*)sqlite3_column_text(statement, 0);
                if (str){
                    NSString *countField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    count = [countField intValue];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return count;
}

+ (void) deleteOrderDishByCode:(NSString *) dishCode {
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *stmt = nil;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ORDERDISH WHERE DISHCODE = \"%@\";", dishCode] ;
        const char *query = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query, -1, &stmt, NULL) != SQLITE_OK) {
            
        }
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(eMenuDB));
        }
    } else {
        NSLog(@"创建/打开数据库失败");
    }
}

+ (int) getDishCountByCode:(NSString *) dishCode {
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    int count = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT DISHCOUNT FROM ORDERDISH WHERE DISHCODE = \"%@\";", dishCode];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                char * str = (char*)sqlite3_column_text(statement, 0);
                if (str){
                    NSString *countField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    count = [countField intValue];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return count;
}

@end
