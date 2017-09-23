//
//  SendHttpDemoTests.m
//  SendHttpDemoTests
//
//  Created by Luke on 2017/9/23.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MyUtilViewController.h"

@interface SendHttpDemoTests : XCTestCase
@property (nonatomic, strong) MyUtilViewController *vc;
@end

@implementation SendHttpDemoTests

- (void)setUp {
    [super setUp];
    _vc = [[MyUtilViewController alloc] init];
}

- (void)tearDown {
    self.vc = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testJudgeNumGreaterTen
{
    BOOL flag0 = [self.vc judgeNumGreaterTen:3];
    XCTAssertFalse(flag0, @"3不大于10");
    
    BOOL flag1 = [self.vc judgeNumGreaterTen:6];
    XCTAssertFalse(flag1, @"6不大于10");
    
    BOOL flag2 = [self.vc judgeNumGreaterTen:10];
    XCTAssertFalse(flag2, @"10不大于10");
    
    BOOL flag3 = [self.vc judgeNumGreaterTen:11];
    XCTAssertTrue(flag3, @"11大于10");
    
    BOOL flag4 = [self.vc judgeNumGreaterTen:100];
    XCTAssertTrue(flag4, @"11大于10");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for (int i=0; i<1000; i++) {
            NSLog(@"testPerformanceExample====%zd",i);
        }
    }];
}

@end
