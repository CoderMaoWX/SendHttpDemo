//
//  CCHttpRequestTools+OKExtension.m
//  okdeer-commonLibrary
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestTools+OKExtension.h"
#import <AFNetworking.h>
#import "OKRequestTipBgView.h"
#import "OKFMDBTool.h"
#import "OKRequestTipBgView.h"

//重复请求次数key
static char const * const kRequestTimeCountKey    = "kRequestTimeCountKey";

@implementation OKHttpRequestTools (OKExtension)

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
+ (NSURLSessionDataTask *)sendExtensionRequest:(OKHttpRequestModel *)requestModel
                                       success:(OKHttpSuccessBlock)successBlock
                                       failure:(OKHttpFailureBlock)failureBlock
{
    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        
        //隐藏弹框
        if (requestModel.loadView && !requestModel.dataTableView) {
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        if (failureBlock) {
            failureBlock(error);
        }
        
        //判断Token状态是否为失效
        if (error.code == [kLoginFail integerValue]) {
            //通知页面需要重新登录
            [[NSNotificationCenter defaultCenter] postNotificationName:kTokenExpiryNotification object:nil];
        }
        
        //如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态
        UITableView *tableView = requestModel.dataTableView;
        if (tableView && [tableView isKindOfClass:[UITableView class]]) {
            [tableView showRequestTip:error];
        }
        
        //如果需要提示错误信息
        if (!requestModel.forbidTipErrorInfo) {
            
            //错误码在200-500内才提示服务端错误信息
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            if (error.code > kRequestTipsStatuesMin && error.code < kRequestTipsStatuesMax) {
                [MBProgressHUD showToastViewOnView:window text:error.domain];
                
            } else {
                [MBProgressHUD showToastViewOnView:window text:RequestFailCommomTip];
            }
        }
    };
    
    //请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:RequestFailCommomTip code:[kServiceErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };
    
    //网络不正常,直接走返回失败
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }
    
    //成功回调
    void(^succResultBlock)(id responseObject, BOOL isCacheData) = ^(id responseObject, BOOL isCacheData){
        
        //判断是否为缓存数据
        requestModel.isCacheData = isCacheData;
        
        if (requestModel.loadView && !requestModel.dataTableView) { //防止页面上有其他弹框
            [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        }
        
        //请求状态码为0表示成功，否则失败
        NSInteger code = [responseObject[kRequestCodeKey] integerValue];
        if (code == [kRequestSuccessStatues integerValue])
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
                    [OKFMDBTool saveDataToDB:data byObjectId:cachekey toTable:JsonDataTableType];
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
        NSDictionary *cacheDic = [OKFMDBTool getObjectById:cachekey fromTable:JsonDataTableType];
        if (cacheDic) {
            NSLog(@"请求接口基地址= %@\n\n请求参数= %@\n\n缓存数据成功返回= %@",requestModel.requestUrl,requestModel.parameters,cacheDic);
            succResultBlock(cacheDic,YES);
        }
    }
    
    //是否显示请求转圈
    if (requestModel.loadView && !requestModel.dataTableView) {
        [requestModel.loadView endEditing:YES];
        [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        [MBProgressHUD showLoadingWithView:requestModel.loadView text:RequestLoadingTip];
    }
    
    __block NSURLSessionDataTask *sessionDataTask = nil;

    //发送网络请求,二次封装入口
    sessionDataTask = [OKHttpRequestTools sendOKRequest:requestModel success:^(id returnValue) {
        succResultBlock(returnValue, NO);
        
    } failure:^(NSError *error) {
        
        if (!requestModel.attemptRequestWhenFail) {
            
            NSInteger countNum = [objc_getAssociatedObject(requestModel, kRequestTimeCountKey) integerValue];
            if (countNum<3) {
                countNum++;
                NSLog(@"网络请求已失败，尝试第-----%zd-----次请求===%@\n\n",countNum,requestModel.requestUrl);
                
                //给requestModel关联一个重复请求次数的key
                objc_setAssociatedObject(requestModel, kRequestTimeCountKey, @(countNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                sessionDataTask = [OKHttpRequestTools sendExtensionRequest:requestModel success:successBlock failure:failureBlock];
                
            } else {
                failResultBlock(error);
            }
            
        } else {
            failResultBlock(error);
        }
    }];
    return sessionDataTask;
}



@end


