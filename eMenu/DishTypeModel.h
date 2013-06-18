//
//  DishTypeModel.h
//  eMenu
//
//  Created by Gong Lingxiao on 13-5-11.
//  Copyright (c) 2013年 Gong Lingxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DishTypeModel : NSObject {
    NSString *typeId;
    NSString *typeName;
}

@property (nonatomic, retain) NSString *typeId;
@property (nonatomic, retain) NSString *typeName;

+ (NSMutableArray *) getAllDishType;

@end
