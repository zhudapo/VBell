//
//  AccountManagerCell.m
//  VBell
//
//  Created by Jose Zhu on 16/4/26.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AccountManagerCell.h"

@interface AccountManagerCell()
@property (nonatomic , strong) UIButton *imageBtn;
@property (nonatomic , strong) UILabel *title;
@property (nonatomic , strong) UILabel *titleDetail;
@property (nonatomic, strong) NSString *username;

@end


@implementation AccountManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageBtn = [[UIButton alloc]init];
        [self.contentView addSubview:_imageBtn];
        self.title = [[UILabel alloc]init];
        [self.contentView addSubview:_title];
        self.titleDetail = [[UILabel alloc]init];
        [self.contentView addSubview:_titleDetail];
    }
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageBtn.frame = CGRectMake(10, 0, 60, 60);
    _title.frame = CGRectMake(80, 5, 150, 25);
    _titleDetail.frame = CGRectMake(80, 35, 150, 20);
}

- (void)setContent:(NSString *)username loginStatus:(BOOL)loginstauts UISwitchStatus:(BOOL)UISwitchStatus
{
    _username = username;
    [_imageBtn setImage:[UIImage imageNamed:@"Account Manager.png"] forState:UIControlStateNormal];
    if (loginstauts) {
        if (UISwitchStatus) {
            _title.text = username;
            _titleDetail.text = [username stringByAppendingString:@"   Registered"];
            _title.textColor = [UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0];
            _titleDetail.textColor = [UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0];
            self.switchOnline = [[UISwitch alloc]initWithFrame:CGRectMake(self.bounds.size.width-80, 10, 70, 30)];
            [_switchOnline addTarget:self action:@selector(loginOrlogout:) forControlEvents:UIControlEventValueChanged];
            _switchOnline.on = YES;
            [self.contentView addSubview:_switchOnline];
        }else{
            _title.text = username;
            _titleDetail.text = [username stringByAppendingString:@"   Registered"];
            _title.textColor = [UIColor grayColor];
            _titleDetail.textColor = [UIColor grayColor];
            self.switchOnline = [[UISwitch alloc]initWithFrame:CGRectMake(self.bounds.size.width-80, 10, 70, 30)];
            [_switchOnline addTarget:self action:@selector(loginOrlogout:) forControlEvents:UIControlEventValueChanged];
            _switchOnline.on = NO;
            [self.contentView addSubview:_switchOnline];
        }
    }else{
        _title.text = username;
        _titleDetail.text = @"Account 1 Disable";
        _title.textColor = [UIColor grayColor];
        _titleDetail.textColor = [UIColor grayColor];
        _switchOnline.on = NO;
    }
    _titleDetail.font = [UIFont systemFontOfSize:12];
}

- (void)loginOrlogout:(UISwitch *)switchLogin
{
    if ([switchLogin isOn]) {
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        NSString *username = [settings objectForKey:@"userName"];
        NSString *pwd = [settings objectForKey:@"passWord"];
        if (username.length!=0&&pwd.length!=0) {
            [self localLogin:username andpassword:pwd];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loginMessage" object:nil];
    }else{
        _title.textColor = [UIColor grayColor];
        _titleDetail.textColor = [UIColor grayColor];
        _titleDetail.text = [_username stringByAppendingString:@"   Disable"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loginoutMessage" object:nil];
    }
}

- (void)localLogin:(NSString *)usernameStr andpassword:(NSString *)password
{
//    [[SampleEasiioSIP sharedSampleSIP] login:usernameStr passwork:password callback:^(BOOL result, int resultCode, NSString *resultMsg) {
//        NSLog(@"%d,%d,%@",result,resultCode,resultMsg);
//        if (result) {
//            _title.textColor = [UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0];
//            _titleDetail.textColor = [UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0];
//            _titleDetail.text = [_username stringByAppendingString:@"   Registered"];
//        } else {
//            if (resultCode == 0) {
//                NSLog(@"网络请求失败，请检查网络连接");
//            } else if (resultCode == 2) {
//                NSLog(@"密码错误或密码账号不匹配");
//            } else if (resultCode == 3) {
//                NSLog(@"获取sip设置信息失败");
//            } else if (resultCode == 4) {
//                NSLog(@"登录帐号或用户名不存在");
//            } else if (resultCode == 5) {
//                NSLog(@"更新域名信息失败");
//            }
//        }
//    }];
}


@end
