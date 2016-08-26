//
//  LoginViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/8/2.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "LoginViewController.h"
#import "LeftMenuController.h"
#import "YQSlideMenuController.h"
#import "LoginTextField.h"
#import "Masonry.h"
#import "mainViewController.h"
#import "userModel.h"
#import "IQKeyboardManager.h"
#import "IncomingViewController.h"
#import "VBellsqlBase.h"
#import "AudioCodecModel.h"
#import "VideoCodecModel.h"
#import "MBProgressHUD.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"


#define rl_log_debug printf
#define rl_log_info printf
#define rl_log_err printf


static int g_accountid = 0;
static int g_callid = 0;

void *vieLocalVideoView = NULL;
void *vieRemoteVideoView = NULL;



static int sipcall_msg_handle(SIPCALL_RECV_MSG msg, unsigned int param1, unsigned int param2, void *dat, int size)
{
    
    rl_log_debug("Enter %s, msg = 0x%X\n", __FUNCTION__, msg);
    switch(msg)
    {
        case SIPCALL_RECV_MSG_RINGBACK:
        {
            rl_log_info("call ringback: cid=%d, aid=%d\n", param1, param2);
        }
            break;
        case SIPCALL_RECV_MSG_INCOMING:
        {
            SIPCALL_INCOMING_DATA *incoming = (SIPCALL_INCOMING_DATA *)dat;
            if(incoming == NULL)
            {
                return -1;
            }
            
            rl_log_info("call incoming: cid=%d, video_mode=%d, remote_username=%s, remote_displayname=%s\n", incoming->cid, incoming->video_mode, incoming->remote_username, incoming->remote_displayname);
            
            g_callid = incoming->cid;
            g_accountid = incoming->aid;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * incomingid = [NSString stringWithFormat:@"%s", incoming->remote_username];
                NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithObject:incomingid forKey:@"comingid"];
                NSLog(@"%D",[NSThread isMainThread]);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"INCOMINGCALLING" object:mutableDictionary];
            });
            
            
        }
            break;
        case SIPCALL_RECV_MSG_FINISH_CALL:
        {
            int cid = param1;
            
            rl_log_info("call finish: cid=%d\n", cid);
            
            if(g_callid == cid)
            {
                mediaengine_StopVoiceTalking(cid);
                
                mediaengine_StopVideoTalking(cid);
                g_callid = 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"FINISHCALL" object:nil];
            });
            
        }
            break;
            
        case SIPCALL_RECV_MSG_ESTABLISH_CALL:
        {   
            int cid = param1;
            int aid = param2;
            SIPCALL_ESTABLISH_DATA *establish = (SIPCALL_ESTABLISH_DATA *)dat;
            if(establish == NULL)
            {
                return -1;
            }
            rl_log_info("call establish: cid=%d, \n \
                        remote_audio=%s:%d, \n \
                        remote_video=%s:%d, \n \
                        local_audio_port=%d, \n \
                        local_video_port=%d \n \
                        enc_payload=%d\n \
                        dec_payload=%d\n \
                        enc_name=%s\n \
                        dec_name=%s\n \
                        video_enc_name=%s\n \
                        video_dec_name=%s\n \
                        video_enc_payload=%d\n \
                        video_dec_payload=%d\n \
                        dtmf_payload=%d\n \
                        video_resolution=%d\n \
                        video_mode=%d\n \
                        send_recv=%d \n",
                        cid,
                        establish->voice.remote_ipaddr, establish->voice.remote_audio_port,
                        establish->voice.remote_ipaddr, establish->voice.remote_video_port,
                        establish->voice.local_audio_port,
                        establish->voice.local_video_port,
                        establish->voice.enc_payload,
                        establish->voice.dec_payload,
                        establish->voice.enc_name,
                        establish->voice.dec_name,
                        establish->voice.video_enc_name,
                        establish->voice.video_dec_name,
                        establish->voice.video_enc_payload,
                        establish->voice.video_dec_payload,
                        establish->voice.dtmf_payload,
                        establish->voice.video_resolution,
                        establish->voice.video_mode,
                        establish->voice.send_recv);
            
            g_callid = cid;
            g_accountid = aid;
            if (establish->voice.video_mode == 1) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"VIDEOCALL" object:nil];
                
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"AUDIOCALL" object:nil];
            }
            mediaengine_StartVoiceTalking(cid, &establish->voice);
            mediaengine_StartVideoTalking(cid, &establish->voice, vieLocalVideoView, vieRemoteVideoView);
            
        }
            break;
        case SIPCALL_RECV_MSG_REG_STATE:
        {
            int aid = param1;
            int status = param2;
            rl_log_info("register state changed: aid=%d, status=%d\n", aid, status);
            NSString * registerState = [NSString stringWithFormat:@"%d", status];
            NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithObject:registerState forKey:@"registerState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGEREGISTERSTATE" object:mutableDictionary];
        }
            break;
    }
    return 0;
}


