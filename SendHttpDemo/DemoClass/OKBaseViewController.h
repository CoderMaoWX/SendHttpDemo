//
//  CCBaseViewController.h
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKBaseViewController : UIViewController


/** 表格数据源数组 */
@property (nonatomic, strong) NSMutableArray *tableDataArr;

/** 子类请求对象数组 */
@property (nonatomic, strong) NSMutableArray <NSURLSessionDataTask *> *sessionDataTaskArr;

/**
 * 取消子类所有请求操作
 */
- (void)cancelRequestOperations;

@end
