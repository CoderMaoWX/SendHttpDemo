//
//  CCHttpRequestTools.m
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKHttpRequestTools.h"
#import <objc/runtime.h>
#import "AFNetworking.h"

static NSMutableArray *globalReqManagerArr_;
static char const * const kRequestUrlKey    = "kRequestUrlKey";

@implementation OKHttpRequestTools

+ (void)load
{
    //开始监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/**
 *  创建请全局求管理者
 */
+ (void)initialize
{
    //维护一个全局请求管理数组,可方便在推出登录,内存警告时清除所有请求
    globalReqManagerArr_ = [NSMutableArray array];
}

#pragma mark -取消全局所有请求

/**
 * 取消全局请求管理数组中所有请求操作
 */
+ (void)cancelGlobalAllReqMangerTask
{
    if (globalReqManagerArr_.count==0) return;
    
    for (NSURLSessionDataTask *sessionTask in globalReqManagerArr_) {
        NSLog(@"取消全局请求管理数组中所有请求操作===%@",sessionTask);
        if ([sessionTask isKindOfClass:[NSURLSessionDataTask class]]) {
            [sessionTask cancel];
        }
    }
    //清除所有请求对象
    [globalReqManagerArr_ removeAllObjects];
}


/**
 *  创建请求管理者
 */
+ (AFHTTPSessionManager *)afManager
{
    AFHTTPSessionManager *mgr_ = [AFHTTPSessionManager manager];
    mgr_.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr_.requestSerializer.timeoutInterval = 60;//设置请求默认超时时间
    mgr_.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr_.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    return mgr_;
}

#pragma mark -======== 底层公共请求入口 ========

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendOKRequest:(OKHttpRequestModel *)requestModel
                                success:(OKHttpSuccessBlock)successBlock
                                failure:(OKHttpFailureBlock)failureBlock
{
    //============失败回调============
    void (^failResultBlock)(NSError *) = ^(NSError *error){

        //包装请求超时NSError
        if (error.code == kCFURLErrorTimedOut) {
            error = [NSError errorWithDomain:RequestTimedOutTip code:[kOKTimedOutCode integerValue] userInfo:nil];
        }
        [self printAbsoluteUrl:error];
        NSLog(@"\n❌❌❌请求接口基地址= %@\n请求参数= %@\n网络数据失败返回= %@\n",requestModel.requestUrl,requestModel.parameters,error);

        //如果不是因为重复请求而失败，就标记为该请求已经结束。否则还是还是保持正在请求的状态
        if (error.code != [kOKRepeatRequest integerValue]) {
            requestModel.isRequesting = NO;
        }
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];

        if (error.code != NSURLErrorCancelled) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            NSLog(@"‼️页面已主动触发取消请求,此次请求不回调到页面");
        }

        //判断Token状态是否为失效
        if (error.code == [kOKLoginFail integerValue]) {
            //通知页面需要重新登录
            [[NSNotificationCenter defaultCenter] postNotificationName:kOKTokenExpiryNotification object:error];
        }
    };

    //网络不正常,直接走返回失败
    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }

    //已经在请求了,不再请求
    if (requestModel.isRequesting) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:RequestRepeatFailTip code:[kOKRepeatRequest integerValue] userInfo:nil]);
        }
        return nil;
    } else {
        //没有请求就标记为正在请求
        requestModel.isRequesting = YES;
    }

    //请求地址为空则不请求
    if (!requestModel.requestUrl) {
        if (failResultBlock) {
            failResultBlock([NSError errorWithDomain:RequestFailCommomTip code:[kOKServiceErrorStatues integerValue] userInfo:nil]);
        }
        return nil;
    };

    //============成功回调============
    void(^succResultBlock)(id responseObject) = ^(id responseObject){

        NSString *code = [NSString stringWithFormat:@"%@",responseObject[kOKRequestCodeKey]];
        if ([responseObject isKindOfClass:[NSDictionary class]] &&
            [code isEqualToString:kOKRequestSuccessStatues])
        {
            NSLog(@"\n✅✅✅请求接口基地址= %@\n请求参数= %@\n网络数据成功返回= %@\n",requestModel.requestUrl,requestModel.parameters,responseObject);

            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }

        } else { //请求code不正确,走失败
            NSString *tipMsg = [NSString stringWithFormat:@"%@",responseObject[kOKRequestMessageKey] ? : RequestFailCommomTip];
            NSDictionary *userInfo = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            NSError *error = [NSError errorWithDomain:tipMsg code:[code integerValue] userInfo:userInfo];
            failResultBlock(error);

            /** 通知页面需要重新登录 */
            if ([code isEqualToString:kOKLoginFail]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kOKTokenExpiryNotification object:error];
            }
        }
        requestModel.isRequesting = NO;

        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };

    //根据请求方式发送网络请求
    return [self startRequest:requestModel succResultBlock:succResultBlock failResultBlock:failResultBlock];
}

