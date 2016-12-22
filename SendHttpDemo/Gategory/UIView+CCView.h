//
//  UIView+MJ.h
//  QQZoneDemo
//
//  Created by MJ Lee on 14-5-26.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCView)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;

@property (nonatomic,assign) CGFloat bottom;  //底部
@property (nonatomic,assign) CGFloat top;     //顶部
@property (nonatomic,assign) CGFloat left;    //左边
@property (nonatomic,assign) CGFloat right;   //右边
@property (nonatomic,assign) CGFloat width;   //宽度
@property (nonatomic,assign) CGFloat height;  //高度

@end
