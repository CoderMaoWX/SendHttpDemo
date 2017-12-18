//
//  CCParkingRequestTipView.h
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/11/24.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

@interface MBProgressHUD (OKExtension)

/**
 *  在指定view上显示转圈的MBProgressHUD (不会自动消失,需要手动调用隐藏方法,非模态)
 *
 *  @param tipStr 提示语
 */
+ (void)showLoadingToView:(UIView *)view text:(NSString *)tipStr;

/**
 *  隐藏指定view上创建的MBProgressHUD
 */
+ (void)hideLoadingFromView:(UIView *)fromView;

/**
 *  在window上带文字几秒后提示消失
 *
 *  @param message 提示文字
 */
+ (void)showToastToWindow:(NSString *)message;

@end


@interface OKRequestTipBgView : UIView

//当前提示view在父视图上的tag
#define kRequestTipViewTag      2016

@property (nonatomic, strong) UIButton *actionBtn;

/**
 返回一个提示空白view

 @param frame 提示View大小
 @param image 图片名字
 @param text 提示文字
 @param title 按钮标题, 不要按钮可不传
 @param block 点击按钮回调Block
 @return 提示空白view
 */
+ (OKRequestTipBgView *)tipViewByFrame:(CGRect)frame
                           tipImage:(UIImage *)image
                            tipText:(id)text
                        actionTitle:(id)title
                        actionBlock:(void(^)(void))block;

@end

