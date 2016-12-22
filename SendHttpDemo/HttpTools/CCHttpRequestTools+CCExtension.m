//
//  CCHttpRequestTools+CCExtension.m
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "CCHttpRequestTools+CCExtension.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "CCFMDBTool.h"

@implementation CCHttpRequestTools (CCExtension)

#pragma mark - 包装每个接口缓存数据的key

/**
 *  根据接口参数包装缓存数据key
 */
+(NSString *)getCacheKeyByRequestUrl:(NSString *)urlString parameter:(NSDictionary *)parameter
{
    NSString * key = @"";
    if (urlString && [urlString isKindOfClass:[NSString class]]) {
        key = urlString;
    }
    if (parameter && [parameter isKindOfClass:[NSDictionary class]]) {
        NSArray * dickeys = [parameter allKeys];
        for (NSString * dickey in dickeys) {
            NSString * valus = [parameter objectForKey:dickey];
            key = [NSString stringWithFormat:@"%@%@%@",key,dickey,valus];
        }
    }
    return key;//[CNUtils md5:key];
}

#pragma mark - 包装请求入口

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendMultifunctionCCRequest:(CCHttpRequestModel *)requestModel
                                             success:(CCHttpSuccessBlock)successBlock
                                             failure:(CCHttpFailureBlock)failureBlock
{
    //请求地址为空则不请求
    if (!requestModel.requestUrl) return nil;
    
    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        
        //判断Token状态是否为失效
        if (error.code == [kLoginFail integerValue]) {
            //通知页面需要重新登录
            [[NSNotificationCenter defaultCenter] postNotificationName:kTokenExpiry object:nil];
            return ;
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
        
        //如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态
        UITableView *tableView = requestModel.dataTableView;
        if (tableView && [tableView isKindOfClass:[UITableView class]]) {
            [tableView showRequestTip:error];
        }
        
        //隐藏弹框
        if (requestModel.loadView) {
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        //如果需要提示错误信息
        if (!requestModel.forbidTipErrorInfo) {
            UIView *tipView = requestModel.loadView ? : [UIApplication sharedApplication].keyWindow;
            
            //错误码在200-500内才提示服务端错误信息
            if (error.code > kRequestTipsStatuesMin && error.code < kRequestTipsStatuesMax) {
                [MBProgressHUD showToastViewOnView:tipView text:error.domain];
            } else {
                [MBProgressHUD showToastViewOnView:tipView text:RequestFailCommomTip];
            }
        }
    };
    
    //成功回调
    void(^succResultBlock)(id responseObject, BOOL isCacheData) = ^(id responseObject, BOOL isCacheData){
        
        //判断是否未缓存数据
        requestModel.isCacheData = isCacheData;
        
        if (requestModel.loadView) { //防止页面上有其他弹框
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        NSInteger code = [responseObject[kRequestCodeKey] integerValue];
        if (code == 0 || code == 200)
        {
            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }
            
            /** <2>.如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态 */
            UITableView *tableView = requestModel.dataTableView;
            if (tableView && [tableView isKindOfClass:[UITableView class]]) {
                [tableView showRequestTip:responseObject];
            }
            
            /** <3>.是否需要缓存 */
            if (isCacheData == NO && requestModel.requestCachePolicy == RequestStoreCacheData) {
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSData * data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                if (data) { //保存数据到数据库
                    NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];//缓存key
                    [CCFMDBTool saveDataToDB:data byObjectId:cachekey toTable:JsonDataTableType];
                }
            }
            
        } else { //请求code不正确,走失败
            failResultBlock([NSError errorWithDomain:responseObject[kRequestMessageKey] code:code userInfo:nil]);
        }
    };
    
    //如果有网络缓存, 则立即返回缓存, 同时继续请求网络最新数据
    if (successBlock && requestModel.requestCachePolicy == RequestStoreCacheData) {
        //缓存key
        NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl parameter:requestModel.parameters];
        NSDictionary *cacheDic = [CCFMDBTool getObjectById:cachekey fromTable:JsonDataTableType];
        if (cacheDic) {
            succResultBlock(cacheDic,YES);
        }
    }
    
    //网络不正常,直接走返回失败
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }
    
    //是否显示请求转圈
    if (requestModel.loadView) {
        [requestModel.loadView endEditing:YES];
        [MBProgressHUD showLoadingWithView:requestModel.loadView text:RequestLoadingTip];
    }
    
    __block NSURLSessionDataTask *sessionDataTask = nil;
    
    //发送网络请求,二次封装入口
    sessionDataTask = [CCHttpRequestTools sendCCRequest:requestModel success:^(id returnValue) {
        NSLog(@"二次封装成功请求时,请求状态: ===%@",sessionDataTask);
        
        succResultBlock(returnValue, NO);
        
    } failure:^(NSError *error) {
        NSLog(@"二次封装失败时,请求状态:  %@======%@",sessionDataTask,sessionDataTask.error);
        
        if (error.code != NSURLErrorCancelled) {
            failResultBlock(error);
            
        } else { //code == -999
            NSLog(@"页面已主动触发取消请求,此次请求不回调到页面");
            
            if (requestModel.loadView) { //隐藏弹框
                [MBProgressHUD hideLoadingFromView:requestModel.loadView];
            }
        }
    }];
    
    NSLog(@"发送完毕,返回请求对象到页面===%@",sessionDataTask);
    return sessionDataTask;
}

@end