@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) LoginTextField *registerNameTxt;
@property (nonatomic, strong) LoginTextField *userNameTxt;
@property (nonatomic, strong) LoginTextField *pwdTxt;
@property (nonatomic, strong) LoginTextField *serverURLTxt;
@property (nonatomic, strong) LoginTextField *serverPortTxt;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *fastLoginBtn;
@property (nonatomic, strong) UIView *localVideoView;
@property (nonatomic, strong) UIView  *remoteVideoView;
@property (nonatomic, strong) UIButton *muteBtn;
@property (nonatomic, strong) UIButton *unLockBtn;
@property (nonatomic, strong) UIButton *hangupBtn;
@property (nonatomic, strong) NSString *incomingNumber;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic)BOOL muteIsHide;
@property (nonatomic)BOOL unLockIsHide;
@property (nonatomic)BOOL hangupIsHide;
@property (nonatomic, strong) NSString *DTMF;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showIncomingVC:) name:@"INCOMINGCALLING" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showVideoView) name:@"VIDEOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishCalling) name:@"FINISHCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAudioCodecSettings) name:@"CHANGEAUDIOCODEC" object:nil];//音频解码器设置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateVideoCodecSettings) name:@"CHANGEVIDEOCODEC" object:nil];//视频解码器设置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setMakeCallNumber:) name:@"makeCallNumber" object:nil];
}

- (void)setupUI
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    __weak typeof(self) weakSelf = self;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DeviceScreenWidth, DeviceScreenHeight)];
    _scrollView.showsVerticalScrollIndicator = FALSE;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    _iconBtn = [[UIButton alloc]initWithFrame:CGRectMake(DeviceScreenWidth/2-50, DeviceScreenHeight/8, 100, 100)];
    [_iconBtn setImage:[UIImage imageNamed:@"VBell.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_iconBtn];
    
    
    
    _registerNameTxt = [[LoginTextField alloc]init];
    _registerNameTxt.text = [user objectForKey:@"userName"];
    [self setTextField:_registerNameTxt andIconImageName:@"User Name.png" andPlaceHolderName:@"Register Name"];
    [_scrollView addSubview:_registerNameTxt];
    
    _userNameTxt = [[LoginTextField alloc]init];
    _userNameTxt.text = [user objectForKey:@"registerName"];
    [self setTextField:_userNameTxt andIconImageName:@"User Name.png" andPlaceHolderName:@"User Name"];
    [_scrollView addSubview:_userNameTxt];
    
    _pwdTxt = [[LoginTextField alloc]init];
    _pwdTxt.text = [user objectForKey:@"passWord"];
    _pwdTxt.secureTextEntry = YES;
    [self setTextField:_pwdTxt andIconImageName:@"Password.png" andPlaceHolderName:@"Password"];
    [_scrollView addSubview:_pwdTxt];
    
    _serverURLTxt = [[LoginTextField alloc]init];
    _serverURLTxt.text = [user objectForKey:@"serverURL"];
    [self setTextField:_serverURLTxt andIconImageName:@"Server URL.png" andPlaceHolderName:@"Server URL"];
    [_scrollView addSubview:_serverURLTxt];
    
    _serverPortTxt = [[LoginTextField alloc]init];
    _serverPortTxt.text = [user objectForKey:@"serverPort"];
    [self setTextField:_serverPortTxt andIconImageName:@"Server Port.png" andPlaceHolderName:@"Server Port"];
    [_scrollView addSubview:_serverPortTxt];
    
    _cancelBtn = [[UIButton alloc]init];
    [_cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:[UIColor orangeColor]];
    _cancelBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    _cancelBtn.layer.cornerRadius=8.0f;
    _cancelBtn.layer.masksToBounds=YES;
    [_cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_cancelBtn];
    
    _loginBtn = [[UIButton alloc]init];
    [_loginBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:[UIColor orangeColor]];
    _loginBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    _loginBtn.layer.cornerRadius=8.0f;
    _loginBtn.layer.masksToBounds=YES;
    [_loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_loginBtn];
    
    _fastLoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(DeviceScreenWidth - 35, DeviceScreenHeight - 35, 25, 25)];
    [_fastLoginBtn setImage:[UIImage imageNamed:@"bg_skip.png"] forState:UIControlStateNormal];
    [_fastLoginBtn addTarget:self action:@selector(fastClick) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_fastLoginBtn];
    
    UILabel *versionLabel = [[UILabel alloc]init];
    versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];//@"1.0.1.18";
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.textColor = [UIColor grayColor];
    [_scrollView addSubview:versionLabel];
    
    [_registerNameTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBtn.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [_userNameTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_registerNameTxt.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [_pwdTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameTxt.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [_serverURLTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pwdTxt.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [_serverPortTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_serverURLTxt.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_serverPortTxt.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.view).offset(DeviceScreenWidth/8);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/4, 35));
    }];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_serverPortTxt.mas_bottom).offset(20);
        make.left.equalTo(_cancelBtn.mas_right).offset(DeviceScreenWidth/4);
        make.right.equalTo(weakSelf.view).offset(-DeviceScreenWidth/8);
        make.height.offset(35);
    }];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
