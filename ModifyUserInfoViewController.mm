//
//  ModifyUserInfoViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/11.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "ModifyUserInfoViewController.h"
#import "AudioCodecViewController.h"
#import "VideoCodecViewController.h"
#import "Masonry.h"
#import "IQKeyboardManager.h"
#import "VBellsqlBase.h"
#import "AccountGroupsModel.h"
#import "VideoCodecModel.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"

#define labelHeight 40
#define marginHeight 10

@interface ModifyUserInfoViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *proxyView;
@property (nonatomic, strong) UIView *codecSettingsView;
@property (nonatomic, strong) UITextField *userRegister;
@property (nonatomic, strong) UITextField *userName;
@property (nonatomic, strong) UITextField *passWord;
@property (nonatomic, strong) UITextField *displayName;
@property (nonatomic, strong) UITextField *serverURL;
@property (nonatomic, strong) UITextField *serverPort;
@property (nonatomic, strong) UITextField *proxyServerURL;
@property (nonatomic, strong) UITextField *proxyServerPort;
@property (nonatomic, strong) UISwitch *proxySwitch;
@property (nonatomic, assign) BOOL isCodecSettingShow;
@property (nonatomic, assign) BOOL isProxyShow;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UIView *setupFirstPartView;
@property (nonatomic, strong) UIView *setupSecondPartView;
@property (nonatomic, strong) UIView *setupProxyPartView;
@property (nonatomic, strong) UIView *setupCodecSettingsView;
@property (nonatomic, strong) UIView *setupFootPartView;
@property (nonatomic, strong) NSString *recordcalluuid;

@end

@implementation ModifyUserInfoViewController

- (void)viewDidLoad {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    __weak typeof(self) weakSelf = self;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    
    
    NSString *modifyAccount = NSLocalizedString(@"Modify Account", nil);
    
    NSString *strTitle = _userNameTitle.length==0? [NSString stringWithFormat:@"%@[Account 1]",modifyAccount]:[NSString stringWithFormat:@"%@ [%@]",modifyAccount,_userNameTitle];
//    NSString *strTitle = _userNameTitle.length==0? [NSString stringWithFormat:@"Modify Account[Account 1]"]:[NSString stringWithFormat:@"Modify Account[%@]",_userNameTitle];
    self.title = strTitle;
    
    self.navigationController.navigationBar.translucent = NO;
    //创建一个UIButton
    UIButton *leftMenuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    //设置UIButton的图像
    [leftMenuButton setImage:[UIImage imageNamed:@"goback.png"] forState:UIControlStateNormal];
    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
    [leftMenuButton addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
    UIBarButtonItem *leftMenu = [[UIBarButtonItem alloc]initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItem = leftMenu;
    
    UIView *sv = [[UIView alloc] init];
    sv.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    //一定要先将view添加到superView上，否则会出错
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(weakSelf.view);
    }];
    self.scrollView = [[UIScrollView alloc]init];
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = FALSE;
    [sv addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        //设置边界约束
        make.edges.equalTo(sv).with.insets(UIEdgeInsetsMake(0,0,0,0));
    }];
    
    self.container = [[UIView alloc] init];
    [_scrollView addSubview:_container];
    //添加container约束
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);//边界紧贴ScrollView边界
        make.width.equalTo(_scrollView);//宽度和ScrollView相等
    }];
    
    
    self.setupFirstPartView = [self setupFirstPart];
    self.setupSecondPartView =[self setupSecondPart];
    //self.setupCodecSettingsView = [self setupCodecSettingsPart];
    self.setupFootPartView =[self setupFooterPart];
    
    
    [_container addSubview:_setupFirstPartView];
    [_container addSubview:_setupSecondPartView];
//    [_container addSubview:_setupProxyPartView];
    [_container addSubview:_setupFootPartView];
    
    [_setupFirstPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_container).offset(15);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, 323));
    }];
    
    [_setupSecondPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_setupFirstPartView.mas_bottom).offset(10);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*1/9));
    }];
    
    [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
    }];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        //container的下边界和最后一个View的下边界紧贴
        make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
    }];
}

- (UIView *)setupFirstPart
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.firstView = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 203 )];
    
    NSArray *array = [NSArray arrayWithObjects:@"Register", @"User Name", @"Password", @"Display Name", @"Server URL", @"Server Port", nil];
    NSString *title = NSLocalizedString(@"Basic", nil);
    
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = title;
    [TopLabel setTextColor:UnifiedColor];
