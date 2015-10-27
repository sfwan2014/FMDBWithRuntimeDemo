//
//  NSObject+FMDB.m
//  FMDB_RuntimeDemo
//
//  Created by 万绍发 on 15/10/27.
//  Copyright © 2015年 sfwan. All rights reserved.
//

#import "NSObject+FMDB.h"
#import "SFDataManager.h"
#import <objc/runtime.h>

#define kOwnerName      @"ownerId"

@implementation NSObject (JSON)

- (id)initContentWithDic:(NSDictionary *)jsonDic
{
    self = [self init];
    if (self != nil) {
        [self setAttributes:jsonDic];
    }
    return self;
}

- (void)setAttributes:(NSDictionary *)jsonDic
{
    
    /*
     key:  json字典的key名
     value: model对象的属性名
     */
    //mapDic： 属性名与json字典的key 的映射关系
    NSDictionary *mapDic = [self attributeMapDictionary:jsonDic];
    
    for (NSString *jsonKey in mapDic) {
        
        //modelAttr:"newsId"
        //jsonKey : "id"
        NSString *modelAttr = [mapDic objectForKey:jsonKey];
        SEL seletor = [self stringToSel:modelAttr];
        
        //判断self 是否有seletor 方法
        if ([self respondsToSelector:seletor]) {
            //json字典中的value
            id value = [jsonDic objectForKey:jsonKey];
            
            if ([value isKindOfClass:[NSNull class]]) {
                value = @"";
            }
            
            //调用属性的设置器方法，参数是json的value
            [self performSelector:seletor withObject:value];
        }
        
    }
}

/*
 SEL 类型的创建方式有两种，例如：setNewsId: 的SEL类型
 1.第一种
 SEL selector = @selector(setNewsId:)
 2.第二种
 SEL selector = NSSelectorFromString(@"setNewsId:");
 */

//将属性名转成SEL类型的set方法
//newsId  --> setNewsId:
- (SEL)stringToSel:(NSString *)attName
{
    //截取收字母
    NSString *first = [[attName substringToIndex:1] uppercaseString];
    NSString *end = [attName substringFromIndex:1];
    
    NSString *setMethod = [NSString stringWithFormat:@"set%@%@:",first,end];
    
    //将字符串转成SEL类型
    return NSSelectorFromString(setMethod);
}

/*
 属性名与json字典中key的映射关系
 key:  json字典的key名
 value: model对象的属性名
 */
- (NSDictionary *)attributeMapDictionary:(NSDictionary *)jsonDic
{
    
    NSMutableDictionary *mapDic = [NSMutableDictionary dictionary];
#pragma mark - 修改字典为空时,程序崩溃问题
    if ([jsonDic isKindOfClass:[NSDictionary class]]) {
        NSArray *array = [jsonDic allKeys];
        for (int i = 0; i < jsonDic.count; i ++) {
            id key = array[i];
            
            [mapDic setObject:key forKey:key];
        }
    }
    return mapDic;
}

@end

@implementation NSObject (FMDB)

#pragma mark - database
-(NSMutableDictionary *)attributeProrertyDic{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i<count; i++) {
        
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        
        // 查看成员变量
        const char *name = ivar_getName(ivar);
        // 归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        if ([value isKindOfClass:[NSNull class]] || value == nil) {
            value = @"";
        }
        [dic setObject:value forKey:key];
    }
    
    free(ivars);
    return dic;
}

-(NSArray *)attributePropertyList{
    
    NSDictionary *dic = [self attributeProrertyDic];
    NSArray *array = [dic allKeys];
    return array;
}


+(SEL)getSetterSelWithAttibuteName:(NSString*)attributeName{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:",capital,[attributeName substringFromIndex:1]];
    return NSSelectorFromString(setterSelStr);
}

// 表名
+(NSString *)tableName{
    return @"TABLENAME";
}


// 主键
+(NSString *)primaryKey{
    return @"Id";
}




#pragma mark - update start 09-09

/*
 * 创建表
 * primaryKeys 主键列表
 * hasOwner 是否设置所有者
 */
