//
//  CCHttpRequestTools.h
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCHttpRequestModel.h"

typedef void (^CCHttpSuccessBlock) (id returnValue);
typedef void (^CCHttpFailureBlock) (NSError * error);


@interface CCHttpRequestTools : NSObject

/**
 http 发送请求入口
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendCCRequest:(CCHttpRequestModel *)requestModel
                              success:(CCHttpSuccessBlock)successBlock
                              failure:(CCHttpFailureBlock)failureBlock;

@end