//        make.left.equalTo()
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
}
#pragma mark- 私有方法
- (void)cancelClick
{
    NSLog(@"cancelClick");
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

- (void)loginClick
{
    
    
    LeftMenuController  *leftMenuViewController = [[LeftMenuController alloc] init];
    mainViewController *mainVC = [[mainViewController alloc]init];
    mainVC.callback = ^(NSString *makeCallNumber){
        _makeCallNumber = makeCallNumber;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    YQSlideMenuController *sideMenuController = [[YQSlideMenuController alloc] initWithContentViewController:nav
                                                                                    leftMenuViewController:leftMenuViewController];
    sideMenuController.scaleContent = NO;
    

    NSString *userName = _userNameTxt.text;
    NSString *registerName = _registerNameTxt.text;
    NSString *passWord = _pwdTxt.text;
    NSString *serverURL = _serverURLTxt.text;
    NSString *serverPort = _serverPortTxt.text;
    
//    if (registerName.length == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = NSLocalizedString(@"RegisterName needed", @"HUD message title");
//        // Move to bottm center.
//        hud.offset = CGPointMake(0.f, 0.f);
//        [hud hideAnimated:YES afterDelay:1.f];
//        return;
//    }
//    if (userName.length == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = NSLocalizedString(@"UserName needed", @"HUD message title");
//        // Move to bottm center.
//        hud.offset = CGPointMake(0.f, 0.f);
//        [hud hideAnimated:YES afterDelay:1.f];
//        return;
//    }
//    
//    if (passWord.length == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = NSLocalizedString(@"PassWord needed", @"HUD message title");
//        // Move to bottm center.
//        hud.offset = CGPointMake(0.f, 0.f);
//        [hud hideAnimated:YES afterDelay:1.f];
//        return;
//    }
//    if (serverURL.length == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = NSLocalizedString(@"ServerURL needed", @"HUD message title");
//        // Move to bottm center.
//        hud.offset = CGPointMake(0.f, 0.f);
//        [hud hideAnimated:YES afterDelay:1.f];
//        return;
//    }
//    if (serverPort.length == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = NSLocalizedString(@"ServerPort needed", @"HUD message title");
//        // Move to bottm center.
//        hud.offset = CGPointMake(0.f, 0.f);
//        [hud hideAnimated:YES afterDelay:1.f];
//        return;
//    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:userName forKey:@"userName"];
    [user setObject:registerName forKey:@"registerName"];
    [user setObject:passWord forKey:@"passWord"];
    [user setObject:serverURL forKey:@"serverURL"];
    [user setObject:serverPort forKey:@"serverPort"];

    [self setupLoginInfo];
    [self presentViewController:sideMenuController animated:YES completion:nil];
}

- (void)updateAudioCodecSettings
{
    NSLog(@"updateAudioCodecSettings");
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *audioCodecArray = [base getAudioCodecInfo];
    AudioCodecModel *audioCodecModelFirst = nil;
    AudioCodecModel *audioCodecModelSecond = nil;
    AudioCodecModel *audioCodecModelThird = nil;
    AudioCodecModel *audioCodecModelForth = nil;
    if (audioCodecArray.count != 0) {
        audioCodecModelFirst = audioCodecArray[0];
        audioCodecModelSecond = audioCodecArray[1];
        audioCodecModelThird = audioCodecArray[2];
        audioCodecModelForth = audioCodecArray[3];
    }else{
        NSLog(@"updateAudioCodecSettings audioCodecArray is nil");
        return;
    }
    SIPCALL_ACCOUNT_SETTING account;
    memset(&account, 0, sizeof(account));
    account.enable = 1;
    
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
    
    sipcall_update_account_setting(0, &account);
}

- (void)updateVideoCodecSettings
{
    NSLog(@"updateVideoCodecSettings");
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *videoCodecArray = [base getVideoCodecInfo];
    VideoCodecModel *videoCodecModel = nil;
    if (videoCodecArray.count != 0) {
        videoCodecModel = videoCodecArray[0];
    }else{
        NSLog(@"updateVideoCodecSettings videoCodecArray is nil");
        return;
    }
    SIPCALL_ACCOUNT_SETTING account;
    memset(&account, 0, sizeof(account));
    account.enable = 1;
    
    account.video[0].enable = videoCodecModel.enable;
    account.video[0].payload = videoCodecModel.payload;
    account.video[0].priority = 7;
    account.video[0].profile_level = 1;
    account.video[0].max_br = 1280;
    strcpy(account.video[0].name, "H264");
    
    sipcall_update_account_setting(0, &account);
}

- (void)setupLoginInfo
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
    sipcall_reg_msg_handle(&sipcall_msg_handle);
    SIPCALL_ACCOUNT_SETTING account;
    sipcall_init();
    memset(&account, 0, sizeof(account));
    account.enable = 1;
    strcpy(account.user_name, [_userNameTxt.text UTF8String]);
    strcpy(account.reg_name, [_registerNameTxt.text UTF8String]);
    strcpy(account.sip.url, [_serverURLTxt.text UTF8String]);
    account.sip.port = [_serverPortTxt.text intValue];
    strcpy(account.password, [_pwdTxt.text UTF8String]);
    
    
    
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
    
//    account.video[0].enable = videoCodecModel.enable;
//    account.video[0].payload = videoCodecModel.payload;
//    account.video[0].priority = 7;
//    account.video[0].profile_level = 1;
//    account.video[0].max_br = 1280;
//    strcpy(account.video[0].name, [videoCodecModel.name UTF8String]);
    
    sipcall_update_account_setting(0, &account);
}


- (void)fastClick
{
    NSLog(@"fastClick");
}

- (void)setTextField:(UITextField *)textField andIconImageName:(NSString *)iconImageName andPlaceHolderName:(NSString *)placeHolderName
{
    UIImageView *registerView = [[UIImageView alloc]init];
    [registerView setImage:[UIImage imageNamed:iconImageName]];
    textField.placeholder = NSLocalizedString(placeHolderName, nil);
    textField.leftView = registerView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    textField.delegate = self;
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[UIColor colorWithRed:82.0/255.0 green:183.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
    textField.layer.borderWidth= 1.0f;
    //    textField.keyboardType = UIKeyboardTypeNumberPad;
    [_scrollView addSubview:textField];
}

#pragma mark -UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor=[UIColor orangeColor].CGColor;
}

// 失去第一响应者时调用
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor=[UIColor colorWithRed:82.0/255.0 green:183.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
}


- (void)setMakeCallNumber:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    _makeCallNumber = [infoDic valueForKey:@"makeCallNumber"];
}

