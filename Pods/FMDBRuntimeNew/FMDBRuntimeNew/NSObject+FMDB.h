//
//  NSObject+FMDB.h
//  FMDB_RuntimeDemo
//
//  Created by 万绍发 on 15/10/27.
//  Copyright © 2015年 sfwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QueryListFinishBlock) (NSArray *list);

@interface NSObject (JSON)
- (id)initContentWithDic:(NSDictionary *)jsonDic;
- (void)setAttributes:(NSDictionary *)jsonDic;
- (NSDictionary *)attributeMapDictionary:(NSDictionary *)jsonDic;
@end

@interface NSObject (FMDB)

/**
 * database
 */

// 表名
+(NSString *)tableName;
// 主键
+(NSString *)primaryKey;


#pragma mark - update
/*
 * 创建表
 * primaryKeys 主键列表
 * hasOwner 是否设置所有者
 */
+(void)createWithKey:(NSArray *)primaryKeys
               owner:(BOOL)hasOwner;

/*
 * 插入或更新
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId(登陆用户id, 所有者) 有则更新该用户下的数据, 无则更新无该约束的数据
 *
 */
-(void)insertOrUpdateValue:(NSString *)value
                    forKey:(NSString *)key
                     owner:(NSString *)ownerId;

/*
 * 更新
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId(登陆用户id, 所有者) 有则更新该用户下的数据, 无则更新无该约束的数据
 *
 */
-(void)updateValue:(NSString *)var
            forKey:(NSString *)valueKey
             owner:(NSString *)ownerId;

/*
 * 插入
 * ownerId 所有者(登陆用户的id), 有则关联,无则不关联
 *
 */
-(void)insertWithOwner:(NSString *)ownerId;

/** 查询
 * 返回结果为字典类型 列表
 *
 */
+(void)queryWithSql:(NSString *)sql
              block:(QueryListFinishBlock)block;
/** 查询
 * 返回结果为model类型 列表
 *
 */
+(void)queryWithSql:(NSString *)sql
 responseModelBlock:(QueryListFinishBlock)block;

/*
 * 查询
 * ownerId (所有者 ,用户id) 有则.查询该用户的数据, 没有则查询所有数据
 */
+(void)queryWithOwner:(NSString *)ownerId
               finish:(QueryListFinishBlock)block;

+(void)queryWithParams:(NSDictionary *)params
                 block:(QueryListFinishBlock)block;
/*
 * 删除
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId (所有者, 登陆用户的id)有则删掉ownerid对应符合条件的行, 无则删除所以符合条件的行
 */
+(void)deleteValue:(NSString *)value
            forKey:(NSString *)key
             owner:(NSString *)ownerId;

/*
 * 清除
 *
 * ownerId(所有者, 登陆用户的id) 有则删掉 对应的行, 无则删除所以的行
 */
+(void)clearWithOwner:(NSString *)ownerId;
+(void)clearWithParams:(NSDictionary *)params;

@end
