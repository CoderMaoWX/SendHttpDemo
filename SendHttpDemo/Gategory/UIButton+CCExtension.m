//
//  UIButton+CCExtension.m
//  Okdeer-jieshun-parkinglot
//
//  Created by mao wangxin on 2016/11/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "UIButton+CCExtension.h"
#import <objc/runtime.h>

static const void *UIButtonBlockKey = &UIButtonBlockKey;

@implementation UIButton (CCExtension)

#pragma mark - ============ 给按钮点击事件 ============

-(void)addTouchUpInsideHandler:(TouchedBlock)handler
{
    objc_setAssociatedObject(self, UIButtonBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(cc_touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)cc_touchUpInsideAction:(UIButton *)btn{
    TouchedBlock block = objc_getAssociatedObject(self, UIButtonBlockKey);
    if (block) {
        block(btn);
    }
}
@end
