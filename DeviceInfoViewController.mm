//
//  DeviceInfoViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/7/29.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "userModel.h"
#import "VBellsqlBase.h"
#import "MBProgressHUD.h"
#import "AllCallsViewController.h"
#import "AddUserViewController.h"
#import "ModifyDeviceViewController.h"
#import "CallingShowViewController.h"
#import "DeviceInfoButton.h"
#import "AllCallsWithUserNameViewController.h"
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"


static int g_accountid = 0;
static int g_callid = 0;
#define rl_log_debug printf
#define rl_log_info printf
#define rl_log_err printf
@interface DeviceInfoViewController ()<ModifyDeviceViewControllerDelegate>{
    int callType;
}
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) DeviceInfoButton *makeCallBtn;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UIButton *rtspBtn;
@property (nonatomic, strong) UIButton *callHistoryBtn;
@property (nonatomic, strong) UIButton *deleteDeviceBtn;
@property (nonatomic, strong) UIButton *numberBtn;
@property (nonatomic, strong) UILabel *rtspLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, assign) BOOL isReadyCall;
@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Device Info", nil);
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
    
    //创建一个UIButton
    UIButton *modifyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    //设置UIButton的图像
    [modifyButton setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
    [modifyButton addTarget:self action:@selector(rightClickEvent) forControlEvents:UIControlEventTouchUpInside];
    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
    UIBarButtonItem *modifyDevice = [[UIBarButtonItem alloc]initWithCustomView:modifyButton];
    //覆盖右侧按键
    self.navigationItem.rightBarButtonItem = modifyDevice;
    
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    //初始
    [self setupUIisRTSPShow:0 andRTSP:@""];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isVideoCall) name:@"VIDEOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isAudioCall) name:@"AUDIOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(modifyDeviceInfo:) name:@"MODIFYDEVICE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isReadyCall:) name:@"CHANGEREGISTERSTATE" object:nil];
}

