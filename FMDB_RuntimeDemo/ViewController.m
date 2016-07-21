//
//  ViewController.m
//  FMDB_RuntimeDemo
//
//  Created by 万绍发 on 15/10/27.
//  Copyright © 2015年 sfwan. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "SFDataManager.h"
#import "City.h"
#import "TestCity.h"

@interface Tool : NSObject
+ (NSString *)transform:(NSString *)chinese;
@end

@implementation Tool

+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSLog(@"%@", pinyin);
    return [pinyin uppercaseString];
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建表
    [TestModel createWithKey:@[@"userId"] owner:nil];

    // 查询
    [TestModel queryWithOwner:nil finish:^(NSArray *list) {
        for (TestModel *model in list) {
            NSLog(@"username:%@ , address:%@", model.userName, model.address);
        }
    }];
    
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    for (int i = 8; i < 20; i++) {
        NSString *name = [NSString stringWithFormat:@"rock%d", i];
        NSString *userId = [NSString stringWithFormat:@"100%d", i];
        NSDictionary *dic = @{@"userName":name, @"userId":userId, @"address":@"南山区", @"pic":@"http://www.hisd.com/pic.jpg"};
        TestModel *model = [[TestModel alloc] initContentWithDic:dic];
        [groups addObject:model];

//        [values addObject:@[userId,name]];
//        [keys addObject:@[@"userId", @"userName"]];
        
        [values addObject:@[userId]];
        [keys addObject:@[@"userId"]];
    }
    
    [TestModel insertOrUpdateGroups:groups values:values forKeys:keys owner:nil];
//    NSDictionary *dic = @{@"userName":@"Mock", @"userId":@"5233", @"address":@"朝阳区", @"pic":@"http://www.hisd.com/pic.jpg"};
//
//    // 创建
//    TestModel *model = [[TestModel alloc] initContentWithDic:dic];
//    
//    // 插入或者更新数据库
//    [model insertOrUpdateValue:model.userId forKey:@"userId" owner:nil];
////    [model insertWithOwner:nil];
//    
//    dic = @{@"userName":@"Dar", @"userId":@"4222", @"address":@"朝阳区", @"pic":@"http://www.hisd.com/pic.jpg"};
//    model = [[TestModel alloc] initContentWithDic:dic];
//    [model insertOrUpdateValue:model.userId forKey:@"userId" owner:nil];
    
    /*
    [TestCity createWithKey:@[@"id"] owner:nil];
    
    NSString *dePath = [[SFDataManager shareDataManager] filePath];
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"china_cities.db" ofType:nil];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fm fileExistsAtPath:dePath]) {
        [fm copyItemAtPath:resourcePath toPath:dePath error:&error];
        NSLog(@"%@", error);
    }
    
    NSString *str = @"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
    NSArray *headKey = [str componentsSeparatedByString:@","];
    TestCity *model = [[TestCity alloc] init];
    [City queryWithOwner:nil finish:^(NSArray *list) {
        NSMutableDictionary *attrDic = [NSMutableDictionary dictionary];
        NSMutableArray *array = [NSMutableArray array];
        for (City *city in list) {
            
            
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            NSString *name = city.name;
            
            NSMutableString *suoxie = [NSMutableString string];
            for (int i = 0; i < name.length; i++) {
                NSString *seprate = [name substringWithRange:NSMakeRange(i, 1)];
                NSString *sepratePY = [Tool transform:seprate];
                NSString *sx = [sepratePY substringToIndex:1];
                [suoxie appendString:sx];
            }
            city.initials = suoxie;
            city.firstChar = [city.pinyin substringToIndex:1];
            
            dic[@"initials"] = suoxie;
            dic[@"city_key"] = city.id;
            dic[@"city_name"] = city.name;
            
            NSString *pinyin = city.pinyin;
            dic[@"pinyin"] = pinyin;
            NSString *firstChar = [[pinyin substringToIndex:1] uppercaseString];
            
            array = [attrDic objectForKey:firstChar];
            if (array == nil) {
                array = [NSMutableArray array];
                [attrDic setObject:array forKey:firstChar];
            }
            
            [array addObject:dic];
            
            
            model.id = city.id;
            model.pinyin = city.pinyin;
            model.initials = city.initials;
            model.firstChar = city.firstChar;
            model.name = city.name;
            
            [model insertOrUpdateValue:city.id forKey:@"id" owner:nil];
        }
        
        NSLog(@"%@", attrDic);
        
//        NSMutableArray *totalArray = [NSMutableArray array];
//        for (NSString *key in [attrDic allKeys]) {
//            NSArray *citys = attrDic[key];
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setObject:key forKey:@"initial"];
//            [dict setObject:citys forKey:@"citys"];
//            [totalArray addObject:dict];
//        }
//        
//        [totalArray writeToFile:@"/Users/dbc/Desktop/CityData.plist" atomically:YES];
    }];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end


