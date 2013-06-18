//
//  DishModel.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-7.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "DishModel.h"

@implementation DishModel

@synthesize dishCode;
@synthesize dishDesc;
@synthesize dishMemberPrice;
@synthesize dishName;
@synthesize dishPrice;
@synthesize dishTypeId;
@synthesize imageUrl;
@synthesize unit;
@synthesize isPopular;
@synthesize dishTypeName;
@synthesize dishCount;

- (NSString *) downloadImage:(NSString *) imageUrlForDownload {
    //NSLog(@"%@", imageUrlForDownload);
    NSString *filePath = @"";
    NSString *stringURL = [WEBSERVICE_ADDRESS stringByAppendingString:imageUrlForDownload];
    NSString *escapedUrlString = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL  *url = [NSURL URLWithString:escapedUrlString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSRange range = [stringURL rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *fileName = [stringURL substringFromIndex:NSMaxRange(range)];

        filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
        [urlData writeToFile:filePath atomically:YES];
    }
    return filePath;
}

+ (NSMutableArray *) searchDish:(NSString *) searchData {
    NSMutableArray *dishList = [[NSMutableArray alloc] init];
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    NSString *actSQL = @"SELECT * FROM DISH;";
    int count = 0;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM DISH WHERE DISHCODE LIKE '%%%%%@%%';", searchData];
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
        actSQL = [NSString stringWithFormat:@"SELECT * FROM DISH WHERE DISHCODE LIKE '%%%%%@%%';", searchData];
    }
    if (count == 0) {
        if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM DISH WHERE DISHNAME LIKE '%%%%%@%%';", searchData];
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
            actSQL = [NSString stringWithFormat:@"SELECT * FROM DISH WHERE DISHNAME LIKE '%%%%%@%%';", searchData];
        }
    }
    
    if (count == 0) {
        actSQL = @"SELECT * FROM DISH;";
    }
    
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = actSQL;
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
                
                [dishList addObject:dishModel];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return dishList;
}

+ (NSMutableArray *) getAllDish {
    NSMutableArray *dishList = [[NSMutableArray alloc] init];
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT d.*, dt.TYPENAME, od.DISHCOUNT FROM DISH d, DISHTYPE dt LEFT JOIN ORDERDISH od ON d.DISHCODE = od.DISHCODE WHERE d.DISHTYPEID = dt.TYPEID;";
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
                // dishTypeName
                NSString *dishTypeNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                dishModel.dishTypeName = dishTypeNameField;
                // dishCount
                char * str = (char*)sqlite3_column_text(statement, 10);
                if (str){
                    NSString *dishCountField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 10)];
                    dishModel.dishCount = dishCountField;
                }
                else{
                    dishModel.dishCount = @"0";
                }
                
                [dishList addObject:dishModel];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return dishList;
}

+ (NSMutableArray *) getDishByType:(NSString *) dishTypeId {
    NSMutableArray *dishList = [[NSMutableArray alloc] init];
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT d.*, dt.TYPENAME, od.DISHCOUNT FROM DISH d, DISHTYPE dt LEFT JOIN ORDERDISH od ON d.DISHCODE = od.DISHCODE WHERE d.DISHTYPEID = dt.TYPEID AND d.DISHTYPEID = \"%@\";", dishTypeId];
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
                // dishTypeName
                NSString *dishTypeNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                dishModel.dishTypeName = dishTypeNameField;
                // dishCount                
                char * str = (char*)sqlite3_column_text(statement, 10);
                if (str){
                    NSString *dishCountField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 10)];
                    dishModel.dishCount = dishCountField;
                }
                else{
                    dishModel.dishCount = @"0";
                }
                
                [dishList addObject:dishModel];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return dishList;
}

@end
