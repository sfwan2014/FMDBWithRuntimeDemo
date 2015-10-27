//
//  EKDataManger.m
//  FMDBDemo
//
//  Created by wanshaofa on 15/6/4.
//  Copyright (c) 2015年 enuke. All rights reserved.
//

#import "SFDataManager.h"

@implementation SFDataManager{
    FMDatabase *db;
}

+(SFDataManager *)shareDataManager{
    static SFDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SFDataManager alloc] init];
    });
    
    return instance;
}

-(id)init{
    self = [super init];
    if (self) {
        db = [FMDatabase databaseWithPath:self.filePath];
    }
    return self;
}

-(void)createTableWithSql:(NSString *)sql{
    if ([db open]) {
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
//            NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(BOOL)insertSql:(NSString *)sql{
    if ([db open]) {
        BOOL res = [db executeUpdate:sql];
        
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
//            NSLog(@"success to insert db table");
        }
        [db close];
        return res;
    }
    return NO;
}

-(BOOL)updateSql:(NSString *)sql{
    if ([db open]) {
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error when update db table");
        } else {
//            NSLog(@"success to update db table");
        }
        [db close];
        return res;
    }
    return NO;
}

-(void)deleteSql:(NSString *)sql{
    if ([db open]) {
        BOOL res = [db executeUpdate:sql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
        
    }
}

-(void)querySql:(NSString *)sql finishBlock:(QueryFinishBlock)block{
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql];
        if (block) {
            block(rs);
        }
        [db close];
}}

#pragma mark - getter
-(NSString *)filePath{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"EKuDataBase.sqlite"];
    
    NSLog(@"cachepath: %@", dbPath);
    
    return dbPath;
}


@end
