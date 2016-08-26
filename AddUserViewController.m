//
//  AddUserViewController.m
//  UIPageViewControllerDemo
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AddUserViewController.h"
#import "VBellsqlBase.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "IQKeyboardManager.h"

#define labelHeight 40
#define marginHeight 10

@interface AddUserViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *use_RTSP_inAudioTalk;
@property (nonatomic, strong) UIButton *use_RTSP_inIncoming;
@property (nonatomic, strong) UIButton *audioEnable;
@property (nonatomic, strong) UIButton *videoEnable;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *proxyView;
@property (nonatomic, strong) UIView *RTSPView;
@property (nonatomic, strong) UITextField *displayName;
@property (nonatomic, strong) UITextField *deviceNumber;
@property (nonatomic, strong) UITextField *passWord;
@property (nonatomic, strong) UITextField *serverURL;
@property (nonatomic, strong) UITextField *serverPort;
@property (nonatomic, strong) UITextField *proxyServerURL;
@property (nonatomic, strong) UITextField *proxyServerPort;
@property (nonatomic, strong) UITextField *DTMFLTxt;
@property (nonatomic, strong) UISwitch *unlockSwitch;
@property (nonatomic, strong) UISwitch *videoPreviewSwitch;
@property (nonatomic, strong) UISwitch *RTSPSwitch;
@property (nonatomic, strong) UITextField *rtspTxt;
@property (nonatomic, assign) BOOL isRTSPShowChanged;
@property (nonatomic, assign) BOOL isCallFeaturesChanged;
@property (nonatomic, assign) BOOL isViewPreviewChanged;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) UIView *setupGeneralSettingsPartView;
@property (nonatomic, strong) UIView *setupCallFeaturesPartView;
@property (nonatomic, strong) UIView *setupRTSPPartView;
@property (nonatomic, strong) UIView *setupFootPartView;
@property (nonatomic, strong) NSString *recordcalluuid;

@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    __weak typeof(self) weakSelf = self;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Add Device", nil);
    
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
    
    
    self.setupGeneralSettingsPartView = [self setupFirstPart];
    self.setupCallFeaturesPartView =[self setupCallFeaturesPart];
    self.setupRTSPPartView = [self setupRTSPPart];
    self.setupFootPartView =[self setupFooterPart];
    
    
    [_container addSubview:_setupGeneralSettingsPartView];
    [_container addSubview:_setupCallFeaturesPartView];
    [_container addSubview:_setupRTSPPartView];
    [_container addSubview:_setupFootPartView];
    [_setupGeneralSettingsPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_container).offset(15);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 4*marginHeight+3*labelHeight + 23));
    }];
    
    [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, 2*marginHeight + 23 + 2*labelHeight));
    }];
    
    [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
        make.left.equalTo(_container).offset(15);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, marginHeight + 23 + labelHeight));
    }];
    
    [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
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
    self.firstView = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 123)];
//    _firstView.backgroundColor = [UIColor redColor];
    NSString *title = NSLocalizedString(@"General Settings", nil);
    //文字与蓝色线条
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = title;
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    //账号
    UILabel *accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight+23, _firstView.bounds.size.width*1/3, labelHeight)];
    accountLabel.text = NSLocalizedString(@"Account", nil);
    accountLabel.font = [UIFont systemFontOfSize:14];
    accountLabel.textColor = [UIColor grayColor];
    [_firstView addSubview:accountLabel];
    
    UILabel *accountNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(_firstView.bounds.size.width *2/3, marginHeight+23, _firstView.bounds.size.width*1/3, labelHeight)];
    accountNumberLabel.text = @"850002";//_userNameTitle;
    accountNumberLabel.font = [UIFont systemFontOfSize:14];
    accountNumberLabel.textAlignment = NSTextAlignmentRight;
    accountNumberLabel.textColor = [UIColor grayColor];
    [_firstView addSubview:accountNumberLabel];
    
    self.displayName = [[UITextField alloc]initWithFrame:CGRectMake(0, 2*marginHeight+labelHeight + 23, _firstView.bounds.size.width, labelHeight)];
    _displayName.placeholder = NSLocalizedString(@"Display Name", nil);
    self.deviceNumber = [[UITextField alloc]initWithFrame:CGRectMake(0, 3*marginHeight+2*labelHeight + 23, _firstView.bounds.size.width, labelHeight)];
    _deviceNumber.placeholder = NSLocalizedString(@"Device Number", nil);
    [self setTextField:_displayName];
    [self setTextField:_deviceNumber];
    [_firstView addSubview:TopLabel];
    [_firstView addSubview:lineView];
    
    return _firstView;
}

