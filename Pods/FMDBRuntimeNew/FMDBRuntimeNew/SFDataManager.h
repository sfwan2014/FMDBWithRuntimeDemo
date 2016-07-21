//
//  EKDataManger.h
//  FMDBDemo
//
//  Created by wanshaofa on 15/6/4.
//  Copyright (c) 2015年 enuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void (^QueryFinishBlock) (FMResultSet *set);

@interface SFDataManager : NSObject

@property (nonatomic, copy) QueryFinishBlock block;
-(NSString *)filePath;
+(SFDataManager *)shareDataManager;
-(void)createTableWithSql:(NSString *)sql;
-(BOOL)insertSql:(NSString *)sql;
-(void)querySql:(NSString *)sql finishBlock:(QueryFinishBlock)block;
-(void)executeQuery:(void (^)(FMDatabase *db, BOOL *rollback))block;
-(void)deleteSql:(NSString *)sql;
-(BOOL)updateSql:(NSString *)sql;
@end
