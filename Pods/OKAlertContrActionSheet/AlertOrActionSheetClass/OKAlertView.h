//
//  OKAlertView.h
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OKAlertViewCallBackBlock)(NSInteger buttonIndex);


@interface OKAlertView : UIView

/** 可以在程序启动后,初始化OKAlertView单个控件的主题色, App设置一次全局生效
 *  用法: [OKActionSheetView appearance].titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], ....};
 */
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *messageTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *otherBtnTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *cancelBtnTitleAttributes UI_APPEARANCE_SELECTOR;

/**
 自定义的AlertView弹框
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 
 @param alertWithCallBlock     点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle      取消按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonTitles      其他按钮标题->(支持 NSString、NSAttributedString)
 */
+ (instancetype)alertWithCallBlock:(OKAlertViewCallBackBlock)alertWithCallBlock
                             title:(id)title
                           message:(id)message
                 cancelButtonTitle:(id)cancelButtonTitle
                 otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;


/**
 使用方式同上个方法, (效果和上面的方法一样,c函数的方式调用代码量更少)
 
 @param title 弹框标题->(支持 NSString、NSAttributedString)
 @param message 弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle 取消按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonTitles 其他按钮标题->(支持 NSString、NSAttributedString)
 @param alertWithCallBlock 点击按钮回调Block
 @return 弹框实例对象
 */
OKAlertView* ShowAlertView(id title, id message, id cancelButtonTitle, NSArray *otherButtonTitles, OKAlertViewCallBackBlock alertWithCallBlock);


/**
 * 单个按钮提示Alert弹框, 没有事件只做提示使用
 *
 @param title 弹框标题->(支持 NSString、NSAttributedString)
 @param message 弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle 取消按钮标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertSingleBtnView(id title, id message, id cancelButtonTitle);


/**
 *  获取OKAlertView上的指定按钮
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (UIButton *)buttonAtIndex:(NSInteger)index;


/**
 *  给OKAlertView的指定按钮设置标题
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable;


/**
 *  2秒自动消失的系统Alert弹框
 *
 *  @msg 提示标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertToast(id msg);


/**
 * 2秒自动消失带标题的系统Alert弹框
 
 * @param title 提示标题->(支持 NSString、NSAttributedString)
 * @param msg   提示信息->(支持 NSString、NSAttributedString)
 */
void ShowAlertToastByTitle(id title, id msg);


/**
 * 指定时间消失Alert弹框
 
 * @param title         提示标题->(支持 NSString、NSAttributedString)
 * @param msg           提示信息->(支持 NSString、NSAttributedString)
 * @param duration      指定消失时间
 * @param dismissBlock  消失回调
 */
void ShowAlertToastDelay(id title, id msg, NSTimeInterval duration, void(^dismissBlock)(void));


#pragma mark - 带输入框的系统弹框

/**
 iOS8.0的带输入框的UIAlertController
 
 @param title 标题
 @param placeholder 占位文字
 @param cancelTitle 取消按钮标题
 @param otherTitle 其他按钮标题
 @param otherBlock 其他按钮回调
 @param cancelBlock 取消按钮回调
 */
+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                               placeholder:(NSString *)placeholder
                               cancelTitle:(NSString *)cancelTitle
                                otherTitle:(NSString *)otherTitle
                              keyboardType:(UIKeyboardType)keyboardType
                               buttonBlock:(void (^)(NSString *inputText))otherBlock
                               cancelBlock:(void (^)(void))cancelBlock;

@end

