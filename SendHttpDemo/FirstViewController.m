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

#define TestRequestUrl1      @"http://api.cnez.info/product/getProductList/1"
#define TestRequestUrl2      @"http://lib3.wap.zol.com.cn/index.php?c=Advanced_List_V1&keyword=808.8GB%205400%E8%BD%AC%2032MB&noParam=1&priceId=noPrice&num=15"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sendHttpAction:(id)sender
{
    DemoVC *demoVC = [[DemoVC alloc] init];
    demoVC.title = @"测试表格分页请求";
    demoVC.hidesBottomBarWhenPushed = YES;
    demoVC.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:demoVC animated:YES];
}

/**
 测试发送不同请求
 */
- (IBAction)sendHttpRequest:(id)sender
{
//    //测试同时发送50个请求, 底层会自动管理
//    for (int i=0; i<20; i++) {
//        
//        //测试发送普通请求
//        [self sendCommomReq];
//        
//        //测试发送封装多功能请求
//        //[self sendMultifunctionReq:i];
//    }
    
//    //测试发送普通请求
    [self sendCommomReq];
//    //测试发送普通请求
//    [self sendMultifunctionReq:0];
}

/**
 * 发送封装多功能请求
 */
- (void)sendMultifunctionReq:(int)tag
{
    CCHttpRequestModel *model = [[CCHttpRequestModel alloc] init];
    model.requestType = HttpRequestTypeGET;
    model.parameters = nil;
    model.requestUrl = TestRequestUrl2;
    
    model.loadView = self.view;
    //model.dataTableView = self.tableView;//如果页面有表格可传入会自动处理很多事件
    //model.sessionDataTaskArr = self.sessionDataTaskArr; //传入,则自动管理取消请求的操作
    //model.requestCachePolicy = RequestStoreCacheData; //需要保存底层网络数据
    
    NSURLSessionDataTask *task = [CCHttpRequestTools sendMultifunctionCCRequest:model success:^(id returnValue) {
        NSLog(@"不错哦, 请求成功了");
        [MBProgressHUD showToastViewOnView:self.view text:@"请求成功,请查看打印日志"];
        
    } failure:^(NSError *error) {
        NSLog(@"悲剧哦, 请求失败了");
        [MBProgressHUD showToastViewOnView:self.view text:@" 悲剧哦, 请求失败了"];
    }];
    
    NSLog(@"发送请求中===%zd===%@",tag,task);
    
//    if (tag == 49) {
//        NSLog(@"取消所有请求后, 底层不会回调成功或失败到页面上来");
//        [self cancelRequestOperations];
//    }
}

/**
 * 发送普通请求
 */
- (void)sendCommomReq
{
    CCHttpRequestModel *model = [[CCHttpRequestModel alloc] init];
    model.requestType = HttpRequestTypeGET;
    model.parameters = nil;
    model.requestUrl = TestRequestUrl1;
    
    NSURLSessionDataTask *task = [CCHttpRequestTools sendCCRequest:model success:^(id returnValue) {
        NSLog(@"发送普通请求, 不错哦, 请求成功了");
        [MBProgressHUD showToastViewOnView:self.view text:@"请求成功,请查看打印日志"];
        
    } failure:^(NSError *error) {
        NSLog(@"发送普通请求, 悲剧哦, 请求失败了");
        [MBProgressHUD showToastViewOnView:self.view text:@" 悲剧哦, 请求失败了"];
    }];
    
    NSLog(@"测试发送普通请求===%@",task);
}

@end
