//
//  CallingShowViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/15.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "CallingShowViewController.h"
#import "VBellsqlBase.h"
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"

@interface CallingShowViewController ()
@property (nonatomic, strong) UILabel *callStatusLabel;
@property (nonatomic, strong) UIView *hideView;
@property (nonatomic)BOOL isHide;
@end

@implementation CallingShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    _callStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*1/3, 20, self.view.bounds.size.width / 3, 40)];
    _callStatusLabel.textAlignment = NSTextAlignmentCenter;
    //label.backgroundColor = [UIColor orangeColor];
    _callStatusLabel.text = NSLocalizedString(@"RingBack", nil);
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *btnMainImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 50, self.view.bounds.size.height*1/3, 107, 107)];
    [btnMainImageBtn setImage:[UIImage imageNamed:@"My Device.png"] forState:UIControlStateNormal];
    btnMainImageBtn.layer.cornerRadius = btnMainImageBtn.bounds.size.height/2;
    btnMainImageBtn.layer.masksToBounds = YES;
//    btnMainImageBtn.backgroundColor = [UIColor redColor];

    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/3, self.view.bounds.size.height*1/3 + 127, self.view.bounds.size.width / 3, 40)];
    //nameLabel.backgroundColor = [UIColor orangeColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = _name;
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/3, self.view.bounds.size.height*1/3 + 127+40+10, self.view.bounds.size.width / 3, 40)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.text = _number;
    
    _hideView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height*4/5, self.view.bounds.size.width, self.view.bounds.size.height*1/5)];
    _hideView.backgroundColor = [UIColor grayColor];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/2-35, 10, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    closeBtn.layer.cornerRadius = closeBtn.bounds.size.height/2;
    closeBtn.layer.masksToBounds = YES;
    [closeBtn setImage:[UIImage imageNamed:@"Hangup.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *hangupLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/2-35, closeBtn.bounds.size.height+10 , 75, 30)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    hangupLabel.textAlignment = NSTextAlignmentCenter;
    hangupLabel.text = NSLocalizedString(@"Hangup", nil);
    hangupLabel.font = [UIFont systemFontOfSize:13];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hideView setHidden:YES];
        _isHide = YES;
    });
    
    
    [self.view addSubview:_callStatusLabel];
    [self.view addSubview:btnMainImageBtn];
    [self.view addSubview:nameLabel];
    [self.view addSubview:numberLabel];
    [self.view addSubview:_hideView];
    [_hideView addSubview:closeBtn];
    [_hideView addSubview:hangupLabel];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeCalling) name:@"FINISHCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioCalling) name:@"AUDIOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isVideoCall) name:@"VIDEOCALL" object:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isHide) {
        [_hideView setHidden:NO];
        _isHide = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_hideView setHidden:YES];
            _isHide = YES;
        });
    }else{
        [_hideView setHidden:YES];
        _isHide = YES;
    }
}

- (void)isVideoCall
{
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    
    [base insertCallingHistoryTabNumber:_number name:_name Calltime:time callType:1 callDictionary:1];
}


- (void)audioCalling
{
    NSLog(@"talking.....");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hideView removeFromSuperview];
        _hideView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height*4/5, self.view.bounds.size.width, self.view.bounds.size.height*1/5)];
        _hideView.backgroundColor = [UIColor grayColor];
        _callStatusLabel.text = NSLocalizedString(@"Talking...", nil);
        UIButton *muteBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/2-20-75, 10, 75, 75)];
        //numberLabel.backgroundColor = [UIColor grayColor];
        muteBtn.layer.cornerRadius = muteBtn.bounds.size.height/2;
        muteBtn.layer.masksToBounds = YES;
        [muteBtn setImage:[UIImage imageNamed:@"Mute.png"] forState:UIControlStateNormal];
        [muteBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *muteLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/2-20-75, muteBtn.bounds.size.height+10 , 75, 30)];
        //numberLabel.backgroundColor = [UIColor grayColor];
        muteLabel.textAlignment = NSTextAlignmentCenter;
        muteLabel.text = NSLocalizedString(@"Mute", nil);
        muteLabel.font = [UIFont systemFontOfSize:13];
        
        UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*1/2+20, 10, 75, 75)];
        //numberLabel.backgroundColor = [UIColor grayColor];
        closeBtn.layer.cornerRadius = closeBtn.bounds.size.height/2;
        closeBtn.layer.masksToBounds = YES;
        [closeBtn setImage:[UIImage imageNamed:@"Hangup.png"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *hangupLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/2+20, closeBtn.bounds.size.height+10 , 75, 30)];
        //numberLabel.backgroundColor = [UIColor grayColor];
        hangupLabel.textAlignment = NSTextAlignmentCenter;
        hangupLabel.text = NSLocalizedString(@"Hangup", nil);
        hangupLabel.font = [UIFont systemFontOfSize:13];
        
        [self.view addSubview:_hideView];
        [_hideView addSubview:muteBtn];
        [_hideView addSubview:muteLabel];
        [_hideView addSubview:closeBtn];
        [_hideView addSubview:hangupLabel];
    });
    
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    
    [base insertCallingHistoryTabNumber:_number name:_name Calltime:time callType:0 callDictionary:1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hideView setHidden:YES];
        _isHide = YES;
    });
}

- (void)closeCalling
{
    NSLog(@"this is code time");
    int cid = _g_callid;
    int aid = _g_accountid;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sipcall_send_msg(SIPCALL_SEND_MSG_HANGUP, cid, aid, NULL, 0);
        if(cid > 0)
        {
            mediaengine_StopVoiceTalking(cid);
            mediaengine_StopVideoTalking(cid);
            _g_callid = 0;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
    NSLog(@"this is code time");
}

@end
