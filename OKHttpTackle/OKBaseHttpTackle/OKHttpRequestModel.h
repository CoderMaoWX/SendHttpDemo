//
//  OKHttpRequestModel.h
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/12/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <Foundation/Foundation.h>

//************客户端自定义错误码提示*******************
/** 网络连接失败 */
#define NetworkConnectFailTip                   @"网络开小差, 请稍后再试"
/** 请求超时 */
#define RequestTimedOutTip                      @"请求超时,请稍后重试"
/** 重复请求 */
#define RequestRepeatFailTip                    @"重复请求!"
/** 错误码在200-500以外的失败统一提示 */
#define RequestFailCommomTip                    @"数据加载失败, 请重试"
/** 请求转圈的统一提示*/
#define RequestLoadingTip                       @"正在拼命加载中..."

static NSString *const kOKRequestCodeKey          = @"code";                      /**< 请求code 的key */
static NSString *const kOKRequestMessageKey       = @"message";                   /**< 请求message 的key */
static NSString *const kOKRequestDataKey          = @"data";                      /**< 请求data 的key */
static NSString *const kOKRequestListkey          = @"list";                      /**< 请求list 的key */
static NSString *const kOKRepeatRequest           = @"-1";                        /**< 重复请求的标志 */
static NSString *const kOKLoginFail               = @"4";                         /**< 需要重新登录标志 */
static NSString *const kOKTimedOutCode            = @"444";                       /**< 请求超时标志 */
static NSString *const kOKServiceErrorStatues     = @"9";                         /**< 请求失败的标志 */
static NSString *const kOKRequestSuccessStatues   = @"0";                         /**< 请求成功的code */
static NSInteger const kOKRequestTipsStatuesMin   = 200;                          /**< 提示后台的code最小值 */
static NSInteger const kOKRequestTipsStatuesMax   = 500;                          /**< 提示后台的code最大值 */
static NSString *const kOKTokenExpiryNotification = @"kOKTokenExpiryNotification";  /**< token实效的通知名称 */

typedef enum : NSUInteger {
    OKHttpRequestTypePOST = 0 ,           /**< post 请求 */
    OKHttpRequestTypeGET   ,              /**< get 请求 */
    OKHttpRequestTypeHEAD  ,              /**< head 请求 */
    OKHttpRequestTypePUT   ,              /**< put 请求 */
}OKHttpRequestType;/**< 请求类型 */


@interface OKHttpRequestModel : NSObject


/**< 必传参数:请求参数字典信息 */
@property (nonatomic, strong) id parameters;

/**< 必传参数:请求地址 */
@property (nonatomic,copy) NSString *requestUrl;

/**< 请求类型 (默认为post) */
@property (nonatomic, assign) OKHttpRequestType requestType;

/**< 请求超时 (默认为60s) */
@property (nonatomic,assign) int timeOut;

/**< 是否正在当前请求 */
@property (nonatomic, assign) BOOL isRequesting;

/** 可选参数: 如果请求时传一个空数组进来, 底层会自动管理相同的请求, 禁止同时重复请求 */
@property (nonatomic, strong) NSMutableArray <NSURLSessionDataTask *> *sessionDataTaskArr;


@end