/**
 * 根据请求方式发送网络请求
 */
+ (NSURLSessionDataTask *)startRequest:(OKHttpRequestModel *)requestModel
                       succResultBlock:(OKHttpSuccessBlock)succResultBlock
                       failResultBlock:(OKHttpFailureBlock)failResultBlock
{
    NSURLSessionDataTask *sessionDataTask = nil;

    //设置请求超时时间
    AFHTTPSessionManager *mgr_ = [self afManager];
    mgr_.requestSerializer.timeoutInterval = requestModel.timeOut ? : 60;

    //根据网络请求方式发请求
    if (requestModel.requestType == OKHttpRequestTypeGET) {

        //get请求
        sessionDataTask = [mgr_ GET:requestModel.requestUrl
                         parameters:requestModel.parameters
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                succResultBlock(responseObject);

                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];

    }
    else if(requestModel.requestType == OKHttpRequestTypePOST){

        //post请求
        sessionDataTask = [mgr_ POST:requestModel.requestUrl
                          parameters:requestModel.parameters
                            progress:nil
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                 succResultBlock(responseObject);

                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];

    }
    else if(requestModel.requestType == OKHttpRequestTypeHEAD){

        //head请求
        sessionDataTask = [mgr_ HEAD:requestModel.requestUrl
                          parameters:requestModel.parameters
                             success:^(NSURLSessionDataTask * _Nonnull task) {
                                 succResultBlock(task);

                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];

    }
    else if(requestModel.requestType == OKHttpRequestTypePUT){

        //put请求
        sessionDataTask = [mgr_ PUT:requestModel.requestUrl
                         parameters:requestModel.parameters
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                succResultBlock(responseObject);

                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];
    }

    //给sessionDataTask关联一个请求key
    [self relatingDataTask:requestModel sessionDataTask:sessionDataTask];
    return sessionDataTask;
}

#pragma mark - 相同请求逻辑判断

/**
 * 给sessionDataTask关联一个请求key
 */
+ (void)relatingDataTask:(OKHttpRequestModel *)requestModel sessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    if (sessionDataTask) {
        objc_setAssociatedObject(sessionDataTask, kRequestUrlKey, requestModel.requestUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
        if (requestModel.sessionDataTaskArr) {
            [requestModel.sessionDataTaskArr addObject:sessionDataTask];
        } else {
            [globalReqManagerArr_ addObject:sessionDataTask];
        }
    }
}

/**
 * 移除当前完成了的请求NSURLSessionDataTask
 */
+ (void)removeCompletedTaskSession:(OKHttpRequestModel *)requestModel
{
    NSString *requestUrl = requestModel.requestUrl;
    if (requestModel.sessionDataTaskArr) {
        //移除页面上传进来的管理数组
        [self removeTaskFromArr:requestModel.sessionDataTaskArr requestUrl:requestUrl];
    } else {
        //移除全局请求数组
        [self removeTaskFromArr:globalReqManagerArr_ requestUrl:requestUrl];
    }
}

#pragma mark - 处理操作请求数组

/**
 * 根据数组移除已完成的请求
 */
+ (void)removeTaskFromArr:(NSMutableArray *)reqArr requestUrl:(NSString *)requestUrl
{
    NSArray *allTaskArr = reqArr.copy;
    for (NSURLSessionDataTask *sessionDataTask in allTaskArr) {

        NSString *oldReqUrl = objc_getAssociatedObject(sessionDataTask, kRequestUrlKey);
        if ([oldReqUrl isEqualToString:requestUrl]) {

            if (sessionDataTask.state == NSURLSessionTaskStateCompleted) {
                [reqArr removeObject:sessionDataTask];
                //NSLog(@"\n‼️移除管理数组中完成了的请求===%@",reqArr);
            }
        }
    }
}

/**
 * 打印请求的绝对地址
 */
+ (void)printAbsoluteUrl:(NSError *)error
{
#ifdef DEBUG
    NSDictionary *errorInfo = error.userInfo;
    if (errorInfo && [errorInfo isKindOfClass:[NSDictionary class]]) {
        NSString *absoluteUrl = errorInfo[@"NSErrorFailingURLStringKey"];
        if (absoluteUrl.length>0) {
            NSLog(@"‼️ 请求接口绝对地址: %@",absoluteUrl);
        }
    }
#endif
}

@end
