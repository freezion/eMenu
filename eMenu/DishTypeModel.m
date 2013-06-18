//
//  DishTypeModel.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-11.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "DishTypeModel.h"

@implementation DishTypeModel

@synthesize typeId;
@synthesize typeName;

+ (NSMutableArray *) getAllDishType {
    NSMutableArray *dishTypeList = [[NSMutableArray alloc] init];
    NSString *databasePath = [SystemUtil getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT * FROM DISHTYPE;";
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(eMenuDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                DishTypeModel *dishTypeModel = [[DishTypeModel alloc] init];
                // typeId
                NSString *typeIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                dishTypeModel.typeId = typeIdField;
                // typeName
                NSString *typeNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                dishTypeModel.typeName = typeNameField;
                [dishTypeList addObject:dishTypeModel];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(eMenuDB);
    }
    return dishTypeList;
}

@end
