//
//  CCBaseViewController.m
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "CCBaseViewController.h"

@interface CCBaseViewController ()

@end

@implementation CCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSMutableArray *)tableDataArr
{
    if (!_tableDataArr) {
        NSMutableArray *tableDataArr = [NSMutableArray array];
        self.tableDataArr = tableDataArr;
    }
    return _tableDataArr;
}

/**
 * 子类请求对象数组
 */
- (NSMutableArray<NSURLSessionDataTask *> *)sessionDataTaskArr
{
    if (!_sessionDataTaskArr) {
        NSMutableArray *sessionDataTaskArr = [NSMutableArray array];
        self.sessionDataTaskArr = sessionDataTaskArr;
    }
    return _sessionDataTaskArr;
}

/**
 * 取消子类所有请求操作
 */
- (void)cancelRequestOperations
{
    //[self.sessionDataTaskArr makeObjectsPerformSelector:@selector(cancel)];
    if (_sessionDataTaskArr.count==0) return;
    
    for (NSURLSessionDataTask *sessionTask in self.sessionDataTaskArr) {
        NSLog(@"父类释放时帮你取消请求操作===%@",sessionTask);
        if ([sessionTask isKindOfClass:[NSURLSessionDataTask class]]) {
            [sessionTask cancel];
        }
    }
    //清除所有请求对象
    [self.sessionDataTaskArr removeAllObjects];
}

- (void)dealloc
{
    //取消子类所有请求操作
    [self cancelRequestOperations];
}


@end
