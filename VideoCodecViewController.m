//
//  VideoCodecViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/11.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "VideoCodecViewController.h"
#import "VBellsqlBase.h"
#import "VideoCodecModel.h"
#import "MBProgressHUD.h"
#import "AudioAndVideoCodecCell.h"
#define contentWidth (self.view.bounds.size.width - 30)
#define labelHeight 40
#define marginHeight 10
#define showFrameViewHeight 40
#define showFrameViewLine 1

@interface VideoCodecViewController ()
@property (nonatomic, strong) UIButton *enableBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *solutionBtn;
@property (nonatomic, strong) UIButton *bitrateBtn;
@property (nonatomic, strong) UIButton *payLoadBtn;
@property (nonatomic, strong) UIView *solutionFrameView;
@property (nonatomic, strong) UIView *bitrateFrameView;
@property (nonatomic, strong) NSArray *solutionArray;
@property (nonatomic, strong) NSArray *bitrateArray;
@property (nonatomic, strong) NSArray *payloadArray;
@property (nonatomic, strong) NSArray *videoCodecInfoArray;

@property (nonatomic, strong) UIView *videoCodecBackgroundView;
@property (nonatomic, strong) UIScrollView *videoCodecScrollView;
@property (nonatomic, strong) UIView *videoCodecViewContainer;
@property (nonatomic, strong) UIScrollView *payLoadScrollView;


@end
VBellsqlBase *base = nil;
VideoCodecModel *model = nil;

@implementation VideoCodecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Video Codec", nil);
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
    base = [VBellsqlBase shareMyDdataBase];
    self.videoCodecInfoArray = [base getVideoCodecInfo];
    if (_videoCodecInfoArray.count != 0) {
        model = _videoCodecInfoArray[0];
    }else{
        return;
    }
    //布局
    [self setContents];
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 125, self.view.bounds.size.width - 30, 40)];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveBtn.backgroundColor = UnifiedColor;
    [saveBtn addTarget:self action:@selector(saveTosqlite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
}

- (void)setContents
{
    //CGFloat contentWidth = self.view.bounds.size.width - 30;
    if (_videoCodecInfoArray.count != 0) {
        model = _videoCodecInfoArray[0];
    }else{
        return;
    }
    UILabel *enableLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, contentWidth/5, 30)];
    UILabel *nameLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(contentWidth*1/5+15, 15, contentWidth/5, 30)];
    UILabel *solutionLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentWidth*2/5+11, 15, contentWidth/5, 30)];
    UILabel *bitrateLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentWidth*3/5+15, 15, contentWidth/5, 30)];
    UILabel *payloadLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentWidth*4/5+15, 15, contentWidth/5, 30)];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 45, contentWidth, 1)];
    [lineView setBackgroundColor:UnifiedColor];
    enableLabel.text = NSLocalizedString(@"Enable", nil);
    nameLabelTitle.text = NSLocalizedString(@"Name", nil);
    solutionLabel.text = NSLocalizedString(@"Solution", nil);
    bitrateLabel.text = NSLocalizedString(@"Bitrate", nil);
    payloadLabel.text = NSLocalizedString(@"Payload", nil);
    [enableLabel setTextColor:UnifiedColor];
    [nameLabelTitle setTextColor:UnifiedColor];
    [solutionLabel setTextColor:UnifiedColor];
    [bitrateLabel setTextColor:UnifiedColor];
    [payloadLabel setTextColor:UnifiedColor];
    
    [enableLabel setFont:[UIFont systemFontOfSize:15]];
    [nameLabelTitle setFont:[UIFont systemFontOfSize:15]];
    [solutionLabel setFont:[UIFont systemFontOfSize:15]];
    [bitrateLabel setFont:[UIFont systemFontOfSize:15]];
    [payloadLabel setFont:[UIFont systemFontOfSize:15]];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(15, 55, contentWidth, 55)];
    //contentView.backgroundColor = [UIColor orangeColor];
    self.enableBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 12, 30, 30)];
    if (model.enable == 1) {
        [_enableBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_enableBtn setSelected:YES];
    }else{
        [_enableBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_enableBtn setSelected:NO];
    }
    [_enableBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentWidth*1/6 +10, 0, contentWidth / 6, 55)];
