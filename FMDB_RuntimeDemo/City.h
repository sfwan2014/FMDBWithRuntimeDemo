//
//  City.h
//  FMDB_RuntimeDemo
//
//  Created by DBC on 16/6/8.
//  Copyright © 2016年 sfwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic, strong) NSString *initials;// 缩写
@property (nonatomic, strong) NSString *firstChar;// 首字母
@end