- (UIView *)setupCallFeaturesPart
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
//    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23 + labelHeight, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    self.unlockSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight)];
    self.videoPreviewSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(view.bounds.size.width-50, marginHeight + 23 + labelHeight, 50, labelHeight)];
    
    [_unlockSwitch addTarget:self action:@selector(callFeaturesChanged:) forControlEvents:UIControlEventValueChanged];
    [_videoPreviewSwitch addTarget:self action:@selector(callFeaturesChangeWithRTSPShowOrNot:) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_videoPreviewSwitch];
    return view;
}

- (UIView *)setupRTSPPart
{
    self.RTSPView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-30, marginHeight + 23 + labelHeight)];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = @"RTSP";
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *rtspEnableLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, _RTSPView.bounds.size.width*3/4, labelHeight)];
    rtspEnableLabel.text = NSLocalizedString(@"RTSP Enable", nil);
    rtspEnableLabel.font = [UIFont systemFontOfSize:14];
    rtspEnableLabel.textColor = [UIColor grayColor];
    
    self.RTSPSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(_RTSPView.bounds.size.width-50, marginHeight + 23, 50, labelHeight)];
    
    [_RTSPSwitch addTarget:self action:@selector(RTSPChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_RTSPView addSubview:TopLabel];
    [_RTSPView addSubview:lineView];
    [_RTSPView addSubview:rtspEnableLabel];
    [_RTSPView addSubview:_RTSPSwitch];
    return _RTSPView;
}

- (UIView *)setupFooterPart
{
    UIView *view= [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*7/9-self.navigationController.navigationBar.bounds.size.height/3-50, self.view.bounds.size.width - 30, 70)];
    //view.backgroundColor = [UIColor redColor];
    self.saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 40)];
    _saveButton.backgroundColor = UnifiedColor;
    [_saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    _saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_saveButton addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:_moreButton];
    [view addSubview:_saveButton];
    return view;
}


- (UIView *)setupCallFeaturesPartChanged
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    
    UILabel *DTMFLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight  + labelHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    DTMFLabel.text = @"DTMF";
    DTMFLabel.font = [UIFont systemFontOfSize:14];
    DTMFLabel.textColor = [UIColor grayColor];
    
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    _unlockSwitch.frame = CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    self.DTMFLTxt = [[UITextField alloc]initWithFrame:CGRectMake(view.bounds.size.width*3/4, marginHeight  + labelHeight + 23, view.bounds.size.width/4, labelHeight)];
    [self setTextField:_DTMFLTxt];
    _videoPreviewSwitch.frame = CGRectMake(view.bounds.size.width-50, 2*(marginHeight + labelHeight) + 23, 50, labelHeight);
    
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:DTMFLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_DTMFLTxt];
    [view addSubview:_videoPreviewSwitch];
    return view;
}

- (UIView *)setupRTSPChanged_ChangeCallFeatures
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInAudioTalkLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInAudioTalkLabel.text = NSLocalizedString(@"Use RTSP in Audio Talk", nil);
    useRTSPInAudioTalkLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInAudioTalkLabel.textColor = [UIColor grayColor];
    
    _unlockSwitch.frame = CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    _videoPreviewSwitch.frame = CGRectMake(view.bounds.size.width-50, 1*(marginHeight + labelHeight) + 23, 50, labelHeight);
    _use_RTSP_inAudioTalk = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 2*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inAudioTalk setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:useRTSPInAudioTalkLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_videoPreviewSwitch];
    [view addSubview:_use_RTSP_inAudioTalk];
    return view;
}

