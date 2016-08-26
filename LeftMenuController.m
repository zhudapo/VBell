//
//  LeftMenuController.m
//  VBell
//
//  Created by Jose Zhu on 16/7/25.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "LeftMenuController.h"
#import "AccountManagerViewController.h"
#import "AudioSettingsViewController.h"
#import "VideoSettingsViewController.h"
#import "AdvanceSettingsViewController.h"
#import "ExprotLogViewController.h"
#import "AboutViewController.h"
#import "UIViewController+YQSlideMenu.h"
#import "Masonry.h"
#import "LeftMenuButton.h"
#import "exitButton.h"


@interface LeftMenuController ()<AccountManagerViewControllerDelegate>
//@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic, strong) UIButton *accountBtn;
@property (nonatomic, strong) UIButton *accountIconBtn;
@property (nonatomic, strong) UIButton *accountNameBtn;
@property (nonatomic, strong) UIButton *settingsBtn;
@property (nonatomic, strong) LeftMenuButton *accountManagerBtn;
@property (nonatomic, strong) LeftMenuButton *audioSettingsBtn;
@property (nonatomic, strong) LeftMenuButton *videoSettingsBtn;
@property (nonatomic, strong) LeftMenuButton *advanceSettingsBtn;
@property (nonatomic, strong) UIButton *developerBtn;
@property (nonatomic, strong) LeftMenuButton *exportLogBtn;
@property (nonatomic, strong) LeftMenuButton *aboutBtn;
@property (nonatomic, strong) exitButton *exitBtn;
@property (nonatomic, assign) BOOL showDelveloperStatus;
@property (nonatomic, assign) BOOL loginStatus;
@property (nonatomic, strong) NSString *registerState;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:42.0/255 green:70.0/255 blue:80.0/255 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRegistState:) name:@"CHANGEREGISTERSTATE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeLoginName:) name:@"CHANGELOGINNAME" object:nil];
    [self setupUI];
}

- (void)changeRegistState:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *registerState = [infoDic valueForKey:@"registerState"];
    if ([registerState isEqualToString:@"3"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_accountNameBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            _registerState = @"3";
        });
    }else if ([registerState isEqualToString:@"2"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_accountNameBtn setTitleColor:UnifiedColor forState:UIControlStateNormal];
            _registerState = @"2";
        });
    }else if ([registerState isEqualToString:@"1"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_accountNameBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            _registerState = @"1";
        });
    }else{//0
        dispatch_async(dispatch_get_main_queue(), ^{
            [_accountNameBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            _registerState = @"0";
        });
    }
}

- (void)changeLoginName:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *changedName = [infoDic valueForKey:@"changedName"];
    [_accountNameBtn setTitle:changedName forState:UIControlStateNormal];
    
}

