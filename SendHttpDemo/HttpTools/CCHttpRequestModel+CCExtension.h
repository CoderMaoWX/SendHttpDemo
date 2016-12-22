//
//  CCHttpRequestModel+CCExtension.h
//  HttpDemo
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "CCHttpRequestModel.h"
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RequestIgnoreCacheData, //忽略网络数据
    RequestStoreCacheData,  //缓存网络数据
} CCRequestCachePolicy;//是否需要缓存网络数据


/**
 * 网络请求Model扩展信息
 */
@interface CCHttpRequestModel (CCExtension)


/** 请求时转圈的父视图 */
@property (nonatomic, strong) UIView *loadView;

/** 页面上有表格如果传此参数,请求完成后会自动刷新页面,控制表格下拉刷新状态, 请求失败,空数据等 会自动添加空白页 */
@property (nonatomic, strong) UITableView *dataTableView;

/** 是否在底层提示失败信息 (默认提示) */
@property (nonatomic, assign) BOOL forbidTipErrorInfo;

/** 是否需要在底层缓存当前网络数据 */
@property (nonatomic, assign) CCRequestCachePolicy requestCachePolicy;

/** 此次返回的数据是否为缓存数据 */
@property (nonatomic, assign) BOOL isCacheData;

@end
