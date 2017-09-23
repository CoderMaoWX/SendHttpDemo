//
//  MyUtilViewController.m
//  SendHttpDemo
//
//  Created by Luke on 2017/9/23.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "MyUtilViewController.h"

@interface MyUtilViewController ()

@end

@implementation MyUtilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 判断传入一个数大于10
 */
- (BOOL)judgeNumGreaterTen:(NSInteger)number
{
    if (number > 10) {
        return YES;
    } else {
        return NO;
    }
}

@end