//    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    _nameLabel.text = model.name;
    
    self.solutionBtn = [[UIButton alloc]initWithFrame:CGRectMake(contentWidth*2/6+20, 0, contentWidth / 6, 55)];
    [_solutionBtn setTitle:model.solution forState:UIControlStateNormal];
    //_solutionBtn.backgroundColor = [UIColor redColor];
//    _solutionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_solutionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_solutionBtn addTarget:self action:@selector(chooseSolution:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bitrateBtn = [[UIButton alloc]initWithFrame:CGRectMake(contentWidth*3/6+25, 0, contentWidth / 6, 55)];
    [_bitrateBtn setTitle:model.bitrate forState:UIControlStateNormal];
//    _bitrateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_bitrateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_bitrateBtn addTarget:self action:@selector(chooseBirtrate:) forControlEvents:UIControlEventTouchUpInside];
    
    self.payLoadBtn = [[UIButton alloc]initWithFrame:CGRectMake(contentWidth*4/6+35, 0, contentWidth / 6, 55)];
    [_payLoadBtn setTitle:[NSString stringWithFormat:@"%d",model.payload] forState:UIControlStateNormal];
//    _payLoadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_payLoadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_payLoadBtn addTarget:self action:@selector(choosePayLoad:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *defaultBtn = [[UIButton alloc]initWithFrame:CGRectMake(contentWidth*5/6+15, 0, contentWidth / 6, 55)];
//    [defaultBtn setImage:[UIImage imageNamed:@"timeline_icon_comment"] forState:UIControlStateNormal];
    
    [contentView addSubview:_enableBtn];
    [contentView addSubview:_nameLabel];
    [contentView addSubview:_solutionBtn];
    [contentView addSubview:_bitrateBtn];
    [contentView addSubview:_payLoadBtn];
//    [contentView addSubview:defaultBtn];
    [self.view addSubview:contentView];
    [self.view addSubview:enableLabel];
    [self.view addSubview:nameLabelTitle];
    [self.view addSubview:solutionLabel];
    [self.view addSubview:bitrateLabel];
    [self.view addSubview:payloadLabel];
    [self.view addSubview:lineView];
}

- (void)chooseSolution:(UIButton *)btn
{
    _videoCodecBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _videoCodecBackgroundView.alpha = 0.7;
    _videoCodecBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecBackgroundView];
    
    _videoCodecScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    recognizer.numberOfTouchesRequired = 1;
    [_videoCodecScrollView addGestureRecognizer:recognizer];
    
    _videoCodecViewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height /2-self.view.bounds.size.height *1/5, self.view.bounds.size.width - 30, 204)];
    _videoCodecViewContainer.backgroundColor = [UIColor whiteColor];
    _videoCodecViewContainer.layer.cornerRadius = 1.0f;
    
    CGFloat videoCodecViewContainerwidth = _videoCodecViewContainer.bounds.size.width;
    [_videoCodecScrollView addSubview:_videoCodecViewContainer];
    
    self.solutionArray = [NSArray arrayWithObjects:@"QCIF",@"CIF",@"VGA",@"4CIF",@"720P", nil];
    for (int i = 0; i < _solutionArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoCodecViewContainerwidth, showFrameViewHeight)];
        [btn setTitle:_solutionArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(solutionClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoCodecViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_videoCodecViewContainer addSubview:btn];
        [_videoCodecViewContainer addSubview:lineView];
    }
}

- (void)chooseBirtrate:(UIButton *)btn
{
    
    _videoCodecBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _videoCodecBackgroundView.alpha = 0.7;
    _videoCodecBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecBackgroundView];
    
    _videoCodecScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    recognizer.numberOfTouchesRequired = 1;
    [_videoCodecScrollView addGestureRecognizer:recognizer];
    
    _videoCodecViewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height /2-self.view.bounds.size.height *1/5, self.view.bounds.size.width - 30, 204)];
    _videoCodecViewContainer.backgroundColor = [UIColor whiteColor];
    _videoCodecViewContainer.layer.cornerRadius = 1.0f;
    
    CGFloat videoCodecViewContainerwidth = _videoCodecViewContainer.bounds.size.width;
    [_videoCodecScrollView addSubview:_videoCodecViewContainer];
    
    self.bitrateArray = [NSArray arrayWithObjects:@"512",@"768",@"1024",@"1536",@"2048", nil];
    for (int i = 0; i < _bitrateArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoCodecViewContainerwidth, showFrameViewHeight)];
        [btn setTitle:_bitrateArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(bitrateClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoCodecViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_videoCodecViewContainer addSubview:btn];
        [_videoCodecViewContainer addSubview:lineView];
    }
}

