//
//  MyCollectionDataVC.m
//  SendHttpDemo
//
//  Created by mao wangxin on 2017/4/17.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "MyCollectionDataVC.h"
#import "OKHttpRequestTools+OKExtension.h"

static NSString *const cellID = @"CollectionCellID";

#define WEAKSELF(weakSelf)  __weak __typeof(&*self)weakSelf = self;
/** 随机色*/
#define MJRandomColor       [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

static NSString *kTestRequestUrl = @"http://lib33.wap.zol.com.cn/index.php?c=Advanced_List_V1&keyword=808.8GB%205400%E8%BD%AC%2032MB&noParam=1&priceId=noPrice&num=15";

@interface MyCollectionDataVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, strong) NSDictionary *params;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation MyCollectionDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    
    WEAKSELF(weakSelf)
    [self.collectionView addheaderRefresh:^{
        [weakSelf requestData:YES];
    } footerBlock:^{
        [weakSelf requestData:NO];
    }];
    
    //重新请求数据
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新数据" style:UIBarButtonItemStylePlain target:self action:@selector(refreshDataAction)];
}

/**
 * 刷新数据
 */
- (void)refreshDataAction
{
    kTestRequestUrl = @"http://lib3.wap.zol.com.cn/index.php?c=Advanced_List_V1&keyword=808.8GB%205400%E8%BD%AC%2032MB&noParam=1&priceId=noPrice&num=15";
    [self.collectionView.mj_header beginRefreshing];
}

/**
 * 发送请求
 */
- (void)requestData:(BOOL)firstPage
{
    if (firstPage) {
        self.pageNum = 1;
    } else {
        self.pageNum ++;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"page"] = @(self.pageNum);
    self.params = info;
    
    OKHttpRequestModel *model = [[OKHttpRequestModel alloc] init];
    model.requestType = OKHttpRequestTypeGET;
    model.parameters = info;
    model.requestUrl = kTestRequestUrl; //可以试着把地址写错,测试请求失败的场景
    
    model.loadView = self.view;
    model.dataTableView = self.collectionView;
    //    model.sessionDataTaskArr = self.sessionDataTaskArr;
    //    model.requestCachePolicy = RequestStoreCacheData;
    
    NSLog(@"发送请求中====%zd",self.pageNum);
    [OKHttpRequestTools sendExtensionRequest:model success:^(id returnValue) {
        if (self.params != info) return;
        if (firstPage) {
            [self.tableDataArr removeAllObjects];
        }
        [self.tableDataArr addObjectsFromArray:returnValue[@"data"]];
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        if (!firstPage) self.pageNum --;
    }];
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 设置尾部控件的显示和隐藏
//    self.collectionView.mj_footer.hidden = self.tableDataArr.count == 0;
    return self.tableDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = MJRandomColor;
    return cell;
}

#pragma mark - <UICollectionViewDataSource>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath===%zd",indexPath.item);
}

/**
 *  设置每个Item大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width/3.5, self.view.bounds.size.width/3.5);
}

/**
 *  添加一个顶部视图
 */
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}


/**
 *  设置每一拦Header大小
 */
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeZero;
//}

@end
