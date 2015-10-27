//
//  ViewController.m
//  FMDB_RuntimeDemo
//
//  Created by 万绍发 on 15/10/27.
//  Copyright © 2015年 sfwan. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"

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
    
    
    NSDictionary *dic = @{@"userName":@"Rock", @"userId":@"3323", @"address":@"朝阳区", @"pic":@"http://www.hisd.com/pic.jpg"};
    
    // 创建
    TestModel *model = [[TestModel alloc] initContentWithDic:dic];
    
    // 插入或者更新数据库
    [model insertOrUpdateValue:model.userId forKey:@"userId" owner:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