//    TopLabel.backgroundColor = [UIColor redColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, (i+1)*marginHeight+i*labelHeight + 23, _firstView.bounds.size.width*1/3, labelHeight)];
        label.text = NSLocalizedString(array[i], nil);
        label.font = [UIFont systemFontOfSize:14];
        [_firstView addSubview:label];
    }
    
    self.userRegister = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, marginHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    _userRegister.text = [user objectForKey:@"registerName"];
    self.userName = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, 2*marginHeight+labelHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    _userName.text = [user objectForKey:@"userName"];
    self.passWord = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, 3*marginHeight+2*labelHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    _passWord.text = [user objectForKey:@"passWord"];
    self.displayName = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, 4*marginHeight+3*labelHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    self.serverURL = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, 5*marginHeight+4*labelHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    _serverURL.text = [user objectForKey:@"serverURL"];
    self.serverPort = [[UITextField alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width*1/3, 6*marginHeight+5*labelHeight + 23, _firstView.bounds.size.width*2/3, labelHeight)];
    _serverPort.text = [user objectForKey:@"serverPort"];
    _passWord.secureTextEntry = YES;
    [_userRegister becomeFirstResponder];
    [self setTextField:_userRegister];
    [self setTextField:_userName];
    [self setTextField:_passWord];
    [self setTextField:_displayName];
    [self setTextField:_serverURL];
    [self setTextField:_serverPort];
    
    [_firstView addSubview:blueDot];
    [_firstView addSubview:TopLabel];
    [_firstView addSubview:lineView];
    
    return _firstView;
}

- (UIView *)setupSecondPart
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //view.backgroundColor = [UIColor grayColor];
    
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Proxy", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    label.text = NSLocalizedString(@"Outbound Proxy", nil);
    label.font = [UIFont systemFontOfSize:14];
    
    self.proxySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(view.bounds.size.width*3/4, marginHeight + 23, view.bounds.size.width*1/4, labelHeight)];
    
    [_proxySwitch addTarget:self action:@selector(proxyChanged:) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:blueDot];
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:label];
    [view addSubview:_proxySwitch];
    
    return view;
}

- (UIView *)setupProxyPart
{
    self.proxyView = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*7/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, labelHeight*2+marginHeight)];
    NSArray *array = [NSArray arrayWithObjects:@"Proxy Server URL", @"Proxy Server Prot", nil];
    for (int i = 0; i < array.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, i*(marginHeight+labelHeight) , _proxyView.bounds.size.width*1/3 + 20, labelHeight)];
        label.text = NSLocalizedString(array[i], nil);
        label.font = [UIFont systemFontOfSize:14];
        [_proxyView addSubview:label];
    }
    
    self.proxyServerURL = [[UITextField alloc]initWithFrame:CGRectMake(_proxyView.bounds.size.width*1/3+23, 0, _proxyView.bounds.size.width*2/3-23, labelHeight)];
    self.proxyServerPort = [[UITextField alloc]initWithFrame:CGRectMake(_proxyView.bounds.size.width*1/3+23, marginHeight+labelHeight, _proxyView.bounds.size.width*2/3-23, labelHeight)];
    [self setSecondPartTextField:_proxyServerURL];
    [self setSecondPartTextField:_proxyServerPort];

    return _proxyView;
}

