//
//  settingViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/6.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//  点击设置push的view

#import "settingViewController.h"
#import "AccountManagerViewController.h"
#import "AudioSettingsViewController.h"
#import "VideoSettingsViewController.h"
#import "AdvanceSettingsViewController.h"
#import "ExprotLogViewController.h"
#import "AboutViewController.h"

@interface settingViewController ()

@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Settings", nil);
    self.navigationController.navigationBar.translucent = NO;
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    UIScrollView *scrView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    //scrView.backgroundColor = [UIColor orangeColor];
    scrView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 50);
    [self.view addSubview:scrView];
    
    //Account Manager
    UIButton *btnAccountManager = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 50)];
    //btnAccountManager.backgroundColor = [UIColor greenColor];
    [btnAccountManager.layer setBorderWidth:1.0];
    btnAccountManager.layer.borderColor = [UIColor grayColor].CGColor;
    [btnAccountManager setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnAccountManager setTitle:NSLocalizedString(@"Account Manager", nil) forState:UIControlStateNormal];
    btnAccountManager.titleLabel.font = [UIFont systemFontOfSize:14];
    [scrView addSubview:btnAccountManager];
    [btnAccountManager addTarget:self action:@selector(AccountManager) forControlEvents:UIControlEventTouchUpInside];
    
    //Audio Settings
    UIButton *btnAudioSettings = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 50)];
    //btnAudioSettings.backgroundColor = [UIColor blackColor];
    [btnAudioSettings.layer setBorderWidth:1.0];
    btnAudioSettings.layer.borderColor = [UIColor grayColor].CGColor;
    [btnAudioSettings setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnAudioSettings setTitle:NSLocalizedString(@"Audio Settings", nil) forState:UIControlStateNormal];
    btnAudioSettings.titleLabel.font = [UIFont systemFontOfSize:14];
    [scrView addSubview:btnAudioSettings];
    [btnAudioSettings addTarget:self action:@selector(AudioSettings) forControlEvents:UIControlEventTouchUpInside];
    
    //Video Settings
    UIButton *btnVideoSettings = [[UIButton alloc]initWithFrame:CGRectMake(0, 170, self.view.bounds.size.width, 50)];
    //btnVideoSettings.backgroundColor = [UIColor blackColor];
    [btnVideoSettings setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnVideoSettings setTitle:NSLocalizedString(@"Video Settings", nil) forState:UIControlStateNormal];
    btnVideoSettings.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnVideoSettings.layer setBorderWidth:1.0];
    btnVideoSettings.layer.borderColor = [UIColor grayColor].CGColor;
    [scrView addSubview:btnVideoSettings];
    [btnVideoSettings addTarget:self action:@selector(VideoSettings) forControlEvents:UIControlEventTouchUpInside];
    
    //Advance Settings
    UIButton *btnAdvanceSettings = [[UIButton alloc]initWithFrame:CGRectMake(0, 240, self.view.bounds.size.width, 50)];
    //btnAdvanceSettings.backgroundColor = [UIColor blackColor];
    [btnAdvanceSettings setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnAdvanceSettings setTitle:NSLocalizedString(@"Advance Settings", nil) forState:UIControlStateNormal];
    btnAdvanceSettings.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnAdvanceSettings.layer setBorderWidth:1.0];
    btnAdvanceSettings.layer.borderColor = [UIColor grayColor].CGColor;
    [scrView addSubview:btnAdvanceSettings];
    [btnAdvanceSettings addTarget:self action:@selector(AdvanceSettings) forControlEvents:UIControlEventTouchUpInside];
    
    //Exprot Log
    UIButton *btnExprotLog = [[UIButton alloc]initWithFrame:CGRectMake(0, 310, self.view.bounds.size.width, 50)];
    //btnExprotLog.backgroundColor = [UIColor blackColor];
    [btnExprotLog setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnExprotLog setTitle:NSLocalizedString(@"Export Log", nil) forState:UIControlStateNormal];
    btnExprotLog.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnExprotLog.layer setBorderWidth:1.0];
    btnExprotLog.layer.borderColor = [UIColor grayColor].CGColor;
    [scrView addSubview:btnExprotLog];
    [btnExprotLog addTarget:self action:@selector(ExprotLog) forControlEvents:UIControlEventTouchUpInside];
    
    //About
    UIButton *btnAbout = [[UIButton alloc]initWithFrame:CGRectMake(0, 380, self.view.bounds.size.width, 50)];
    //btnAbout.backgroundColor = [UIColor blackColor];
    [btnAbout setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [btnAbout setTitle:NSLocalizedString(@"About", nil) forState:UIControlStateNormal];
    btnAbout.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnAbout.layer setBorderWidth:1.0];
    btnAbout.layer.borderColor = [UIColor grayColor].CGColor;
    [scrView addSubview:btnAbout];
    [btnAbout addTarget:self action:@selector(About) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginMessage:) name:@"loginMessage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginoutMessage:) name:@"loginoutMessage" object:nil];
}

- (void)AccountManager
{

    AccountManagerViewController *accountManagerVC = [[AccountManagerViewController alloc]init];
    if (_loginStatus) {
        accountManagerVC.UISwitchStatus = YES;
    }else{
        accountManagerVC.UISwitchStatus = NO;
    }
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:accountManagerVC animated:YES];
}

- (void)AudioSettings
{

    AudioSettingsViewController *audioSettingsVC = [[AudioSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:audioSettingsVC animated:YES];
}

- (void)VideoSettings
{

    VideoSettingsViewController *videoSettingsVC = [[VideoSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:videoSettingsVC animated:YES];
}

- (void)AdvanceSettings
{

    AdvanceSettingsViewController *advanceSettingVC = [[AdvanceSettingsViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:advanceSettingVC animated:YES];
}

- (void)ExprotLog
{

    ExprotLogViewController *exprotLogVC = [[ExprotLogViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:exprotLogVC animated:YES];
}

- (void)About
{

    AboutViewController *aboutVC = [[AboutViewController alloc]init];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:aboutVC animated:YES];
}


- (void)loginMessage:(NSNotification *)notification
{
    _loginStatus = YES;
}

- (void)loginoutMessage:(NSNotification *)notification
{
    _loginStatus = NO;
}

@end
