//
//  OKHttpRequestModel+OKExtension.m
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestModel+OKExtension.h"
#import <objc/runtime.h>

static char const * const kLoadViewKey                  = "kLoadViewKey";
static char const * const kDataTableViewKey             = "kDataTableViewKey";
static char const * const kErrorAlertTipStringKey       = "kErrorAlertTipStringKey";
static char const * const kTryRequestWhenFailCountkey   = "kTryRequestWhenFailCountkey";
static char const * const kRequestCachePolicyKey        = "kRequestCachePolicyKey";
static char const * const kIsCacheDataKey               = "kIsCacheDataKey";


@implementation OKHttpRequestModel (OKExtension)


#pragma mark - ========== 请求时的转圈父视图 ==========

- (void)setLoadView:(UIView *)loadView
{
    objc_setAssociatedObject(self, kLoadViewKey, loadView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)loadView
{
    return objc_getAssociatedObject(self, kLoadViewKey);
}

#pragma mark - ========== 页面上有表格如果传此参数,请求完成后会帮你刷新页面,控制下拉刷新状态等 ==========

- (void)setDataTableView:(UITableView *)dataTableView
{
    objc_setAssociatedObject(self, kDataTableViewKey, dataTableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableView *)dataTableView
{
    return objc_getAssociatedObject(self, kDataTableViewKey);
}

#pragma mark - ========== 是否在底层提示失败信息 (默认不提示) ==========

- (void)setErrorAlertTipString:(NSString *)errorAlertTipString
{
    objc_setAssociatedObject(self, kErrorAlertTipStringKey, errorAlertTipString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)errorAlertTipString
{
    return objc_getAssociatedObject(self, kErrorAlertTipStringKey);
}

#pragma mark - ========== 在失败时尝试重新请求次数 ==========

- (void)setTryRequestWhenFailCount:(NSInteger)tryRequestWhenFailCount
{
    objc_setAssociatedObject(self, kTryRequestWhenFailCountkey, @(tryRequestWhenFailCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tryRequestWhenFailCount
{
    id value = objc_getAssociatedObject(self, kTryRequestWhenFailCountkey);
    return [value integerValue];
}

#pragma mark - ========== 请求缓存策略 ==========
/**
 * 如果请求时缓存了网络数据,则下次相同的请求地址时,
 * 则会优先返回缓存数据,同时请求最新的数据再返回
 */
- (void)setRequestCachePolicy:(CCRequestCachePolicy)requestCachePolicy
{
    objc_setAssociatedObject(self, kRequestCachePolicyKey, @(requestCachePolicy), OBJC_ASSOCIATION_ASSIGN);
}

- (CCRequestCachePolicy)requestCachePolicy
{
    id obj = objc_getAssociatedObject(self, kRequestCachePolicyKey);
    CCRequestCachePolicy policy = [obj integerValue];
    return policy;
}

#pragma mark - ========== 此次返回的数据是否为缓存数据 ==========

- (void)setIsCacheData:(BOOL)isCacheData
{
    objc_setAssociatedObject(self, kIsCacheDataKey, @(isCacheData), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isCacheData
{
    id value = objc_getAssociatedObject(self, kIsCacheDataKey);
    return [value boolValue];
}

@end

