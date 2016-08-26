//
//  AudioAndVideoCodecCell.m
//  VBell
//
//  Created by Jose Zhu on 16/8/3.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AudioAndVideoCodecCell.h"
@interface AudioAndVideoCodecCell()
@property (nonatomic , strong) UIButton *enableBtn;
@property (nonatomic , strong) UILabel *nameLabel;
@property (nonatomic , strong) UIButton *payload;

@end

@implementation AudioAndVideoCodecCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enableBtn = [[UIButton alloc]init];
        [_enableBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_enableBtn];
        self.nameLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_nameLabel];
        self.payload = [[UIButton alloc]init];
        [_payload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_payload];
    }
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _enableBtn.frame = CGRectMake(-10, 12.5, 30, 30);
    _nameLabel.frame = CGRectMake(70, 12.5, 50, 30);
    _payload.frame = CGRectMake(170, 12.5, 50, 30);
}

- (void)setContent:(AudioCodecModel *)audioCodecModel
{
    _nameLabel.text = audioCodecModel.name;
    if (audioCodecModel.enable == 0) {
        _enableBtn.selected = NO;
        [_enableBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
    }else{
        _enableBtn.selected = YES;
        [_enableBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateSelected];
    }
    [_payload setTitle:[NSString stringWithFormat:@"%d",audioCodecModel.payload] forState:UIControlStateNormal];
}

#pragma -mark enable按钮
- (void)didCheck:(UIButton *)btn
{
    if (btn.selected) {
        [btn setSelected:NO];
        [btn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
    }else{
        [btn setSelected:YES];
        [btn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateSelected];
    }
}
@end
