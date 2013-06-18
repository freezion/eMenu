//
//  SystemUtil.m
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-10.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import "SystemUtil.h"
#import "GDataXMLNode.h"

@implementation SystemUtil

@synthesize inputStream;
@synthesize outputStream;
@synthesize asyncSocket;

- (void) connectServer
{
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError*error = nil;
    if(![asyncSocket connectToHost:HOST_IP onPort:HOST_PORT error:&error]) {
        NSLog(@"is aready connected");
    }
}

- (void) sendNotificatiion {
    [self connectServer];
    NSString *response  = @"1\r\n";
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
	[asyncSocket writeData:data withTimeout:-1 tag:1];
    [asyncSocket readDataWithTimeout:-1 tag:1];
}

- (void) socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(uint16_t)port{
    NSLog(@"connected to the server");
}

- (void) socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err{
    NSLog(@"close connected");
}

+ (void) syncData {
    [self deleteAllDish];
    [self deleteAllDishType];
    [self deleteAllOrderDish];
    [self syncDishData];
    [self syncDishTypeData];
}

+ (void) syncDishData {
    NSString *webserviceUrl = [WEBSERVICE_ADDRESS stringByAppendingString:@"SyncMenu.asmx/SyncDish"];
    NSURL *url = [NSURL URLWithString:webserviceUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request buildPostBody];
    [request setDelegate:self];
    [request startSynchronous];
    
    if(request.responseStatusCode == 200)
    {
        NSData *responseData = [request responseData];
        [self loadDish:responseData];
    }
}

+ (void) loadDish:(NSData *) responseData {
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData options:0 error:&error];
    GDataXMLElement *root = [doc rootElement];
    NSData *data = [[root stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    //NSLog(@"%@", [root stringValue]);
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", error);
    } else {
        for(NSDictionary *item in jsonArray) {
            DishModel *dishModel = [[DishModel alloc] init];
            dishModel.dishCode = [item objectForKey:@"DishCode"];
            dishModel.dishName = [item objectForKey:@"DishName"];
            dishModel.dishDesc = [item objectForKey:@"DishDesc"];
            dishModel.dishMemberPrice = [item objectForKey:@"DishMemberPrice"];
            dishModel.isPopular = [item objectForKey:@"IsPopular"];
            dishModel.unit = [item objectForKey:@"DishUnit"];
            dishModel.dishPrice = [item objectForKey:@"DishPrice"];
            NSString *imageUrl = [item objectForKey:@"ImageUrl"];
            if (imageUrl) {
                imageUrl = [dishModel downloadImage:imageUrl];
                dishModel.imageUrl = imageUrl;
            }
            dishModel.dishTypeId = [item objectForKey:@"DishTypeId"];
            [self insertDish:dishModel];
        }
    }
}

+ (void) syncDishTypeData {
    NSString *webserviceUrl = [WEBSERVICE_ADDRESS stringByAppendingString:@"SyncMenu.asmx/SyncDishType"];
    NSURL *url = [NSURL URLWithString:webserviceUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request buildPostBody];
    [request setDelegate:self];
    [request startSynchronous];
    
    if(request.responseStatusCode == 200)
    {
        NSData *responseData = [request responseData];
        [self loadDishType:responseData];
    }
}

+ (void) loadDishType:(NSData *) responseData {
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData options:0 error:&error];
    GDataXMLElement *root = [doc rootElement];
    NSData *data = [[root stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    //NSLog(@"%@", [root stringValue]);
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", error);
    } else {
        for(NSDictionary *item in jsonArray) {
            DishTypeModel *dishTypeModel = [[DishTypeModel alloc] init];
            dishTypeModel.typeId = [item objectForKey:@"DishTypeId"];
            dishTypeModel.typeName = [item objectForKey:@"DishTypeName"];
            [self insertDishType:dishTypeModel];
        }
    }
}

+ (NSString *)getDBPath {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"eMenu.db"]];
    return databasePath;
}

+ (void)insertDish:(DishModel *) dishModel
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK) {
        NSString *dishCode = dishModel.dishCode;
        NSString *dishName = dishModel.dishName;
        NSString *dishDesc = dishModel.dishDesc;
        NSString *dishPrice = dishModel.dishPrice;
        NSString *dishMemberPrice = dishModel.dishMemberPrice;
        NSString *isPopular = dishModel.isPopular;
        NSString *unit = dishModel.unit;
        NSString *imageUrl = dishModel.imageUrl;
        NSString *dishTypeId = dishModel.dishTypeId;
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO DISH VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", dishCode, dishName, dishDesc, dishPrice, dishMemberPrice, isPopular, unit, imageUrl, dishTypeId];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(eMenuDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(eMenuDB);
    }
}

+ (void)insertDishType:(DishTypeModel *) dishTypeModel
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK) {
        NSString *typeId = dishTypeModel.typeId;
        NSString *typeName = dishTypeModel.typeName;
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO DISHTYPE VALUES(\"%@\",\"%@\")", typeId, typeName];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(eMenuDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(eMenuDB);
    }
}

+ (void) createDishTable {
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS DISH(DISHCODE VARCHAR(50) PRIMARY KEY, DISHNAME TEXT, DISHDESC TEXT, DISHPRICE TEXT, DISHMEMBERPRICE TEXT, ISPOPULAR VARCHAR(10), DISHUNIT VARCHAR(20), IMAGEURL TEXT, DISHTYPEID VARCHAR(50));";
        if (sqlite3_exec(eMenuDB, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"create failed!\n");
        }
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
}

+ (void) createDishTypeTable {
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS DISHTYPE(TYPEID VARCHAR(50) PRIMARY KEY, TYPENAME TEXT);";
        if (sqlite3_exec(eMenuDB, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"create failed!\n");
        }
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
}

+ (void) createOrderDishTable {
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS ORDERDISH(DISHCODE VARCHAR(50) PRIMARY KEY, DISHCOUNT VARCHAR(50), ISADD VARCHAR(10), DISHTYPEID VARCHAR(50), DISHTYPENAME TEXT);";
        if (sqlite3_exec(eMenuDB, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"create failed!\n");
        }
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
}

+ (void) createOrderInfoTable {
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &eMenuDB)==SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS ORDERINFO(ORDERCODE VARCHAR(50) PRIMARY KEY;";
        if (sqlite3_exec(eMenuDB, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"create failed!\n");
        }
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
}

+ (void)deleteOrderInfo
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *stmt = nil;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"DELETE FROM ORDERINFO;";
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

+ (void)deleteAllDish
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *stmt = nil;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"DELETE FROM DISH;";
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

+ (void)deleteAllDishType
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *stmt = nil;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"DELETE FROM DISHTYPE;";
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

+ (void)deleteAllOrderDish
{
    NSString *databasePath = [self getDBPath];
    sqlite3 *eMenuDB;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *stmt = nil;
    if (sqlite3_open(dbpath, &eMenuDB) == SQLITE_OK)
    {
        NSString *querySQL = @"DELETE FROM ORDERDISH;";
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

@end