- (void)setupUI
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    __weak typeof(self) weakSelf = self;
    _accountBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 44, 44, 44)];
    _accountBtn.backgroundColor = [UIColor whiteColor];
    _accountBtn.layer.masksToBounds = YES;
    _accountBtn.layer.cornerRadius = _accountBtn.frame.size.height / 2;
    
    [self.view addSubview:_accountBtn];
    
    _accountIconBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 44, 24, 24)];
    _accountIconBtn.center = _accountBtn.center;
    //_accountIconBtn.backgroundColor = [UIColor redColor];
    [_accountIconBtn setImage:[UIImage imageNamed:@"Account Manager.png"] forState:UIControlStateNormal];
    [self.view addSubview:_accountIconBtn];
    
    _accountNameBtn = [[UIButton alloc]init];//WithFrame:CGRectMake(64, 40+20, 100, 20)
    _accountNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_accountNameBtn setTitle:[user objectForKey:@"userName"] forState:UIControlStateNormal];
    [self.view addSubview:_accountNameBtn];
    
    _settingsBtn = [[UIButton alloc]init];
    _settingsBtn.backgroundColor = UnifiedColor;
    [_settingsBtn setTitle:NSLocalizedString(@"SETTINGS", nil) forState:UIControlStateNormal];
    [self.view addSubview:_settingsBtn];
    _settingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _settingsBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _settingsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    _accountManagerBtn = [[LeftMenuButton alloc]init];
    [_accountManagerBtn setImage:[UIImage imageNamed:@"Account Manager.png"] forState:UIControlStateNormal];
    [_accountManagerBtn setTitle:NSLocalizedString(@"Account Manager", nil) forState:UIControlStateNormal];
    _accountManagerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_accountManagerBtn addTarget:self action:@selector(accounts) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_accountManagerBtn];
    
    UIView *firstLine = [[UIView alloc]init];
    firstLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:firstLine];
    
    _audioSettingsBtn = [[LeftMenuButton alloc]init];
    [_audioSettingsBtn setImage:[UIImage imageNamed:@"Audio Settings.png"] forState:UIControlStateNormal];
    [_audioSettingsBtn setTitle:NSLocalizedString(@"Audio Settings", nil) forState:UIControlStateNormal];
    _audioSettingsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_audioSettingsBtn addTarget:self action:@selector(AudioSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_audioSettingsBtn];
    
    UIView *secondLine = [[UIView alloc]init];
    secondLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:secondLine];
    
    _videoSettingsBtn = [[LeftMenuButton alloc]init];
    [_videoSettingsBtn setImage:[UIImage imageNamed:@"Video Settings.png"] forState:UIControlStateNormal];
    [_videoSettingsBtn setTitle:NSLocalizedString(@"Video Settings", nil) forState:UIControlStateNormal];
    _videoSettingsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_videoSettingsBtn addTarget:self action:@selector(VideoSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoSettingsBtn];
    
    UIView *thirdLine = [[UIView alloc]init];
    thirdLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:thirdLine];
    
    _advanceSettingsBtn = [[LeftMenuButton alloc]init];
    [_advanceSettingsBtn setImage:[UIImage imageNamed:@"Advance Setting.png"] forState:UIControlStateNormal];
    [_advanceSettingsBtn setTitle:NSLocalizedString(@"Advance Settings", nil) forState:UIControlStateNormal];
    _advanceSettingsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_advanceSettingsBtn addTarget:self action:@selector(AdvanceSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_advanceSettingsBtn];
    
    _developerBtn = [[UIButton alloc]init];
    _developerBtn.backgroundColor = UnifiedColor;
    [_developerBtn setTitle:NSLocalizedString(@"DEVELOPER", nil) forState:UIControlStateNormal];
    [self.view addSubview:_developerBtn];
    _developerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _developerBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _developerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_developerBtn addTarget:self action:@selector(doShowDeveloperOrNot) forControlEvents:UIControlEventTouchUpInside];
    
    _exitBtn = [[exitButton alloc]init];
    [_exitBtn setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
    [_exitBtn setTitle:NSLocalizedString(@"Exit", nil) forState:UIControlStateNormal];
    [_exitBtn setTitleColor:[UIColor colorWithRed:224.0/255 green:141.0/255 blue:40.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_exitBtn addTarget:self action:@selector(Exit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_exitBtn];
    
    
    [_accountNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_accountBtn.mas_right).offset(5);
        make.top.offset(57);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [_settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_accountBtn.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(300, 20));
    }];
    [_accountManagerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_settingsBtn.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];
    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_accountManagerBtn.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 1));
    }];
    [_audioSettingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstLine.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];
    [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_audioSettingsBtn.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 1));
    }];
    [_videoSettingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(secondLine.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];
    [thirdLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_videoSettingsBtn.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 1));
    }];
    [_advanceSettingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(thirdLine.mas_bottom);
        make.left.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];
    [_developerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_advanceSettingsBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(300, 20));
    }];
    [_exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view).offset(-15);
        make.left.equalTo(weakSelf.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
}