- (void)choosePayLoad:(UIButton *)btn
{
    
    _videoCodecBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _videoCodecBackgroundView.alpha = 0.7;
    _videoCodecBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecBackgroundView];
    
    _videoCodecScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height)];
    _videoCodecScrollView.contentSize = CGSizeMake(self.view.bounds.size.width - 100, 1229);
    _videoCodecScrollView.bounces = NO;
    _videoCodecScrollView.showsVerticalScrollIndicator = FALSE;
    [[UIApplication sharedApplication].keyWindow addSubview:_videoCodecScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    recognizer.numberOfTouchesRequired = 1;
    [_videoCodecScrollView addGestureRecognizer:recognizer];
    
    _payLoadScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(50, 0, self.view.bounds.size.width - 100, 1229)];
    _payLoadScrollView.backgroundColor = [UIColor whiteColor];
    _payLoadScrollView.showsVerticalScrollIndicator = FALSE;
    
    CGFloat videoCodecViewContainerwidth = _payLoadScrollView.bounds.size.width;
    [_videoCodecScrollView addSubview:_payLoadScrollView];
    
    self.payloadArray = [NSArray arrayWithObjects:@"90",@"91",@"92",@"93",@"94",@"95",@"96",@"97",@"98",@"99",@"100",@"101",@"102",@"103",@"104",@"105",@"106",@"107",@"108",@"109",@"110",@"111",@"112",@"113",@"114",@"115",@"116",@"117",@"118",@"119", nil];
    for (int i = 0; i < _payloadArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoCodecViewContainerwidth, showFrameViewHeight)];
        [btn setTitle:_payloadArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(payLoadClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoCodecViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_payLoadScrollView addSubview:btn];
        [_payLoadScrollView addSubview:lineView];
    }
}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    [_videoCodecBackgroundView removeFromSuperview];
    [_videoCodecScrollView removeFromSuperview];
    [_payLoadScrollView removeFromSuperview];
}

#pragma mark 下拉选中方法
- (void)solutionClick:(UIButton *)btn
{
    NSString *changeTitle = [_solutionArray objectAtIndex:btn.tag];
    [_solutionBtn setTitle:changeTitle forState:UIControlStateNormal];
    [_videoCodecBackgroundView removeFromSuperview];
    [_videoCodecScrollView removeFromSuperview];
}

- (void)bitrateClick:(UIButton *)btn
{
    NSString *changeTitle = [_bitrateArray objectAtIndex:btn.tag];
    [_bitrateBtn setTitle:changeTitle forState:UIControlStateNormal];
    [_videoCodecBackgroundView removeFromSuperview];
    [_videoCodecScrollView removeFromSuperview];
}

- (void)payLoadClick:(UIButton *)btn
{
    NSString *changeTitle = [_payloadArray objectAtIndex:btn.tag];
    [_payLoadBtn setTitle:changeTitle forState:UIControlStateNormal];
    [_videoCodecBackgroundView removeFromSuperview];
    [_videoCodecScrollView removeFromSuperview];
    [_payLoadScrollView removeFromSuperview];
}


#pragma mark enable按钮
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

#pragma mark saveTosqlite保存
- (void)saveTosqlite
{
    int enable = _enableBtn.selected?1:0;
    NSString *name,*solution,*bitrate;
    int payload = 0;
    name = _nameLabel.text;
    solution = _solutionBtn.titleLabel.text;
    bitrate = _bitrateBtn.titleLabel.text;
    payload = [_payLoadBtn.titleLabel.text intValue];
    if ([base updateVideoCodecEable:enable andname:name andsolution:solution andbitrate:bitrate andpayload:payload]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save codec setting success!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGEVIDEOCODEC" object:nil];
        [[self navigationController] popViewControllerAnimated:YES];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save codec setting failed!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
    }

}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
