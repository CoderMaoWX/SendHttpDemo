//
//  DemoVC.m
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "DemoVC.h"
#import "CCHttpRequestTools+CCExtension.h"

#define WEAKSELF(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define TestRequestUrl        @"http://lib.wap.zol.com.cn/ipj/docList/?v=11.0&class_id=0&isReviewing=NO&last_time=2016-12-21%2021%3A55&page=1&retina=1&vs=iph501"

@interface DemoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"请求数据" style:UIBarButtonItemStylePlain target:self action:@selector(navBarItemAction)];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    WEAKSELF(weakSelf)
    [self.tableView addheaderRefresh:^{
        [weakSelf requestData:0];
    } footerBlock:^{
         [weakSelf requestData:1];
    }];
}

/**
 请求数据
 */
- (void)navBarItemAction
{
    [self.tableView.mj_header beginRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *dic = self.tableDataArr[indexPath.row];
    cell.textLabel.text = dic[@"stitle"];
    return cell;
}

/**
 * 发送请求
 */
- (void)requestData:(int)tag
{
    CCHttpRequestModel *model = [[CCHttpRequestModel alloc] init];
    model.requestType = HttpRequestTypeGET;
    model.parameters = nil;
    model.requestUrl = TestRequestUrl; //可以试着把地址写错,测试请求失败的场景
    
    model.loadView = self.view;
    model.dataTableView = self.tableView;
    model.sessionDataTaskArr = self.sessionDataTaskArr;
    model.requestCachePolicy = RequestStoreCacheData;
    
    NSLog(@"发送请求中====%zd",tag);
    [CCHttpRequestTools sendMultifunctionCCRequest:model success:^(id returnValue) {
        if (tag == 0) [self.tableDataArr removeAllObjects];
        
        [self.tableDataArr addObjectsFromArray:returnValue[@"list"]];
        [self.tableView reloadData];
    } failure:nil];
}

- (void)dealloc
{
    NSLog(@"DemoVC dealloc");
}

@end