- (UIView *)setupCallFeaturesPartHasUseRTSPInAudioTalk
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    
    UILabel *DTMFLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight  + labelHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    DTMFLabel.text = NSLocalizedString(@"DTMF", nil);
    DTMFLabel.font = [UIFont systemFontOfSize:14];
    DTMFLabel.textColor = [UIColor grayColor];
    
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInAudioTalkLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInAudioTalkLabel.text = NSLocalizedString(@"Use RTSP in Audio Talk", nil);
    useRTSPInAudioTalkLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInAudioTalkLabel.textColor = [UIColor grayColor];
    
    _unlockSwitch.frame = CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    self.DTMFLTxt = [[UITextField alloc]initWithFrame:CGRectMake(view.bounds.size.width*3/4, marginHeight  + labelHeight + 23, view.bounds.size.width/4, labelHeight)];
    [self setTextField:_DTMFLTxt];
    _videoPreviewSwitch.frame = CGRectMake(view.bounds.size.width-50, 2*(marginHeight + labelHeight) + 23, 50, labelHeight);
    _use_RTSP_inAudioTalk = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 3*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inAudioTalk setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:DTMFLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:useRTSPInAudioTalkLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_DTMFLTxt];
    [view addSubview:_videoPreviewSwitch];
    [view addSubview:_use_RTSP_inAudioTalk];
    return view;
}

- (UIView *)setupCallFeaturesPartRTSPShowAndUnlockClosed
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInIncomingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInIncomingLabel.text = NSLocalizedString(@"Use RTSP in InComing", nil);
    useRTSPInIncomingLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInIncomingLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInAudioTalkLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInAudioTalkLabel.text = NSLocalizedString(@"Use RTSP in Audio Talk", nil);
    useRTSPInAudioTalkLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInAudioTalkLabel.textColor = [UIColor grayColor];
    
    _unlockSwitch.frame = CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    _videoPreviewSwitch.frame = CGRectMake(view.bounds.size.width-50, 1*(marginHeight + labelHeight) + 23, 50, labelHeight);
    _use_RTSP_inIncoming = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 2*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inIncoming setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    _use_RTSP_inAudioTalk = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 3*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inAudioTalk setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:useRTSPInIncomingLabel];
    [view addSubview:useRTSPInAudioTalkLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_videoPreviewSwitch];
    [view addSubview:_use_RTSP_inAudioTalk];
    [view addSubview:_use_RTSP_inIncoming];
    return view;
}

