//
//  IncomingViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/26.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "IncomingViewController.h"
#import "VBellsqlBase.h"
#import "userModel.h"
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"

@interface IncomingViewController (){
    int callType;
}
@property (nonatomic, strong) UILabel *callStatusLabel;
@property (nonatomic, strong) UIButton *hangupBtn;
@property (nonatomic, strong) UIButton *answerBtn;
@property (nonatomic, strong) UILabel *answerLabel;
@property (nonatomic, strong) UIView *hideView;
@property (nonatomic)BOOL isHide;
@property (nonatomic, strong) userModel *model;
@property (nonatomic, strong) NSString *time;
@end

@implementation IncomingViewController


- (void)viewWillAppear:(BOOL)animated
{
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *incomingArray = [base getUserInfoNameWithNumber:_number];
    userModel *model = nil;
    if (incomingArray.count != 0) {
        model = incomingArray[0];
    }else{
        //return;
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    //    self.view.backgroundColor = [UIColor redColor];
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
    nameLabel.text = model==nil?_number:model.userName;
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width *1/3, self.view.bounds.size.height*1/3 + 127+40+10, self.view.bounds.size.width / 3, 40)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.text = _number;
    _hideView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height*4/5, self.view.bounds.size.width, self.view.bounds.size.height*1/5)];
    _hideView.backgroundColor = [UIColor grayColor];
    
    UIButton *muteBtn = [[UIButton alloc]initWithFrame:CGRectMake(35, 10, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    muteBtn.layer.cornerRadius = muteBtn.bounds.size.height/2;
    muteBtn.layer.masksToBounds = YES;
    [muteBtn setImage:[UIImage imageNamed:@"Answer.png"] forState:UIControlStateNormal];
    [muteBtn addTarget:self action:@selector(acceptCaling) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *muteLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, muteBtn.bounds.size.height+10 , 75, 30)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    muteLabel.textAlignment = NSTextAlignmentCenter;
    muteLabel.text = NSLocalizedString(@"Accept", nil);
    muteLabel.font = [UIFont systemFontOfSize:13];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-110, 10, 75, 75)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    closeBtn.layer.cornerRadius = closeBtn.bounds.size.height/2;
    closeBtn.layer.masksToBounds = YES;
    [closeBtn setImage:[UIImage imageNamed:@"Hangup.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeCalling) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *hangupLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-110, closeBtn.bounds.size.height+10 , 75, 30)];
    //numberLabel.backgroundColor = [UIColor grayColor];
    hangupLabel.textAlignment = NSTextAlignmentCenter;
    hangupLabel.text = NSLocalizedString(@"Hangup", nil);
    hangupLabel.font = [UIFont systemFontOfSize:13];
    
    
    
    [self.view addSubview:_hideView];
    [_hideView addSubview:muteBtn];
    [_hideView addSubview:muteLabel];
    [_hideView addSubview:closeBtn];
    [_hideView addSubview:hangupLabel];
    //    [self.view addSubview:label];
    [self.view addSubview:btnMainImageBtn];
    [self.view addSubview:nameLabel];
    [self.view addSubview:numberLabel];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hideView setHidden:YES];
        _isHide = YES;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    callType = 1;
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _time = [foromatter stringFromDate:[NSDate date]];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *incomingArray = [base getUserInfoNameWithNumber:_number];
    userModel *model = nil;
    if (incomingArray.count != 0) {
        model = incomingArray[0];
        //来电的时候区分来电时候是视频还是语音，先将数据插入为未接，如果接通后再根据时间来修改是否接通
        [base insertCallingHistoryTabNumber:_number name:model.userName Calltime:_time callType:1 callDictionary:0];
    }else{
        [base insertCallingHistoryTabNumber:_number name:_number Calltime:_time callType:1 callDictionary:0];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeCalling) name:@"FINISHCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioCalling) name:@"AUDIOCALL" object:nil];
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

- (void)audioCalling
{
    callType = 0;
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
    [base updateCallHistorycallDictionary:2 andCallType:callType callTime:_time];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hideView setHidden:YES];
        _isHide = YES;
    });
}

- (void)closeCalling
{
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
}

- (void)acceptCaling
{
    int cid = _g_callid;
    int aid = _g_accountid;
    sipcall_send_msg(SIPCALL_SEND_MSG_ANSWER, cid, aid, NULL, 0);
    NSLog(@"I accept Calling");
    
    //当前呼叫时间
   
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *incomingArray = [base getUserInfoNameWithNumber:_number];
    userModel *model = nil;
    if (incomingArray.count != 0) {
        model = incomingArray[0];
    }else{
        return;
    }
    //来电的时候区分来电时候是视频还是语音，暂时写死 1
//    [base insertCallingHistoryTabNumber:_number name:model.userName Calltime:time callType:1 callDictionary:2];
    [base updateCallHistorycallDictionary:2 andCallType:callType callTime:_time];
//    [_answerBtn setImage:[UIImage imageNamed:@"icon_bizcard_box_item_block_nor"] forState:UIControlStateNormal];
//    _answerLabel.text = @"UnLock";
    NSLog(@"I accept Calling end");
}

@end
