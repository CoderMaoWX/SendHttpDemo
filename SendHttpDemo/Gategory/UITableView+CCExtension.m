//
//  UITableView+CCExtension.m
//  Okdeer-jieshun-parkinglot
//
//  Created by mao wangxin on 2016/11/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "UITableView+CCExtension.h"
#import "CCHttpRequestModel.h"
#import "CCParkingRequestTipView.h"
#import <AFNetworkReachabilityManager.h>
#import <MJRefresh.h>

#define WEAKSELF(weakSelf)  __weak __typeof(&*self)weakSelf = self;

static char const * const kEmptyStrKey    = "kEmptyStrKey";
static char const * const kEmptyImgKey    = "kEmptyImgKey";
static char const * const kErrorImgKey    = "kErrorImgKey";
static char const * const kNetErrorStrKey = "kNetErrorStrKey";

@implementation UITableView (CCExtension)

#pragma mark - ========== 请求失败提示view相关 ==========

- (void)setEmptyString:(NSString *)emptyString
{
    objc_setAssociatedObject(self, kEmptyStrKey, emptyString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyString
{
    return objc_getAssociatedObject(self, kEmptyStrKey);
}

#pragma mark - ========== 提示图片名字 ==========

- (void)setEmptyImageName:(NSString *)emptyImageName
{
    objc_setAssociatedObject(self, kEmptyImgKey, emptyImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)emptyImageName
{
    return objc_getAssociatedObject(self, kEmptyImgKey);
}

#pragma mark - ========== 请求失败文字 ==========

- (void)setNetErrorString:(NSString *)netErrorString
{
    objc_setAssociatedObject(self, kNetErrorStrKey, netErrorString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)netErrorString
{
    return objc_getAssociatedObject(self, kNetErrorStrKey);
}

#pragma mark - ========== 请求失败提示图片 ==========

- (void)setErrorImageName:(NSString *)errorImageName
{
    objc_setAssociatedObject(self, kErrorImgKey, errorImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)errorImageName
{
    return objc_getAssociatedObject(self, kErrorImgKey);
}

#pragma mark - 给表格添加上下拉刷新事件

/**
 初始化表格的上下拉刷新控件
 
 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(MJRefreshComponentRefreshingBlock)headerBlock footerBlock:(MJRefreshComponentRefreshingBlock)footerBlock
{
    if (headerBlock) {
        WEAKSELF(weakSelf)
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            //每次下拉刷新时先结束上啦
            [weakSelf.mj_footer endRefreshing];
            
            headerBlock();
        }];
        [self.mj_header beginRefreshing];
    }
    
    if (footerBlock) {
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉view
        self.mj_footer.hidden = YES;
    }
}


#pragma mark - 给表格添加上请求失败提示事件

/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作
 
 @param responseData 网络请求回调数据
 */
- (void)showRequestTip:(id)responseData
{
    //请求回调后收起上下拉控件
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }
    
    if (self.mj_footer) {
        [self.mj_footer endRefreshing];
    }
    
    //如果请求成功处理
    if ([responseData isKindOfClass:[NSDictionary class]]) {
        
        //页面没有数据
        if (self.numberOfSections == 0 || (self.numberOfSections == 1 && [self numberOfRowsInSection:0] == 0)) {
            
            //根据状态,显示背景提示Viwe
            if (![AFNetworkReachabilityManager sharedManager].reachable) {//没有网络
                WEAKSELF(weakSelf)
                [self showTipBotton:YES TipStatus:RequesErrorNoNetWork tipString:nil clickBlock:^{
                    if (weakSelf.mj_header) {
                        //1.先移除页面上已有的提示CCParkingRequestTipView视图
                        [weakSelf removeOldTipBgView];
                        
                        //2.开始走下拉请求
                        [weakSelf.mj_header beginRefreshing];
                    }
                }];
                
            } else {
                [self showTipBotton:YES TipStatus:RequestEmptyDataStatus tipString:nil clickBlock:nil];
            }
            
        } else { //页面有数据
            
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:RequestNormalStatus tipString:nil clickBlock:nil];
            
            //控制上啦控件的显示
            if (!self.mj_footer) return;
            
            NSArray *listArr = responseData[@"data"];
            if ([listArr isKindOfClass:[NSArray class]]) {
                if (listArr.count>0) {
                    self.mj_footer.hidden = NO;
                } else {
                    [self.mj_footer endRefreshingWithNoMoreData];
                    //self.mj_footer.hidden = YES;
                }
                
            } else {
                self.mj_footer.hidden = NO;
            }
            
//            if (responseData[@"totalPage"]) {
//                NSInteger totalPage = [responseData[@"totalPage"] integerValue];
//                NSInteger currentPage = [responseData[@"currentPage"] integerValue];
//                
//                if (totalPage > currentPage) {
//                    self.mj_footer.hidden = NO;
//                } else {
//                    [self.mj_footer endRefreshingWithNoMoreData];
//                    self.mj_footer.hidden = YES;
//                }
//            } else {
//                self.mj_footer.hidden = NO;
//            }
        }
        
    } else if([responseData isKindOfClass:[NSError class]]){ //请求失败处理
        NSError *error = (NSError *)responseData;
        
        //页面没有数据
        if (self.numberOfSections == 0 || (self.numberOfSections == 1 && [self numberOfRowsInSection:0] == 0)) {
            
            //根据状态,显示背景提示Viwe
            WEAKSELF(weakSelf)
            //没有网络
            if (![AFNetworkReachabilityManager sharedManager].reachable) {
                [self showTipBotton:YES TipStatus:RequesErrorNoNetWork tipString:NetworkConnectFailTip clickBlock:^{
                    if (weakSelf.mj_header) {
                        //1.先移除页面上已有的提示CCParkingRequestTipView视图
                        [weakSelf removeOldTipBgView];
                        
                        //2.开始走下拉请求
                        [weakSelf.mj_header beginRefreshing];
                    }
                }];
                
            } else {
                [self showTipBotton:YES TipStatus:RequestFailStatus tipString:error.domain clickBlock:^{
                    if (weakSelf.mj_header) {
                        //1.先移除页面上已有的提示CCParkingRequestTipView视图
                        [weakSelf removeOldTipBgView];
                        
                        //2.开始走下拉请求
                        [weakSelf.mj_header beginRefreshing];
                    }
                }];
            }
            
        } else { //页面有数据
            
            //隐藏背景提示Viwe
            [self showTipBotton:NO TipStatus:RequestFailStatus tipString:error.domain clickBlock:nil];
        }
    }
}

#pragma mark - 如果请求失败,无网络则展示空白提示view

/**
 * 设置提示图片和文字
 */
- (void)showTipBotton:(BOOL)show TipStatus:(TableVieTipStatus)state tipString:(NSString *)tipString clickBlock:(void(^)())blk
{
    //先移除页面上已有的提示CCParkingRequestTipView视图
    [self removeOldTipBgView];
    
    if (!show) return;
    
    NSString *tipText = nil;
    NSString *imageName = nil;
    NSString *actionTitle = nil;
    
    if (state == RequestNormalStatus) { //正常状态
        //不需要处理, 留给后面扩展
        
    } else if (state == RequestEmptyDataStatus) { //请求空数据
        tipText = self.emptyString ? : @"暂无数据 ";
        imageName = self.emptyImageName ? : @"empty_data_icon";
        
    } else if (state == RequesErrorNoNetWork) { //网络连接失败
        tipText = @"网络开小差, 请稍后再试哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"networkfail_icon";
        
    } else if (state == RequestFailStatus) { //请求失败
        tipText = @"加载失败了哦!";
        actionTitle = @"重新加载";
        imageName = self.errorImageName ? : @"loading_fail_icon";
    }
    
    //这里防止表格有偏移量，一定要设置y的起始位置为0
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    UIView *tipBgView = [CCParkingRequestTipView tipViewByFrame:rect tipImageName:imageName tipText:tipText actionTitle:actionTitle actionBlock:blk];
    [self addSubview:tipBgView];
}

/**
 先移除页面上已有的提示CCParkingRequestTipView视图
 */
- (void)removeOldTipBgView
{
    for (UIView *tempView in self.subviews) {
        if ([tempView isKindOfClass:[CCParkingRequestTipView class]] ||
            tempView.tag == kRequestTipViewTag) {
            [tempView removeFromSuperview];
            break;
        }
    }
}

@end