- (UIView *)setupCallFeaturesPartRTSPShowAndUnlockOn
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height*5/9+self.navigationController.navigationBar.bounds.size.height/3+marginHeight-50, self.view.bounds.size.width - 30, self.view.bounds.size.height*1/9)];
    //    view.backgroundColor = [UIColor grayColor];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"Call Features", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *unlockLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    unlockLabel.text = NSLocalizedString(@"Unlock", nil);
    unlockLabel.font = [UIFont systemFontOfSize:14];
    unlockLabel.textColor = [UIColor grayColor];
    
    UILabel *DTMFLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight  + labelHeight + 23, view.bounds.size.width*3/4, labelHeight)];
    DTMFLabel.text = NSLocalizedString(@"DTMF", nil);
    DTMFLabel.font = [UIFont systemFontOfSize:14];
    DTMFLabel.textColor = [UIColor grayColor];
    
    UILabel *videoPreviewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    videoPreviewLabel.text = NSLocalizedString(@"Video Preview", nil);
    videoPreviewLabel.font = [UIFont systemFontOfSize:14];
    videoPreviewLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInIncomingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInIncomingLabel.text = NSLocalizedString(@"Use RTSP in InComing", nil);
    useRTSPInIncomingLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInIncomingLabel.textColor = [UIColor grayColor];
    
    UILabel *useRTSPInAudioTalkLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 4*(marginHeight + labelHeight) + 23, view.bounds.size.width*3/4, labelHeight)];
    useRTSPInAudioTalkLabel.text = NSLocalizedString(@"Use RTSP in Audio Talk", nil);
    useRTSPInAudioTalkLabel.font = [UIFont systemFontOfSize:14];
    useRTSPInAudioTalkLabel.textColor = [UIColor grayColor];
    
    _unlockSwitch.frame = CGRectMake(view.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    self.DTMFLTxt = [[UITextField alloc]initWithFrame:CGRectMake(view.bounds.size.width*3/4, marginHeight  + labelHeight + 23, view.bounds.size.width/4, labelHeight)];
    [self setTextField:_DTMFLTxt];
    _videoPreviewSwitch.frame = CGRectMake(view.bounds.size.width-50, 2*(marginHeight + labelHeight) + 23, 50, labelHeight);
    _use_RTSP_inIncoming = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 3*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inIncoming setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    _use_RTSP_inAudioTalk = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width-30, 4*(marginHeight + labelHeight) + 23, 30, 30)];
    [_use_RTSP_inAudioTalk setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    
    [view addSubview:TopLabel];
    [view addSubview:lineView];
    [view addSubview:unlockLabel];
    [view addSubview:DTMFLabel];
    [view addSubview:videoPreviewLabel];
    [view addSubview:useRTSPInIncomingLabel];
    [view addSubview:useRTSPInAudioTalkLabel];
    [view addSubview:_unlockSwitch];
    [view addSubview:_DTMFLTxt];
    [view addSubview:_videoPreviewSwitch];
    [view addSubview:_use_RTSP_inAudioTalk];
    [view addSubview:_use_RTSP_inIncoming];
    return view;
}

- (UIView *)setupRTSPPartChanged
{
    self.RTSPView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-30, 4*(marginHeight + labelHeight) + 23 )];
    
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = @"RTSP";
    [TopLabel setTextColor:UnifiedColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    lineView.backgroundColor = UnifiedColor;
    
    UILabel *rtspEnableLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight + 23, _RTSPView.bounds.size.width*3/4, labelHeight)];
    rtspEnableLabel.text = NSLocalizedString(@"RTSP Enable", nil);
    rtspEnableLabel.font = [UIFont systemFontOfSize:14];
    rtspEnableLabel.textColor = [UIColor grayColor];
    
    UILabel *audioEnableLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1*(marginHeight + labelHeight) + 23, _RTSPView.bounds.size.width*3/4, labelHeight)];
    audioEnableLabel.text = NSLocalizedString(@"Audio Enable", nil);
    audioEnableLabel.font = [UIFont systemFontOfSize:14];
    audioEnableLabel.textColor = [UIColor grayColor];
    
    UILabel *videoEnableLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*(marginHeight + labelHeight) + 23, _RTSPView.bounds.size.width*3/4, labelHeight)];
    videoEnableLabel.text = NSLocalizedString(@"Video Enable", nil);
    videoEnableLabel.font = [UIFont systemFontOfSize:14];
    videoEnableLabel.textColor = [UIColor grayColor];

    _RTSPSwitch.frame = CGRectMake(_RTSPView.bounds.size.width-50, marginHeight + 23, 50, labelHeight);
    _audioEnable = [[UIButton alloc]initWithFrame:CGRectMake(_RTSPView.bounds.size.width-30, 1*(marginHeight + labelHeight) + 23, 30, 30)];
    [_audioEnable setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    _videoEnable = [[UIButton alloc]initWithFrame:CGRectMake(_RTSPView.bounds.size.width-30, 2*(marginHeight + labelHeight) + 23, 30, 30)];
    [_videoEnable setBackgroundImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
    _rtspTxt = [[UITextField alloc]initWithFrame:CGRectMake(0, 3*(marginHeight + labelHeight) + 23, _RTSPView.bounds.size.width, labelHeight)];
//    _rtspTxt.text = [NSString stringWithFormat:@"rtsp://%@",_deviceNumber.text];
    _rtspTxt.text = @"rtsp://";
    [self setTextField:_rtspTxt];

    [_RTSPView addSubview:TopLabel];
    [_RTSPView addSubview:lineView];
    [_RTSPView addSubview:rtspEnableLabel];
    [_RTSPView addSubview:audioEnableLabel];
    [_RTSPView addSubview:videoEnableLabel];
    [_RTSPView addSubview:_RTSPSwitch];
    [_RTSPView addSubview:_audioEnable];
    [_RTSPView addSubview:_videoEnable];
    [_RTSPView addSubview:_rtspTxt];
    return _RTSPView;
}

- (void)callFeaturesChanged:(UISwitch *)unlockSwitch
{
    if ([unlockSwitch isOn]) {
        if (_isRTSPShowChanged) {
            [_setupFootPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            [_setupRTSPPartView removeFromSuperview];
            
            _setupCallFeaturesPartView = [self setupCallFeaturesPartHasUseRTSPInAudioTalk];
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupRTSPPartView];
            [_container addSubview:_setupFootPartView];
            
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, 4*(marginHeight + labelHeight) + 23));
            }];
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 4*(marginHeight + labelHeight)+ 23));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            _isCallFeaturesChanged = YES;
        }else{
            [_setupFootPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            [_setupRTSPPartView removeFromSuperview];
            _setupCallFeaturesPartView = [self setupCallFeaturesPartChanged];
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupRTSPPartView];
            [_container addSubview:_setupFootPartView];
            
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, 3*(marginHeight + labelHeight) + 23));
            }];
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, marginHeight + 23 + labelHeight));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            _isCallFeaturesChanged = YES;
        }
    }else{
        if (!_isRTSPShowChanged) {
            [_setupFootPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            self.setupCallFeaturesPartView = [self setupCallFeaturesPart];
            self.setupFootPartView = [self setupFooterPart];
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupFootPartView];
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 2*(marginHeight + labelHeight) + 23));
            }];
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, marginHeight + 23 + labelHeight));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            _isCallFeaturesChanged = NO;
        }else{
            [_setupFootPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            self.setupCallFeaturesPartView = [self setupCallFeaturesPartRTSPShowAndUnlockClosed];
            self.setupFootPartView = [self setupFooterPart];
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupFootPartView];
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 4*(marginHeight + labelHeight) + 23));
            }];
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, (marginHeight + labelHeight)*4+ 23 ));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            _isCallFeaturesChanged = NO;
        }

    }
}

