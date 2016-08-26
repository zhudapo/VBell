//
//  exitButton.m
//  VBell
//
//  Created by Jose Zhu on 16/8/2.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "exitButton.h"

@implementation exitButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 修改 title 的 frame */
    // 1.获取 titleLabel 的 frame
    CGRect titleLabelFrame = self.titleLabel.frame;
    // 2.修改 titleLabel 的 frame
    titleLabelFrame.origin.x = 35;
    titleLabelFrame.origin.y = -1;
    titleLabelFrame.size.width = 50;
    titleLabelFrame.size.height = 20;
    // 3.重新赋值
    self.titleLabel.frame = titleLabelFrame;
    
    /** 修改 imageView 的 frame */
    // 1.获取 imageView 的 frame
    CGRect imageViewFrame = self.imageView.frame;
    // 2.修改 imageView 的 frame
    imageViewFrame.origin.x = 10;
    imageViewFrame.origin.y = 0;
    imageViewFrame.size.width = 18;
    imageViewFrame.size.height = 18;
    // 3.重新赋值
    self.imageView.frame = imageViewFrame;
}

@end