+(void)createWithKey:(NSArray *)primaryKeys owner:(BOOL)hasOwner{
    
    NSString *tableName = [[self class]tableName];
    //    NSString *primaryKey = [[self class] primaryKey];
    
    id model = [[self alloc] init];
    NSArray *attributes = [model attributePropertyList];
    
    NSMutableString *mutSql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (",tableName];
    for (int i = 0; i < attributes.count; i++) {
        NSString *key = attributes[i];
        key = [key substringFromIndex:1];
        NSString *proType = @"BLOB";
        
        [mutSql appendFormat:@"'%@' %@, ", key, proType];
        
    }
    if (hasOwner) {
        // 登陆用户id
        [mutSql appendFormat:@"'%@' BLOB,", kOwnerName];
    }
    // 设置联合主键
    NSString *primaryKey = [primaryKeys componentsJoinedByString:@","];
    [mutSql appendFormat:@"PRIMARY KEY(%@))", primaryKey];
    
    [[SFDataManager shareDataManager] createTableWithSql:mutSql];
}

/*
 * 插入或更新
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId(登陆用户id, 所有者) 有则更新该用户下的数据, 无则更新无该约束的数据
 *
 */
-(void)insertOrUpdateValue:(NSString *)value forKey:(NSString *)key owner:(NSString *)ownerId{
    
    NSString *tableName = [[self class] tableName];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@' AND %@ = '%@'", tableName, key, value, kOwnerName, ownerId];
    if (!ownerId) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'", tableName, key, value];
    }
    [[self class] queryWithSql:sql block:^(NSArray *list) {
        if (list.count > 0) {
            [self updateValue:value forKey:key owner:ownerId];
        } else {
            [self insertWithOwner:ownerId];
        }
    }];
}

// UPDATE CircleDetailTable SET _gchat_desc = 'Fred' WHERE _ownerId = '3826'

/*
 * 更新
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId(登陆用户id, 所有者) 有则更新该用户下的数据, 无则更新无该约束的数据
 *
 */
-(void)updateValue:(NSString *)var forKey:(NSString *)valueKey owner:(NSString *)ownerId{
    NSDictionary *attributeDic = [self attributeProrertyDic];
    NSArray *allKeys = [attributeDic allKeys];
    
    NSString *tableName = [[self class] tableName];
    
    NSString *headSql = [NSString stringWithFormat:@"UPDATE %@ SET ", tableName];
    NSMutableString *valueSql = [NSMutableString stringWithFormat:@""];
    
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        id value = attributeDic[key];
        key = [key substringFromIndex:1];
        if (i == allKeys.count -1) {
            [valueSql appendFormat:@"%@='%@'", key, value];
            break;
        }
        [valueSql appendFormat:@"%@='%@',", key, value];
    }
    
    NSString *footerSql = [NSString stringWithFormat:@"WHERE %@='%@' AND %@='%@'", kOwnerName, ownerId, valueKey, var];
    if (!ownerId) {
        footerSql = [NSString stringWithFormat:@"WHERE %@='%@'", valueKey, var];
    }
    
    NSString *sql = [NSString stringWithFormat:@"%@%@%@", headSql, valueSql, footerSql];
    
    [[SFDataManager shareDataManager] updateSql:sql];
}
/*
 * 插入
 * ownerId 所有者(登陆用户的id), 有则关联,无则不关联
 *
 */
-(void)insertWithOwner:(NSString *)ownerId{
    
    NSDictionary *attributeDic = [self attributeProrertyDic];
    NSArray *allKeys = [attributeDic allKeys];
    
    NSString *tableName = [[self class] tableName];
    
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"INSERT INTO '%@'", tableName];
    NSMutableString *sqlKeyStr = [NSMutableString stringWithFormat:@"("];
    NSMutableString *sqlValueStr = [NSMutableString stringWithFormat:@") VALUES ("];
    
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        NSString *value = attributeDic[key];
        key = [key substringFromIndex:1];
        if (value == nil || (![value isKindOfClass:[NSNumber class]] && value.length == 0)) {
            continue;
        }
        [newDic setObject:value forKey:key];
    }
    
    if (ownerId) {
        [newDic setValue:ownerId forKey:kOwnerName];
    }
    
    allKeys = [newDic allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        NSString *value = newDic[key];
        
        if (i == allKeys.count - 1) {
            [sqlKeyStr appendFormat:@"'%@' ", key];
            [sqlValueStr appendFormat:@"'%@' ", value];
            break;
        }
        
        [sqlKeyStr appendFormat:@"'%@', ", key];
        [sqlValueStr appendFormat:@"'%@', ", value];
    }
    [sqlValueStr appendString:@")"];
    
    [sqlStr appendString:sqlKeyStr];
    [sqlStr appendString:sqlValueStr];
    
    BOOL res = [[SFDataManager shareDataManager] insertSql:sqlStr];
    if (!res) {
        NSLog(@"insert error");
    }
}


/** 查询
 * 返回结果为model类型 列表
 *
 */
