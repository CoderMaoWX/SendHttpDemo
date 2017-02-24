//
//  AppDelegate.m
//  SendHttpDemo
//
//  Created by mao wangxin on 2016/12/22.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[DemoViewController new]];
    [self.window makeKeyAndVisible];

    return YES;
}


@end