- (void)doShowDeveloperOrNot
{
    __weak typeof(self) weakSelf = self;
    UIView *forthLine = [[UIView alloc]init];
    UIView *fifthLine = [[UIView alloc]init];
    if (!_showDelveloperStatus) {
        _exportLogBtn = [[LeftMenuButton alloc]init];
        [_exportLogBtn setImage:[UIImage imageNamed:@"Export Log.png"] forState:UIControlStateNormal];
        [_exportLogBtn setTitle:NSLocalizedString(@"Export Log", nil) forState:UIControlStateNormal];
        _exportLogBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_exportLogBtn addTarget:self action:@selector(ExprotLog) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exportLogBtn];
        
        forthLine.backgroundColor = [UIColor blackColor];
        [self.view addSubview:forthLine];
        
        _aboutBtn = [[LeftMenuButton alloc]init];
        [_aboutBtn setImage:[UIImage imageNamed:@"About.png"] forState:UIControlStateNormal];
        [_aboutBtn setTitle:NSLocalizedString(@"About", nil) forState:UIControlStateNormal];
        _aboutBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_aboutBtn addTarget:self action:@selector(About) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_aboutBtn];
        
        
        fifthLine.backgroundColor = [UIColor blackColor];
        [self.view addSubview:fifthLine];
        
        [_exportLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_developerBtn.mas_bottom);
            make.left.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(300, 50));
        }];
        [forthLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_exportLogBtn.mas_bottom);
            make.left.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(300, 1));
        }];
        [_aboutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(forthLine.mas_bottom);
            make.left.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(300, 50));
        }];
        [fifthLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_aboutBtn.mas_bottom);
            make.left.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(300, 1));
        }];
        _showDelveloperStatus = YES;
    }else{
        [_exportLogBtn removeFromSuperview];
        [forthLine removeFromSuperview];
        [_aboutBtn removeFromSuperview];
        [fifthLine removeFromSuperview];
        _showDelveloperStatus = NO;
    }
}

//Accounts
- (void) accounts
{
    AccountManagerViewController *accountManagerVC = [[AccountManagerViewController alloc]init];
    accountManagerVC.delegate = self;
    accountManagerVC.registerState = _registerState;
    if (_loginStatus) {
        accountManagerVC.UISwitchStatus = YES;
    }else{
        accountManagerVC.UISwitchStatus = NO;
    }
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:accountManagerVC animated:YES];
    [self.slideMenuController showViewController:accountManagerVC];
}

- (void)AudioSettings
{
    
    AudioSettingsViewController *audioSettingsVC = [[AudioSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:audioSettingsVC animated:YES];
    [self.slideMenuController showViewController:audioSettingsVC];
}

- (void)VideoSettings
{
    
    VideoSettingsViewController *videoSettingsVC = [[VideoSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:videoSettingsVC animated:YES];
    [self.slideMenuController showViewController:videoSettingsVC];
}

- (void)AdvanceSettings
{
    
    AdvanceSettingsViewController *advanceSettingVC = [[AdvanceSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:advanceSettingVC animated:YES];
    [self.slideMenuController showViewController:advanceSettingVC];
}

- (void)ExprotLog
{
    
    ExprotLogViewController *exprotLogVC = [[ExprotLogViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:exprotLogVC animated:YES];
    [self.slideMenuController showViewController:exprotLogVC];
}

- (void)About
{
    
    AboutViewController *aboutVC = [[AboutViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:aboutVC animated:YES];
    [self.slideMenuController showViewController:aboutVC];
}

- (void)Exit
{
    NSLog(@"Exit");
}


# pragma -mark AccountManagerViewControllerDelegate
//- (void)ModifyUserDetail:(AccountManagerViewController *)cell userName:(NSString *)username
//{
//    [_accountBtn setTitle:username forState:UIControlStateNormal];
//}
@end
