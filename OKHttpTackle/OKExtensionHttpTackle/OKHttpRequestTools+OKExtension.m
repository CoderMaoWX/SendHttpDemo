//
//  CCHttpRequestTools+OKExtension.m
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestTools+OKExtension.h"
#import <AFNetworking.h>
#import "CommonCrypto/CommonDigest.h"
#import <CommonCrypto/CommonCryptor.h>
#import "OKRequestTipBgView.h"
#import "OKFMDBTool.h"
#import <objc/runtime.h>
#import <OKAlertView.h>

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
    return [OKHttpRequestTools md5:key];
}

+ (NSString *)md5: (NSString *) inPutText{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);

    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - 包装请求入口

/**
 * 显示表格分页与空数据提示
 */
+ (void)showTipViewAndDataPageWhenReqComplete:(OKHttpRequestModel *)requestModel reqData:(id)responseObject
{
    UIScrollView *tableView = requestModel.dataTableView;
    if (tableView && [tableView isKindOfClass:[UIScrollView class]]) {
        [tableView showRequestTip:responseObject];
    }
}

/**
 * 判断是否需要显示和隐藏请求转圈和提示view
 */
+ (void)showReqLoadingView:(OKHttpRequestModel *)requestModel show:(BOOL)show
{
    if (!requestModel.loadView || requestModel.dataTableView) return;
    if (show) {
        [requestModel.loadView endEditing:YES];
        [MBProgressHUD hideLoadingFromView:requestModel.loadView];
        [MBProgressHUD showLoadingToView:requestModel.loadView text:RequestLoadingTip];
    } else {
        [MBProgressHUD hideLoadingFromView:requestModel.loadView];
    }
}

/**
 * 如果需要提示错误信息,则弹框提示
 */
+ (void)showReqErrorTipText:(OKHttpRequestModel *)requestModel error:(NSError *)error
{
    if (requestModel.errorAlertTipString && !requestModel.dataTableView) {
        //错误码在200-500以内,则按照服务端的错误信息提示
        NSString *errorMsg = error.domain;
        NSInteger code = error.code;
        NSString *msg = requestModel.errorAlertTipString;
        if (code > kOKRequestTipsStatuesMin && code < kOKRequestTipsStatuesMax && errorMsg.length) {
            ShowAlertToast(errorMsg);

        } else if ([msg isKindOfClass:[NSString class]]) {
            if (code != [kOKLoginFail integerValue]) { //已登录才提示
                ShowAlertToast(msg);
            }
        }
    }
}

/**
 * 获取缓存字典
 */
+ (NSDictionary *)getCacheDataByReqModel:(OKHttpRequestModel *)requestModel
{
    //缓存key
    NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl
                                             parameter:requestModel.parameters];
    NSDictionary *cacheDic = [OKFMDBTool getObjectById:cachekey
                                             fromTable:JsonDataTableType];
    return cacheDic;
}

/**
 * 保存网络数据到数据库
 */
+ (BOOL)saveReqDataToCache:(NSDictionary *)responseObject requestModel:(OKHttpRequestModel *)requestModel
{
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData * data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        //缓存key
        NSString *cachekey = [self getCacheKeyByRequestUrl:requestModel.requestUrl
                                                 parameter:requestModel.parameters];
        //保存数据到数据库
        return [OKFMDBTool saveDataToDB:data
                             byObjectId:cachekey
                                toTable:JsonDataTableType];
    }
    return  NO;
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

        /** 回调页面请求 */
        if (failureBlock) {
            failureBlock(error);
        }
        //判断是否需要显示和隐藏请求转圈和提示view
        [self showReqLoadingView:requestModel show:NO];

        //如果需要提示错误信息,则弹框提示
        [self showReqErrorTipText:requestModel error:error];

        //如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态
        [self showTipViewAndDataPageWhenReqComplete:requestModel reqData:error];
    };

    //成功回调
    void(^succResultBlock)(id responseObject, BOOL isCacheData) = ^(id responseObject, BOOL isCacheData){
        //判断是否为缓存数据
        requestModel.isCacheData = isCacheData;

        //判断是否需要显示和隐藏请求转圈和提示view
        [self showReqLoadingView:requestModel show:NO];

        //请求状态码为0表示成功，否则失败
        NSString *code = [NSString stringWithFormat:@"%@",responseObject[kOKRequestCodeKey]];
        if ([responseObject isKindOfClass:[NSDictionary class]] &&
            [code isEqualToString:kOKRequestSuccessStatues])
        {
            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }

            /** <2>.如果请求完成后需要判断页面表格下拉控件,分页,空白提示页的状态 */
            [self showTipViewAndDataPageWhenReqComplete:requestModel reqData:responseObject];

            /** <3>.是否需要缓存 */
            if (isCacheData == NO && requestModel.requestCachePolicy == RequestStoreCacheData) {
                //保存网络数据到数据库
                [self saveReqDataToCache:responseObject requestModel:requestModel];
            }

        } else { //请求code不正确,走失败
            NSString *tipMsg = [NSString stringWithFormat:@"%@",responseObject[kOKRequestMessageKey] ? : @""];
            NSDictionary *userInfo = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            //失败回调页面
            failResultBlock([NSError errorWithDomain:tipMsg code:[code integerValue] userInfo:userInfo]);
        }
    };

    //如果有网络缓存, 则立即返回缓存, 同时继续请求网络最新数据
    if (successBlock && requestModel.requestCachePolicy == RequestStoreCacheData) {
        NSDictionary *cacheDic = [self getCacheDataByReqModel:requestModel];
        if (cacheDic) {
            NSLog(@"\n❤️❤️❤️请求接口基地址= %@\n\n请求参数= %@\n缓存数据成功返回= %@",requestModel.requestUrl,requestModel.parameters,cacheDic);
            succResultBlock(cacheDic,YES);
        }
    }

    //判断是否需要显示和隐藏请求转圈和提示view
    [self showReqLoadingView:requestModel show:YES];

    //发送网络请求,二次封装入口
    __block NSURLSessionDataTask *sessionDataTask = nil;
    sessionDataTask = [OKHttpRequestTools sendOKRequest:requestModel success:^(id returnValue) {
        succResultBlock(returnValue, NO);

    } failure:^(NSError *error) {

        //请求失败后再重复请求的次数
        if (requestModel.tryRequestWhenFailCount>0) {
            NSInteger countNum = [objc_getAssociatedObject(requestModel, kRequestTimeCountKey) integerValue];
            if (countNum < requestModel.tryRequestWhenFailCount) {
                countNum++;
                NSLog(@"⁉️⁉️⁉️请求已失败，尝试第-----%zd-----次请求===%@",countNum,requestModel.requestUrl);

                //给requestModel关联一个重复请求次数的key
                objc_setAssociatedObject(requestModel, kRequestTimeCountKey, @(countNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                sessionDataTask = [OKHttpRequestTools sendExtensionRequest:requestModel
                                                                   success:successBlock
                                                                   failure:failureBlock];
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