- (UIView *)setupCodecSettingsPart
{
    self.codecSettingsView = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*8/9-self.navigationController.navigationBar.bounds.size.height/3-70, self.view.bounds.size.width - 30, self.navigationController.navigationBar.bounds.size.height*3+marginHeight)];
    
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Codec Settings", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UIButton *audioBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, marginHeight + 23 , self.view.bounds.size.width - 30, 30)];
    [audioBtn setTitle:NSLocalizedString(@"Audio Codec", nil) forState:UIControlStateNormal];
    //audioBtn.backgroundColor = [UIColor redColor];
    audioBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [audioBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [audioBtn addTarget:self action:@selector(audioCodecSetting) forControlEvents:UIControlEventTouchUpInside];
    UIView *audioLineView = [[UIView alloc]initWithFrame:CGRectMake(0, marginHeight + 53, self.view.bounds.size.width - 30, 1)];
    audioLineView.backgroundColor = [UIColor grayColor];
    
    
    UIButton *videoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, marginHeight + 64 , self.view.bounds.size.width - 30, 30)];
    [videoBtn setTitle:NSLocalizedString(@"Video Codec", nil) forState:UIControlStateNormal];
    //videoBtn.backgroundColor = [UIColor redColor];
    videoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [videoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(videoCodecSetting) forControlEvents:UIControlEventTouchUpInside];
    UIView *videoLineView = [[UIView alloc]initWithFrame:CGRectMake(0, marginHeight + 94, self.view.bounds.size.width - 30, 1)];
    videoLineView.backgroundColor = [UIColor grayColor];
    
    UIButton *hideBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, marginHeight + 105, self.view.bounds.size.width - 30, 20)];
    //hideBtn.backgroundColor = [UIColor orangeColor];
    [hideBtn setTitle:NSLocalizedString(@"Hide", nil) forState:UIControlStateNormal];
    [hideBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    hideBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [hideBtn addTarget:self action:@selector(hideFrame) forControlEvents:UIControlEventTouchUpInside];
    
    _saveButton.frame = CGRectMake(15, self.view.bounds.size.height*7/9+self.navigationController.navigationBar.bounds.size.height+marginHeight, self.view.bounds.size.width - 30, labelHeight);
    
    //_codecSettingsShow.backgroundColor = [UIColor redColor];
    [_codecSettingsView addSubview:blueDot];
    [_codecSettingsView addSubview:audioBtn];
    [_codecSettingsView addSubview:videoBtn];
    [_codecSettingsView addSubview:TopLabel];
    [_codecSettingsView addSubview:lineView];
    [_codecSettingsView addSubview:audioLineView];
    [_codecSettingsView addSubview:videoLineView];
    [_codecSettingsView addSubview:hideBtn];

    return _codecSettingsView;
}

- (UIView *)setupFooterPart
{
    UIView *view= [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*7/9-self.navigationController.navigationBar.bounds.size.height/3-50, self.view.bounds.size.width - 30, 70)];
    //view.backgroundColor = [UIColor redColor];
    self.moreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 20)];
    [_moreButton setTitle:NSLocalizedString(@"More", nil) forState:UIControlStateNormal];
    _moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(codecSettingsShow) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, view.bounds.size.width, 40)];
    _saveButton.backgroundColor = UnifiedColor;
    [_saveButton setTitle:NSLocalizedString(@"Save" , nil)forState:UIControlStateNormal];
    _saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_saveButton addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_moreButton];
    [view addSubview:_saveButton];
    return view;
}

- (UIView *)setupNoMoreFooterPart
{
    UIView *view= [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*7/9-self.navigationController.navigationBar.bounds.size.height/3-80, self.view.bounds.size.width - 30, 70)];
    //view.backgroundColor = [UIColor redColor];
//    self.moreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 20)];
//    [_moreButton setTitle:@"More" forState:UIControlStateNormal];
//    _moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_moreButton addTarget:self action:@selector(codecSettingsShow) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 40)];
    _saveButton.backgroundColor = UnifiedColor;
    [_saveButton setTitle:NSLocalizedString(@"Save" , nil) forState:UIControlStateNormal];
    _saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [view addSubview:_moreButton];
    [view addSubview:_saveButton];
    return view;
}


- (void)proxyChanged:(UISwitch *)proxySwitch
{
    if ([proxySwitch isOn]) {
        if (_isCodecSettingShow) {
            [_setupFootPartView removeFromSuperview];
            [_setupProxyPartView removeFromSuperview];
            [_setupCodecSettingsView removeFromSuperview];
            self.setupProxyPartView = [self setupProxyPart];
            self.setupCodecSettingsView = [self setupCodecSettingsPart];
            self.setupFootPartView = [self setupNoMoreFooterPart];
            [_container addSubview:_setupProxyPartView];
            [_container addSubview:_setupCodecSettingsView];
            [_container addSubview:_setupFootPartView];
            [_setupProxyPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, labelHeight*2+marginHeight));
            }];
            [_setupCodecSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupProxyPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, self.navigationController.navigationBar.bounds.size.height*3+marginHeight));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCodecSettingsView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            [_moreButton removeFromSuperview];
            self.isProxyShow = YES;
        }else{
            [_setupFootPartView removeFromSuperview];
            [_setupProxyPartView removeFromSuperview];
            self.setupProxyPartView = [self setupProxyPart];
            self.setupFootPartView = [self setupFooterPart];
            [_container addSubview:_setupProxyPartView];
            [_container addSubview:_setupFootPartView];
            [_setupProxyPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, labelHeight*2+marginHeight));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupProxyPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            
            self.isProxyShow = YES;
        }
    }else{
        if (!_isCodecSettingShow) {
            [_setupFootPartView removeFromSuperview];
            [_setupProxyPartView removeFromSuperview];
            
            self.setupFootPartView = [self setupFooterPart];
            [_container addSubview:_setupFootPartView];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
        }else{
            [_setupFootPartView removeFromSuperview];
            [_setupProxyPartView removeFromSuperview];
            [_setupCodecSettingsView removeFromSuperview];
            [_container addSubview:_setupCodecSettingsView];
            [_container addSubview:_setupFootPartView];
            
            [_setupCodecSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, self.navigationController.navigationBar.bounds.size.height*3+marginHeight));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCodecSettingsView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
        }
        self.isProxyShow = NO;
    }
}

