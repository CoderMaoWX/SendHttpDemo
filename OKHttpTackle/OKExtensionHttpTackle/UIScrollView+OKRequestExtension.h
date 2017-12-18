//
//  UIScrollView+OKRequestExtension.h
//  CommonFrameWork
//
//  Created by mao wangxin on 2017/4/17.
//  Copyright © 2017年 OKDeer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>

//判断表格数据分页的字段key
#define kTotalPageKey                               @"totalPage"
#define kCurrentPageKey                             @"currentPage"
#define kListKey                                    @"list"

/** 进入刷新状态的回调 */
typedef void (^OKRefreshingBlock)(void);

typedef enum : NSUInteger {
    RequestNormalStatus,    //0 正常状态
    RequestEmptyDataStatus, //1 空数据状态
    RequestFailStatus,      //2 请求失败状态
    RequesNoNetWorkStatus,  //3 网络连接失败状态
} TableVieTipStatus;


@interface UIScrollView (OKRequestExtension)


/** 一个属性即可自动设置显示请求提示view，(但是在请求失败时只能显示无数据提示) */
@property (nonatomic, assign) BOOL automaticShowTipView;

/**
 * 以下所有的属性需要配合 <showRequestTip:> 方法使用
 */
/** 如果是UItableView,底部显示没有更多数据提示 */
@property (nonatomic, strong) NSString *footerTipString;
/** 如果是UItableView,底部显示没有更多数据提示图片 */
@property (nonatomic, strong) UIImage *footerTipImage;

/** 空数据文字 */
@property (nonatomic, strong) NSString *reqEmptyTipString;
/** 空数据图片 */
@property (nonatomic, strong) UIImage *reqEmptyTipImage;
/** 请求失败文字 */
@property (nonatomic, strong) NSString *reqFailTipString;
/** 请求失败图片 */
@property (nonatomic, strong) UIImage *reqFailTipImage;
/** 网络连接失败文字 */
@property (nonatomic, strong) NSString *netErrorTipString;
/** 网络连接失败图片 */
@property (nonatomic, strong) UIImage *netErrorTipImage;
/** 自定义按钮标题 */
@property (nonatomic, strong) NSString *customBtnTitle;
/** 自定义按钮点击的事件 */
@property (nonatomic, copy) void (^customBtnActionBlcok)(void);


#pragma mark -- 给表格添加上下拉刷新事件

/**
 初始化表格的上下拉刷新控件

 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(OKRefreshingBlock)headerBlock
             footerBlock:(OKRefreshingBlock)footerBlock;


#pragma mark -- 处理表格上下拉刷新,分页,添加空白页事件

/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作，
 使用方法：--> 需要在网络请求的成功和失败回调中调用即可
 @param responseData 网络请求回调数据 (NSDictionary,NSError)
 */
- (void)showRequestTip:(id)responseData;

@end

