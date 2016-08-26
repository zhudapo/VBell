//
//  AudioSettingsViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AudioSettingsViewController.h"
#import "AudioSettingsModel.h"
#import "VBellsqlBase.h"
#import "MBProgressHUD.h"
#import "IQKeyboardManager.h"

#define  labelHeight  40
#define  marginHeight  10

@interface AudioSettingsViewController ()<UITextFieldDelegate>

@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIView *secondView;
@property (nonatomic , strong) UITextField *field;
@property (nonatomic , strong) UIButton *echoCancellerBtn;
@property (nonatomic , strong) UIButton *cngBtn;
@property (nonatomic , strong) UIButton *vadBtn;
@property (nonatomic , strong) UIButton *sendingBtn;
@property (nonatomic , strong) UIButton *recevingBtn;
@property (nonatomic , strong) NSMutableArray *arrayBtn;
@property (nonatomic , strong) NSArray *audioSettingInfoArray;


@end

@implementation AudioSettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //键盘处理点击空白收起键盘
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //设置navigation
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Audio Settings", nil);
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
    //查询显示数据
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.audioSettingInfoArray = [base getAudioSettingInfo];
    AudioSettingsModel *model = nil;
    if (_audioSettingInfoArray.count != 0) {
        model = _audioSettingInfoArray[0];
    }else{
        return;
    }
    
    UIView *viewFirst = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 173)];
    //    viewFirst.backgroundColor = [UIColor redColor];
    [self createView:viewFirst topTitle:@"Echo CanCellation" firstLabelText:@"Echo Canceller" secondLabelText:@"CNG" thirdLableText:@"VAD"];
    //******************2
    self.secondView = [[UIView alloc]initWithFrame:CGRectMake(15, 200, self.view.bounds.size.width - 30, 173)];
    //viewFirst.backgroundColor = [UIColor redColor];
    [self createView:_secondView topTitle:@"Auto Gain Control" firstLabelText:@"AGC(Sending-side)" secondLabelText:@"AGC(Receving-side)" thirdLableText:@"AGC Target(1-20dB)"];

    self.echoCancellerBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, marginHeight+23, 30, 30)];
    self.cngBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 2*marginHeight+23+labelHeight, 30, 30)];
    self.vadBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 3*marginHeight+23+2*labelHeight, 30, 30)];
    
    self.sendingBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, marginHeight+23, 30, 30)];
    self.recevingBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width -60, 2*marginHeight+23+labelHeight, 30, 30)];
    self.field = [[UITextField alloc]initWithFrame:CGRectMake(_secondView.bounds.size.width-50, 3*marginHeight+23+2*labelHeight, 50, 30)];
    _field.text = [NSString stringWithFormat:@"%d",model.aGC_target];
    _field.layer.cornerRadius=3.0f;
    _field.layer.masksToBounds=YES;
    _field.layer.borderColor=[[UIColor orangeColor]CGColor];
    _field.layer.borderWidth= 1.0f;
    _field.keyboardType = UIKeyboardTypeNumberPad;
    _field.delegate = self;
    if (model.cNG == 1) {
        [_cngBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_cngBtn setSelected:YES];
    }else{
        [_cngBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_cngBtn setSelected:NO];
    }
    if (model.vAD == 1) {
        [_vadBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_vadBtn setSelected:YES];
    }else{
        [_vadBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_vadBtn setSelected:NO];
    }
    if (model.aGC_sending == 1) {
        [_sendingBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_sendingBtn setSelected:YES];
    }else{
        [_sendingBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_sendingBtn setSelected:NO];
    }
    if (model.aGC_receving == 1) {
        [_recevingBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_recevingBtn setSelected:YES];
    }else{
        [_recevingBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_recevingBtn setSelected:NO];
    }if (model.echoCanceller) {
        [_echoCancellerBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_echoCancellerBtn setSelected:YES];
    }else{
        [_echoCancellerBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_echoCancellerBtn setSelected:NO];
    }
    [_echoCancellerBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_cngBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_vadBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_sendingBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_recevingBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewFirst addSubview:_echoCancellerBtn];
    [viewFirst addSubview:_cngBtn];
    [viewFirst addSubview:_vadBtn];
    
    [_secondView addSubview:_sendingBtn];
    [_secondView addSubview:_recevingBtn];
    [_secondView addSubview:_field];
    
    [self.view addSubview:viewFirst];
    [self.view addSubview:_secondView];
    
    UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake(10, 400, self.view.bounds.size.width - 2*marginHeight, 40)];
    btnSave.backgroundColor = UnifiedColor;
    [btnSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveTosqlite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];
    
}


- (void)createView:(UIView *)view topTitle:(NSString *)title firstLabelText:(NSString *)firstText secondLabelText:(NSString *)secondText thirdLableText:(NSString *)thirdText
{
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(title, nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *firstViewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    firstViewLine.backgroundColor = UnifiedColor;
    UILabel *firstlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight+TopLabel.bounds.size.height+3, view.bounds.size.width * 6/7, labelHeight)];
    //firstlabel.backgroundColor = [UIColor purpleColor];
    firstlabel.text = NSLocalizedString(firstText, nil);
    UILabel *secondlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*marginHeight+TopLabel.bounds.size.height+3+labelHeight, view.bounds.size.width * 6/7, labelHeight)];
    //secondlabel.backgroundColor = [UIColor blueColor];
    secondlabel.text = NSLocalizedString(secondText, nil);
    UILabel *thirdlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3*marginHeight+TopLabel.bounds.size.height+6+2*labelHeight, view.bounds.size.width * 6/7, labelHeight)];
    //secondlabel.backgroundColor = [UIColor blueColor];
    thirdlabel.text = NSLocalizedString(thirdText, nil);
    [view addSubview:blueDot];
    [view addSubview:firstlabel];
    [view addSubview:TopLabel];
    [view addSubview:firstViewLine];
    [view addSubview:secondlabel];
    [view addSubview:thirdlabel];
    
}

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

- (void)saveTosqlite
{
    int agc_target = [_field.text intValue];
    int echo_Canceller = 0, cng = 0,vad = 0,sending= 0 ,receving = 0;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    echo_Canceller = _echoCancellerBtn.selected?1:0;
    cng = _cngBtn.selected?1:0;
    vad = _vadBtn.selected?1:0;
    sending = _sendingBtn.selected?1:0;
    receving = _recevingBtn.selected?1:0;
    if (agc_target > 20 || agc_target <= 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"AGC Target must between 1 and 20!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        return;
    }
    if ([base updateAudioEchoCanceller:echo_Canceller cng:cng vad:vad agc_sending:sending agc_receving:receving agc_target:agc_target]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save audio setting success!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save audio setting failed!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate 只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
