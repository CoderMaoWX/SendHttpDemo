//
//  OKActionSheetView.h
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OKActionSheetCallBackBlock)(NSInteger buttonIndex);

/**
 * 仿ActionSheet的弹框
 */
@interface OKActionSheetView : UIView

/** 可以在程序启动后,初始化OKAlertView单个控件的主题色, App设置一次全局生效
 *  用法: [OKActionSheetView appearance].titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], ....};
 */
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *otherBtnTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *cancelBtnTitleAttributes UI_APPEARANCE_SELECTOR;

#pragma mark - 底部显示直角的ActionSheet

/**
 *  自定义从底部弹出的直角ActionSheet （注意：则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1）
 *
 *  @param buttonBlock            点击按钮回调
 *  @param cancelButtonBlock      点击取消或点击背景退出弹框事件
 *  @param title                  标题->(支持 NSString、NSAttributedString)
 *  @param cancelButtonTitle      取消按钮标题->(支持 NSString、NSAttributedString)
 *  @param otherButtonTitleArr    其他按钮标题->(支持 NSString、NSAttributedString的混合数组)
 *
 *  @return 返回自定义的ActionSheet实例
 */
+ (instancetype)actionSheetByBottomSquare:(OKActionSheetCallBackBlock)buttonBlock
                        cancelButtonBlock:(void (^)())cancelButtonBlock
                                WithTitle:(id)title
                        cancelButtonTitle:(id)cancelButtonTitle
                      otherButtonTitleArr:(NSArray *)otherButtonTitleArr;



#pragma mark - 底部显示带圆角的ActionSheet

/**
 *  自定义从底部弹出的圆角ActionSheet （注意：则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1）
 *
 *  @param buttonBlock            点击按钮回调
 *  @param cancelButtonBlock      点击取消或点击背景退出弹框事件回调
 *  @param title                  标题->(支持 NSString、NSAttributedString)
 *  @param cancelButtonTitle      取消按钮标题->(支持 NSString、NSAttributedString)
 *  @param otherButtonTitleArr    其他按钮标题->(支持 NSString、NSAttributedString的混合数组)
 *
 *  @return 返回自定义的ActionSheet实例
 */
+ (instancetype)actionSheetByBottomCornerRadius:(OKActionSheetCallBackBlock)buttonBlock
                              cancelButtonBlock:(void (^)())cancelButtonBlock
                                      WithTitle:(id)title
                              cancelButtonTitle:(id)cancelButtonTitle
                            otherButtonTitleArr:(NSArray *)otherButtonTitleArr;


#pragma mark - 顶部显示直角ActionSheet入口


/**
 从顶部弹出带圆角的ActionSheet

 @param buttonBlock     点击按钮回调
 @param cancelButtonBlock 点击取消或点击背景退出弹框事件回调
 @param superView       从顶部弹出的父视图
 @param buttonTitleArr  按钮标题(支持 NSString、NSAttributedString)
 @param buttonImageArr  按钮图标(支持 NSString、UIImage)
 @return                返回自定义的ActionSheet实例
 */
+ (instancetype)actionSheetByTopSquare:(OKActionSheetCallBackBlock)buttonBlock
                     cancelButtonBlock:(void (^)())cancelButtonBlock
                             superView:(UIView *)superView
                              position:(CGPoint)position
                        buttonTitleArr:(NSArray *)buttonTitleArr
                        buttonImageArr:(NSArray <NSString *> *)buttonImageArr;


/**
 *  给ActionSheet的指定按钮设置标题
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 *
 *  @param index  所有按钮数组对应的那个角标
 *  @param title  标题->(支持 NSString、NSAttributedString)
 *  @param enable 指定的按钮之后可点击
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable;


/**
 *  获取ActionSheet上的指定按钮
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (UIButton *)buttonAtIndex:(NSInteger)index;

/**
 *  主动退出弹框
 *  @param sender 可选参数, 传一个对象即响应点击背景回调
 */
- (void)dismissCCActionSheet:(id)sender;

@end


