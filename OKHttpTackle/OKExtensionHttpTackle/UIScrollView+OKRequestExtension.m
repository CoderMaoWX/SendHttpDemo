//
//  UIScrollView+OKRequestExtension.m
//  CommonFrameWork
//
//  Created by mao wangxin on 2017/4/17.
//  Copyright © 2017年 OKDeer. All rights reserved.
//

#import "UIScrollView+OKRequestExtension.h"
#import <AFNetworkReachabilityManager.h>
#import "OKRequestTipBgView.h"

/** 网络连接失败 */
#define kNetworkConnectDefaultFailTips              @"网络开小差, 请稍后再试"
#define kAgainRequestDefaultTipString               @"重新加载"
#define kEmptyDataDefaultTipText                    @"暂无数据"
#define kReqFailDefaultTipText                      @"数据加载失败"
/*  弱引用 */
#define WEAKSELF                                    typeof(self) __weak weakSelf = self;
/*  强引用 */
#define STRONGSELF                                  typeof(weakSelf) __strong strongSelf = weakSelf;

//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

//-忽略警告的宏-
#define OKPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static char const * const kAutomaticShowTipViewKey  = "kAutomaticShowTipViewKey";
static char const * const kFooterTipStringKey       = "kFooterTipStringKey";
static char const * const kFooterTipImageKey        = "kFooterTipImageKey";
static char const * const kReqEmptyTipStringKey     = "kReqEmptyTipStringKey";
static char const * const kReqEmptyTipImageKey      = "kReqEmptyTipImageKey";
static char const * const kReqFailTipStringKey      = "kReqFailTipStringKey";
static char const * const kReqFailTipImageKey       = "kReqFailTipImageKey";
static char const * const kNetErrorTipStringKey     = "kNetErrorTipStringKey";
static char const * const kNetErrorTipImageKey      = "kNetErrorTipImageKey";
static char const * const kActionBtnTitleKey        = "kActionBtnTitleKey";
static char const * const kActionBtnBlockKey        = "kActionBtnBlockKey";

@implementation NSObject (ScrollViewSwizze)

+ (void)ok_exchangeInstanceMethod:(SEL)originSelector otherSelector:(SEL)otherSelector
{
    method_exchangeImplementations(class_getInstanceMethod(self, originSelector), class_getInstanceMethod(self, otherSelector));
}
@end

@implementation UIScrollView (OKRequestExtension)

// ==================== 是否自动显示请求提示view ====================