- (void)RTSPChanged:(UISwitch *)RTSPSwitch
{
    if ([RTSPSwitch isOn]) {
        if (!_isCallFeaturesChanged){
            if ([_videoPreviewSwitch isOn]) {
                [_setupFootPartView removeFromSuperview];
                [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartRTSPShowAndUnlockClosed];
                self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }else{
                [_setupFootPartView removeFromSuperview];
                [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupRTSPChanged_ChangeCallFeatures];
                self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*3+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }
        }else{
            if ([_videoPreviewSwitch isOn]) {
                [_setupFootPartView removeFromSuperview];
                [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartRTSPShowAndUnlockOn];
                self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*5+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
                _isCallFeaturesChanged = YES;
            }else{
                [_setupFootPartView removeFromSuperview];
                [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartHasUseRTSPInAudioTalk];
                self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
                _isCallFeaturesChanged = YES;
            }
            
        }
        
    }else{
        if (_isCallFeaturesChanged) {
            [_setupFootPartView removeFromSuperview];
            [_setupRTSPPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            
            self.setupCallFeaturesPartView = [self setupCallFeaturesPartChanged];
            self.setupRTSPPartView = [self setupRTSPPart];
            
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupRTSPPartView];
            [_container addSubview:_setupFootPartView];
            
            
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*3+ 23));
            }];
            
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*1+ 23));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            self.isRTSPShowChanged  = NO;
        }else{
            [_setupFootPartView removeFromSuperview];
            [_setupRTSPPartView removeFromSuperview];
            [_setupCallFeaturesPartView removeFromSuperview];
            
            self.setupCallFeaturesPartView = [self setupCallFeaturesPart];
            self.setupRTSPPartView = [self setupRTSPPart];
            [_container addSubview:_setupCallFeaturesPartView];
            [_container addSubview:_setupRTSPPartView];
            [_container addSubview:_setupFootPartView];
            
            [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*2+ 23));
            }];
            [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*1+ 23));
            }];
            [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                make.left.equalTo(_container).offset(15);
                make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
            }];
            [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                //container的下边界和最后一个View的下边界紧贴
                make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
            }];
            self.isRTSPShowChanged  = NO;
        }
    }
    
}