- (void)codecSettingsShow
{
    if (!_isProxyShow) {//switch开关为关闭的时候显示下面内容
        [_setupFootPartView removeFromSuperview];
        [_setupCodecSettingsView removeFromSuperview];
        self.setupCodecSettingsView = [self setupCodecSettingsPart];
        self.setupFootPartView = [self setupNoMoreFooterPart];
        [_container addSubview:_setupCodecSettingsView];
        [_container addSubview:_setupFootPartView];
        [_setupCodecSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, self.navigationController.navigationBar.bounds.size.height*3+marginHeight));
        }];
        [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupCodecSettingsView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
        }];
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
        }];
        [_moreButton removeFromSuperview];
        self.isCodecSettingShow = YES;
    }else{//switch开关为开启的时候显示下面内容
        [_setupFootPartView removeFromSuperview];
        [_setupCodecSettingsView removeFromSuperview];
        self.setupCodecSettingsView = [self setupCodecSettingsPart];
        self.setupFootPartView = [self setupNoMoreFooterPart];
        [_container addSubview:_setupCodecSettingsView];
        [_container addSubview:_setupFootPartView];
        [_setupCodecSettingsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupProxyPartView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, self.navigationController.navigationBar.bounds.size.height*3+marginHeight));
        }];
        [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupCodecSettingsView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
        }];
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            //container的下边界和最后一个View的下边界紧贴
            make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
        }];
        [_moreButton removeFromSuperview];
        self.isCodecSettingShow = YES;
    }
    
}

- (void)hideFrame
{
    [_codecSettingsView removeFromSuperview];
    if (!_isProxyShow) {
        [_setupFootPartView removeFromSuperview];
        self.setupFootPartView = [self setupFooterPart];
        [_container addSubview:_setupFootPartView];
        [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupSecondPartView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
        }];
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            //container的下边界和最后一个View的下边界紧贴
            make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
        }];
    }else{
        [_setupFootPartView removeFromSuperview];
        self.setupFootPartView = [self setupFooterPart];
        [_container addSubview:_setupFootPartView];
        [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_setupProxyPartView.mas_bottom).offset(10);
            make.left.equalTo(_container).offset(15);
            make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
        }];
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            //container的下边界和最后一个View的下边界紧贴
            make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
        }];

    }
    _isCodecSettingShow = NO;
}

- (void)setTextField:(UITextField *)textField
{
    textField.delegate = self;
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=UnifiedColor.CGColor;
    textField.layer.borderWidth= 1.0f;
    textField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 7, 30)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
//    textField.keyboardType = UIKeyboardTypeNumberPad;
    [_firstView addSubview:textField];
}

- (void)setSecondPartTextField:(UITextField *)textField
{
    textField.delegate = self;
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=UnifiedColor.CGColor;
    textField.layer.borderWidth= 1.0f;
    textField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 7, 30)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
//    textField.keyboardType = UIKeyboardTypeNumberPad;
    [_proxyView addSubview:textField];
}

- (void)audioCodecSetting
{
    AudioCodecViewController *audioVC = [[AudioCodecViewController alloc]init];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:audioVC animated:NO];
}

- (void)videoCodecSetting
{
    VideoCodecViewController *videoVC = [[VideoCodecViewController alloc]init];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:videoVC animated:NO];
}

#pragma mark -UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor=[[UIColor orangeColor] CGColor];
    textField.backgroundColor = [UIColor whiteColor];
}

// 失去第一响应者时调用
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor=UnifiedColor.CGColor;
//    textField.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
}


