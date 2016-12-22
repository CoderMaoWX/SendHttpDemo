//
//  FirstViewController.m
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "FirstViewController.h"
#import "DemoVC.h"
#import <MBProgressHUD.h>

//发送封装多功能请求用到
#import "CCHttpRequestTools+CCExtension.h"
//发送普通请求用到
#import "CCHttpRequestTools.h"

#define TestRequestUrl      @"http://api.cnez.info/product/getProductList/1"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)sendHttpAction:(id)sender {
    
    DemoVC *demoVC = [[DemoVC alloc] init];
    demoVC.title = @"测试表格分页请求";
    demoVC.hidesBottomBarWhenPushed = YES;
    demoVC.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:demoVC animated:YES];
}


/**
 测试:同时发送100个请求
 */
- (IBAction)sendHttpRequest:(id)sender
{
    for (int i=0; i<50; i++) {
        [self sendMultifunctionReq:i];
    }
    
    //测试发送普通请求
    //[self sendCommomReq];
}

/**
 * 发送封装多功能请求
 */
- (void)sendMultifunctionReq:(int)tag
{
    CCHttpRequestModel *model = [[CCHttpRequestModel alloc] init];
    model.requestType = HttpRequestTypeGET;
    model.parameters = nil;
    model.requestUrl = TestRequestUrl;
    
    model.loadView = self.view;
    //    model.dataTableView = self.tableView;
    model.sessionDataTaskArr = self.sessionDataTaskArr; //传入,则自动管理取消请求的操作
    model.requestCachePolicy = RequestStoreCacheData; //需要保存底层网络数据
    
    NSLog(@"发送请求中====%zd",tag);
    [CCHttpRequestTools sendMultifunctionCCRequest:model success:^(id returnValue) {
        NSLog(@"不错哦, 请求成功了");
        
    } failure:^(NSError *error) {
        NSLog(@"悲剧哦, 请求失败了");
    }];
    
    if (tag == 49) {
        NSLog(@"取消所有请求====19");
        [self cancelRequestOperations];
    }
}

/**
 * 发送普通请求
 */
- (void)sendCommomReq
{
    CCHttpRequestModel *model = [[CCHttpRequestModel alloc] init];
    model.requestType = HttpRequestTypeGET;
    model.parameters = nil;
    model.requestUrl = TestRequestUrl;
    
    [CCHttpRequestTools sendCCRequest:model success:^(id returnValue) {
        NSLog(@"发送普通请求, 不错哦, 请求成功了");
        [MBProgressHUD showToastViewOnView:self.view text:@"请求成功,请查看打印日志"];
        
    } failure:^(NSError *error) {
        NSLog(@"发送普通请求, 悲剧哦, 请求失败了");
        [MBProgressHUD showToastViewOnView:self.view text:@" 悲剧哦, 请求失败了"];
    }];
}

@end
