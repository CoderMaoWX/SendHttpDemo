//
//  CCHttpRequestTools+CCExtension.h
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "CCHttpRequestTools.h"
#import "UITableView+CCExtension.h"
#import "CCHttpRequestModel+CCExtension.h"

/**
 * 封装此网络底层解决的问题:
 *
 1.子类每个发送很多请求后,在退出当前页面时,安全处理了多个网络请求同时返回所做的不必要操作;
 2.每个请求只需要设置一个属性即可添加请求转圈和请求失败提示弹框;
 3.为每个请求提供是否需要缓存网络数据到数据库的操作;
 4.处理了如果页面上有表格,只需要设置一个属性,即可控制表格上下拉刷新控件的状态;
 5.处理了表格如果有分页数据, 底层自动处理分页逻辑,页面只需关注累加返回数据即可;
 6.处理了如果请求无数据,请求失败时,则提示自动添加空白提示页面,和点击再次重试操作;
 */
@interface CCHttpRequestTools (CCExtension)

/**
 http 多功能请求入口
 @param requestModel 请求参数等信息
 @param successBlock 请求成功执行的block
 @param failureBlock 请求失败执行的block
 @return 返回当前请求的对象
 */
+ (NSURLSessionDataTask *)sendMultifunctionCCRequest:(CCHttpRequestModel *)requestModel
                                             success:(CCHttpSuccessBlock)successBlock
                                             failure:(CCHttpFailureBlock)failureBlock;
@end