- (void)showIncomingVC:(NSNotification *)notification
{
    IncomingViewController *incomingVC = [[IncomingViewController alloc]init];
    incomingVC.g_callid = g_callid;
    incomingVC.g_accountid = g_accountid;
    NSDictionary * infoDic = [notification object];
    _incomingNumber = [infoDic valueForKey:@"comingid"];
    incomingVC.number = _incomingNumber;
    
    NSLog(@"incoming call");
    [[self getCurrentVC] presentViewController:incomingVC animated:YES completion:nil];
    NSLog(@"incoming call");
}

- (void)showVideoView
{
    
    self.localVideoView = [[VideoRenderIosView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 100, 0, 100, 200)];
    _localVideoView.backgroundColor = [UIColor grayColor];
    
    self.remoteVideoView = [[VideoRenderIosView alloc]initWithFrame:self.view.bounds];
    _remoteVideoView.backgroundColor = [UIColor grayColor];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setupVoidUI];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        recognizer.numberOfTouchesRequired = 1;
        [_remoteVideoView addGestureRecognizer:recognizer];
        
        
        [_remoteVideoView addSubview:_localVideoView];
        [[[UIApplication sharedApplication]keyWindow] addSubview:_remoteVideoView];
    });
    
    
    vieLocalVideoView = (__bridge void *)_localVideoView;
    vieRemoteVideoView = (__bridge void *)_remoteVideoView;

}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    if (_muteIsHide) {
        [_muteBtn setHidden:NO]; [_unLockBtn setHidden:NO]; [_hangupBtn setHidden:NO];
        _muteIsHide = NO;_unLockIsHide = NO;_hangupIsHide = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_muteBtn setHidden:YES]; [_unLockBtn setHidden:YES]; [_hangupBtn setHidden:YES];
            _muteIsHide = YES;_unLockIsHide = YES;_hangupIsHide = YES;
        });
    }else{
        [_muteBtn setHidden:YES]; [_unLockBtn setHidden:YES]; [_hangupBtn setHidden:YES];
        _muteIsHide = YES;_unLockIsHide = YES;_hangupIsHide = YES;
    }
}

