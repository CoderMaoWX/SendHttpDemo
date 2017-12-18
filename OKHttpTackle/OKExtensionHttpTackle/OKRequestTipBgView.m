//
//  OKRequestTipBgView.m
//  CommonFrameWork
//
//  Created by mao wangxin on 2016/11/24.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKRequestTipBgView.h"

#ifndef UIColorFromHex
#define UIColorFromHex(hexValue)            ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

@implementation MBProgressHUD (OKExtension)

#pragma mark - 弹框在指定view上

/**
 *  隐藏指定view上创建的MBProgressHUD
 */
+ (void)hideLoadingFromView:(UIView *)fromView
{
    for (UIView *tipView in fromView.subviews) {
        if ([tipView isKindOfClass:[MBProgressHUD class]]) {
            [(MBProgressHUD *)tipView hideAnimated:YES];
            if (tipView.superview) {
                [tipView removeFromSuperview];
            }
        }
    }
}

/**
 *  在指定view上显示转圈的MBProgressHUD (不会自动消失,需要手动调用隐藏方法)
 *
 *  @param tipStr 提示语
 */
+ (void)showLoadingToView:(UIView *)addView text:(NSString *)tipStr
{
    if (!addView || !tipStr || tipStr.length==0) return;

    [self hideLoadingFromView:addView];

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:addView];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.userInteractionEnabled = NO;
    HUD.label.text = tipStr;
    [HUD showAnimated:YES];
    [addView addSubview:HUD];
}

/**
 *  在window上带文字几秒后提示消失
 *
 *  @param message 提示文字
 */
+ (void)showToastToWindow:(NSString *)message
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [self hideLoadingFromView:window];

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.mode = MBProgressHUDModeText;
    HUD.userInteractionEnabled = NO;
    HUD.label.text = message;
    [HUD showAnimated:YES];
    [window addSubview:HUD];
    [HUD hideAnimated:YES afterDelay:2];
}

@end


@interface OKRequestTipBgView ()
@property (nonatomic, copy) void(^block)(void);
@end

@implementation OKRequestTipBgView

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
                        actionBlock:(void(^)(void))block
{
    OKRequestTipBgView *tipView = [[OKRequestTipBgView alloc] initWithFrame:frame
                                                             tipImage:image
                                                              tipText:text
                                                          actionTitle:title
                                                          actionBlock:block];
    tipView.tag = kRequestTipViewTag;
    tipView.backgroundColor = [UIColor clearColor];
    return tipView;
}

- (instancetype)initWithFrame:(CGRect)frame
                     tipImage:(UIImage *)image
                      tipText:(id)text
                  actionTitle:(id)title
                  actionBlock:(void(^)(void))block
{
    self = [super initWithFrame:frame];
    if(self){
        self.block = block;

        CGFloat spaceMargin = 15;
        UIView *contenView = [[UIView alloc] init];
        contenView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        contenView.backgroundColor = [UIColor clearColor];
        [self addSubview:contenView];

        CGFloat contenViewMaxHeight = 0;

        //顶部图片
        UIImageView *_tipImageView = nil;
        if (image) {
            _tipImageView = [[UIImageView alloc] initWithImage:image];
            _tipImageView.backgroundColor = [UIColor clearColor];
            _tipImageView.contentMode = UIViewContentModeScaleAspectFill;
            [contenView addSubview:_tipImageView];
            //设置frame
            _tipImageView.frame = CGRectMake((frame.size.width-image.size.width)/2, 0, image.size.width, image.size.height);

            contenViewMaxHeight = CGRectGetMaxY(_tipImageView.frame)+spaceMargin;
        }

        //中间文字
        UILabel *_tipLabel = nil;
        if (text) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.backgroundColor = [UIColor clearColor];
            _tipLabel.font = [UIFont boldSystemFontOfSize:14];
            _tipLabel.textColor = UIColorFromHex(0x666666);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            [contenView addSubview:_tipLabel];

            if ([text isKindOfClass:[NSString class]]) {
                _tipLabel.text = text;
            } else if ([text isKindOfClass:[NSAttributedString class]]) {
                _tipLabel.attributedText = text;
            }
            [_tipLabel sizeToFit];
            //设置frame
            _tipLabel.frame = CGRectMake((frame.size.width-_tipLabel.bounds.size.width)/2,
                                         contenViewMaxHeight,
                                         _tipLabel.bounds.size.width,
                                         _tipLabel.bounds.size.height);

            contenViewMaxHeight = CGRectGetMaxY(_tipLabel.frame)+spaceMargin;
        }

        //底部按钮
        if (title) {
            UIButton *actionBtn = [[UIButton alloc] init];
            actionBtn.backgroundColor = [UIColor clearColor];
            actionBtn.layer.cornerRadius = 6;
            actionBtn.layer.borderColor = UIColorFromHex(0x666666).CGColor;
            actionBtn.layer.borderWidth = 1;
            [actionBtn setTitleColor:UIColorFromHex(0x666666) forState:0];
            actionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            actionBtn.titleLabel.numberOfLines = 0;
            [actionBtn addTarget:self action:@selector(buttonAction) forControlEvents:(UIControlEventTouchUpInside)];
            [contenView addSubview:actionBtn];
            self.actionBtn = actionBtn;

            if ([title isKindOfClass:[NSString class]]) {
                [actionBtn setTitle:title forState:0];
            } else if ([title isKindOfClass:[NSAttributedString class]]) {
                [actionBtn setAttributedTitle:title forState:0];
            }
            [actionBtn sizeToFit];

            //设置frame
            CGFloat btnW = actionBtn.bounds.size.width+30;
            actionBtn.frame = CGRectMake((contenView.bounds.size.width-btnW)/2, contenViewMaxHeight,
                                         btnW, actionBtn.bounds.size.height);

            contenViewMaxHeight = CGRectGetMaxY(actionBtn.frame);
        }

        //设置contenView位置
        contenView.frame = CGRectMake(0,(frame.size.height-contenViewMaxHeight)/2,
                                      frame.size.width,
                                      contenViewMaxHeight);
    }
    return self;
}

/**
 * 提示按钮点击事件
 */
- (void)buttonAction
{
    if (self.block) {
        self.block();
    }
}

@end

