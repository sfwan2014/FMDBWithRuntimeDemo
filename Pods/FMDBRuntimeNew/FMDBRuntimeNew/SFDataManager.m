//
//  EKDataManger.m
//  FMDBDemo
//
//  Created by wanshaofa on 15/6/4.
//  Copyright (c) 2015年 enuke. All rights reserved.
//

#import "SFDataManager.h"

@implementation SFDataManager{
    FMDatabaseQueue *databaseQueue;
}

-(void)dealloc{
    
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
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.filePath];
    }
    return self;
}

-(void)createTableWithSql:(NSString *)sql{
    [databaseQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                //            NSLog(@"success to creating db table");
            }
//            [db close];
        }
    }];
}

-(BOOL)insertSql:(NSString *)sql{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            BOOL res = [db executeUpdate:sql];
            
            if (!res) {
                NSLog(@"error when insert db table");
            } else {
                //            NSLog(@"success to insert db table");
            }
//            [db close];
//            return res;
        }
    }];
    
    return YES;
}

-(BOOL)updateSql:(NSString *)sql{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                NSLog(@"error when update db table");
            } else {
                //            NSLog(@"success to update db table");
            }
//            [db close];
//            return res;
        }
    }];
//    return NO;
}

-(void)deleteSql:(NSString *)sql{
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            BOOL res = [db executeUpdate:sql];
            
            if (!res) {
                NSLog(@"error when delete db table");
            } else {
                NSLog(@"success to delete db table");
            }
//            [db close];
            
        }
    }];
}

-(void)querySql:(NSString *)sql finishBlock:(QueryFinishBlock)block{
    [databaseQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:sql];
            if (block) {
                block(rs);
            }
//            [db close];
        }
    }];
}
// 多线程 执行查询, 插入, 更新接口
-(void)executeQuery:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [databaseQueue inTransaction:block];
}

#pragma mark - getter
-(NSString *)filePath{

    NSString *documentDirectory = [self cachePath];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"dbc.sqlite"];
    
    NSLog(@"cachepath: %@", dbPath);
    
    return dbPath;
}


-(NSString *)cachePath{
    //获取Documents路径
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString*path=[paths objectAtIndex:0];
    NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@", path, @"list_data"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fm fileExistsAtPath:fileDirectory isDirectory:&isDirectory]) {
        NSError *error = nil;
        BOOL res = [fm createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (res == YES) {
            return fileDirectory;
        }
        assert("创建目录失败");
    }
    return fileDirectory;
}

@end
