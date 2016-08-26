//
//  DeviceInfoButton.m
//  VBell
//
//  Created by Jose Zhu on 16/8/10.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "DeviceInfoButton.h"

@interface DeviceInfoButton()

@property(nonatomic,strong)UIImageView *mBtnImageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation DeviceInfoButton

- (instancetype)initWithFrame:(CGRect)frame andBtnWidth:(CGFloat)btnWidth andImage:(UIImage *)image andBtnName:(NSString *)btnName
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mBtnImageView = [[UIImageView alloc]initWithFrame:CGRectMake((btnWidth-50)/2, 10, 50, 50)];
        _mBtnImageView.image = image;
        [self addSubview:_mBtnImageView];
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, btnWidth, btnWidth-50)];
        _label.text = NSLocalizedString(btnName , nil);
        _label.font = [UIFont systemFontOfSize:13];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        
        [self addSubview:_label];
    }
    return self;
    
}


@end