- (void)setAutomaticShowTipView:(BOOL)automaticShowTipView
{
    objc_setAssociatedObject(self, kAutomaticShowTipViewKey, @(automaticShowTipView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)automaticShowTipView
{
    id value = objc_getAssociatedObject(self, kAutomaticShowTipViewKey);
    return [value boolValue];
}

// ==================== UItableView"没有更多数据"提示 ====================

- (void)setFooterTipString:(NSString *)footerTipString
{
    objc_setAssociatedObject(self, kFooterTipStringKey, footerTipString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)footerTipString
{
    return objc_getAssociatedObject(self, kFooterTipStringKey);//@"—— 没有更多数据啦 ——"
}

// ==================== UItableView"没有更多数据"提示图片 ====================

- (void)setFooterTipImage:(UIImage *)footerTipImage
{
    objc_setAssociatedObject(self, kFooterTipImageKey, footerTipImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)footerTipImage
{
    return objc_getAssociatedObject(self, kFooterTipImageKey);
}

// ==================== 请求空数据提示 ====================

- (void)setReqEmptyTipString:(NSString *)reqEmptyTipString
{
    objc_setAssociatedObject(self, kReqEmptyTipStringKey, reqEmptyTipString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)reqEmptyTipString
{
    NSString *emptyTip = objc_getAssociatedObject(self, kReqEmptyTipStringKey);
    return emptyTip ? : kEmptyDataDefaultTipText;
}

// ==================== 请求空数据图片 ====================

- (void)setReqEmptyTipImage:(UIImage *)reqEmptyTipImage
{
    objc_setAssociatedObject(self, kReqEmptyTipImageKey, reqEmptyTipImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)reqEmptyTipImage
{
    UIImage *image = objc_getAssociatedObject(self, kReqEmptyTipImageKey);
    if (!image) {
        image = [self getBundleImageByName:@"OKHttpTackle.bundle/ok_empty_data_icon"];
    }
    return image;
}

// ==================== 请求失败提示 ====================

- (void)setReqFailTipString:(NSString *)reqFailTipString
{
    objc_setAssociatedObject(self, kReqFailTipStringKey, reqFailTipString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)reqFailTipString
{
    NSString *tipStr = objc_getAssociatedObject(self, kReqFailTipStringKey);
    return tipStr ? : kReqFailDefaultTipText;
}

// ==================== 请求失败图片 ====================

- (void)setReqFailTipImage:(UIImage *)reqFailTipImage
{
    objc_setAssociatedObject(self, kReqFailTipImageKey, reqFailTipImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)reqFailTipImage
{
    UIImage *image = objc_getAssociatedObject(self, kReqFailTipImageKey);
    if (!image) {
        image = [self getBundleImageByName:@"OKHttpTackle.bundle/ok_loading_fail_icon"];
    }
    return image;
}

// ==================== 网络错误提示 ====================

- (void)setNetErrorTipString:(NSString *)netErrorTipString
{
    objc_setAssociatedObject(self, kNetErrorTipStringKey, netErrorTipString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)netErrorTipString
{
    NSString *tipStr = objc_getAssociatedObject(self, kNetErrorTipStringKey);
    return tipStr ? : kNetworkConnectDefaultFailTips;
}

// ==================== 网络错误图片 ====================

- (void)setNetErrorTipImage:(UIImage *)netErrorTipImage
{
    objc_setAssociatedObject(self, kNetErrorTipImageKey, netErrorTipImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)netErrorTipImage
{
    UIImage *image = objc_getAssociatedObject(self, kNetErrorTipImageKey);
    if (!image) {
        image = [self getBundleImageByName:@"OKHttpTackle.bundle/ok_networkfail_icon"];
    }
    return image;
}

// ==================== 按钮点击的Target ====================

- (void)setCustomBtnTitle:(NSString *)customBtnTitle
{
    objc_setAssociatedObject(self, kActionBtnTitleKey, customBtnTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)customBtnTitle
{
    return objc_getAssociatedObject(self, kActionBtnTitleKey);
}

// ==================== 按钮点击事件回调 ====================

- (void)setCustomBtnActionBlcok:(void (^)(void))customBtnActionBlcok
{
    objc_setAssociatedObject(self, kActionBtnBlockKey, customBtnActionBlcok, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))customBtnActionBlcok
{
    return objc_getAssociatedObject(self, kActionBtnBlockKey);
}

/**
 *  获取NSBundle里的提示图片资源
 */
- (UIImage *)getBundleImageByName:(NSString *)name
{
    return [UIImage imageNamed:name
                      inBundle:[NSBundle bundleForClass:[OKRequestTipBgView class]]
 compatibleWithTraitCollection:nil];
}

/**
 * 开始监听网络
 */
+ (void)load
{
    //AFN需要提前监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - 给表格添加上下拉刷新事件

/**
 初始化表格的上下拉刷新控件

 @param headerBlock 下拉刷新需要调用的函数
 @param footerBlock 上啦刷新需要调用的函数
 */
- (void)addheaderRefresh:(OKRefreshingBlock)headerBlock footerBlock:(OKRefreshingBlock)footerBlock
{
    if (headerBlock) {
        WEAKSELF
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            STRONGSELF

            //1.先移除页面上已有的提示视图
            [strongSelf removeOldTipBgView];

            //2.每次下拉刷新时先结束上啦
            [strongSelf.mj_footer endRefreshing];

            headerBlock();
        }];
        [self.mj_header beginRefreshing];
    }

    if (footerBlock) {
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            footerBlock();
        }];
        //这里需要先隐藏,否则已进入页面没有数据也会显示上拉view
        self.mj_footer.hidden = YES;
    }
}

#pragma mark - 给表格添加上请求失败提示事件

/**
 调用此方法,会自动处理表格上下拉刷新,分页,添加空白页等操作

 @param responseData 网络请求回调数据
 */
- (void)showRequestTip:(id)responseData
{
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }

    if (self.mj_footer) {
        [self.mj_footer endRefreshing];
    }

    //判断请求状态: responseData为字典就是请求成功, 为NSError或nil则是请求失败
    BOOL requestSuccess = [responseData isKindOfClass:[NSDictionary class]];

    if ([self contentViewIsEmptyData]) {//页面没有数据

        //根据状态,显示背景提示Viwe
        if (![AFNetworkReachabilityManager sharedManager].reachable) {
            //显示没有网络提示
            [self showTipWithStatus:RequesNoNetWorkStatus];

        } else {
            //成功:显示空数据提示, 失败:显示请求失败提示
            TableVieTipStatus status = requestSuccess ? RequestEmptyDataStatus : RequestFailStatus;
            [self showTipWithStatus:status];
        }

    } else { //页面有数据

        //移除页面上已有的提示视图
        [self removeOldTipBgView];

        if (requestSuccess && self.mj_footer) {
            //控制刷新控件显示的分页逻辑
            [self setPageRefreshStatus:responseData];
        }

        //分页时页面上有数据，但下拉失败时需要提示
        if (!requestSuccess && self.mj_header) {
            //RequestFailCommomTip
            [MBProgressHUD showToastToWindow:@"数据加载失败, 请重试"];
        }
    }
}

#pragma mark - 如果请求失败,无网络则展示空白提示view

/**
 * 设置提示图片和文字
 */
- (void)showTipWithStatus:(TableVieTipStatus)state
{
    //先移除页面上已有的提示视图
    [self removeOldTipBgView];

    //不显示表格的FooterView
    [self showTableFootView:NO];

    WEAKSELF
    void (^removeTipViewBlock)(void) = ^(){
        STRONGSELF
        //移除提示视图,重新请求
        [strongSelf removeTipViewAndRefresh];
    };

    void (^customBtnActionBlock)(void) = ^(){
        STRONGSELF
        //如果额外设置了按钮事件
        if (strongSelf.customBtnActionBlcok) {
            //1. 先移除页面上已有的提示视图
            [strongSelf removeOldTipBgView];
            //2. 回调按钮点击事件
            strongSelf.customBtnActionBlcok();
        }
    };

    NSString *tipString = nil;
    UIImage *tipImage = nil;
    NSString *actionTitle = nil;
    void (^block)(void) = nil;
    BOOL needToSelector = self.customBtnActionBlcok ? YES : NO;

    if (state == RequesNoNetWorkStatus) {//没有网络

        tipString = self.netErrorTipString;
        tipImage = self.netErrorTipImage;
        actionTitle = self.customBtnTitle ? : kAgainRequestDefaultTipString;
        if (self.mj_header) {
            block = removeTipViewBlock;

        } else if (needToSelector) {
            block = customBtnActionBlock;
        } else {
            actionTitle = nil;
        }
    } else if (state == RequestEmptyDataStatus) {//空数据提示

        tipString = self.reqEmptyTipString;
        tipImage = self.reqEmptyTipImage;
        actionTitle = self.customBtnTitle;
        block = customBtnActionBlock;

    } else if (state == RequestFailStatus) {//请求失败提示

        tipString = self.reqFailTipString;
        tipImage = self.reqFailTipImage;
        actionTitle = self.customBtnTitle ? : kAgainRequestDefaultTipString;
        if (self.mj_header) {
            block = removeTipViewBlock;

        } else if (needToSelector) {
            block = customBtnActionBlock;
        } else {
            actionTitle = nil;
        }
    } else {
        return;
    }

    //需要显示的自定义提示view
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    OKRequestTipBgView *tipBgView = [OKRequestTipBgView tipViewByFrame:rect
                                                        tipImage:tipImage
                                                         tipText:tipString
                                                     actionTitle:actionTitle
                                                     actionBlock:block];
    tipBgView.backgroundColor = self.backgroundColor ? : [UIColor clearColor];
    [self addSubview:tipBgView];
}

/**
 * 控制刷新控件显示的分页逻辑
 */
- (void)setPageRefreshStatus:(NSDictionary *)responseData
{
    id totalPage = responseData[kTotalPageKey];
    id currentPage = responseData[kCurrentPageKey];
    NSArray *dataArr = responseData[kListKey];

    if (totalPage && currentPage) {

        if ([totalPage integerValue] > [currentPage integerValue]) {
            self.mj_footer.hidden = NO;

            //是否显示表格的FooterView
            [self showTableFootView:NO];

        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
            self.mj_footer.hidden = YES;

            //是否显示表格的FooterView
            [self showTableFootView:YES];
        }

    } else if([dataArr isKindOfClass:[NSArray class]]){
        if (dataArr.count>0) {
            self.mj_footer.hidden = NO;

            //是否显示表格的FooterView
            [self showTableFootView:NO];

        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
            self.mj_footer.hidden = YES;

            //是否显示表格的FooterView
            [self showTableFootView:YES];
        }

    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
        self.mj_footer.hidden = YES;

        //是否显示表格的FooterView
        [self showTableFootView:YES];
    }
}

/**
 * 移除提示视图,重新请求
 */
- (void)removeTipViewAndRefresh
{
    if (self.mj_header) {
        //1.先移除页面上已有的提示视图
        [self removeOldTipBgView];

        //2.开始走下拉请求
        [self.mj_header beginRefreshing];

    } else {
        //兼容self为webView.scrollView是从这种方式的访问
        if ([self isKindOfClass:[UIScrollView class]]) {
            UIResponder *rsp = self;
            while (![rsp isKindOfClass:[UIViewController class]]) {
                rsp = rsp.nextResponder;
            }
            //获取到webview所在的控制器
            UIViewController *webViewVC = (UIViewController *)rsp;

            //获取控制器中的webview
            for (UIView *tempView in webViewVC.view.subviews) {
                if ([tempView isKindOfClass:[UIWebView class]]) {

                    if ([tempView respondsToSelector:@selector(reload)]) {
                        NSLog(@"webview执行重新加载");

                        //1.先移除页面上已有的提示视图
                        [self removeOldTipBgView];

                        //2.执行webview的reload方法
                        OKPerformSelectorLeakWarning(
                                                     [tempView performSelector:@selector(reload)];
                                                     );
                    }
                    break;
                }
            }
        }
    }
}

/**
 先移除页面上已有的提示视图
 */
- (void)removeOldTipBgView
{
    for (UIView *tempView in self.subviews) {
        if ([tempView isKindOfClass:[OKRequestTipBgView class]] &&
            tempView.tag == kRequestTipViewTag) {
            [tempView removeFromSuperview];
            break;
        }
    }
}

/**
 * 判断ScrollView页面上是否有数据
 */
- (BOOL)contentViewIsEmptyData
{
    BOOL isEmpty = NO;

    //如果是UITableView
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        if (tableView.numberOfSections==0 ||
            (tableView.numberOfSections==1 && [tableView numberOfRowsInSection:0] == 0)) {
            isEmpty = YES;
        }

    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        if (collectionView.numberOfSections==0 ||
            (collectionView.numberOfSections==1 && [collectionView numberOfItemsInSection:0] == 0)) {
            isEmpty = YES;
        }
    } else {
        if (self.hidden || self.alpha == 0) {
            isEmpty = NO;
        } else {
            isEmpty = YES;
        }
    }
    return isEmpty;
}

/**
 *  是否显示表格的FooterView
 */
- (void)showTableFootView:(BOOL)show
{
    //如果是表格，设置没有更多数据footerView
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        if (show) {
            if (self.footerTipString) {
                tableView.tableFooterView = self.customFootTipLabel;

            } else if (self.footerTipImage) {
                tableView.tableFooterView = self.customFootTipView;
            }
        } else {
            tableView.tableFooterView = [UIView new];
        }

    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        if (show) {
            if (self.footerTipString) {
                UILabel *tipLabel = self.customFootTipLabel;
                tipLabel.frame = CGRectMake(0, collectionView.frame.size.height, self.bounds.size.width, 50);
                [collectionView addSubview:tipLabel];

            } else if (self.footerTipImage) {
                UIView *footerView = self.customFootTipView;
                CGRect rect = footerView.frame;
                rect.origin.y = collectionView.frame.size.height;
                footerView.frame = rect;
                [collectionView addSubview:footerView];
            }

        } else {
            UIView *footerView = [collectionView viewWithTag:kRequestTipViewTag];
            [footerView removeFromSuperview];
        }
    }
}

/**
 * 底部提示文案Label
 */
- (UILabel *)customFootTipLabel
{
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 50);
    tipLabel.backgroundColor = [UIColor clearColor];
    //tipLabel.text = [NSString stringWithFormat:@"━━━━━━ %@ ━━━━━━",self.footerTipString];
    tipLabel.text = self.footerTipString;
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = [UIColor lightGrayColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    return tipLabel;
}

/**
 * 底部提示图片
 */
- (UIView *)customFootTipView
{
    CGFloat height = self.footerTipImage.size.height;

    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.frame = CGRectMake(0, 0, self.bounds.size.width, height+30);
    footerView.tag = kRequestTipViewTag;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.footerTipImage];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.center = footerView.center;
    [footerView addSubview:imageView];
    return footerView;
}

#pragma mark -=========== 自动添加提示View入口 ===========

/**
 *  处理自动根据表格数据来显示提示view
 */
- (void)convertShowTipView
{
    //需要显示提示view
    if (self.automaticShowTipView) {

        /** 给表格添加请求失败提示事件
         * <警告：这里如果有MJRefresh下拉刷新控件, 一定要延迟，因为MJRefresh库也替换了reloadData方法，否则不能收起刷新控件>
         */
        CGFloat delay = 0.0;
        if (self.mj_header || self.mj_footer) {
            delay = 0.5;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showRequestTip:[NSDictionary new]];
        });
    }
}

@end

#pragma mark -===========监听UITableView刷新方法===========

@implementation UITableView (OKRequestTipView)

/**
 * 监听表格所有的刷新方法
 */
+(void)load
{
    //交换刷新表格方法
    [self ok_exchangeInstanceMethod:@selector(reloadData)
                      otherSelector:@selector(ok_reloadData)];
    //交换删除表格方法
    [self ok_exchangeInstanceMethod:@selector(deleteRowsAtIndexPaths:withRowAnimation:)
                      otherSelector:@selector(ok_deleteRowsAtIndexPaths:withRowAnimation:)];
    //交换刷新表格Sections方法
    [self ok_exchangeInstanceMethod:@selector(reloadSections:withRowAnimation:)
                      otherSelector:@selector(ok_reloadSections:withRowAnimation:)];
}

- (void)ok_reloadData
{
    NSLog(@"交换表格系统刷新方法");
    [self ok_reloadData];

    //显示自定义提示view
    [self convertShowTipView];
}

- (void)ok_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
                 withRowAnimation:(UITableViewRowAnimation)animation
{
    NSLog(@"交换删除表格方法");
    [self ok_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];

    //是否显示自定义提示view
    [self convertShowTipView];
}

- (void)ok_reloadSections:(NSIndexSet *)sections
         withRowAnimation:(UITableViewRowAnimation)animation
{
    NSLog(@"交换刷新表格Sections方法");
    [self ok_reloadSections:sections withRowAnimation:animation];

    //是否显示自定义提示view
    [self convertShowTipView];
}

@end

#pragma mark -===========监听UICollectionView刷新方法===========

@implementation UICollectionView (OKRequestTipView)

/**
 * 监听CollectionView所有的刷新方法
 */
+ (void)load
{
    [self ok_exchangeInstanceMethod:@selector(reloadData)
                      otherSelector:@selector(ok_reloadData)];

    [self ok_exchangeInstanceMethod:@selector(deleteSections:)
                      otherSelector:@selector(ok_deleteSections:)];

    [self ok_exchangeInstanceMethod:@selector(reloadSections:)
                      otherSelector:@selector(ok_reloadSections:)];

    [self ok_exchangeInstanceMethod:@selector(deleteItemsAtIndexPaths:)
                      otherSelector:@selector(ok_deleteItemsAtIndexPaths:)];

    [self ok_exchangeInstanceMethod:@selector(reloadItemsAtIndexPaths:)
                      otherSelector:@selector(ok_reloadItemsAtIndexPaths:)];
}

- (void)ok_reloadData
{
    NSLog(@"交换刷新CollectionView系统方法");
    [self ok_reloadData];

    //显示自定义提示view
    [self convertShowTipView];
}

- (void)ok_deleteSections:(NSIndexSet *)sections
{
    [self ok_deleteSections:sections];

    [self convertShowTipView];
}

- (void)ok_reloadSections:(NSIndexSet *)sections
{
    [self ok_reloadSections:sections];

    [self convertShowTipView];
}

- (void)ok_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self ok_deleteItemsAtIndexPaths:indexPaths];

    [self convertShowTipView];
}

- (void)ok_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self ok_reloadItemsAtIndexPaths:indexPaths];

    [self convertShowTipView];
}

@end

#pragma mark -===========监听UIWebView刷新方法===========

@implementation UIWebView (OKRequestTipView)

/**
 * 监听UIWebView所有的刷新方法
 */
+ (void)load
{
    [self ok_exchangeInstanceMethod:@selector(reload)
                      otherSelector:@selector(ok_reload)];
}

- (void)ok_reload
{
    [self ok_reload];

    [self.scrollView convertShowTipView];
}

@end