+(void)queryWithSql:(NSString *)sql responseModelBlock:(QueryListFinishBlock)block{
    [self queryWithSql:sql block:^(NSArray *list) {
        NSMutableArray *allModels = [NSMutableArray array];
        for (NSDictionary *dic in list) {
            id model = [[self alloc] initContentWithDic:dic];
            [allModels addObject:model];
        }
        
        if (block) {
            block(allModels);
        }
    }];
}

/** 查询
 * 返回结果为字典类型 列表
 *
 */
+(void)queryWithSql:(NSString *)sql block:(QueryListFinishBlock)block{
    
    [[SFDataManager shareDataManager] querySql:sql finishBlock:^(FMResultSet *rs) {
        
        //        NSMutableArray *allModels = [NSMutableArray array];
        NSMutableArray *propertyList = [NSMutableArray array];
        while ([rs next]) {
            
            id model = [[self alloc] init];
            
            NSArray *allKeys = [model attributePropertyList];
            
            NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
            for (int i = 0; i < allKeys.count; i++) {
                
                NSString *key = allKeys[i];
                if ([key hasPrefix:@"_"]) {
                    key = [key substringFromIndex:1];
                }
                
                id value = [rs stringForColumn:key];
                if (value == nil) {
                    value = @"";
                }
                
                [propertyDic setObject:value forKey:key];
            }
            
            [propertyList addObject:propertyDic];
            //            [allModels addObject:model];
        }
        if (block) {
            block(propertyList);
        }
    }];
}

/*
 * 查询
 * ownerId (所有者 ,用户id) 有则.查询该用户的数据, 没有则查询所有数据
 */
+(void)queryWithOwner:(NSString *)ownerId finish:(QueryListFinishBlock)block{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'",[self tableName], kOwnerName, ownerId];
    if (!ownerId) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@",[self tableName]];
    }
    //    [self queryWithSql:sql block:block];
    [self queryWithSql:sql responseModelBlock:block];
}

/*
 * params 根据条件进行查询
 *
 *
 */
+(void)queryWithParams:(NSDictionary *)params block:(QueryListFinishBlock)block{
    
    NSMutableString * sqlHead = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",[self tableName]];
    NSArray *allKeys = [params allKeys];
    NSMutableString *sqlBody = [NSMutableString string];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        id value = params[key];
        if (i == 0) {
            [sqlBody appendFormat:@"WHERE %@ = '%@'", key, value];
            continue;
        }
        [sqlBody appendFormat:@"AND %@ = '%@'", key, value];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@ %@",sqlHead, sqlBody];
    //    [self queryWithSql:sql block:block];
    [self queryWithSql:sql responseModelBlock:block];
}

/*
 * 删除
 * value 对应条件的值 ,key 对应条件的 名
 * ownerId (所有者, 登陆用户的id)有则删掉ownerid对应符合条件的行, 无则删除所以符合条件的行
 */
+(void)deleteValue:(NSString *)value forKey:(NSString *)key owner:(NSString *)ownerId{
    
    NSString *tableName = [[self class]tableName];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@'",tableName, value, key, kOwnerName, ownerId];
    if (!ownerId) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",tableName, value, key];
    }
    [[SFDataManager shareDataManager] deleteSql:sql];
}
/*
 * 清除
 *
 * ownerId(所有者, 登陆用户的id) 有则删掉 对应的行, 无则删除所以的行
 */
+(void)clearWithOwner:(NSString *)ownerId{
    NSString *tableName = [[self class]tableName];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",tableName,  kOwnerName, ownerId];
    if (!ownerId) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@ ",tableName];
    }
    [[SFDataManager shareDataManager] deleteSql:sql];
}

/*
 * params 参数条件根据条件进行清除
 *
 */
+(void)clearWithParams:(NSDictionary *)params{
    //    NSString *tableName = [[self class]tableName];
    
    //    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",tableName,  kOwnerName, ownerId];
    //    if (!ownerId) {
    //        sql = [NSString stringWithFormat:@"DELETE FROM %@ ",tableName];
    //    }
    //    [[SFDataManager shareDataManager] deleteSql:sql];
    
    if (params == nil) {
        [self clearWithOwner:nil];
    }
    
    NSMutableString * sqlHead = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",[self tableName]];
    NSArray *allKeys = [params allKeys];
    NSMutableString *sqlBody = [NSMutableString string];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        id value = params[key];
        if (i == 0) {
            [sqlBody appendFormat:@"WHERE %@ = '%@'", key, value];
            continue;
        }
        [sqlBody appendFormat:@"AND %@ = '%@'", key, value];
    }
    
    NSString * sql = [NSString stringWithFormat:@"%@ %@",sqlHead, sqlBody];
    
    [[SFDataManager shareDataManager] deleteSql:sql];
}

@end