- (void)setupVoidUI
{
    //视频界面出来的时候就去查询本地数据
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    if (_incomingNumber.length == 0) {
        _array = [base getUserInfoNameWithNumber:_makeCallNumber];
    }else{
        _array = [base getUserInfoNameWithNumber:_incomingNumber];
    }
    
    userModel *model = nil;
    if (_array.count != 0) {
        model = _array[0];
        _DTMF = model.DTMF;
    }else{
        return;
    }
    
//    [base insertCallingHistoryTabNumber:_number name:model.userName Calltime:_time callType:1 callDictionary:0];
    
    
    _muteBtn = [[UIButton alloc]initWithFrame:CGRectMake(DeviceScreenWidth/6-37, self.view.bounds.size.height - 85, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    _muteBtn.layer.cornerRadius = _muteBtn.bounds.size.height/2;
    _muteBtn.layer.masksToBounds = YES;
    [_muteBtn setImage:[UIImage imageNamed:@"Mute.png"] forState:UIControlStateNormal];
    [_muteBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
    
    _unLockBtn = [[UIButton alloc]initWithFrame:CGRectMake(DeviceScreenWidth/2-37, self.view.bounds.size.height - 85, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    _unLockBtn.layer.cornerRadius = _unLockBtn.bounds.size.height/2;
    _unLockBtn.layer.masksToBounds = YES;
    [_unLockBtn setImage:[UIImage imageNamed:@"UnLock.png"] forState:UIControlStateNormal];
    [_unLockBtn addTarget:self action:@selector(sendUnLockBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    _hangupBtn = [[UIButton alloc]initWithFrame:CGRectMake(DeviceScreenWidth*5/6-37, self.view.bounds.size.height - 85, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    _hangupBtn.layer.cornerRadius = _hangupBtn.bounds.size.height/2;
    _hangupBtn.layer.masksToBounds = YES;
    [_hangupBtn setImage:[UIImage imageNamed:@"Hangup.png"] forState:UIControlStateNormal];
    [_hangupBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_muteBtn setHidden:YES];
        [_unLockBtn setHidden:YES];
        [_hangupBtn setHidden:YES];
        _muteIsHide = YES;
        _unLockIsHide = YES;
        _hangupIsHide = YES;
    });
    
//    [_remoteVideoView addSubview:_hideView];
    [_remoteVideoView addSubview:_muteBtn];
    [_remoteVideoView addSubview:_unLockBtn];
    [_remoteVideoView addSubview:_hangupBtn];
    
    
}

- (void)sendUnLockBtn
{
    mediaengine_SendDtmf(g_callid, [_DTMF intValue]);
    NSLog(@"I want send DTMF:%@",_DTMF);
    
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    if ([result isKindOfClass:[UINavigationController class]]) {
        UIViewController * viewController =[[(UINavigationController *)result viewControllers]lastObject];
        result=viewController;
    }
    if(result.presentedViewController&&[result.presentedViewController isKindOfClass:[UIViewController class]]){
        result=result.presentedViewController;
        
    }
    return result;
}

- (void)closeCalling
{
    NSLog(@"this is code time");
    int cid = g_callid;
    int aid = g_accountid;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sipcall_send_msg(SIPCALL_SEND_MSG_HANGUP, cid, aid, NULL, 0);
        if(cid > 0)
        {
            mediaengine_StopVoiceTalking(cid);
            mediaengine_StopVideoTalking(cid);
            g_callid = 0;
            vieLocalVideoView = nil;
            vieRemoteVideoView = nil;
            [_localVideoView removeFromSuperview];
            [_remoteVideoView removeFromSuperview];
        }
        [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
    });
    NSLog(@"this is code time");
}

- (void)finishCalling
{
    dispatch_async(dispatch_get_main_queue(), ^{
        vieLocalVideoView = nil;
        vieRemoteVideoView = nil;
        [_localVideoView removeFromSuperview];
        [_remoteVideoView removeFromSuperview];
    });
    
}

@end