- (void)setupUIisRTSPShow:(int)showRTSPOrNot andRTSP:(NSString *)rtspStr
{
    __weak typeof(self) weakSelf = self;
    self.topView = [[UIView alloc]init];
    _topView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_topView];
    
    self.iconBtn = [[UIButton alloc]init];
    _iconBtn.backgroundColor = [UIColor clearColor];
    [_iconBtn setImage:[UIImage imageNamed:@"My Device.png"] forState:UIControlStateNormal];
    [_topView addSubview:_iconBtn];
    
    UIButton *accountBtn = [[UIButton alloc]init];
    [accountBtn setTitle:NSLocalizedString(@"ACCOUNT", nil) forState:UIControlStateNormal];
    accountBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [accountBtn setTitleColor:UnifiedColor forState:UIControlStateNormal];
    accountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_topView addSubview:accountBtn];
    
    UIView *firstLineView = [[UIView alloc]init];
    firstLineView.backgroundColor = [UIColor redColor];
    [_topView addSubview:firstLineView];
    
    UIButton *nameBtn = [[UIButton alloc]init];
    [nameBtn setTitle:NSLocalizedString(@"NAME", nil) forState:UIControlStateNormal];
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nameBtn setTitleColor:UnifiedColor forState:UIControlStateNormal];
    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_topView addSubview:nameBtn];
    
    UIView *secondLineView = [[UIView alloc]init];
    secondLineView.backgroundColor = [UIColor redColor];
    [_topView addSubview:secondLineView];
    
    self.numberBtn = [[UIButton alloc]init];
    [_numberBtn setTitle:NSLocalizedString(@"NUMBER" , nil)forState:UIControlStateNormal];
    _numberBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_numberBtn setTitleColor:UnifiedColor forState:UIControlStateNormal];
    _numberBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_topView addSubview:_numberBtn];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    UILabel *accountLabel = [[UILabel alloc]init];
    [_topView addSubview:accountLabel];
    accountLabel.textAlignment = NSTextAlignmentRight;
    accountLabel.text = [user objectForKey:@"userName"];//@"54654";
    accountLabel.font = [UIFont systemFontOfSize:13];
    
    _nameLabel = [[UILabel alloc]init];
    [_topView addSubview:_nameLabel];
    _nameLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.text = _name;
    _nameLabel.font = [UIFont systemFontOfSize:13];
    
    _numberLabel = [[UILabel alloc]init];
    [_topView addSubview:_numberLabel];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    _numberLabel.text = _number;
    _numberLabel.font = [UIFont systemFontOfSize:13];
    
    
    self.makeCallBtn = [[DeviceInfoButton alloc]initWithFrame:CGRectZero andBtnWidth:(DeviceScreenWidth-80)/3 andImage:[UIImage imageNamed:@"MAKE CALL-1.png"] andBtnName:@"Make Call"];
    _makeCallBtn.backgroundColor = UnifiedColor;
    _makeCallBtn.layer.cornerRadius = 10.0f;
    _makeCallBtn.layer.masksToBounds = YES;
    [_makeCallBtn addTarget:self action:@selector(makeCallBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_makeCallBtn];
    
    self.rtspBtn = [[DeviceInfoButton alloc]initWithFrame:CGRectZero andBtnWidth:(DeviceScreenWidth-80)/3 andImage:[UIImage imageNamed:@"RTSP-1.png"] andBtnName:@"RTSP"];
    
    _rtspBtn.layer.cornerRadius = 10.0f;
    _rtspBtn.layer.masksToBounds = YES;
    [_rtspBtn addTarget:self action:@selector(rtspBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rtspBtn];
    
    self.callHistoryBtn = [[DeviceInfoButton alloc]initWithFrame:CGRectZero andBtnWidth:(DeviceScreenWidth-80)/3 andImage:[UIImage imageNamed:@"RECENT ACTIVITY-1.png"] andBtnName:@"History"];
    _callHistoryBtn.backgroundColor = UnifiedColor;
    _callHistoryBtn.layer.cornerRadius = 10.0f;
    _callHistoryBtn.layer.masksToBounds = YES;
    [_callHistoryBtn addTarget:self action:@selector(callHistoryBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_callHistoryBtn];
    
    self.deleteDeviceBtn = [[DeviceInfoButton alloc]initWithFrame:CGRectZero andBtnWidth:(DeviceScreenWidth-80)/3 andImage:[UIImage imageNamed:@"DELETE DEVICE-1.png"] andBtnName:@"Delete"];
    _deleteDeviceBtn.backgroundColor = UnifiedColor;
    _deleteDeviceBtn.layer.cornerRadius = 10.0f;
    _deleteDeviceBtn.layer.masksToBounds = YES;
    [_deleteDeviceBtn addTarget:self action:@selector(deleteDeviceInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteDeviceBtn];
    if (showRTSPOrNot == 0) {//初始化
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            _rtspBtn.enabled = NO;
            _rtspBtn.backgroundColor = [UIColor grayColor];
            make.top.equalTo(weakSelf.view);
            make.left.equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth, DeviceScreenHeight/3));
        }];
    }else if(showRTSPOrNot == 1){//开启
        _rtspBtn.enabled = YES;
        _rtspBtn.backgroundColor = UnifiedColor;
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth, DeviceScreenHeight/3+70));
        }];
    }else{//关闭
        _rtspBtn.enabled = NO;
        _rtspBtn.backgroundColor = [UIColor grayColor];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth, DeviceScreenHeight/3+20));
        }];
    }
    [_iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView);
        make.leading.offset(30);
        make.size.mas_equalTo(CGSizeMake(107, 107));
    }];
    
    [accountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconBtn.mas_right).offset(20);
        make.top.equalTo(_topView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        //make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [firstLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconBtn.mas_right).offset(20);
        make.top.equalTo(accountBtn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth-137, 1));
    }];
    
    [nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconBtn.mas_right).offset(20);
        make.top.equalTo(firstLineView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        //make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconBtn.mas_right).offset(20);
        make.top.equalTo(nameBtn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth-137, 1));
    }];
    
    [_numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconBtn.mas_right).offset(20);
        make.top.equalTo(secondLineView.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        //make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    if (showRTSPOrNot==1) {//开启
        self.rtspLabel = [[UILabel alloc]init];
        _rtspLabel.text = [NSString stringWithFormat:@"RTSP  %@",rtspStr];
        _rtspLabel.font = [UIFont systemFontOfSize:13];
        [_topView addSubview:_rtspLabel];
        [_rtspLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconBtn.mas_right).offset(20);
            make.top.equalTo(_numberBtn.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(200, 30));
        }];
    }
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-5);
        make.top.equalTo(_topView.mas_top).offset(18);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-5);
        make.top.equalTo(firstLineView.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        //make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-5);
        make.top.equalTo(secondLineView.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        //make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    
    [_makeCallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.view).offset(20);
        make.size.mas_equalTo(CGSizeMake((DeviceScreenWidth-80)/3, (DeviceScreenWidth-80)/3+10));
    }];
    
    [_rtspBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom).offset(20);
        make.left.equalTo(_makeCallBtn.mas_right).offset(20);
        make.size.mas_equalTo(CGSizeMake((DeviceScreenWidth-80)/3, (DeviceScreenWidth-80)/3+10));
    }];
    
    [_callHistoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom).offset(20);
        make.left.equalTo(_rtspBtn.mas_right).offset(20);
        make.size.mas_equalTo(CGSizeMake((DeviceScreenWidth-80)/3, (DeviceScreenWidth-80)/3+10));
    }];
    
    [_deleteDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_makeCallBtn.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.view).offset(20);
        make.size.mas_equalTo(CGSizeMake((DeviceScreenWidth-80)/3, (DeviceScreenWidth-80)/3+10));
    }];
    
}

- (void)isVideoCall
{
    NSLog(@"isVideoCall");
    callType = 1;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    [base insertCallingHistoryTabNumber:_numberLabel.text name:_nameLabel.text Calltime:time callType:callType callDictionary:1];
}

