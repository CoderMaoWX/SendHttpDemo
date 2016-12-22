//
//  CCHttpRequestTools.m
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "CCHttpRequestTools.h"
#import <AFNetworking.h>

@implementation CCHttpRequestTools


static AFHTTPSessionManager *mgr_;

/**
 *  常见创建请求管理者
 */
+ (void)initialize
{
    mgr_ = [AFHTTPSessionManager manager];
    mgr_.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr_.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr_.requestSerializer.timeoutInterval = 60;//默认超时时间
    mgr_.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
}

#pragma mark - 包装请求入口

/**
 http 发送请求入口
 
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendCCRequest:(CCHttpRequestModel *)requestModel
                                success:(CCHttpSuccessBlock)successBlock
                                failure:(CCHttpFailureBlock)failureBlock
{
    //请求地址为空则不请求
    if (!requestModel.requestUrl) return nil;
    
    //如果有相同url正在请求, 则取消此次请求
    if ([self isCurrentSessionDataTaskRunning:requestModel]) return nil;

    //失败回调
    void (^failResultBlock)(NSError *) = ^(NSError *error){
        NSLog(@"请求参数= %@\n请求地址= %@\n网络数据失败返回= %@",requestModel.parameters,requestModel.requestUrl,error);
        
        if (failureBlock) {
            failureBlock(error);
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    //成功回调
    void(^succResultBlock)(id responseObject) = ^(id responseObject){
        
        NSInteger code = [responseObject[kRequestCodeKey] integerValue];
        if (code == 0 || code == 200)
        {
            NSLog(@"请求参数= %@\n请求地址= %@\n网络数据成功返回= %@",requestModel.parameters,requestModel.requestUrl,responseObject);
            
            /** <1>.回调页面请求 */
            if (successBlock) {
                successBlock(responseObject);
            }
            
        } else { //请求code不正确,走失败
            failResultBlock([NSError errorWithDomain:responseObject[kRequestMessageKey] code:code userInfo:nil]);
        }
        
        //每个请求完成后,从队列中移除当前请求任务
        [self removeCompletedTaskSession:requestModel];
    };
    
    //网络不正常,直接走返回失败
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        if (failureBlock) {
            failResultBlock([NSError errorWithDomain:NetworkConnectFailTip code:kCFURLErrorNotConnectedToInternet userInfo:nil]);
        }
        return nil;
    }
    
    //设置请求超时时间
    mgr_.requestSerializer.timeoutInterval = requestModel.timeOut ? : 60;

    NSURLSessionDataTask *sessionDataTask = nil;
    
    //根据网络请求方式发请求
    if (requestModel.requestType == HttpRequestTypeGET) {
        
        //get请求
        sessionDataTask = [mgr_ GET:requestModel.requestUrl
                         parameters:requestModel.parameters
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                NSLog(@"get请求请求绝对地址: %@",task.response.URL.absoluteString);
                                succResultBlock(responseObject);
                                
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];
        
    }
    else if(requestModel.requestType == HttpRequestTypePOST){
        
        //post请求
        sessionDataTask = [mgr_ POST:requestModel.requestUrl
                          parameters:requestModel.parameters
                            progress:nil
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                 NSLog(@"post请求请求绝对地址: %@",task.response.URL.absoluteString);
                                 succResultBlock(responseObject);
                      
                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];
        
    }
    else if(requestModel.requestType == HttpRequestTypeHEAD){
        
        //head请求
        sessionDataTask = [mgr_ HEAD:requestModel.requestUrl
                          parameters:requestModel.parameters
                             success:^(NSURLSessionDataTask * _Nonnull task) {
                                 NSLog(@"head请求请求绝对地址: %@",task.response.URL.absoluteString);
                                 succResultBlock(task);
            
                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 failResultBlock(error);
                             }];
        
    }
    else if(requestModel.requestType == HttpRequestTypePUT){
        
        //put请求
        sessionDataTask = [mgr_ PUT:requestModel.requestUrl
                         parameters:requestModel.parameters
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                NSLog(@"put请求请求绝对地址: %@",task.response.URL.absoluteString);
                                succResultBlock(task);
                     
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                failResultBlock(error);
                            }];
    }
    
    //添加请求操作对象
    if (sessionDataTask) {
        [requestModel.sessionDataTaskArr addObject:sessionDataTask];
    }
    
    return sessionDataTask;
}


/**
 * 判断是否有相同的url正在请求
 */
+ (BOOL)isCurrentSessionDataTaskRunning:(CCHttpRequestModel *)requestModel
{
    NSString *requestUrl = requestModel.requestUrl;
    for (NSURLSessionDataTask *sessionDataTask in requestModel.sessionDataTaskArr) {
        
        NSString *oldReqUrl = [sessionDataTask.currentRequest.URL description];
        if ([oldReqUrl isEqualToString:requestUrl]) {
            
            if (sessionDataTask.state != NSURLSessionTaskStateCompleted) {
                NSLog(@"有相同url正在请求, 取消此次请求===%@",requestModel.requestUrl);
                return YES;
            }
        }
    }
    return NO;
}

/**
 * 移除当前完成了的请求NSURLSessionDataTask
 */
+ (void)removeCompletedTaskSession:(CCHttpRequestModel *)requestModel
{
    NSString *requestUrl = requestModel.requestUrl;
    NSArray *allTaskArr = requestModel.sessionDataTaskArr.copy;
    for (NSURLSessionDataTask *sessionDataTask in allTaskArr) {
        
        NSString *oldReqUrl = [sessionDataTask.currentRequest.URL description];
        if ([oldReqUrl isEqualToString:requestUrl]) {
            
            if (sessionDataTask.state == NSURLSessionTaskStateCompleted) {
                [requestModel.sessionDataTaskArr removeObject:sessionDataTask];
                NSLog(@"移除当前完成了的请求NSURLSessionDataTask===%@",requestModel.requestUrl);
            }
        }
    }
}

@end

