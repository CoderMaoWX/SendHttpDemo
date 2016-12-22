//
//  CCParkingRequestTipView.h
//  OkdeerUser
//
//  Created by mao wangxin on 2016/11/24.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCParkingRequestTipView : UIView

//当前提示view在父视图上的tag
#define kRequestTipViewTag      2016

/**
 *  根据类型显示提示view
 */
+ (CCParkingRequestTipView *)tipViewByFrame:(CGRect)frame tipImageName:(NSString *)imageName tipText:(id)tipText actionTitle:(NSString *)actionTitle actionBlock:(void(^)())touchBlock;

@end