- (void)doLogin:(UIButton *)btn
{
    NSString *registerNameStr = _userRegister.text;
    NSString *usernameStr = _userName.text;
    NSString *password = _passWord.text;
//    NSString *dispalyNameStr = _displayName.text;
    NSString *serverURLStr = _serverURL.text;
    NSString *serverPortStr = _serverPort.text;
//    if ([self.delegate respondsToSelector:@selector(modifyUserInfoController:registerName:userName:passWord:serverURL:serverPort:)]) {
//        [self.delegate modifyUserInfoController:self registerName:registerNameStr userName:usernameStr passWord:password serverURL:serverURLStr serverPort:serverPortStr];
//    }
    
    [self setupLoginInforegisterName:registerNameStr userName:usernameStr passWord:password serverURL:serverURLStr serverPort:serverPortStr];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setupLoginInforegisterName:(NSString *)registerName userName:(NSString *)userName passWord:(NSString *)passWord serverURL:(NSString *)serverURL serverPort:(NSString *)serverPort
{
    NSLog(@"setupLoginInfo");
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *audioCodecArray = [base getAudioCodecInfo];
    NSArray *videoCodecArray = [base getVideoCodecInfo];
    AudioCodecModel *audioCodecModelFirst = nil;
    AudioCodecModel *audioCodecModelSecond = nil;
    AudioCodecModel *audioCodecModelThird = nil;
    AudioCodecModel *audioCodecModelForth = nil;
    VideoCodecModel *videoCodecModel = nil;
    if (audioCodecArray.count != 0) {
        audioCodecModelFirst = audioCodecArray[0];
        audioCodecModelSecond = audioCodecArray[1];
        audioCodecModelThird = audioCodecArray[2];
        audioCodecModelForth = audioCodecArray[3];
    }else{
        return;
    }
    if (videoCodecArray.count != 0) {
        videoCodecModel = videoCodecArray[0];
    }else{
        return;
    }
    
    mediaengine_Init();
    sipcall_set_ipaddr([self getIPAddress]);
    //sipcall_reg_msg_handle(&sipcall_msg_handle);
//    sipcall_init();
    
    SIPCALL_ACCOUNT_SETTING account;
    memset(&account, 0, sizeof(account));
    account.enable = 1;
    strcpy(account.user_name, [userName UTF8String]);
    strcpy(account.reg_name, [registerName UTF8String]);
    strcpy(account.sip.url, [serverURL UTF8String]);
    account.sip.port = [serverPort intValue];
    strcpy(account.password, [passWord UTF8String]);
    
    
    
    account.audio[0].enable = audioCodecModelFirst.enable;
    account.audio[0].payload = audioCodecModelFirst.payload;
    account.audio[0].priority = 10;
    strcpy(account.audio[0].name, [audioCodecModelFirst.name UTF8String]);
    
    account.audio[1].enable = audioCodecModelSecond.enable;
    account.audio[1].payload = audioCodecModelSecond.payload;
    account.audio[1].priority = 9;
    strcpy(account.audio[1].name, [audioCodecModelSecond.name UTF8String]);
    
    account.audio[2].enable = audioCodecModelThird.enable;
    account.audio[2].payload = audioCodecModelThird.payload;
    account.audio[2].priority = 8;
    strcpy(account.audio[2].name, [audioCodecModelThird.name UTF8String]);
    
    account.audio[3].enable = audioCodecModelForth.enable;
    account.audio[3].payload = audioCodecModelForth.payload;
    account.audio[3].priority = 7;
    strcpy(account.audio[3].name, [audioCodecModelForth.name UTF8String]);
    
    account.video[0].enable = videoCodecModel.enable;
    account.video[0].payload = videoCodecModel.payload;
    account.video[0].priority = 7;
    account.video[0].profile_level = 1;
    account.video[0].max_br = 1280;
    strcpy(account.video[0].name, "H264");
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setObject:userName forKey:@"userName"];
    [user setObject:registerName forKey:@"registerName"];
    [user setObject:passWord forKey:@"passWord"];
    [user setObject:serverURL forKey:@"serverURL"];
    [user setObject:serverPort forKey:@"serverPort"];
    
//    if ([self.delegate respondsToSelector:@selector(modifyUserInfoController:userName:)]) {
//        [self.delegate modifyUserInfoController:self userName:userName];
//    }
    
    NSString * changedName = [NSString stringWithFormat:@"%@", userName];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithObject:changedName forKey:@"changedName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGELOGINNAME" object:mutableDictionary];
    
    sipcall_update_account_setting(0, &account);
}

- (char *)getIPAddress
{
    char *address = "error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    NSLog(@"IP:%s",address);
    return address;
    
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}



@end