- (void)callFeaturesChangeWithRTSPShowOrNot:(UISwitch *)videoSwitch
{
    if (![_RTSPSwitch isOn]) {
        return;
    }else{
        if ([_unlockSwitch isOn]) {
            if ([_videoPreviewSwitch isOn]) {
                [_setupFootPartView removeFromSuperview];
                //            [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartRTSPShowAndUnlockOn];
                //self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*5+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }else{
                [_setupFootPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartHasUseRTSPInAudioTalk];
                //self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }
        }else{
            if ([_videoPreviewSwitch isOn]) {
                [_setupFootPartView removeFromSuperview];
                //            [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupCallFeaturesPartRTSPShowAndUnlockClosed];
                //            self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }else{
                [_setupFootPartView removeFromSuperview];
                //            [_setupRTSPPartView removeFromSuperview];
                [_setupCallFeaturesPartView removeFromSuperview];
                
                self.setupCallFeaturesPartView = [self setupRTSPChanged_ChangeCallFeatures];
                //            self.setupRTSPPartView = [self setupRTSPPartChanged];
                [_container addSubview:_setupCallFeaturesPartView];
                [_container addSubview:_setupRTSPPartView];
                [_container addSubview:_setupFootPartView];
                
                [_setupCallFeaturesPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupGeneralSettingsPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*3+ 23));
                }];
                [_setupRTSPPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupCallFeaturesPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30,(marginHeight + labelHeight)*4+ 23));
                }];
                [_setupFootPartView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_setupRTSPPartView.mas_bottom).offset(10);
                    make.left.equalTo(_container).offset(15);
                    make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-30, 70));
                }];
                [_container mas_makeConstraints:^(MASConstraintMaker *make) {
                    //container的下边界和最后一个View的下边界紧贴
                    make.bottom.equalTo(_setupFootPartView.mas_bottom).offset(10);
                }];
                self.isRTSPShowChanged = YES;
            }
        }
    }
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
    textField.layer.cornerRadius=3.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor grayColor]CGColor];
    textField.layer.borderWidth= 1.0f;
    //    textField.keyboardType = UIKeyboardTypeNumberPad;
    [_proxyView addSubview:textField];
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
    textField.layer.borderColor=[[UIColor grayColor] CGColor];
    textField.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
}


- (void)addUser
{
    int unlockStatus = [_unlockSwitch isOn];
    int void_previewStatus = [_videoPreviewSwitch isOn];
    NSString *dtmf = _DTMFLTxt.text;
    
    
    if (_displayName.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Device name needed", @"HUD message title");
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        return;
    }else if (_deviceNumber.text.length == 0){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Device number needed", @"HUD message title");
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        return;
    }else{
        NSString *address = nil;
        VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
        if (_rtspTxt.text.length == 0) {
            address = @"rtsp://%@";//[NSString stringWithFormat:@"rtsp://%@",_deviceNumber.text];
        }else{
            address = [NSString stringWithFormat:@"%@",_rtspTxt.text];
        }
        if([base insertUserInfoTabNumber:_deviceNumber.text name:_displayName.text rtspAddress:address unlock:unlockStatus dtmf:dtmf video_preview:void_previewStatus]){
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"Add Device Success!", @"HUD message title");
            hud.offset = CGPointMake(0.f, 0.f);
            [hud hideAnimated:YES afterDelay:1.f];
            _callback(self.displayName.text,self.deviceNumber.text,address);
            [[self navigationController] popViewControllerAnimated:YES];
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"Device number exist!", @"HUD message title");
            hud.offset = CGPointMake(0.f, 0.f);
            [hud hideAnimated:YES afterDelay:1.f];
            return;
        }
    }
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
