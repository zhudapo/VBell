//
//  LeftMenuButton.m
//  VBell
//
//  Created by Jose Zhu on 16/8/2.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "LeftMenuButton.h"

@implementation LeftMenuButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 修改 title 的 frame */
    // 1.获取 titleLabel 的 frame
    CGRect titleLabelFrame = self.titleLabel.frame;
    // 2.修改 titleLabel 的 frame
    titleLabelFrame.origin.x = 50;
    titleLabelFrame.origin.y = -1;
    titleLabelFrame.size.width = 300;
    titleLabelFrame.size.height = 50;
    // 3.重新赋值
    self.titleLabel.frame = titleLabelFrame;
    
    /** 修改 imageView 的 frame */
    // 1.获取 imageView 的 frame
    CGRect imageViewFrame = self.imageView.frame;
    // 2.修改 imageView 的 frame
    imageViewFrame.origin.x = 15;
    imageViewFrame.origin.y = 12;
    imageViewFrame.size.width = 24;
    imageViewFrame.size.height = 24;
    // 3.重新赋值
    self.imageView.frame = imageViewFrame;
}
@end
