//
//  UIView+MJ.m
//  QQZoneDemo
//
//  Created by MJ Lee on 14-5-26.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UIView+CCView.h"

@implementation UIView (CCView)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}
-(CGFloat)top{
    return self.frame.origin.y;
}

-(CGFloat)bottom{
    return self.frame.size.height + self.frame.origin.y;
}

-(CGFloat)left{
    return self.frame.origin.x;
}

-(CGFloat)right{
    return self.frame.size.width + self.frame.origin.x;
}

-(CGFloat)width{
    return self.frame.size.width;
}

-(CGFloat)height{
    return self.frame.size.height;
}

-(void)setTop:(CGFloat)top{
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, self.frame.size.height);
}

-(void)setLeft:(CGFloat)left{
    self.frame = CGRectMake(left, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(void)setBottom:(CGFloat)bottom{
    self.frame = CGRectMake(self.frame.origin.x, bottom - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

-(void)setRight:(CGFloat)right{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, right - self.frame.size.width, self.frame.size.height);
}

-(void)setWidth:(CGFloat)width{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

-(void)setHeight:(CGFloat)height{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