- (void)isAudioCall
{
    NSLog(@"isAudioCall");
    callType = 0;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    [base insertCallingHistoryTabNumber:_numberLabel.text name:_nameLabel.text Calltime:time callType:callType callDictionary:1];
}

- (void)isReadyCall:(NSNotification*)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *registerState = [infoDic valueForKey:@"registerState"];
    if ([registerState isEqualToString:@"2"]) {
        _isReadyCall = YES;
    }
}


-(void)makeCallBtn:(UIButton *)btn
{
    NSLog(@"make call");
    if (_isReadyCall) {
        //呼叫
        CallingShowViewController *callingShowVC = [[CallingShowViewController alloc]init];
        int cid = 1000;
        SIPCALL_DIALOUT_DATA dialout;
        memset(&dialout, 0, sizeof(dialout));
        dialout.cid = cid;
        strcpy(dialout.remote_username, [_numberLabel.text UTF8String]);
        
        NSString *callNumber =  _numberLabel.text;
        NSArray *array = [callNumber componentsSeparatedByString:@"."];
        if (array.count == 4) {
            sipcall_send_msg(SIPCALL_SEND_MSG_DIALOUT, cid, 1, &dialout, sizeof(dialout));
            g_callid = cid;
            g_accountid = 1;
            callingShowVC.g_accountid = 1;
        }else{
            sipcall_send_msg(SIPCALL_SEND_MSG_DIALOUT, cid, 0, &dialout, sizeof(dialout));
            g_callid = cid;
            g_accountid = 0;
            callingShowVC.g_accountid = 0;
        }
        callingShowVC.g_callid = cid;
        callingShowVC.name = _nameLabel.text;
        callingShowVC.number = _numberLabel.text;
        
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithObject:_numberLabel.text forKey:@"makeCallNumber"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"makeCallNumber" object:mutableDictionary];
        
        [self presentViewController:callingShowVC animated:YES completion:nil];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Account is not Ready", @"HUD message title");
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        return;
    }
}

-(void)deleteDeviceInfo:(UIButton *)btn
{
    NSLog(@"deleteDeviceInfo");
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    BOOL result = [base deleteUserInfoUsingPhoneNumber:_number];
    if (result) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DELETEDEVICE" object:_number];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Delete Device Success!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        
        //传递的值
//        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithObject:_number forKey:@"deviceNumber"];
//        [mutableDictionary setValue:_displayName.text forKey:@"deviceName"];
        //发出通知
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DELETEDEVICE" object:nil];
        [[self navigationController] popViewControllerAnimated:YES];
        
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Delete wrong!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
    }
}

-(void)callHistoryBtn:(UIButton *)btn
{
    NSLog(@"callHistoryBtn");
    AllCallsWithUserNameViewController *allCallCV = [[AllCallsWithUserNameViewController alloc]init];
    allCallCV.number = _number;
    allCallCV.name = _name;
    [self.navigationController pushViewController:allCallCV animated:YES];
}

- (void)rtspBtn:(UIButton *)btn
{
    NSLog(@"rtspBtn");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEOCALL" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AUDIOCALL" object:nil];
    //
}

- (void)rightClickEvent
{
    NSLog(@"ModifyDeviceInfoShow");
    ModifyDeviceViewController *modifyDeviceVC = [[ModifyDeviceViewController alloc]init];
    modifyDeviceVC.name = _nameLabel.text;
    modifyDeviceVC.number = _numberLabel.text;
    modifyDeviceVC.delegate = self;
    [self.navigationController pushViewController:modifyDeviceVC animated:YES];
}

- (void)changeDeviceInfoRTSPStatus:(BOOL)changeStatusOrNot andShowRtspLable:(NSString *)RTSPlabel
{
    if (!changeStatusOrNot) {
        //rtsp开关关闭
        [_topView removeFromSuperview];
        [_makeCallBtn removeFromSuperview];
        [_rtspBtn removeFromSuperview];
        [_callHistoryBtn removeFromSuperview];
        [_deleteDeviceBtn removeFromSuperview];
        [_rtspLabel removeFromSuperview];
        [self setupUIisRTSPShow:2 andRTSP:RTSPlabel];
    }else{
        //rtsp开关开启
        [_topView removeFromSuperview];
        [_makeCallBtn removeFromSuperview];
        [_rtspBtn removeFromSuperview];
        [_callHistoryBtn removeFromSuperview];
        [_deleteDeviceBtn removeFromSuperview];
        [_rtspLabel removeFromSuperview];
        [self setupUIisRTSPShow:1 andRTSP:RTSPlabel];
        
    }
}

- (void)modifyDeviceInfo:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSLog(@"This is change infoDic:%@",infoDic);
    _nameLabel.text = [infoDic  valueForKey:@"deviceName"];
    _numberLabel.text = [infoDic  valueForKey:@"deviceNumber"];
}

- (void)backToLastController
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
