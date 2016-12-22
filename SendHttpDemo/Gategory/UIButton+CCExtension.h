//
//  UIButton+CCExtension.h
//  Okdeer-jieshun-parkinglot
//
//  Created by mao wangxin on 2016/11/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchedBlock)(UIButton *btn);

@interface UIButton (CCExtension)

-(void)addTouchUpInsideHandler:(TouchedBlock)handler;

@end
